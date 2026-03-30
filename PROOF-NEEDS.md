# Proof Requirements

## Current state
- `src/abi/Types.idr` (463 lines) — Core webview shell types
- `src/abi/Foreign.idr` (666 lines) — FFI declarations
- `src/abi/Layout.idr` (200 lines) — Memory layout definitions
- `src/abi/Groove.idr` (435 lines) — Groove protocol type definitions
- No `believe_me`, `sorry`, `postulate`, or `assert_total` in ABI layer
- Zig FFI layer in `src/interface/ffi/`

## What needs proving
- **IPC message integrity**: Prove that messages between webview and Rust backend cannot be tampered with or replayed
- **Groove protocol handshake**: Prove the Groove capability negotiation terminates and produces a valid capability set (no privilege escalation)
- **Panel isolation**: Prove that panels loaded into the webview cannot access resources outside their declared manifest permissions
- **Memory layout ABI stability**: Prove `Layout.idr` definitions are backward-compatible across versions (no silent field reordering)
- **Extension loading safety**: Prove `.eph` module loading validates signatures before execution
- **Resource cleanup on teardown**: Prove all allocated resources (file handles, sockets, shared memory) are released when panels or the shell close

## Recommended prover
- **Idris2** — Already used for ABI; dependent types are ideal for proving protocol properties and capability correctness

## Priority
- **HIGH** — Gossamer is a webview shell that loads and executes panels from potentially diverse sources. Panel isolation and IPC integrity are security-critical. The Groove protocol's capability negotiation is the core trust boundary.
