<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->
# TOPOLOGY.md — Gossamer

## Purpose

Gossamer is a desktop application framework that wraps a web frontend in a native webview window, similar to Tauri or Electron, but with compile-time guarantees via Ephapax linear types and Idris2 ABI proofs. Resource leaks, IPC type mismatches, and permission bypasses become compile errors rather than runtime failures. Target users are developers building privacy-sensitive desktop tools who need ~1MB binaries and zero garbage collection.

## Module Map

```
gossamer/
├── src/                           # Ephapax core + Idris2 ABI proofs
│   ├── core/                      # Ephapax linear type modules
│   │   ├── Bridge.eph             # Frontend-backend bridge
│   │   ├── Capabilities.eph       # Capability grants/revokes
│   │   ├── Dialog.eph             # Native dialog boxes
│   │   ├── Filesystem.eph         # Filesystem access (linear)
│   │   ├── Groove.eph             # Groove protocol integration
│   │   ├── Platform.eph           # Platform detection/abstraction
│   │   ├── Shell.eph              # Shell integration
│   │   ├── ShellExec.eph          # Shell execution (linear handle)
│   │   ├── SSG.eph                # Static site generation mode
│   │   └── Tray.eph               # System tray (linear handle)
│   ├── interface/                 # The ABI ↔ FFI cleave surface
│   │   ├── abi/                   # Formal ABI proofs (Idris2)
│   │   │   ├── Types.idr          # Fundamental ABI types
│   │   │   ├── Layout.idr         # Memory layout proofs
│   │   │   ├── HandleLinearity.idr    # Linear handle proofs (no leaks)
│   │   │   ├── IPCIntegrity.idr        # IPC message type proofs
│   │   │   ├── CapabilityAuthenticity.idr  # Capability verification
│   │   │   ├── PanelIsolation.idr      # PanLL panel sandbox proofs
│   │   │   ├── ResourceCleanup.idr / GrooveResidue.idr  # residue→0 teardown
│   │   │   ├── AndroidComponents.idr   # Android lifecycle proofs
│   │   │   ├── Groove.idr              # Groove IPC ABI
│   │   │   ├── Foreign.idr             # curated C FFI declarations
│   │   │   └── ForeignGen.idr          # GENERATED %foreign mirror (just abi-gen)
│   │   ├── ffi/                   # Zig C-ABI FFI implementation
│   │   │   ├── src/               #   *.zig exports (the real libgossamer surface)
│   │   │   └── test/              #   integration_test.zig
│   │   └── generated/            # Auto-generated C headers
│   ├── aspects/                   # integrity / observability / security
│   ├── contracts/                 # Contractile API contracts
│   └── bridges/                   # Cross-language bridge adapters
├── bindings/                      # Language wrappers (rust/, affinescript/)
├── android/                       # Android shims (gossamer-android-services)
├── cli/                           # `gossamer` CLI tool
├── api/                           # REST/IPC API surface
├── schema/                        # JSON Schema for config/IPC
├── generated/                     # Auto-generated distribution artifacts
└── verification/                  # Formal proof artifacts
```

> The single source of truth for the C ABI is the Zig FFI in
> `src/interface/ffi/src/`; `src/interface/abi/ForeignGen.idr` is generated
> from it (`just abi-gen`) so the type-checked Idris2 ABI cannot drift
> (gossamer#82).

## Data Flow

```
[Web Frontend (HTML/JS or AffineScript → Wasm)]
        │  IPC messages (Groove protocol)
        ▼
[src/core/Bridge.eph] ──► [IPCIntegrity.idr proof] ──► compile-time type check
        │
        ├──► [src/core/Capabilities.eph] ──► [CapabilityAuthenticity.idr] ──► allowed?
        │
        ├──► [src/core/Filesystem.eph] ──► [HandleLinearity.idr] ──► linear handle
        │                                        │
        │                                        ▼
        │                               [src/interface/ffi/src/ implementation]
        │                               (Zig C ABI, zero-cost, no GC)
        │
        └──► [src/core/Tray.eph / Dialog.eph / Shell.eph]
                        │
                        ▼
              [Platform native APIs]
              (Windows/macOS/Linux/Android)
```
