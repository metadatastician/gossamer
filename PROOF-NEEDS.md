# Proof Requirements

## Current state
- `src/interface/abi/Types.idr` — Core webview shell types
- `src/interface/abi/Foreign.idr` — FFI declarations
- `src/interface/abi/Layout.idr` — Memory layout definitions
- `src/interface/abi/Groove.idr` — Groove protocol type definitions
- `src/interface/abi/HandleLinearity.idr` — Handle lifecycle and uniqueness proofs
- `src/interface/abi/IPCIntegrity.idr` — IPC message integrity proofs
- `src/interface/abi/PanelIsolation.idr` — Panel isolation proofs
- `src/interface/abi/CapabilityAuthenticity.idr` — Capability authenticity proofs
- `src/interface/abi/GrooveTermination.idr` — Groove handshake termination proof ✅
- `src/interface/abi/LayoutStability.idr` — Memory layout ABI stability proofs ✅
- `src/interface/abi/ResourceCleanup.idr` — Resource cleanup on teardown proofs ✅
- `src/interface/abi/WindowStateMachine.idr` — Window state machine correctness (GS1) ✅ NEW 2026-04-11
- `src/interface/abi/IPCDispatch.idr` — IPC handler type safety, 25 handlers (GS2) ✅ NEW 2026-04-11
- No `believe_me`, `sorry`, `postulate`, or `assert_total` in ABI layer
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
