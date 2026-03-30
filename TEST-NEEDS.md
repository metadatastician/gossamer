# Test & Benchmark Requirements

## Current State
- Unit tests: NONE
- Integration tests: 2 Zig integration tests (template-level)
- E2E tests: NONE
- Benchmarks: NONE
- panic-attack scan: NEVER RUN (feature dir exists but no report)

## What's Missing
### Point-to-Point (P2P)
46 Zig + 19 Ephapax + 8 Idris2 + 1 Rust + 2 ReScript + 11 Shell source files with ZERO functional tests:

#### Core (Ephapax — src/core/):
- Shell.eph — no tests
- Bridge.eph — no tests
- Capabilities.eph — no tests
- Dialog.eph — no tests
- Filesystem.eph — no tests
- Groove.eph — no tests

#### FFI (Zig — 46 files):
- Webview rendering engine — no tests
- IPC bridge — no tests
- Platform-specific code — no tests
- Build system — no tests
- Only 2 template integration tests exist

#### Bindings:
- Android, CLI, API — no tests

#### Idris2 ABI (8 files):
- No verification tests

#### Features:
- SSG, arXiv integration — no tests

### End-to-End (E2E)
- Webview lifecycle: create window -> load content -> interact -> close
- IPC: send message -> receive in webview -> respond -> process in native
- Dialog system: show dialog -> user interaction -> return result
- Filesystem access: request access -> validate capability -> perform operation
- Shell execution: invoke command -> capture output -> return
- Groove integration: discover services -> negotiate -> communicate
- Mobile (Android): app launch -> render -> interact -> navigate
- SSG: build static site -> serve -> verify output

### Aspect Tests
- [ ] Security (IPC injection, webview escaping, filesystem capability bypass, shell command injection)
- [ ] Performance (webview render latency, IPC throughput, memory usage)
- [ ] Concurrency (concurrent IPC messages, parallel webview operations)
- [ ] Error handling (webview crash recovery, IPC timeout, missing capabilities)
- [ ] Accessibility (webview content accessibility, keyboard navigation, screen reader support)

### Build & Execution
- [ ] zig build — not verified
- [ ] Ephapax compile — not verified
- [ ] Gossamer window opens — not verified
- [ ] IPC communication works — not verified
- [ ] CLI --help works — not verified
- [ ] Self-diagnostic — none

### Benchmarks Needed
- Webview render time for typical content
- IPC message latency (roundtrip)
- Memory footprint vs Tauri/Electron
- Startup time to first paint
- Large document rendering performance

### Self-Tests
- [ ] panic-attack assail on own repo
- [ ] Webview self-test (load test page, verify rendering)
- [ ] IPC echo test
- [ ] Capability system self-check

## Priority
- **HIGH** — Webview shell framework (46 Zig + 19 Ephapax + 8 Idris2 files) that replaced Tauri across 13 repos with ZERO functional tests. This is a foundational infrastructure component — every project migrated to Gossamer depends on it working correctly. The IPC bridge, capability system, and shell execution all have security implications and no test coverage whatsoever. As the replacement for Tauri (which has extensive testing), the complete absence of tests is a serious risk.

## FAKE-FUZZ ALERT

- `tests/fuzz/placeholder.txt` is a scorecard placeholder inherited from rsr-template-repo — it does NOT provide real fuzz testing
- Replace with an actual fuzz harness (see rsr-template-repo/tests/fuzz/README.adoc) or remove the file
- Priority: P2 — creates false impression of fuzz coverage
