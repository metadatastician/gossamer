---
title: Ephapax Primer
date: 2026-03-29
---

# Ephapax Primer for Gossamer

Gossamer applications are written in Ephapax, a language with two type modes:

- **Affine mode** (`~`): values may be used *at most once* (can be dropped)
- **Linear mode** (`!`): values must be used *exactly once* (cannot be dropped)

## Why Linear Types Matter

In a traditional framework, this code compiles but crashes at runtime:

```javascript
// Tauri/Electron — runtime error
const window = createWindow();
window.close();
window.setTitle("oops");  // Use-after-free
```

In Gossamer, the compiler catches it:

```
let win = gossamer_create("App", 800, 600);  // win : !Handle
gossamer_destroy(win);                        // win consumed
gossamer_set_title(win, "oops");              // ERROR: win already consumed
```

## Resource Types

| Type | Mode | Meaning |
|------|------|---------|
| `!Handle` | Linear | Webview handle — must be destroyed exactly once |
| `!Channel` | Linear | IPC channel — must be closed |
| `!CapToken` | Linear | Capability — consumed on use |
| `~Config` | Affine | Configuration — may be dropped |
| `String` | Unrestricted | Normal value — copy freely |

## The `__ffi()` Intrinsic

Ephapax calls Zig functions via `__ffi()`:

```
// Ephapax side
let handle = __ffi("gossamer_create", title, width, height);

// Zig side (C ABI)
export fn gossamer_create(
    title: [*:0]const u8,
    width: c_int,
    height: c_int,
) u64 { ... }
```

The Idris2 ABI layer proves that the types match:

```idris
-- Idris2 proof (erased at runtime)
createProof : ForeignSafe "gossamer_create"
                [StringArg, IntArg, IntArg] HandleResult
```

## Region Types

Ephapax has region-scoped allocation. Memory allocated in a region
is freed when the region ends — no manual malloc/free, no GC:

```
region frame {
    let buf = alloc<[u8; 1024]>(frame);
    process(buf);
}   // buf is freed here — compiler proves no escaping references
```

## Further Reading

- [Ephapax Language Reference](https://github.com/hyperpolymath/ephapax)
- [Gossamer Architecture](architecture.html)
- [arXiv Paper](https://github.com/metadatastician/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex)
