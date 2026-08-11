<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Gossamer — LLM Context (Developer)

## Identity

Gossamer — Linearly-typed webview shell framework. Ephapax backend,
Idris2 ABI, Zig FFI. License: MPL-2.0.
Author: Jonathan D.A. Jewell. Status: v0.2 development.

## Architecture

```
Idris2 ABI (src/interface/abi/*.idr)
  ↓ generates C headers (src/interface/generated/*.h)
Zig FFI (src/interface/ffi/src/*.zig)
  ↓ produces libgossamer.so / libgossamer.a
Ephapax Core (src/core/*.eph)
  ↓ Shell, Bridge, Capabilities modules
CLI (cli/) — links libgossamer
```

### Zig FFI Details

- Exports 19+ `gossamer_*` C functions
- Thread-local error safety (clearError on all entries)
- Capability registry: 256 slots, FIFO eviction
- Dialog allocator: c_allocator consistent
- Async IPC: worker threads, 256-slot inflight tracker
- CSP enforcement: gossamer_set_csp + CLI auto-apply

### Ephapax Type System

- **Linear mode**: WebviewHandle, Channel, Cap must be consumed exactly once
- **Affine mode**: More permissive (may drop, may not duplicate)
- Conformance suite: `conformance/valid/` (should pass) + `conformance/invalid/` (should fail)
- No GC. Regions + linear types only. No Arc/Rc equivalents.

## Critical Invariants

1. Linear resources: Borrow returns handle, consume destroys it
2. ABI-FFI alignment: Result codes in Types.idr MUST match Result enum in main.zig
3. Platform dispatch: Compile-time @import("builtin").os.tag, no runtime
4. No GC: Regions + linear types only
5. MkCap not exported: Framework-only capability creation
6. MainThreadProof: Required for WebviewHandle creation, cannot be forged
7. Dangerous patterns BANNED: believe_me, assert_total, sorry, Admitted, unsafeCoerce, Obj.magic

## Source Layout

```
src/
  interface/
    abi/                   Idris2 ABI definitions
      Types.idr            Core types, result codes
      Layout.idr           Memory layout proofs
      Foreign.idr          FFI function declarations
    ffi/                   Zig implementation
      src/main.zig         Primary implementation
      build.zig            Build configuration
      test/                Integration tests
    generated/             Auto-generated C headers
  core/
    Shell.eph              Webview shell management
    Bridge.eph             IPC bridge
    Capabilities.eph       Capability system
  platform/                Platform-specific Ephapax
cli/                       Gossamer CLI binary
examples/                  Example applications
  hello/main.eph           Hello world example
conformance/               Linear type conformance tests
  valid/*.eph              Should pass type checking
  invalid/*.eph            Should fail type checking
```

## Features (v0.2)

- Synchronous IPC: gossamer_channel_send / gossamer_channel_bind
- Async IPC: gossamer_channel_bind_async (worker threads, 256 inflight)
- CSP enforcement: gossamer_set_csp + CLI auto-apply from gossamer.conf.json
- Streaming events: gossamer_emit with JS/Rust/ReScript subscribe/unsubscribe
- Thread-local error safety: clearError on all 16+ exported entries
- Capability registry: 256 slots, FIFO eviction
- Dialog system: c_allocator consistent

## Dependencies

- **System**: GTK 3 (gtk3-devel), WebKit2GTK 4.1 (webkit2gtk4.1-devel)
- **Build**: Zig 0.14+, pkg-config
- **Type checking**: Ephapax compiler (built from ~/Documents/hyperpolymath-repos/ephapax)
- **ABI layer**: Idris2 0.7+ (optional)
- **Bindings**: Rust (gossamer-rs crate), ReScript

## Commands

```bash
# Build
just build-ffi / build-ffi-release / build-cli / build-cli-release / build
just check / check-affine / check-example <name>

# Run
just run-example <name> / hello / install

# Test
just test-ffi / test-conformance / test-integration / test

# Dev
just clean / symbols / symbol-count / deps

# Onboarding
just doctor / heal / tour / help-me / assail
```

## Build Outputs

| Artifact | Location |
|----------|----------|
| libgossamer.so | src/interface/ffi/zig-out/lib/ |
| libgossamer.a | src/interface/ffi/zig-out/lib/ |
| gossamer CLI | cli/zig-out/bin/gossamer |
| C headers | src/interface/generated/ |

## Related Projects

- **Ephapax**: The linear-typed language Gossamer uses
- **PanLL**: Panel framework (Gossamer migration from Tauri)
- **IDApTIK**: Game using Gossamer webviews
- **Burble**: Voice platform (IPC/caps patterns from Gossamer)
- **Groove**: Service discovery (Gossamer is a groove target)

## File Map

| Path | What |
|------|------|
| `0-AI-MANIFEST.a2ml` | Universal AI entry point |
| `src/interface/abi/` | Idris2 formal ABI |
| `src/interface/ffi/` | Zig C-ABI implementation |
| `src/core/` | Ephapax application modules |
| `cli/` | Gossamer CLI |
| `examples/` | Example applications |
| `conformance/` | Linear type test suite |
| `.machine_readable/` | STATE.a2ml, META.a2ml, ECOSYSTEM.a2ml |
| `contractile.just` | Contractile recipes (imported) |
