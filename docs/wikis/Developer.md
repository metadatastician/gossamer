<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Developer Guide

This page is the *signpost* for people who hack **on** or **in** Gossamer — the Zig FFI, the Idris2 ABI proofs, the Ephapax core, or a new language binding. Canonical docs live in the repo under [`docs/`](https://github.com/hyperpolymath/gossamer/tree/main/docs); this page tells you where each layer lives, how to build it, and how to keep the proofs honest.

New here? Read [Home](Home) first, then [docs/QUICKSTART.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/QUICKSTART.adoc) to ship an app. This page is for changing Gossamer *itself*.

## The four layers

Gossamer is one native library assembled from four layers, each with its own language and its own guarantee:

| Layer | Language | Lives in | Guarantee |
|---|---|---|---|
| Frontend | HTML/CSS/JS, or AffineScript → Wasm | your app | — |
| Backend | Ephapax — `let` (affine, at most once) / `let!` (linear, exactly once) | [`src/core/*.eph`](https://github.com/hyperpolymath/gossamer/tree/main/src/core) | resources used exactly once; region memory, no GC ever |
| Native glue | Zig — the `libgossamer` C ABI | [`src/interface/ffi/src/*.zig`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/ffi) | ~135 exported `gossamer_*` symbols; per-platform webview |
| ABI proofs | Idris2 0.8.0 | [`src/interface/abi/*.idr`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/abi) | machine-checked layout & linearity, `%default total`, zero axioms |

The Zig export surface is the **single source of truth** for the C ABI (`gossamer#82`). The Idris2 layer *mirrors and proves* that surface — it never invents it.

## Repo map

| Path | What |
|---|---|
| [`src/core/`](https://github.com/hyperpolymath/gossamer/tree/main/src/core) | Ephapax backend — linear/affine modules (`Shell`, `Bridge`, `Capabilities`, `Groove`, `Filesystem`, `Dialog`, `Tray`, `Platform`, `ShellExec`, `SSG`, `Conf`, …) |
| [`src/interface/abi/`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/abi) | Idris2 ABI proofs (shell + groove packages), incl. the generated [`ForeignGen.idr`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/abi/ForeignGen.idr) |
| [`src/interface/ffi/`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/ffi) | Zig FFI — [`build.zig`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/ffi/build.zig), [`src/main.zig`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/ffi/src/main.zig), `src/webview_{gtk,cocoa,win32,ios,android}.zig`, `test/` |
| [`src/interface/generated/abi/`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/generated/abi) | Auto-generated C header (`gossamer.h`) |
| `bindings/rust/`, `bindings/affinescript/` | Language bindings over the C ABI |
| [`android/gossamer-android-services/`](https://github.com/hyperpolymath/gossamer/tree/main/android/gossamer-android-services) | Android Service / Receiver / Widget shims (JNI) |
| `examples/` | Runnable examples (`hello`, …) |
| [`docs/`](https://github.com/hyperpolymath/gossamer/tree/main/docs) | Canonical documentation |
| [`Justfile`](https://github.com/hyperpolymath/gossamer/blob/main/Justfile) | Task recipes (build / check / abi) |

## Building

Three independent toolchains. `just` wraps the raw commands; the raw form is shown so you know what runs.

**1 — Zig FFI (the native library).** Requires Zig 0.15 and the platform webview dev headers (on Fedora: `gtk3-devel webkit2gtk4.1-devel`).

```bash
cd src/interface/ffi && zig build      # libgossamer.so + libgossamer.a   (just build-ffi)
zig build -Dtarget=aarch64-macos       # cross-compile to any platform
```

**2 — Ephapax core.** The backend compiler is a separate dependency — build it once, then type-check the linear core:

```bash
git clone https://github.com/hyperpolymath/ephapax && cd ephapax && cargo build -p ephapax-cli
```
```bash
just check        # ephapax check src/core/*.eph --mode linear
just eph-check    # linearity gate: proves that leaking a `let!` handle is a compile error
```

**3 — Idris2 ABI proofs.** Type-check both packages with `idris2 0.8.0`:

```bash
just abi-check    # decoupling guards, then --typecheck both ipkgs
```

- `gossamer-abi.ipkg` — the **shell** package (11 modules, groove-agnostic).
- `gossamer-groove.ipkg` — the **groove** package (4 modules, one-way depends on the shell).

Every module is `%default total` with **zero `believe_me` and zero axioms**. No shell module imports a groove module; the dependency points one way only.

## ABI codegen — keeping the proofs in sync

`Gossamer.ABI.ForeignGen` ([`src/interface/abi/ForeignGen.idr`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/abi/ForeignGen.idr)) is a **generated** file that mirrors every `export fn gossamer_*` in the Zig surface, so the typechecked ABI cannot drift from the native reality. When you add or change a Zig export:

1. Run `just abi-gen` — regenerates `ForeignGen` from the Zig surface (via `scripts/gen-abi-foreign.sh`).
2. Commit the regenerated file. CI (`check-abi-ffi-cleave.sh`) fails the build if the mirror is **stale**.

## Adding or verifying a proof

1. Add your module under [`src/interface/abi/`](https://github.com/hyperpolymath/gossamer/tree/main/src/interface/abi) and list it in the right package — `gossamer-abi.ipkg` for shell proofs, `gossamer-groove.ipkg` for groove proofs.
2. Keep it `%default total`; no `believe_me`, no postulated axioms. Defer nothing silently — record any open obligation in `PROOF-NEEDS.md`, the discharge ledger.
3. Run `just abi-check`. A green typecheck is the gate.

[`Foreign.idr`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/abi/Foreign.idr) and [`Types.idr`](https://github.com/hyperpolymath/gossamer/blob/main/src/interface/abi/Types.idr) are the entry points; [`ABI-FFI-README.adoc`](https://github.com/hyperpolymath/gossamer/blob/main/docs/developer/ABI-FFI-README.adoc) walks the layout, linearity, and state-machine proofs in depth.

## Tests

192 integration tests exercise the FFI, async IPC, the capability registry, CSP enforcement, and the webview lifecycle:

```bash
cd src/interface/ffi && zig build test
```

## Bindings

Two bindings ship in-tree; both call the same `libgossamer` C ABI. Do **not** re-declare symbols by hand — bind against the surface `ForeignGen` mirrors.

| Binding | Path | Ships as |
|---|---|---|
| Rust | `bindings/rust/` | in-tree crate |
| AffineScript | `bindings/affinescript/` | `@gossamer/api` (Deno ESM) |

(ReScript/Gleam/Elixir/Julia bindings referenced in older notes are stale — Rust and AffineScript are the current two.)

## Key developer docs

| Doc | Why read it |
|---|---|
| [docs/developer/ABI-FFI-README.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/developer/ABI-FFI-README.adoc) | The ABI↔FFI contract, build & cross-compile, per-language call examples |
| [docs/EPHAPAX-GRAMMAR.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/EPHAPAX-GRAMMAR.adoc) | EBNF grammar for `.eph` source |
| [docs/architecture/THREAT-MODEL.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/architecture/THREAT-MODEL.adoc) | Trust boundaries and attacker model |
| [docs/architecture/android-components.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/architecture/android-components.adoc) | Android Service / Receiver / Widget design |
| [docs/decisions/ADR-001-gossamer-webview-shell.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/decisions/ADR-001-gossamer-webview-shell.adoc) | Why a linearly-typed webview shell |
| [docs/decisions/0001-adopt-rsr-standard.adoc](https://github.com/hyperpolymath/gossamer/blob/main/docs/decisions/0001-adopt-rsr-standard.adoc) | The repository standard this project follows |
| `PROOF-NEEDS.md` | Proof-obligation discharge ledger (repo root) |

## Contributing

Read `CONTRIBUTING.md` at the repo root before you open a PR. The short version: work one unit per PR, keep `just check`, `just abi-check`, and `zig build test` green, and regenerate `ForeignGen` (`just abi-gen`) whenever you touch a Zig export. Gossamer is MPL-2.0, v0.3.x, ~92% MVP, CRG grade D (targeting C).
