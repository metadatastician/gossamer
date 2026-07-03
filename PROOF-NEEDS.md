# Proof Requirements

## Current state
- `src/interface/abi/Types.idr` — Core webview shell types
- `src/interface/abi/Foreign.idr` — FFI declarations
- `src/interface/abi/Layout.idr` — Memory layout definitions
- `src/interface/abi/Groove.idr` — Groove protocol type definitions
- `src/interface/abi/GrooveLinearity.idr` — Groove-handle linearity (instantiates the shell's generic `LinearHandle` for `GrooveHandle`) ✅ NEW (gossamer#95)
- `src/interface/abi/HandleLinearity.idr` — Handle lifecycle and uniqueness proofs (groove-agnostic)
- `src/interface/abi/IPCIntegrity.idr` — IPC message integrity proofs
- `src/interface/abi/PanelIsolation.idr` — Panel isolation proofs
- `src/interface/abi/CapabilityAuthenticity.idr` — Capability authenticity proofs
- `src/interface/abi/GrooveTermination.idr` — Groove handshake termination proof ✅
- `src/interface/abi/LayoutStability.idr` — Memory layout ABI stability proofs ✅
- `src/interface/abi/ResourceCleanup.idr` — Resource cleanup on teardown proofs ✅
- `src/interface/abi/WindowStateMachine.idr` — Window state machine correctness (GS1) ✅ NEW 2026-04-11
- `src/interface/abi/IPCDispatch.idr` — IPC handler type safety, 25 handlers (GS2) ✅ NEW 2026-04-11
- **All 15 ABI modules above build green and pass `idris2 0.8.0 --typecheck` cleanly**, now split across two de-conflated packages (`gossamer#95`): the groove-agnostic **shell** `gossamer-abi.ipkg` (11 modules) and the **groove** `gossamer-groove.ipkg` (4: `Groove`, `GrooveLinearity`, `CapabilityAuthenticity`, `GrooveTermination`), which *depends on* the shell. The dependency points one way only — no shell module imports a groove module. The canonical sources live in `src/interface/abi/`; `src/interface/Gossamer/ABI/<M>.idr` are symlinks (a single source of truth, no drift). `scripts/check-abi-decoupling.sh` gates both invariants in CI. Prior to `gossamer#22` / `#36` / `#40` / `#41`, several modules were excluded from the ipkg and had never been built — their PROOF-NEEDS ✅ markers reflected an unverified posture; build is now the oracle.
- **ABI ↔ FFI cleave (`gossamer#82`)**: `idris2 --typecheck` proves the ABI internally sound but does **not** check that a `%foreign "C:sym, libgossamer"` resolves to a real Zig export (that linkage is only exercised at link time). The honest `Foreign.idr` (`gossamer#95`) removed all 8 phantom declarations, and `scripts/check-abi-ffi-cleave.sh` now gates it in CI: **every ABI `%foreign` resolves to a real `export fn` (phantom = 0)**. Coverage of the real C surface is **29 / 130** `gossamer_*` exports declared; the remaining **101 uncovered** exports are the open expansion work tracked in `gossamer#82` (declare-or-codegen the full cleave). The gate reports coverage but only *fails* on phantom, so new Zig exports don't break CI before their ABI declaration lands.
- **One class-J axiom**: `Gossamer.ABI.PanelIsolation.stringNotEqCommut` — sanctioned principled assumption over the Idris2 backend primitive `prim__eq_String` (content-symmetry on every supported backend; cannot be derived inside Idris2). `%unsafe`-annotated, `believe_me ()`-bodied, documented at the use site. Same trust posture as boj-server's `Boj.SafetyLemmas.charEqSym` and four sibling axioms over String / Char primitives. See "Class-J axioms (trusted base)" section below.
- No other `believe_me`, `sorry`, `postulate`, or `assert_total` in the ABI layer.
- Zig FFI layer in `src/interface/ffi/`

## What needs proving
- ~~**IPC message integrity**~~: ✅ Proved in IPCIntegrity.idr — hash preservation, sequence monotonicity, protocol conformance, no phantom messages
- ~~**Groove protocol handshake**~~: ✅ Proved in GrooveTermination.idr — terminates in ≤4 steps, no privilege escalation, deterministic
- ~~**Panel isolation**~~: ✅ Proved in PanelIsolation.idr — state tokens are tag-exclusive, channels are tag-exclusive, registry isolation
- ~~**Memory layout ABI stability**~~: ✅ Proved in LayoutStability.idr — field prefix preservation, result code stability, handle size stability, append-only rule
- ~~**Resource cleanup on teardown**~~: ✅ Proved in ResourceCleanup.idr — every resource has cleanup action, LIFO order, panel teardown, shell teardown total
- ~~**Window state machine correctness (GS1)**~~: ✅ Proved in WindowStateMachine.idr — Closed is terminal, borrow/consuming classification, all states reachable from Created, borrow preserves Active, consuming leads to Closed (2026-04-11)
- ~~**IPC handler type safety (GS2)**~~: ✅ Proved in IPCDispatch.idr — all 25 handlers have declared input/output types, dispatch is total, capability-guarded vs plain commands classified, distinctness witnesses (2026-04-11)
- **Extension loading safety**: Prove `.eph` module loading validates signatures before execution (BLOCKED: requires Ephapax module system, see NEXT-STEPS.md P6)

## Recommended prover
- **Idris2** — Already used for ABI; dependent types are ideal for proving protocol properties and capability correctness

## Priority
- **LOW** — 7 of 8 proof requirements completed. Only extension loading safety remains, blocked on Ephapax module system completion.

## Class-J axioms (trusted base)

This repo has one class-J axiom, sanctioned and documented:

| Axiom | Module | Justification | Soundness oracle |
|---|---|---|---|
| `stringNotEqCommut` | `Gossamer.ABI.PanelIsolation` | Commutativity of `prim__eq_String`: the Idris2 backend primitive for `String == String`. Holds on every supported backend (Chez, Racket, Node, JS — all dispatch to native string-equal which is content-symmetric). Cannot be derived inside Idris2 (opaque primitive with no constructors / induction principle). | Per-backend property-test validation (deferred to the backend-assurance harness once ported from boj-server's `project_boj_server_backend_assurance_harness`). |

The axiom is `%unsafe`-marked and the function body is `believe_me ()` — explicit, named, audited; **not unproven debt**. Sites that depend on it: `PanelIsolation.distinctSym`.

**Reduce-the-trusted-base path**: when gossamer adopts the backend-assurance harness, `stringNotEqCommut` can be promoted from class-J axiom to a backend-verified theorem via runtime correspondence tests against the primitive.

## Discharge ledger (2026-05-20, standards#131 close-out)

| Module | Discharged in | State |
|---|---|---|
| GrooveTermination | [gossamer#36](https://github.com/hyperpolymath/gossamer/pull/36) | **MERGED** |
| LayoutStability | [gossamer#40](https://github.com/hyperpolymath/gossamer/pull/40) | **MERGED** |
| IPCIntegrity | [gossamer#40](https://github.com/hyperpolymath/gossamer/pull/40) | **MERGED** |
| PanelIsolation (+ class-J axiom) | [gossamer#41](https://github.com/hyperpolymath/gossamer/pull/41) | open, ready, idris2 ✓ 13/13 local |
| ResourceCleanup | [gossamer#41](https://github.com/hyperpolymath/gossamer/pull/41) | same branch as #41 |

**Lesson memorialised**: the OWED notes carried in the original gossamer#22 deferred-list misdiagnosed the root cause on every one of the four deferred items. The notes named `choose` / theorem restatement / axiom-vs-refactor; the actual fixes were `module-qualify the names` / `reorder + 0-quantity-mark + add accessors` / `import + capitalise the typo` / `class-J axiom` (the last one was right by accident). **Build is the only oracle for proof-bearing code; comment-only notes from never-built modules are hints, not specs.**
