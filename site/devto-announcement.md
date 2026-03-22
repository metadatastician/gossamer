---
title: "Gossamer: I built a webview shell where resource leaks are compile errors"
published: false
description: "A desktop app framework with linear types — no GC, no refcounting, provable resource safety"
tags: programming, webdev, rust, opensource
cover_image:
---

# Gossamer: A Linearly-Typed Webview Shell

I've been working on a desktop application framework that does something no other webview shell does: it **proves at compile time** that your app can't leak resources, use freed handles, or bypass permissions.

## The problem with every existing framework

Every webview shell — Electron, Tauri, Wails, Neutralinojs — manages resources the same way:

- **Electron**: Garbage collection (V8 + Node GC)
- **Tauri**: Reference counting (`Arc<Mutex<...>>`)
- **Wails**: Go's garbage collector
- **Everyone**: Runtime-checked JSON for IPC

These work, but they can't **prove** correctness. A Tauri app with a missing `drop` call leaks memory silently. An Electron app with a GC pause stutters. A JSON IPC mismatch crashes at runtime, not at compile time.

## What if the compiler guaranteed it?

Gossamer is built in [Ephapax](https://github.com/hyperpolymath/ephapax), a language with two binding modes:

- `let x = ...` — **affine**: use at most once, implicit drop OK
- `let! x = ...` — **linear**: use exactly once, compiler error if unused

This means:

```
fn main(): I64 =
  let! handle = __ffi("gossamer_create", "Hello", 800, 600, 1, 1, 0) in
  let! _ = __ffi("gossamer_load_html", handle, "<h1>Hello!</h1>") in
  __ffi("gossamer_run", handle)
```

- Remove `gossamer_run(handle)` → **compile error** (linear variable not consumed)
- Use `handle` after `gossamer_run` → **compile error** (already consumed)
- Forget to close an IPC channel → **compile error**

These aren't runtime panics. The program **won't compile**.

## Region-linear fusion: no GC, ever

Gossamer uses region-based memory management. Every allocation belongs to a region (an arena). When the region exits, all memory is freed in bulk.

The key insight: **linear types prevent values from escaping their region**. A value allocated in region `r` can't appear in the return type of that region block. The type checker recursively checks all type constructors. This is one rule, and it works identically for both affine and linear bindings.

Result: no garbage collector, no reference counting, no tracing, no runtime overhead. Memory management is entirely determined at compile time.

## The stack

```
Ephapax (.eph) — your app, linear types
    ↓ __ffi()
Zig (.zig) — platform webview (GTK/WebKit)
    ↓ C ABI
Idris2 (.idr) — formal proofs (erased at runtime)
```

At runtime: just Zig + GTK. ~1-3MB binary. No VM, no GC runtime.

## It works today

I've verified end-to-end on Fedora Linux:

- `gossamer_create("Title", 800, 600, ...)` → real GTK window
- `gossamer_load_html(handle, "<h1>Hello</h1>")` → WebKitGTK renders it
- `gossamer_run(handle)` → blocks on event loop, window visible
- Close window → handle consumed, process exits cleanly

I even wrapped an existing application (a game level editor) with Gossamer, replacing its Tauri 2.0 backend. The ReScript frontend didn't change at all — same HTML/CSS/JS, different native shell.

## Comparison

| | Electron | Tauri | **Gossamer** |
|---|---|---|---|
| Resource safety | GC | Runtime (Arc) | **Compile-time** |
| IPC types | None | Codegen | **Compile-time** |
| GC needed? | Yes | No* | **Never** |
| Binary size | 150-300MB | 3-8MB | **1-3MB** |
| Permissions | Opt-in | Runtime JSON | **Linear tokens** |

*Tauri uses `Arc<Mutex<...>>`, which is reference counting.

## Current status

- **Phase 1 (v0.1.0)**: Linux — WebKitGTK. Working, released.
- **Phase 2**: macOS (WKWebView) + Windows (WebView2). Stubs written.
- **Phase 3**: Mobile (iOS/Android).

## Links

- **GitHub**: [hyperpolymath/gossamer](https://github.com/hyperpolymath/gossamer)
- **Paper**: [Gossamer: A Linearly-Typed Webview Shell with Provable Resource Safety](https://github.com/hyperpolymath/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex) (arXiv submission pending)
- **Language**: [Ephapax](https://github.com/hyperpolymath/ephapax) — the dyadic linear/affine language
- **Release**: [v0.1.0](https://github.com/hyperpolymath/gossamer/releases/tag/v0.1.0)

---

*Gossamer is PMPL-1.0 licensed. Built by [hyperpolymath](https://github.com/hyperpolymath).*
