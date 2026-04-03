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

### P0 — Wire IPC (make buttons work) [DONE 2026-03-29]

> All subsequent phases (P1–P3 platforms, integration tests, packaging) completed 2026-04-03. See CHANGELOG.md for details.

All 18 IPC commands wired through gossamer_channel_bind in main.eph:
- 6 disk/system commands (load_level, save_level, validate_level_abi,
  list_levels, export_level_config, get_system_info)
- 12 level-building commands (create_level, destroy_level, add_zone,
  add_device, add_guard, add_dog, add_drone, set_mission, set_physical,
  validate_level, serialize_level, deserialize_level)
Sidebar buttons in App.res call gossamerInvoke() for each command.
EditorLevelCmd.res provides typed ReScript wrappers for all 12.

### P1 — Ephapax SSG [PARTIAL — 2026-03-29]

AWK SSG pipeline working: 5 pages (index, architecture, getting-started,
ephapax-primer, platform-support) built from site/src/content/ via
scripts/md-to-html.awk + template-sub.awk. Site sources committed.

Remaining: rewrite SSG in Ephapax (the full dogfooding goal — Gossamer's
website built by Gossamer's language, not AWK).

### P2 — arXiv submission [BLOCKED — user login required]

Upload `docs/whitepapers/gossamer-arxiv-paper.tex` to arxiv.org.
Category: cs.PL (Programming Languages) or cs.SE (Software Engineering).
Also submit the dyadic paper from the ephapax repo.

### P3 — Phase 2 platforms [DONE 2026-03-29]

Windows WebView2: Full COM callback chain (EnvCompletedHandler +
ControllerCompletedHandler) with event-synchronised create(). IPC handler
(WebMessageHandler) receives chrome.webview.postMessage, dispatches to
bindings map, sends responses via ExecuteScript. Platform detection query
API (6 exports). Idris2 ABI declarations. Cross-compilation Justfile recipes.
macOS Cocoa already had full lifecycle — verified IPC dispatch path.
Version bumped to 0.3.0.

### P4 — Ecosystem visibility

- Submit to awesome-zig (PR to awesome list)
- Submit to awesome-wasm
- Post dev.to announcement (draft at site/devto-announcement.md)
- Post to lobste.rs / Hacker News
- OpenSSF Scorecard badge

### P5 — IDApTIK full migration [PARTIALLY DONE — staging decision required]

- [x] Wire all 12 UMS FFI functions through IPC (done in P0, 2026-03-29)
- [ ] Migrate UMS from Tauri to Gossamer for desktop (requires staging vs live decision)
- [x] Mobile platform support: iOS screen size fixed, Android JNI constructor fixed (2026-04-03)
- [ ] Test with real level editing workflow

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
