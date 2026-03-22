# Gossamer — Next Steps

<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->

## Completed (2026-03-21/22)

- [x] Gossamer repo created (RSR template, all workflows)
- [x] Zig FFI builds (libgossamer.so, 20 symbols, WebKitGTK)
- [x] Idris2 ABI (Types.idr, Foreign.idr, Layout.idr)
- [x] Ephapax compiler restored (15 crates, 172+ tests)
- [x] Region-linear fusion in type checker
- [x] `__ffi()` intrinsic (parser → type checker → interpreter → WASM)
- [x] Native FFI via dlopen (real GTK window created)
- [x] String FFI (C strings bypass region system)
- [x] Core .eph modules (Shell, Bridge, Capabilities)
- [x] Ephapax tooling (LSP, DAP, tree-sitter, VS Code, linter, formatter, spec, conformance, stdlib, asdf)
- [x] Ephapaxiser updated with region types
- [x] IDApTIK UMS Gossamer wrapper (Shell.eph, LevelEditor.eph, main.eph)
- [x] IDApTIK UMS launched in Gossamer — visible window with styled UI
- [x] macOS/Windows platform stubs
- [x] arXiv paper with formal type rules
- [x] v0.1.0 release on GitHub
- [x] Mirrored to GitLab + Bitbucket
- [x] GitHub Pages site + dev.to draft

## Next Session Priorities

### P0 — Wire IPC (make buttons work)

The IDApTIK UMS sidebar buttons are static HTML. Wire `gossamer_channel_bind`
so that JS `onclick` events call `__ffi("idaptik_ums_create_level", ...)`
through the IPC bridge. This is the "make it interactive" step.

### P1 — Ephapax SSG

Build a static site generator in Ephapax. Use it to generate the Gossamer
docs site. Dogfooding: Gossamer's website built by Gossamer's language.

### P2 — arXiv submission

Upload `docs/whitepapers/gossamer-arxiv-paper.tex` to arxiv.org.
Category: cs.PL (Programming Languages) or cs.SE (Software Engineering).
Also submit the dyadic paper from the ephapax repo.

### P3 — Phase 2 platforms

Implement macOS (WKWebView via Cocoa Objective-C runtime) and Windows
(WebView2 via COM). The Zig stubs are ready — fill in the platform calls.

### P4 — Ecosystem visibility

- Submit to awesome-zig (PR to awesome list)
- Submit to awesome-wasm
- Post dev.to announcement (draft at site/devto-announcement.md)
- Post to lobste.rs / Hacker News
- OpenSSF Scorecard badge

### P5 — IDApTIK full migration

- Wire all 12 UMS FFI functions through IPC
- Migrate UMS from Tauri to Gossamer for desktop
- Keep Tauri for mobile (until Phase 3)
- Test with real level editing workflow

### P6 — Ephapax compiler improvements

- WASM FFI imports (not just interpreter dlopen)
- Module system (import Gossamer.Shell)
- Closure conversion (currently stubbed)
- Multi-file compilation

## Architecture Reference

```
Ephapax (.eph) — app code, linear types, regions
    ↓ __ffi()
Zig (.zig) — platform webview (GTK/WebKit/WebView2)
    ↓ C ABI
Idris2 (.idr) — formal proofs (compile-time, erased)
```

Runtime: just Zig + GTK. No GC, no VM, ~1-3MB.
