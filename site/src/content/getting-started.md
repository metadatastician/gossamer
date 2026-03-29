---
title: Getting Started
date: 2026-03-29
---

# Getting Started with Gossamer

## Prerequisites

| Platform | Dependencies |
|----------|-------------|
| Fedora/RHEL | `sudo dnf install gtk3-devel webkit2gtk4.1-devel zig` |
| Ubuntu/Debian | `sudo apt install libgtk-3-dev libwebkit2gtk-4.1-dev` + [Zig 0.15+](https://ziglang.org/download/) |
| macOS | Xcode command line tools (WKWebView built-in) + Zig |
| Windows | WebView2 Runtime (bundled with Edge) + Zig |

## Build

```bash
git clone https://github.com/hyperpolymath/gossamer
cd gossamer
just build-ffi     # Build libgossamer.so (Zig FFI)
just hello         # Run the hello world example
```

## Your First Application

Create a file `app.eph`:

```
// A minimal Gossamer application
let main = fn() -> !{
  let win = gossamer_create("My App", 800, 600);
  gossamer_set_html(win, "<h1>Hello, Gossamer!</h1>");
  gossamer_run(win);
}
```

Run it:

```bash
just run app.eph
```

## Project Structure

```
your-app/
  src/
    main.eph           # Entry point (Ephapax)
    App.res             # Frontend (ReScript, optional)
  src/interface/
    abi/Types.idr       # ABI proofs (Idris2)
    ffi/src/main.zig    # Platform bindings (Zig)
```

## IPC Communication

Gossamer provides typed IPC between the frontend (JavaScript/ReScript) and
backend (Ephapax/Zig). Register commands with `gossamer_channel_bind`:

```
gossamer_channel_bind(win, "greet", fn(payload) -> String {
  "Hello, " ++ payload ++ "!"
});
```

Call from JavaScript:

```javascript
const result = await gossamerInvoke("greet", "World");
// result === "Hello, World!"
```

## Next Steps

- [Architecture](architecture.html) — How the stack works
- [Ephapax Primer](ephapax-primer.html) — Linear types in practice
- [Platform Support](platform-support.html) — OS-specific details
