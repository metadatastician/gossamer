<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->

# Gossamer

**A linearly-typed webview shell with provable resource safety.**

[![License: PMPL-1.0](https://img.shields.io/badge/License-PMPL--1.0-blue.svg)](https://github.com/hyperpolymath/palimpsest-license)
[![Release](https://img.shields.io/github/v/release/hyperpolymath/gossamer)](https://github.com/hyperpolymath/gossamer/releases)

Gossamer is a desktop application framework that wraps web frontends in native webview windows — like Tauri or Electron — but with three guarantees no other framework provides:

1. **Linearly-owned webview handles** — use-after-free and double-free are *compile errors*
2. **Typed IPC** — frontend-backend message shape agreement at compile time
3. **Linear capability tokens** — permissions enforced by the type system, not runtime config

Built in [Ephapax](https://github.com/hyperpolymath/ephapax) (a dyadic language with affine + linear types), using the Idris2 ABI / Zig FFI standard.

## How it compares

|  | Electron | Tauri | Wails | **Gossamer** |
|--|----------|-------|-------|-------------|
| Resource lifecycle | GC | Arc (refcount) | GC | **Proved (linear)** |
| IPC type safety | None | Codegen | Reflection | **Compile-time** |
| Permissions | Opt-in | Runtime JSON | None | **Linear tokens** |
| GC required? | Yes | No* | Yes | **Never** |
| Binary size | 150-300MB | 3-8MB | 5-10MB | **1-3MB** |

\* Tauri uses `Arc<Mutex<...>>`, which is reference counting.

## Hello World

```
fn main(): I64 =
  let! handle = __ffi("gossamer_create", "Hello", 800, 600, 1, 1, 0) in
  let! _ = __ffi("gossamer_load_html", handle, "<h1>Hello!</h1>") in
  __ffi("gossamer_run", handle)
```

- Remove `gossamer_run` → **compile error** (linear variable not consumed)
- Use `handle` after `gossamer_run` → **compile error** (already consumed)

## The stack

```
Ephapax (.eph) — application code with linear types
    ↓ __ffi()
Zig (.zig) — platform webview bindings (GTK / WebKit / WebView2)
    ↓ C ABI
Idris2 (.idr) — formal ABI proofs (compile-time only, erased)
```

At runtime: just Zig + GTK. No GC runtime, no VM. ~1-3MB.

## Quick Start

```bash
# Prerequisites (Fedora)
sudo dnf install gtk3-devel webkit2gtk4.1-devel zig

# Build the Zig FFI
cd src/interface/ffi && zig build

# Build the Ephapax compiler
cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli

# Run hello example
cd ~/Documents/hyperpolymath-repos/gossamer
bash examples/hello/run.sh
```

## Architecture

- **Idris2 ABI** (`src/interface/abi/*.idr`) — formal specification with dependent type proofs
- **Zig FFI** (`src/interface/ffi/src/*.zig`) — platform webview implementation
- **Ephapax core** (`src/core/*.eph`) — Shell, Bridge, Capabilities modules
- **Examples** (`examples/`) — hello world, IPC demo, capabilities demo

## Region-Linear Fusion

The core innovation: regions provide *scope* (when memory is freed), linear types provide *obligation* (whether the programmer must act). Together they prove that all memory is freed with no GC:

- **No Escape**: values in region `r` cannot appear in types that outlive `r`
- **All Linears Consumed**: linear variables must be consumed before region exit
- **Orthogonality**: region rules and qualifier rules are independent — one implementation, both modes

## Roadmap

- **v0.1 (current)**: Linux (WebKitGTK)
- **v0.2**: macOS (WKWebView) + Windows (WebView2)
- **v0.3**: Mobile (iOS / Android)
- **v1.0**: Plugin system, auto-updater

## Paper

*Gossamer: A Linearly-Typed Webview Shell with Provable Resource Safety*
— [LaTeX source](docs/whitepapers/gossamer-arxiv-paper.tex) (arXiv submission pending)

## License

PMPL-1.0-or-later (Palimpsest License)

Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
