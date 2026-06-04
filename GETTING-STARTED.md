<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Getting Started with Gossamer

## Core Technologies

- **Ephapax** — Linear type compiler ensuring resource safety at compile time
- **Zig FFI** — High-performance C ABI implementation via libgossamer
- **Idris2** — Formal verification layer for ABI correctness proofs

## Quick Start

```bash
# Check prerequisites
just doctor

# Build the FFI library and CLI
just build

# Run the hello example (requires X11/Wayland)
just hello

# Run all tests
just test

# Benchmark core operations
just test-zig-bench
```

## Configuration Files

- **gossamer-abi.ipkg / gossamer-abi-tests.ipkg** — Idris2 ABI package and its test runner
- **flake.nix** — Nix development environment (fallback to guix.scm)
- **guix.scm** — Primary Guix package definition for reproducible dev env
- **gossamer.conf.json** — Runtime config: window size, IPC protocol, CSP, capabilities, sandbox

## Top 5 Files to Read First

1. **README.adoc** — Project philosophy and overview
2. **Justfile** — Build recipes and development workflow
3. **src/interface/ffi/main.zig** — FFI implementation (libgossamer)
4. **src/core/Shell.eph** — Main application module (linear types)
5. **examples/hello/main.eph** — Minimal runnable example

## Key Commands

| Task | Command |
|------|---------|
| Build FFI + CLI + type-check | `just build` |
| Run conformance tests | `just test-conformance` |
| Type-check Ephapax code | `just check` |
| Install CLI to ~/.local/bin | `just install` |
| View all available recipes | `just` |
| Auto-heal missing dependencies | `just heal` |

## Troubleshooting

**GTK3/WebKit2 not found:**
```bash
sudo dnf install gtk3-devel webkit2gtk4.1-devel
```

**Linear type error on handle:**
Every webview/channel handle must be explicitly consumed. If you see "resource leaked", ensure all handles returned by `gossamer_*` functions are passed to a destructor.

**Ephapax compiler not found:**
```bash
cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli
```

Run `just help-me` for more troubleshooting steps.
