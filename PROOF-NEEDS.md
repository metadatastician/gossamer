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
- **ABI ↔ FFI cleave (`gossamer#82`) — closed.** `idris2 --typecheck` proves the ABI internally sound but does **not** check that a `%foreign "C:sym, libgossamer"` resolves to a real Zig export (that linkage is only exercised at link time). This is now closed at source:
  - **No phantom, no drift.** `Gossamer.ABI.ForeignGen` is a **generated** raw `%foreign` mirror of the C ABI — `scripts/gen-abi-foreign.sh` emits one declaration per `export fn gossamer_*` in `src/interface/ffi/src/*.zig`, making the **Zig FFI the single source of truth**. Coverage is **130 / 130 (100%)**.
  - **Enforced in CI.** `scripts/check-abi-ffi-cleave.sh` hard-fails on any phantom `%foreign` *and* runs the generator in `--check` mode: if a Zig export is added/changed/removed and `ForeignGen.idr` isn't regenerated (`just abi-gen`), CI fails. The ABI therefore cannot drift from — or lie about — the FFI.
  - Curated safe wrappers over the core subset (with `MainThreadProof` etc.) remain hand-written in `Gossamer.ABI.Foreign`; `ForeignGen` is the complete raw layer beneath them.
- **Zero class-J axioms** (as of 2026-07-07): the former `stringNotEqCommut` axiom was eliminated constructively — see "Class-J axioms (trusted base)" below for the retirement record.
- No `believe_me`, `sorry`, `postulate`, or `assert_total` anywhere in the ABI layer.
- Zig FFI layer in `src/interface/ffi/`

## What needs proving
- ~~**IPC message integrity**~~: ✅ Proved in IPCIntegrity.idr — hash preservation, sequence monotonicity, protocol conformance, no phantom messages
- ~~**Groove protocol handshake**~~: ✅ Proved in GrooveTermination.idr — terminates in ≤4 steps, no privilege escalation, deterministic
- ~~**Panel isolation**~~: ✅ Proved in PanelIsolation.idr — state tokens are tag-exclusive, channels are tag-exclusive, registry isolation
- ~~**Memory layout ABI stability**~~: ✅ Proved in LayoutStability.idr — field prefix preservation, result code stability, handle size stability, append-only rule
- ~~**Resource cleanup on teardown**~~: ✅ Proved in ResourceCleanup.idr — every resource has cleanup action, LIFO order, panel teardown, shell teardown total
- ~~**Soft-groove disconnect privacy (residue→0)**~~: ✅ Proved in `GrooveResidue.idr` (`gossamer#82`, groove package) — models `gossamer_groove_disconnect_typed` and proves the `SoftGroove` privacy guarantee: disconnecting a soft groove erases the peer identity (`softWipeZeroResidue`: residue = 0) and clears the whole slot, while a hard groove retains its peer (`hardDisconnectRetainsPeer` — the distinction is real), and the wipe is idempotent. Closes the `RC-7`/`RC-8` gap ResourceCleanup's plain `disconnect` did not cover. Zero `believe_me`.
- ~~**Window state machine correctness (GS1)**~~: ✅ Proved in WindowStateMachine.idr — Closed is terminal, borrow/consuming classification, all states reachable from Created, borrow preserves Active, consuming leads to Closed (2026-04-11)
- ~~**IPC handler type safety (GS2)**~~: ✅ Proved in IPCDispatch.idr — all 25 handlers have declared input/output types, dispatch is total, capability-guarded vs plain commands classified, distinctness witnesses (2026-04-11)
- ~~**Ephapax `.eph` resource linearity (gossamer#82)**~~: ✅ Verified by the **Ephapax compiler** (`ephapax check`, `--mode linear`) — the oracle is a second toolchain, not Idris2. The 13 `src/core/*.eph` bindings to the libgossamer C ABI were `__ffi` passthroughs over raw `I64` handles with comments *claiming* linearity, zero `let!` bindings, and (because `__ffi` is typed `I64` while wrappers declared non-`I64` returns) **not one type-checked**. Now: 13/13 type-check; the 8 handle-owning modules (`Bridge`/`Channel`, `Shell`/`Webview`, `Tray`/`Tray`, `Capabilities`/`CapToken`, `Conf`/`Conf`, `ClosureConversion`/`Closure`, `ShellExec`/`Child`, `Dialog`/`DialogPath`) use `extern` opaque handle types + `let!` so a leaked handle is a compile error, adversarially verified by deleting each consume and confirming rejection. Enforced in CI by `scripts/check-eph-linearity.sh` (positive: all type-check; negative: every handle's leak is rejected) + the `Ephapax Linearity Gate` workflow. `Groove`'s connection linearity stays in the Idris2 layer (registry-indexed at the `.eph` surface). NB this is *resource* linearity, distinct from **Extension loading safety** below.
- **Extension loading safety**: Prove `.eph` module loading validates signatures before execution (BLOCKED: requires Ephapax module system, see NEXT-STEPS.md P6)

## Recommended prover
- **Idris2** — Already used for ABI; dependent types are ideal for proving protocol properties and capability correctness

## Priority
- **LOW** — 7 of 8 proof requirements completed. Only extension loading safety remains, blocked on Ephapax module system completion.

## Class-J axioms (trusted base)

This repo has **zero class-J axioms** (as of 2026-07-07).

**Retired**: `stringNotEqCommut` (`Gossamer.ABI.PanelIsolation`) axiomatised commutativity of the opaque `prim__eq_String` primitive so that `distinctSym : Distinct a b -> Distinct b a` could flip the carried `So (not (a == b))` witness. It was eliminated constructively, not by adopting the backend-assurance harness: `MkDistinct` now carries an erased `So` witness for **both** orientations of the inequality. At every construction site the tags are concrete string literals, so both witnesses are auto-solved by evaluation at zero runtime cost (both are `0`-quantity), and `distinctSym` is a pure swap of the two witnesses. The trusted base gained nothing and lost the axiom.

## Discharge ledger (2026-05-20, standards#131 close-out)

| Module | Discharged in | State |
|---|---|---|
| GrooveTermination | [gossamer#36](https://github.com/hyperpolymath/gossamer/pull/36) | **MERGED** |
| LayoutStability | [gossamer#40](https://github.com/hyperpolymath/gossamer/pull/40) | **MERGED** |
| IPCIntegrity | [gossamer#40](https://github.com/hyperpolymath/gossamer/pull/40) | **MERGED** |
| PanelIsolation (+ class-J axiom) | [gossamer#41](https://github.com/hyperpolymath/gossamer/pull/41) | open, ready, idris2 ✓ 13/13 local |
| ResourceCleanup | [gossamer#41](https://github.com/hyperpolymath/gossamer/pull/41) | same branch as #41 |

**Lesson memorialised**: the OWED notes carried in the original gossamer#22 deferred-list misdiagnosed the root cause on every one of the four deferred items. The notes named `choose` / theorem restatement / axiom-vs-refactor; the actual fixes were `module-qualify the names` / `reorder + 0-quantity-mark + add accessors` / `import + capitalise the typo` / `class-J axiom` (the last one was right by accident). **Build is the only oracle for proof-bearing code; comment-only notes from never-built modules are hints, not specs.**
