# Hacker News / Lobste.rs Post Draft: Gossamer

**Title**: Gossamer: A webview shell where resource leaks are compile errors

**Body**:

I've been working on a desktop app framework that does something I haven't seen before: it **proves at compile time** that your application handles resources correctly.

Every webview framework (Electron, Tauri, Wails, Neutralinojs) manages resources the same way:
- Electron: GC (V8 + Node)
- Tauri: Reference counting
- Wails: Go GC

These work, but they can't *prove* correctness. A missing `drop()` in Tauri leaks memory silently. A GC pause in Electron causes stuttering. A JSON IPC mismatch crashes at runtime.

Gossamer is different. It uses linear types from the [Ephapax](https://github.com/hyperpolymath/ephapax) language:

```
let! handle = __ffi("gossamer_create", "App", 800, 600, 1, 1, 0) in
let! _ = __ffi("gossamer_load_html", handle, "<h1>Hello</h1>") in
__ffi("gossamer_run", handle)
```

- Remove the `gossamer_run` line → **compile error** (handle not consumed)
- Use `handle` after `gossamer_run` → **compile error** (already consumed)
- Forget to close an IPC channel → **compile error**

No runtime panics. The program **won't compile**.

**How it works**:
- **Ephapax** app code with linear types (`let!` = use exactly once)
- **Zig** native FFI (no GC, cross-platform)
- **Idris2** formal ABI proofs (16 modules, zero axioms)

**Platforms**: Linux (WebKitGTK), macOS (WKWebView), Windows (WebView2), Android, iOS

**Binary size**: ~1-3MB (vs ~150MB for Electron)

**Repository**: https://github.com/metadatastician/gossamer

**Paper**: https://github.com/metadatastician/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex

---

The key insight is that resource safety doesn't have to be enforced at runtime. With the right type system, the compiler can catch these errors before your program ever runs.

This eliminates entire classes of bugs that have plagued desktop app development for decades.

Discussion points:
- Is compile-time resource safety valuable for your use cases?
- Would you use a framework that requires learning a new language (Ephapax) for these guarantees?
- What other resource safety issues would you want caught at compile time?
