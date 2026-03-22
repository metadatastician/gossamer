// Gossamer — WebView2 Platform Implementation (Windows) — Phase 2 Stub
//
// Will provide the platform-specific webview operations for Windows using
// Win32 API and WebView2 (Edge/Chromium). This is the Phase 2 implementation.
//
// Dependencies:
//   WebView2Loader.dll (Microsoft Edge WebView2 Runtime)
//   ole32.lib, comctl32.lib
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

/// Platform-specific webview state for Win32/WebView2.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// HWND (window handle)
    hwnd: ?*anyopaque,
    /// ICoreWebView2 pointer
    webview: ?*anyopaque,
    /// ICoreWebView2Controller pointer
    controller: ?*anyopaque,
    /// Whether COM has been initialised
    com_initialized: bool,
};

/// Error type for platform operations.
pub const PlatformError = error{
    ComInitFailed,
    WindowCreateFailed,
    WebviewCreateFailed,
    OperationFailed,
};

/// Create a new Win32 window containing a WebView2 control.
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
) PlatformError!WebviewState {
    // Phase 2: Implement using Win32 API
    // Steps:
    // 1. CoInitializeEx(NULL, COINIT_APARTMENTTHREADED)
    // 2. RegisterClassEx + CreateWindowEx
    // 3. CreateCoreWebView2EnvironmentWithOptions
    // 4. CreateCoreWebView2Controller
    // 5. ShowWindow
    _ = title;
    _ = width;
    _ = height;
    _ = resizable;
    _ = decorations;
    _ = fullscreen;
    return PlatformError.ComInitFailed;
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    // Phase 2: ICoreWebView2::NavigateToString(html)
    _ = state;
    _ = html;
    return PlatformError.OperationFailed;
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    // Phase 2: ICoreWebView2::Navigate(url)
    _ = state;
    _ = url;
    return PlatformError.OperationFailed;
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    // Phase 2: ICoreWebView2::ExecuteScript(js, handler)
    _ = state;
    _ = js;
    return PlatformError.OperationFailed;
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    // Phase 2: SetWindowText(hwnd, title)
    _ = state;
    _ = title;
    return PlatformError.OperationFailed;
}

/// Resize the window.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    // Phase 2: SetWindowPos or MoveWindow
    _ = state;
    _ = width;
    _ = height;
    return PlatformError.OperationFailed;
}

/// Run the Win32 message loop. Blocks until the window is closed.
pub fn run(_: *WebviewState) void {
    // Phase 2: GetMessage/TranslateMessage/DispatchMessage loop
}

/// Destroy the webview and its window.
pub fn destroy(state: *WebviewState) void {
    // Phase 2: DestroyWindow, release COM objects, CoUninitialize
    state.com_initialized = false;
}
