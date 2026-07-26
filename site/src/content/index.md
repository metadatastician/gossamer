---
title: Gossamer
date: 2026-03-28
---

# A Linearly-Typed Webview Shell

Gossamer is a desktop application framework where **resource leaks are compile errors**.

Built on [Ephapax](https://github.com/hyperpolymath/ephapax), a dyadic language with both affine and linear type modes, Gossamer provides three guarantees no other framework offers:

## Compile-Time Resource Safety

Webview handles, IPC channels, and capability tokens are **linear types**. The compiler proves that every handle is created exactly once and consumed exactly once. Use-after-free and double-free are type errors, not runtime crashes.

## Typed IPC Protocol

The frontend-backend communication protocol is checked at compile time. Message shape mismatches between JavaScript and the backend are impossible. No `JSON.parse` failures at runtime.

## Linear Capability Tokens

Permissions are linear values in the type system. A plugin cannot access the filesystem without holding a capability token. The compiler enforces this, not a configuration file.

## The Stack

```
Ephapax (.eph) -- Application code with linear types
    | __ffi()
Zig (.zig)     -- Platform webview bindings (GTK/WebKit/Win32)
    | C ABI
Idris2 (.idr)  -- Formal ABI proofs (compile-time only, erased)
```

At runtime: just Zig + GTK. Binary size 1-3 MB. No GC runtime, no VM, no interpreter overhead.

## Quick Start

```
sudo dnf install gtk3-devel webkit2gtk4.1-devel zig
git clone https://github.com/metadatastician/gossamer
cd gossamer
just build-ffi
just hello
```

## Links

- [GitHub](https://github.com/metadatastician/gossamer)
- [GitLab](https://gitlab.com/metadatastician/gossamer)
- [Bitbucket](https://bitbucket.org/metadatastician/gossamer)
- [arXiv Paper](https://github.com/metadatastician/gossamer/blob/main/docs/whitepapers/gossamer-arxiv-paper.tex)
