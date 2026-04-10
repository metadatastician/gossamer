# Proof Requirements

## Current state
- `src/abi/Types.idr` (463 lines) — Core webview shell types
- `src/abi/Foreign.idr` (666 lines) — FFI declarations
- `src/abi/Layout.idr` (200 lines) — Memory layout definitions
- `src/abi/Groove.idr` (435 lines) — Groove protocol type definitions
- `src/abi/HandleLinearity.idr` — Handle lifecycle and uniqueness proofs
- `src/abi/IPCIntegrity.idr` — IPC message integrity proofs
- `src/abi/PanelIsolation.idr` — Panel isolation proofs
- `src/abi/CapabilityAuthenticity.idr` — Capability authenticity proofs
- `src/abi/GrooveTermination.idr` — Groove handshake termination proof ✅ NEW
- `src/abi/LayoutStability.idr` — Memory layout ABI stability proofs ✅ NEW
- `src/abi/ResourceCleanup.idr` — Resource cleanup on teardown proofs ✅ NEW
- No `believe_me`, `sorry`, `postulate`, or `assert_total` in ABI layer
- Zig FFI layer in `src/interface/ffi/`

## What needs proving
- ~~**IPC message integrity**~~: ✅ Proved in IPCIntegrity.idr — hash preservation, sequence monotonicity, protocol conformance, no phantom messages
- ~~**Groove protocol handshake**~~: ✅ Proved in GrooveTermination.idr — terminates in ≤4 steps, no privilege escalation, deterministic
- ~~**Panel isolation**~~: ✅ Proved in PanelIsolation.idr — state tokens are tag-exclusive, channels are tag-exclusive, registry isolation
- ~~**Memory layout ABI stability**~~: ✅ Proved in LayoutStability.idr — field prefix preservation, result code stability, handle size stability, append-only rule
- **Extension loading safety**: Prove `.eph` module loading validates signatures before execution (BLOCKED: requires Ephapax module system, see NEXT-STEPS.md P6)
- ~~**Resource cleanup on teardown**~~: ✅ Proved in ResourceCleanup.idr — every resource has cleanup action, LIFO order, panel teardown, shell teardown total

## Recommended prover
- **Idris2** — Already used for ABI; dependent types are ideal for proving protocol properties and capability correctness

## Priority
- **MEDIUM** (was HIGH) — 5 of 6 proof requirements now completed. Only extension loading safety remains, blocked on Ephapax module system completion.
