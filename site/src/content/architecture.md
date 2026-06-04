<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
---
title: Architecture
date: 2026-03-28
---

# Gossamer Architecture

Gossamer is structured as four layers, each with a distinct responsibility.

## Layer 1: Web Frontend

Standard HTML, CSS, and JavaScript (or ReScript) running inside the OS-provided webview. No custom rendering engine, no bundled browser.

## Layer 2: Ephapax Application Layer

Command handlers with linear ownership, capability tokens, and the plugin host. This is where application logic lives. The `.eph` files in `src/core/` define the typed interfaces:

- **Shell.eph** -- Webview window lifecycle (create, loadHTML, navigate, run, destroy)
- **Bridge.eph** -- Typed IPC channels between frontend and backend
- **Capabilities.eph** -- Linear capability tokens for permission enforcement
- **Groove.eph** -- Service discovery for composable integration
- **SSG.eph** -- Static site generator pipeline

## Layer 3: Idris2 ABI

Formal specifications of the webview handle, IPC protocol, and capability types. Dependent type proofs guarantee:

- Handle non-nullity (`So (ptr /= 0)`)
- Main-thread witness (`MainThreadProof`)
- Valid state transitions (`ValidTransition`)
- Capability scope enforcement

These proofs are erased at runtime -- zero cost.

## Layer 4: Zig FFI

Platform-specific bindings to WebKitGTK (Linux), WKWebView (macOS), and WebView2 (Windows). The Zig layer provides:

- C ABI compatibility
- Cross-compilation support
- Zero runtime dependencies
- Compile-time platform dispatch

## IPC Design

The IPC channel is parameterised by request and response types. A protocol is a type-level list of named commands, each with typed request and response. The frontend JavaScript client is generated from the same protocol definition, guaranteeing compile-time agreement.

## Groove Integration

Gossamer discovers and connects to other hyperpolymath services via the Groove protocol. Well-known ports are probed for capability manifests, and matching grooves are activated automatically. This enables composable integration without explicit configuration.
