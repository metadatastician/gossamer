# Add Gossamer - Resource-Safe Webview Framework

**Description**

Gossamer is a webview framework for building desktop applications that **proves at compile time** that your app handles resources correctly. Unlike Electron, Tauri, Wails, or Neutralinojs — which rely on garbage collection, reference counting, or runtime checks — Gossamer uses linear types to enforce resource safety as a compile-time guarantee.

**Homepage**: https://github.com/metadatastician/gossamer

**Repository**: https://github.com/metadatastician/gossamer

**License**: MPL-2.0

**Language**: Ephapax (application), Zig (FFI), Idris2 (proofs)

**Features**:
- **Compile-time resource safety**: Handle leaks, use-after-free, and permission bypasses are compile errors
- **No garbage collector**: Region-based memory with linear types (deterministic, zero-overhead cleanup)
- **Type-safe IPC**: Frontend and backend agree on message shapes at compile time
- **Capability system**: Permission enforcement by the compiler, not by JSON config
- **Cross-platform**: Linux (WebKitGTK), macOS (WKWebView), Windows (WebView2)
- **Mobile support**: Android (JNI), iOS (WKWebView)
- **Tiny binaries**: ~1-3MB (vs ~150MB for Electron)
- **Formally verified**: 16 ABI proof modules in Idris2, zero axioms, zero `believe_me`

**Comparison**:

| Feature | Electron | Tauri | Wails | Gossamer |
|---------|----------|-------|-------|----------|
| Handle leaks | Yes | Yes | Yes | **No (compile error)** |
| IPC type-safe | No | Partial | No | **Yes (compile-time)** |
| Permission enforcement | Runtime config | Runtime config | None | **Compiler-enforced** |
| Garbage collector | V8 + Node GC | RC (Arc\<Mutex\<…\>>) | Go GC | **None, ever** |
| Binary size | ~150MB | ~3MB | ~5MB | **~1MB** |

**Category**: Frameworks / Webview Shells

**Entry to add**:

```markdown
- [gossamer](https://github.com/metadatastician/gossamer) - A linearly-typed webview shell where resource leaks are compile errors. No GC, type-safe IPC, compiler-enforced permissions.
```

---

Gossamer is particularly suitable for applications where correctness is critical, such as:
- Security-sensitive applications
- Long-running desktop utilities
- Applications where resource leaks would be catastrophic
- Projects that need formal verification

The framework is built on three pillars:
1. **Ephapax** language with linear types (application logic)
2. **Zig** for platform-native FFI (Linux WebKitGTK, macOS WKWebView, Windows WebView2)
3. **Idris2** for formal ABI proofs (16 modules, zero axioms)
