<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
---
title: Platform Support
date: 2026-03-29
---

# Platform Support

Gossamer uses platform-native webviews through Zig FFI bindings.

## Current Status

| Platform | Engine | Status | File |
|----------|--------|--------|------|
| Linux | WebKitGTK | Production | `webview_gtk.zig` |
| FreeBSD | WebKitGTK | Production | `webview_gtk.zig` |
| macOS | WKWebView | Scaffold | `webview_cocoa.zig` |
| Windows | WebView2 | Scaffold | `webview_win32.zig` |
| iOS | WKWebView | Planned | `webview_ios.zig` |
| Android | WebView | Planned | `webview_android.zig` |

## Linux (Production)

The primary platform. Uses WebKitGTK for rendering.

**Requirements:**
- GTK 3.x development headers
- WebKit2GTK 4.1 development headers
- Zig 0.15+

**Build:**
```bash
just build-ffi     # Produces libgossamer.so
```

The FFI exposes 20 C-compatible symbols:
- `gossamer_create` / `gossamer_destroy` — lifecycle
- `gossamer_set_html` / `gossamer_navigate` — content
- `gossamer_channel_bind` / `gossamer_channel_send` — IPC
- `gossamer_run` / `gossamer_quit` — event loop

## macOS (Scaffold)

Uses WKWebView through Objective-C runtime bindings from Zig.

**Architecture:**
```
Zig (webview_cocoa.zig)
  → objc_msgSend (Objective-C runtime)
    → NSApplication, NSWindow, WKWebView
```

**Remaining work:**
- Code signing and notarisation
- NSMenu for system tray integration
- Touch Bar support (where available)
- DMG packaging

## Windows (Scaffold)

Uses WebView2 through COM interface bindings from Zig.

**Architecture:**
```
Zig (webview_win32.zig)
  → Win32 API (CreateWindowExW)
    → WebView2 COM (ICoreWebView2)
```

**Remaining work:**
- WebView2Loader.dll loading
- COM vtable bindings for ICoreWebView2
- IPC through add_WebMessageReceived
- MSIX packaging

## Mobile (Planned)

Mobile support is planned through Zig FFI bindings to native webview APIs:

- **iOS**: UIKit + WKWebView (same engine as macOS)
- **Android**: JNI + android.webkit.WebView

Until Phase 3, mobile apps use the companion [Tauri 2.0](https://tauri.app/)
backend through `opsm_mobile`.

## Cross-Compilation

Zig's built-in cross-compilation makes targeting multiple platforms
from a single machine practical:

```bash
# Build for macOS from Linux
zig build -Dtarget=aarch64-macos
# Build for Windows from Linux
zig build -Dtarget=x86_64-windows
```

The Zig FFI layer compiles for all targets; platform-specific code
is selected by `@import("builtin").os.tag`.
