# Gossamer Plugin System — Next-Session Handover

**Prepared:** 2026-04-12  
**For:** Next Claude session  
**Status:** Ready to start — all maintenance backlog closed, this is the single remaining COULD  
**Priority:** CRG B gate (production readiness)

---

## Context

Gossamer is a linearly-typed webview shell. All maintenance work is now complete:
- Async IPC bugs fixed (thread detach, null-return UB, ABI gap)
- Streaming/binary IPC implemented (`gossamer_emit_binary`, `__gossamer_emit_binary` JS bridge)
- Full Foreign.idr ABI declared (28 symbols added 2026-04-12)
- Hot reload, SSG, multi-window — all confirmed done

The one remaining perfective item is the **plugin system**: dynamic loading of `.so`/`.dylib`/`.dll`
files at runtime to extend Gossamer without recompiling or re-linking `libgossamer`.

---

## What the Plugin System Must Do

A plugin is a shared library that can be loaded/unloaded at runtime. It must be able to:

1. **Register IPC handlers** — same API as `gossamer_channel_bind`/`gossamer_channel_bind_async`
   but called from inside the loaded `.so`
2. **Emit events** — call `gossamer_emit` / `gossamer_emit_binary` on handles it receives
3. **Request capabilities** — `gossamer_cap_grant` / `gossamer_cap_check`
4. **Declare a stable ABI entry point** — one `gossamer_plugin_init(handle, channel)` symbol
   that Gossamer calls after loading

Plugins must **not** be able to:
- Access internals of `GossamerHandle` (opaque u64 only)
- Call GTK/WebKit APIs directly (must go through `gossamer_eval`)
- Bypass the capability system

---

## Key Design Decisions to Make

**D1: Sandboxing model**  
Options: (a) pure API restriction (only `gossamer_*` symbols exported to plugin, no libc direct), 
(b) seccomp filter on the loaded library, (c) subprocess/socket boundary.  
Recommendation: start with (a) — use `dlopen` with `RTLD_LOCAL` so the plugin can only call
symbols we explicitly expose via a thin vtable/ABI struct. Defer seccomp to Phase 6b.

**D2: Lifecycle**  
`gossamer_plugin_load(handle_ptr, path)` → plugin_id (u32)  
`gossamer_plugin_unload(plugin_id)` → void (must drain inflight async calls first)  
`gossamer_plugin_list()` → JSON array of {id, name, version, status}

**D3: IPC routing after unload**  
If a handler registered by a plugin is called after `unload`, it must return a clean error
(not a use-after-free crash). Solution: mark handlers with a `plugin_id` and check liveness
before dispatch.

**D4: Idris2 ABI**  
Add to `src/interface/abi/Foreign.idr`:  
`prim__pluginLoad`, `prim__pluginUnload`, `prim__pluginList`

---

## Files to Touch

| File | Change |
|------|--------|
| `src/interface/ffi/src/main.zig` | Add `plugin_registry` struct, `gossamer_plugin_load/unload/list` exports |
| `src/interface/ffi/src/plugin.zig` | New file — `dlopen`/`dlsym`/`dlclose` wrapper, vtable struct |
| `src/interface/abi/Foreign.idr` | `prim__pluginLoad`, `prim__pluginUnload`, `prim__pluginList` |
| `src/interface/ffi/test/integration_test.zig` | Null-handle + invalid-path rejection tests |
| `build.zig` | `linkSystemLibrary("dl")` for Linux; `loadDll` on Windows |
| `.machine_readable/6a2/STATE.a2ml` | Update milestones, session-history |

---

## Plugin ABI Contract (proposed)

The plugin `.so` must export exactly one symbol:

```c
// gossamer_plugin_entry_t — the plugin's entry point
typedef void (*gossamer_plugin_entry_t)(
    uint64_t handle,   // webview handle (opaque)
    uint64_t channel,  // pre-opened IPC channel (opaque)
    const GossamerVtable* vtable  // restricted function table
);
```

`GossamerVtable` is a struct of function pointers covering only the safe public API:
`eval`, `emit`, `emit_binary`, `channel_bind`, `channel_bind_async`, `cap_grant`, `cap_check`,
`cap_revoke`, `last_error`. No GTK internals.

The vtable lives in `src/interface/ffi/src/plugin.zig` and is populated at load time.
The Idris2 `PluginVtable.idr` proves the vtable shape is stable across versions.

---

## Threat Model Note

The plugin system intentionally **does not** sandbox plugins cryptographically — a malicious `.so`
loaded by the process has the same privileges as the process. That is acceptable for this use case
(developer tooling, not untrusted third-party extensions). If true sandboxing is needed later,
the subprocess/socket boundary (option c above) can be added as a thin wrapper without changing
the core vtable API.

---

## State on Entry to Next Session

Read in this order:
1. `0-AI-MANIFEST.a2ml` (root)
2. `.machine_readable/6a2/STATE.a2ml`
3. This file

Then start with `src/interface/ffi/src/plugin.zig` (new file) and work outward.

---

## Checklist

- [ ] `src/interface/ffi/src/plugin.zig` — `dlopen` wrapper + `GossamerVtable` struct
- [ ] `gossamer_plugin_load` / `gossamer_plugin_unload` / `gossamer_plugin_list` in `main.zig`
- [ ] Handler liveness check (plugin_id on BindingEntry, checked before dispatch)
- [ ] `prim__pluginLoad`, `prim__pluginUnload`, `prim__pluginList` in `Foreign.idr`
- [ ] Integration tests (null path, missing symbol, double-unload)
- [ ] `build.zig` links `dl` on Linux
- [ ] `STATE.a2ml` milestone added and updated
- [ ] `HANDOVER-gossamer-plugin-system.md` deleted on completion
