<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Glossary

Hit an unfamiliar word? This page defines Gossamer's vocabulary — each term as Gossamer *actually* uses it, not in the abstract. Canonical detail lives in the linked docs and source. For orientation, start at [Home](Home) or the [Developer](Developer) page.

---

### ABI
Application Binary Interface — the typed contract for the native library. Gossamer specifies its ABI in [Idris2](#idris2) (`src/interface/abi/*.idr`) and machine-checks it: `idris2 0.8.0 --typecheck`, `%default total`, **zero axioms, zero `believe_me`**. It ships as two packages — a groove-agnostic **shell** (`gossamer-abi.ipkg`) and a **groove** package (`gossamer-groove.ipkg`) that depends one-way on the shell. See [ABI/FFI docs](https://github.com/metadatastician/gossamer/blob/main/docs/developer/ABI-FFI-README.adoc).

### affine type
A binding used **at most once**. In [Ephapax](#ephapax), `let x = …` is affine — the value may simply be dropped without being consumed, so implicit cleanup is fine. Everything that isn't a scarce resource is affine. Contrast [linear type](#linear-type).

### AffineScript
The estate frontend language; it compiles to [typed-wasm](#typed-wasm) and is one of Gossamer's **two** supported bindings, shipped as `@gossamer/api` (Deno ESM). Frontends can equally be plain HTML/CSS/JS. Repo: [affinescript](https://github.com/hyperpolymath/affinescript).

### capability registry
Gossamer's compile-time-enforced permission model. A **256-slot** registry (FIFO eviction, clear overflow diagnostics) holds *capabilities* — unforgeable tokens that authorize one class of resource access. The Idris2 `Cap` constructor is not exported, so a capability cannot be forged externally. Permissions are checked by the compiler, not a JSON file. Backend surface: [`src/core/Capabilities.eph`](https://github.com/metadatastician/gossamer/blob/main/src/core/Capabilities.eph). See [linear type](#linear-type).

### cleave surface
The enforced seam between the Idris2 [ABI](#abi) and the Zig [FFI](#ffi). CI (`check-abi-ffi-cleave.sh`, run by `just abi-check`) fails if the generated [`%foreign`](#foreign) mirror drifts from the Zig `export fn gossamer_*` surface, so the typechecked ABI and the shipped library can never diverge. See the [Justfile](https://github.com/metadatastician/gossamer/blob/main/Justfile).

### contractile
A machine-readable governance policy expressed as data rather than prose. Gossamer uses six contractile verbs — **must / trust / bust / adjust / dust / intend** — under [`.machine_readable/contractiles/`](https://github.com/metadatastician/gossamer/tree/main/.machine_readable/contractiles/).

### CRG
Component Readiness Grade — a per-component maturity scale from **X** (untested) through **F/E/D/C/B/A** (field-proven). Grades are evidence-based, earned, and can be lost on regression. Gossamer is currently grade **D**, targeting **C**. See [CRG-CRITERIA.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/governance/CRG-CRITERIA.adoc).

### CSP
Content Security Policy. `gossamer_set_csp()` applies a CSP to the [webview](#webview) at runtime; the CLI auto-loads it from `gossamer.conf.json`. It is Gossamer's front-line control over what the frontend may load or execute. See the [threat model](https://github.com/metadatastician/gossamer/blob/main/docs/architecture/THREAT-MODEL.adoc).

### Ephapax
Gossamer's backend language — linearly-typed, [region-based](#region-based-memory), no GC ever. Backend logic lives in `src/core/*.eph`; its two binding modes ([`let` / `let!`](#let-vs-let)) are how you declare which values are scarce resources. Grammar: [EPHAPAX-GRAMMAR.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/EPHAPAX-GRAMMAR.adoc). Repo: [ephapax](https://github.com/hyperpolymath/ephapax).

### FFI
Foreign Function Interface — Gossamer's native glue, written in pure [Zig](#zig) (`src/interface/ffi/src/*.zig`). It exports **~135** C-ABI `gossamer_*` symbols that call each platform's [webview](#webview) directly. The Idris2 [ABI](#abi) proves properties C/Zig can't express; the Zig FFI implements them. See [libgossamer](#libgossamer).

### foreign
In Idris2, `%foreign` declares an external C symbol. `Gossamer.ABI.ForeignGen` ([`src/interface/abi/ForeignGen.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/ForeignGen.idr)) is a **generated** file mirroring every Zig export with a typed `%foreign` declaration — regenerate it with `just abi-gen`. It is the machine-checked half of the [cleave surface](#cleave-surface).

### Groove
A bidirectional capability-discovery interface between two co-present systems — each usable standalone, each enhanced when the other is present. A connection yields a **linear** `GrooveHandle` that must be consumed exactly once by disconnect (proved in [`Groove.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/Groove.idr) / [`GrooveLinearity.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/GrooveLinearity.idr)). Grooves are panel-optional and can power [PanLL](#panll) panels. IPC surface: [`src/core/Groove.eph`](https://github.com/metadatastician/gossamer/blob/main/src/core/Groove.eph).

| Kind | Teardown behaviour |
|---|---|
| **Soft groove** | Transient — disconnect wipes the whole slot, leaving **zero [residue](#residue)** |
| **Hard groove** | Persistent — disconnect deactivates only, keeping peer identity for auto-reconnect |

### handle
A **linear** reference to a live OS resource — a window, IPC connection, or file handle. Handles are bound with `let!`, so the compiler forces each to be consumed exactly once: a forgotten close is a *compile error*, not a leak. Non-null and main-thread invariants are proved in [`HandleLinearity.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/HandleLinearity.idr). See [linear type](#linear-type).

### Idris2
The dependently-typed language in which Gossamer's [ABI](#abi) and its safety proofs are written. The entire ABI typechecks under `idris2 0.8.0 --typecheck` with `%default total` and zero axioms / zero `believe_me` — the guarantees are machine-checked, not asserted.

### IPC
Inter-process communication between frontend and backend, in three flavours: **synchronous** request/response; **asynchronous** (`gossamer_channel_bind_async`, worker-thread callbacks with a 256-slot inflight tracker); and **streaming** backend→frontend push (`gossamer_emit`). Message shapes are agreed at compile time, so IPC can't type-mismatch at runtime.

### JNI
Java Native Interface. On Android, Gossamer reaches the platform through a Zig JNI vtable (`jni.zig`) plus Service / Receiver / Widget shims. See [android-components.adoc](https://github.com/metadatastician/gossamer/blob/main/docs/architecture/android-components.adoc).

### let vs let!
Ephapax's two binding modes — you declare intent, the compiler enforces it.

| Form | Discipline | Use for |
|---|---|---|
| `let x = …` | [affine](#affine-type) — at most once | ordinary values (cleanup optional) |
| `let! x = …` | [linear](#linear-type) — exactly once | scarce resources ([handles](#handle), windows, connections) |

### libgossamer
The compiled native library (`libgossamer.so` / `.a` / `.dylib`) produced from the Zig [FFI](#ffi). It exposes the **~135** C-ABI `gossamer_*` symbols; any language with a C FFI can drive it — Gossamer ships **Rust** and [AffineScript](#affinescript) bindings.

### linear type
A binding that must be used **exactly once** — neither dropped nor duplicated. In Ephapax `let! x = …` is linear, and it is how Gossamer makes leaks impossible: a live resource that is never consumed fails to compile. Contrast [affine type](#affine-type); see [handle](#handle).

### MPL-2.0
Mozilla Public License 2.0 — Gossamer's licence. File-level copyleft, friendly to commercial integration. Gossamer is a *component* used inside IDApTIK, which is AGPL-3.0-or-later.

### PanLL
The panel UI system that can host Gossamer webviews as panels. [Grooves](#groove) are panel-optional but can drive PanLL panels, and [transmute](#transmute)'s `panll_attach` / `panll_detach` modes move a window in and out of a PanLL surface.

### region-based memory
Gossamer's GC-free memory model. Values live in **regions** — scoped arenas that free everything at once on exit — and [linear types](#linear-type) guarantee nothing escapes the region. No GC, no reference counting, no tracing, no pauses: deterministic, zero-overhead cleanup.

### residue
State left behind after a resource is torn down. Gossamer proves **zero-residue teardown** for soft [grooves](#groove): the typed disconnect provably *erases* the peer identity rather than merely marking it inactive, closing the **RC-7 / RC-8** gap. Proof: [`GrooveResidue.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/GrooveResidue.idr).

### RSR
Rhodium Standard Repository — the estate-wide template Gossamer follows for structure, machine-readable state, [contractiles](#contractile), and workflows. See [ADR-0001](https://github.com/metadatastician/gossamer/blob/main/docs/decisions/0001-adopt-rsr-standard.adoc).

### transmute
Switching a window between render modes — `gui`, `tui`, `cli`, `terminal_export`, and `panll_attach` / `panll_detach`. `gossamer_transmute` permits only legal transitions (illegal ones return `invalid_param`); the transition relation is proved in [`TransmuteStateMachine.idr`](https://github.com/metadatastician/gossamer/blob/main/src/interface/abi/TransmuteStateMachine.idr). See [PanLL](#panll).

### typed-wasm
The shared, typed WebAssembly compile target used across the estate; [AffineScript](#affinescript) frontends compile to it. Repo: [typed-wasm](https://github.com/hyperpolymath/typed-wasm).

### webview
The OS-native HTML rendering component Gossamer wraps — **WebKitGTK** on Linux, **WKWebView** on macOS, **WebView2** (COM) on Windows, and the system WebView via [JNI](#jni) on Android. There is no bundled browser engine; Gossamer is just your app and the OS.

### Zig
The systems language Gossamer's [FFI](#ffi) is written in. Zig gives C-ABI exports for free, compile-time platform dispatch (no runtime cost), easy cross-compilation, and no required runtime — so [libgossamer](#libgossamer) carries no VM, interpreter, or GC.

---

Related: [Home](Home) · [Developer](Developer)
