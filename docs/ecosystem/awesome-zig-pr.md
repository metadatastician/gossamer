# Add Gossamer - A Linearly-Typed Webview Shell

**Description**

Gossamer is a webview shell framework (like Electron or Tauri) with a unique difference: it uses linear types to **prove at compile time** that your app can't leak resources, use freed handles, or bypass permissions.

**Homepage**: https://github.com/metadatastician/gossamer

**Repository**: https://github.com/metadatastician/gossamer

**License**: MPL-2.0

**Language**: Zig (FFI layer), Ephapax (application code)

**Features**:
- Compile-time resource safety through linear types
- No garbage collector (region-based memory management)
- Cross-platform: Linux (WebKitGTK), macOS (WKWebView), Windows (WebView2)
- Mobile: Android (JNI), iOS (WKWebView)
- Type-safe IPC with capability system
- ~1-3MB binary size (vs ~150MB for Electron)
- Formal verification in Idris2 (16 ABI proof modules, zero axioms)

**Category**: Webview / Desktop Application Framework

**Entry to add**:

```markdown
- [gossamer](https://github.com/metadatastician/gossamer) - A linearly-typed webview shell with provable resource safety. No GC, no refcounting, compile-time guarantees.
```

**Suggested category**: `Projects` → `Webview` or `Desktop Applications`

---

This framework represents a novel approach to desktop app development, combining:
1. **Zig** for the native FFI layer (fast, no GC, cross-platform)
2. **Ephapax** for application code (linear types, region-based memory)
3. **Idris2** for formal ABI proofs (compile-time verification)

The key innovation is that resource safety is enforced by the compiler, not by runtime checks or discipline. This eliminates entire classes of bugs (handle leaks, use-after-free, permission bypasses) that plague other webview frameworks.
