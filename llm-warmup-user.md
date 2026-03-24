# Gossamer — LLM Context (User)

## What It Is

Gossamer is a linearly-typed webview shell framework. A lightweight
alternative to Electron/Tauri where linear types (via Ephapax) guarantee
resources cannot be leaked or double-freed.

## Architecture

- **Idris2 ABI** (`src/interface/abi/`): Formal interface specification
  with dependent type proofs
- **Zig FFI** (`src/interface/ffi/`): C-ABI implementation producing
  libgossamer.so and libgossamer.a
- **Ephapax** (`src/core/`): Application code with linear/affine types
- **CLI** (`cli/`): Gossamer binary linking libgossamer

## Quick Commands

```bash
just build        # Build everything (FFI + CLI + type-check)
just build-ffi    # Build libgossamer.so/.a
just hello        # Run hello example (needs display)
just test         # All tests (Zig + conformance + integration)
just deps         # Quick dependency check
just doctor       # Full prerequisite check
```

## Prerequisites

Zig 0.14+, GTK3 (gtk3-devel), WebKit2GTK 4.1 (webkit2gtk4.1-devel),
Ephapax compiler, pkg-config, just. Optional: Idris2.

## Key Concepts

- **Linear resources**: WebviewHandle, Channel, Cap must be consumed
  exactly once. Borrow returns handle; consume destroys it.
- **Capability tokens**: MkCap not exported. Framework-only creation.
  256 slots, FIFO eviction.
- **Platform dispatch**: Compile-time OS selection in Zig (no runtime).
- **CSP enforcement**: Set via API or auto-applied from gossamer.conf.json.
- **19+ exported FFI symbols**: create, load_html, load_url, run, navigate,
  eval, channel_send, channel_bind, channel_bind_async, set_csp, emit, etc.

## Status

v0.2 development — async IPC, CSP, streaming events implemented.
Phase 2: async IPC via worker threads, 256-slot inflight tracker.
