# Test & Benchmark Requirements

## CRG Grade: C (achieved 2026-04-04)

### What was added (CRG blitz D→C)

All tests implemented as Deno TypeScript (no FFI required — contract-level testing):

| Suite | File | Count | Coverage |
|-------|------|-------|----------|
| Unit | `tests/unit/capability_test.ts` | 18 | Capability system: grant/revoke/check/resourceKind |
| Unit | `tests/unit/ipc_test.ts` | 17 | IPC channel: bind/dispatch/close/result codes |
| Unit | `tests/unit/dialog_test.ts` | 17 | Dialog types, filter parsing, Option semantics |
| Property | `tests/property/contracts_test.ts` | 15 | Core invariants: IPC/cap/shell/FS/dialog/result codes |
| E2E | `tests/e2e/webview_lifecycle_test.ts` | 15 | Webview state machine, IPC round-trip, cap lifecycle |
| Aspect | `tests/aspect/security_test.ts` | 25 | IPC/shell/FS injection, dialog escaping, cap forging |
| **Total** | | **107** | **106/106 passing** |

### Benchmarks baselined (Deno.bench)

`tests/bench/gossamer_bench.ts` — 22 benchmarks across 6 groups:
- **ipc**: serialise/deserialise throughput (small: 567ns, 1KB: 8µs, batch-100: 66.9µs)
- **capability**: lookup speed (100-entry: 85ns, 1000: 138ns, 10000: 69ns)
- **path**: normalise throughput (single: 855ns, null-byte rejection: 38ns)
- **dialog**: state machine transitions (single: 16ns, 1000-cycle: 8.1µs)
- **result**: code lookup (single: 13ns, all-12: 26ns, 1000-random: 2.2µs)
- **ipc-validate**: command name validation (valid: 97ns, invalid: 83ns)

### Run

```sh
# All tests
deno task test

# Benchmarks
deno task test:bench
```

---

## What remains for CRG B

### Native/Zig coverage
- Zig unit tests for IPC message format and capability bit-flag ops (need `zig build test`)
- Integration tests with real FFI (requires libgossamer.so built and loaded)

### Remaining aspect suites
- [ ] Performance aspect (webview render latency, memory footprint vs Tauri/Electron)
- [ ] Concurrency aspect (concurrent IPC messages, parallel webview operations)
- [ ] Error handling aspect (webview crash recovery, IPC timeout, missing capabilities)
- [ ] Accessibility aspect (keyboard navigation, screen reader)

### Remaining E2E scenarios
- Groove integration: discover services → negotiate → communicate
- Mobile (Android): app launch → render → interact → navigate
- SSG: build static site → serve → verify output
- Dialog system: show dialog → user interaction (requires native process)

### Build & Execution
- [ ] `zig build` — verified working on CI
- [ ] Ephapax compile — verified working on CI
- [ ] Gossamer window opens — verified in CI (Xvfb or headless)
- [ ] CLI --help works — verified in CI

### Fuzz testing
- Real fuzz harness (was: `tests/fuzz/placeholder.txt` — DELETED 2026-04-04)
- Target: IPC message parser, capability token validation, shell command sanitiser

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Webview self-test (load test page, verify rendering)
- [ ] IPC echo test
- [ ] Capability system self-check

## Priority
- **HIGH** — Webview shell framework (46 Zig + 19 Ephapax + 8 Idris2 files) that replaced Tauri
  across 13 repos. The IPC bridge, capability system, and shell execution all have security
  implications. CRG C baseline covers contract-level invariants; native integration tests needed for CRG B.
