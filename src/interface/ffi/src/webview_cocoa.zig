// Gossamer — WKWebView Platform Implementation (macOS) — Phase 2 Stub
//
// Will provide the platform-specific webview operations for macOS using
// Cocoa and WKWebView. This is the Phase 2 implementation.
//
// Dependencies (system frameworks):
//   Cocoa.framework
//   WebKit.framework
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

/// Platform-specific webview state for Cocoa/WKWebView.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// NSWindow pointer (opaque)
    window: ?*anyopaque,
    /// WKWebView pointer (opaque)
    webview: ?*anyopaque,
    /// Whether Cocoa has been initialised
    cocoa_initialized: bool,
};

/// Error type for platform operations.
pub const PlatformError = error{
    CocoaInitFailed,
    WindowCreateFailed,
    WebviewCreateFailed,
    OperationFailed,
};

/// Create a new Cocoa window containing a WKWebView.
/// Must be called from the main thread (Cocoa requirement).
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
) PlatformError!WebviewState {
    // Phase 2: Implement using Objective-C runtime or objc crate
    // Steps:
    // 1. [NSApplication sharedApplication]
    // 2. [[NSWindow alloc] initWithContentRect:...]
    // 3. [[WKWebView alloc] initWithFrame:configuration:]
    // 4. [window setContentView:webview]
    // 5. [window makeKeyAndOrderFront:nil]
    _ = title;
    _ = width;
    _ = height;
    _ = resizable;
    _ = decorations;
    _ = fullscreen;
    return PlatformError.CocoaInitFailed;
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    // Phase 2: [webview loadHTMLString:baseURL:]
    _ = state;
    _ = html;
    return PlatformError.OperationFailed;
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    // Phase 2: [webview loadRequest:[NSURLRequest requestWithURL:...]]
    _ = state;
    _ = url;
    return PlatformError.OperationFailed;
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    // Phase 2: [webview evaluateJavaScript:completionHandler:]
    _ = state;
    _ = js;
    return PlatformError.OperationFailed;
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    // Phase 2: [window setTitle:...]
    _ = state;
    _ = title;
    return PlatformError.OperationFailed;
}

/// Resize the window.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    // Phase 2: [window setFrame:display:]
    _ = state;
    _ = width;
    _ = height;
    return PlatformError.OperationFailed;
}

/// Run the Cocoa event loop. Blocks until the window is closed.
pub fn run(_: *WebviewState) void {
    // Phase 2: [NSApp run]
}

/// Destroy the webview and its window.
pub fn destroy(state: *WebviewState) void {
    // Phase 2: [window close], release objects
    state.cocoa_initialized = false;
}
