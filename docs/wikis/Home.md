<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Gossamer

**Build desktop apps that can't leak resources. By design, not by discipline.**

Gossamer wraps your web frontend in a native window — like Tauri or Electron — but the compiler proves your app handles every resource correctly. Leaked handles, dangling references, and permission bypasses become compile errors instead of production incidents.

This wiki is the *signpost* — canonical docs live in the repo at [`docs/`](https://github.com/metadatastician/gossamer/tree/main/docs). Don't edit pages directly in the wiki UI; edit [`docs/wikis/`](https://github.com/metadatastician/gossamer/tree/main/docs/wikis) in the code repo.

---

## Start here

| If you want to… | Go to |
|---|---|
| Build a desktop app with Gossamer | [docs/QUICKSTART.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/QUICKSTART.adoc) |
| Understand the architecture | [docs/README.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/README.adoc) |
| Read the grammar reference | [docs/gossamer-conf-reference.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/gossamer-conf-reference.adoc) |
| Browse all docs by topic | [docs/README.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/README.adoc) |
| See the comparison against Tauri/Electron | [README.md](https://github.com/metadatastician/gossamer/blob/main/README.md#at-a-glance) |
| See current project state | [.machine_readable/descriptiles/STATE.a2ml](https://github.com/metadatastician/gossamer/blob/main/.machine_readable/descriptiles/STATE.a2ml) |

---

## Pick your track

| You are a… | Read |
|---|---|
| **App developer** using Gossamer to build a desktop app | [User](User) |
| **Contributor** hacking on the FFI / ABI proofs / Ephapax core | [Developer](Developer) |
| **Maintainer** owning releases, governance, CI | [Maintainer](Maintainer) |
| **Curious / non-technical** reader | [Lay-Public](Lay-Public) |
| Anyone hitting an unfamiliar term | [Glossary](Glossary) |

---

## What Gossamer is

Gossamer is a **linearly-typed desktop webview framework**. Your web frontend runs inside the OS webview (WebKitGTK/WKWebView/WebView2); the backend is written in [Ephapax](https://github.com/hyperpolymath/ephapax), a language with two binding modes:

- `let x = ...` — use at most once; implicit cleanup is fine
- `let! x = ...` — use **exactly once**; compiler enforces it

Resources that matter (windows, file handles, IPC connections) use `let!`. Everything else uses `let`. You declare intent; the compiler enforces it.

### Key guarantees vs alternatives

| | Electron | Tauri | Wails | **Gossamer** |
|---|---|---|---|---|
| Handle leaks possible? | Yes | Yes | Yes | **No (compile error)** |
| IPC type-safe? | No | Partial | No | **Yes (compile-time)** |
| Permission enforcement | Opt-in | Runtime config | None | **Compiler-enforced** |
| Garbage collector | V8+Node GC | None* | Go GC | **None, ever** |

## Component map

| Layer | Technology |
|---|---|
| Frontend | Any web tech (HTML/CSS/JS or AffineScript → Wasm) |
| Backend | [Ephapax](https://github.com/hyperpolymath/ephapax) (`let!` linear types) |
| Native glue | Zig FFI (`src/interface/ffi/`) |
| ABI proofs | Idris2 (`src/interface/abi/`) |
| IPC channel | `gossamer_channel_bind_async` (256-slot inflight) |
| Permission model | Capability registry + `gossamer_grant` (compile-time enforced) |

## Project status (as of 2026-06-05)

- **Phase**: Testing / alpha (~92% MVP complete)
- **Licence**: MPL-2.0 (component — used inside IDApTIK which is AGPL-3.0-or-later)
- **CRG grade**: D, targeting C
- **What's complete**: Core FFI, capability registry, async IPC, CSP enforcement, multiple window support, Rust + AffineScript bindings, `gossamer.conf` DSL, CLI, Android Phase 1
- **What's pending**: IDApTIK desktop migration (Tauri → Gossamer), Android Phase 2, production hardening

## Relationship to other projects

- **[Ephapax](https://github.com/hyperpolymath/ephapax)** — backend language (linear+affine types, Wasm target)
- **[IDApTIK](https://github.com/hyperpolymath/idaptik)** — game that uses Gossamer as desktop shell (migration in progress)
- **[AffineScript](https://github.com/hyperpolymath/affinescript)** — web frontend language (compiles to Wasm, used in the browser side)
- **[typed-wasm](https://github.com/hyperpolymath/typed-wasm)** — shared compile target

## Governance

- **Licence**: MPL-2.0 (file-level copyleft, friendly to commercial integration)
- **Machine-readable state**: [`.machine_readable/descriptiles/`](https://github.com/metadatastician/gossamer/tree/main/.machine_readable/descriptiles/) — updated each session
- **Contractiles**: 6-verb governance (`must/trust/bust/adjust/dust/intend`) in [`.machine_readable/contractiles/`](https://github.com/metadatastician/gossamer/tree/main/.machine_readable/contractiles/)
- **Security policy**: [SECURITY.md](https://github.com/metadatastician/gossamer/blob/main/SECURITY.md)
- **Open issues**: [github.com/metadatastician/gossamer/issues](https://github.com/metadatastician/gossamer/issues)
