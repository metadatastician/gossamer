<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# TEST-NEEDS.md — gossamer

## CRG Grade: B — TARGET 2026-04-10

## Current Test State

| Category | Count | Notes |
|----------|-------|-------|
| Unit tests | 5 | ipc, capability, dialog, guard_mode, result_code |
| E2E tests | 1 | webview_lifecycle |
| Property tests | 1 | contracts |
| Aspect tests | 1 | security |
| Benchmarks | 2 | gossamer_bench, startup_bench |
| **Total** | **10** | Up from 6 |

## What's Covered

- [x] IPC message format and channel lifecycle (ipc_test.ts)
- [x] Capability token model (capability_test.ts)
- [x] Dialog system (dialog_test.ts)
- [x] Window guard mode system (guard_mode_test.ts) ✅ NEW
- [x] Result code system / ABI contract (result_code_test.ts) ✅ NEW
- [x] Webview lifecycle E2E (webview_lifecycle_test.ts)
- [x] Contract properties (contracts_test.ts)
- [x] Security aspects (security_test.ts)
- [x] Startup performance benchmarks (startup_bench.ts) ✅ NEW

## Formal Proof Coverage (Idris2 ABI layer)

- [x] Types.idr — Core types, result codes, platform detection
- [x] HandleLinearity.idr — Handle lifecycle, uniqueness, consumption
- [x] IPCIntegrity.idr — Message integrity, sequence monotonicity
- [x] PanelIsolation.idr — Panel-scoped state, channel isolation
- [x] CapabilityAuthenticity.idr — Declaration-implementation correspondence
- [x] GrooveTermination.idr — Handshake terminates in ≤4 steps ✅ NEW
- [x] LayoutStability.idr — ABI backward compatibility ✅ NEW
- [x] ResourceCleanup.idr — Teardown releases all resources ✅ NEW

## Still Missing (for CRG A)

- [ ] Zig FFI native tests (requires cross-compilation test harness)
- [ ] CI/CD automated test pipeline
- [ ] Fuzz testing for IPC message parsing
- [ ] Mobile platform tests (iOS/Android real devices)

## Run Tests

```bash
just test
```
