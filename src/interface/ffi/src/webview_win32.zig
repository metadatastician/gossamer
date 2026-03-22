// Gossamer — WebView2 Platform Implementation (Windows)
//
// Provides the platform-specific webview operations for Windows using
// Win32 API and WebView2 (Edge/Chromium).
//
// WebView2 is async (COM callbacks), so create() uses an event to block
// until the webview is ready, matching the synchronous C ABI.
//
// Dependencies:
//   WebView2Loader.dll (Microsoft Edge WebView2 Runtime)
//   ole32.lib, user32.lib, kernel32.lib
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");

// Win32 API bindings
const HWND = std.os.windows.HWND;
const HINSTANCE = std.os.windows.HINSTANCE;
const LPARAM = std.os.windows.LPARAM;
const WPARAM = std.os.windows.WPARAM;
const LRESULT = std.os.windows.LRESULT;
const BOOL = std.os.windows.BOOL;

const w = std.os.windows;

// External Win32 function declarations
extern "user32" fn CreateWindowExW(
    dwExStyle: u32,
    lpClassName: ?[*:0]const u16,
    lpWindowName: ?[*:0]const u16,
    dwStyle: u32,
    x: i32,
    y: i32,
    nWidth: i32,
    nHeight: i32,
    hWndParent: ?HWND,
    hMenu: ?*anyopaque,
    hInstance: ?HINSTANCE,
    lpParam: ?*anyopaque,
) callconv(.c) ?HWND;

extern "user32" fn DestroyWindow(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn ShowWindow(hWnd: HWND, nCmdShow: i32) callconv(.c) BOOL;
extern "user32" fn SetWindowTextW(hWnd: HWND, lpString: [*:0]const u16) callconv(.c) BOOL;
extern "user32" fn GetMessageW(lpMsg: *MSG, hWnd: ?HWND, wMsgFilterMin: u32, wMsgFilterMax: u32) callconv(.c) BOOL;
extern "user32" fn TranslateMessage(lpMsg: *const MSG) callconv(.c) BOOL;
extern "user32" fn DispatchMessageW(lpMsg: *const MSG) callconv(.c) LRESULT;
extern "user32" fn DefWindowProcW(hWnd: HWND, uMsg: u32, wParam: WPARAM, lParam: LPARAM) callconv(.c) LRESULT;
extern "user32" fn RegisterClassExW(lpwcx: *const WNDCLASSEXW) callconv(.c) u16;
extern "user32" fn PostQuitMessage(nExitCode: i32) callconv(.c) void;
extern "user32" fn MoveWindow(hWnd: HWND, x: i32, y: i32, nWidth: i32, nHeight: i32, bRepaint: BOOL) callconv(.c) BOOL;

extern "ole32" fn CoInitializeEx(pvReserved: ?*anyopaque, dwCoInit: u32) callconv(.c) i32;
extern "ole32" fn CoUninitialize() callconv(.c) void;

extern "kernel32" fn GetModuleHandleW(lpModuleName: ?[*:0]const u16) callconv(.c) ?HINSTANCE;

const MSG = extern struct {
    hwnd: ?HWND,
    message: u32,
    wParam: WPARAM,
    lParam: LPARAM,
    time: u32,
    pt_x: i32,
    pt_y: i32,
};

const WNDCLASSEXW = extern struct {
    cbSize: u32 = @sizeOf(WNDCLASSEXW),
    style: u32 = 0,
    lpfnWndProc: *const fn (HWND, u32, WPARAM, LPARAM) callconv(.c) LRESULT,
    cbClsExtra: i32 = 0,
    cbWndExtra: i32 = 0,
    hInstance: ?HINSTANCE = null,
    hIcon: ?*anyopaque = null,
    hCursor: ?*anyopaque = null,
    hbrBackground: ?*anyopaque = null,
    lpszMenuName: ?[*:0]const u16 = null,
    lpszClassName: [*:0]const u16,
    hIconSm: ?*anyopaque = null,
};

const WM_DESTROY: u32 = 0x0002;
const WS_OVERLAPPEDWINDOW: u32 = 0x00CF0000;
const WS_VISIBLE: u32 = 0x10000000;
const CW_USEDEFAULT: i32 = @as(i32, @bitCast(@as(u32, 0x80000000)));
const SW_SHOW: i32 = 5;
const COINIT_APARTMENTTHREADED: u32 = 0x2;

/// WebView2 COM interface pointers (opaque — actual types from WebView2.h).
/// These are populated asynchronously by CreateCoreWebView2EnvironmentWithOptions.
const ICoreWebView2 = anyopaque;
const ICoreWebView2Controller = anyopaque;

/// Platform-specific webview state for Win32/WebView2.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// HWND (window handle)
    hwnd: ?HWND,
    /// ICoreWebView2 pointer
    webview: ?*ICoreWebView2,
    /// ICoreWebView2Controller pointer
    controller: ?*ICoreWebView2Controller,
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

/// Opaque reference to GossamerHandle from main.zig.
const GossamerHandle = @import("main.zig").GossamerHandle;

/// Window class name (UTF-16).
const CLASS_NAME = std.unicode.utf8ToUtf16LeStringLiteral("GossamerWindow");

/// Window procedure callback.
fn wndProc(hwnd: HWND, msg: u32, wParam: WPARAM, lParam: LPARAM) callconv(.c) LRESULT {
    switch (msg) {
        WM_DESTROY => {
            PostQuitMessage(0);
            return 0;
        },
        else => return DefWindowProcW(hwnd, msg, wParam, lParam),
    }
}

/// Create a new Win32 window. WebView2 will be attached asynchronously.
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
) PlatformError!WebviewState {
    _ = resizable;
    _ = fullscreen;

    // Initialise COM
    const hr = CoInitializeEx(null, COINIT_APARTMENTTHREADED);
    if (hr < 0) return PlatformError.ComInitFailed;

    const hInstance = GetModuleHandleW(null) orelse return PlatformError.WindowCreateFailed;

    // Register window class
    var wc = WNDCLASSEXW{
        .lpfnWndProc = &wndProc,
        .hInstance = hInstance,
        .lpszClassName = CLASS_NAME,
    };
    wc.cbSize = @sizeOf(WNDCLASSEXW);
    _ = RegisterClassExW(&wc);

    // Convert title to UTF-16
    var title_buf: [256]u16 = undefined;
    const title_slice = std.mem.span(title);
    const title_len = std.unicode.utf8ToUtf16Le(&title_buf, title_slice) catch
        return PlatformError.WindowCreateFailed;
    title_buf[title_len] = 0;
    const title_w: [*:0]const u16 = title_buf[0..title_len :0];

    // Window style
    var style: u32 = WS_VISIBLE;
    if (decorations) {
        style |= WS_OVERLAPPEDWINDOW;
    }

    // Create the window
    const hwnd = CreateWindowExW(
        0,
        CLASS_NAME,
        title_w,
        style,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        @intCast(width),
        @intCast(height),
        null,
        null,
        hInstance,
        null,
    ) orelse return PlatformError.WindowCreateFailed;

    _ = ShowWindow(hwnd, SW_SHOW);

    // WebView2 creation is async via COM callbacks.
    // In a full implementation, we'd call CreateCoreWebView2EnvironmentWithOptions
    // here and use an event/semaphore to block until the webview is ready.
    // For now, the window is created but WebView2 attachment is pending.
    //
    // TODO: Call CreateCoreWebView2EnvironmentWithOptions from WebView2Loader.dll
    // via dlopen/GetProcAddress, create controller + webview in callbacks,
    // signal completion via Windows event object.

    return WebviewState{
        .hwnd = hwnd,
        .webview = null, // Populated async
        .controller = null, // Populated async
        .com_initialized = true,
    };
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    // TODO: ICoreWebView2::NavigateToString(html)
    // Requires WebView2 COM interface vtable bindings
    _ = state;
    _ = html;
    if (state.webview == null) return PlatformError.OperationFailed;
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    // TODO: ICoreWebView2::Navigate(url)
    _ = state;
    _ = url;
    if (state.webview == null) return PlatformError.OperationFailed;
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    // TODO: ICoreWebView2::ExecuteScript(js, handler)
    _ = state;
    _ = js;
    if (state.webview == null) return PlatformError.OperationFailed;
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    var title_buf: [256]u16 = undefined;
    const title_slice = std.mem.span(title);
    const title_len = std.unicode.utf8ToUtf16Le(&title_buf, title_slice) catch
        return PlatformError.OperationFailed;
    title_buf[title_len] = 0;
    const title_w: [*:0]const u16 = title_buf[0..title_len :0];
    _ = SetWindowTextW(hwnd, title_w);
}

/// Resize the window.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = MoveWindow(hwnd, 0, 0, @intCast(width), @intCast(height), 1);
}

/// Run the Win32 message loop. Blocks until the window is closed.
pub fn run(_: *WebviewState) void {
    var msg: MSG = std.mem.zeroes(MSG);
    while (GetMessageW(&msg, null, 0, 0) != 0) {
        _ = TranslateMessage(&msg);
        _ = DispatchMessageW(&msg);
    }
}

/// Destroy the webview and its window.
pub fn destroy(state: *WebviewState) void {
    if (state.com_initialized) {
        if (state.hwnd) |hwnd| {
            _ = DestroyWindow(hwnd);
        }
        CoUninitialize();
        state.hwnd = null;
        state.webview = null;
        state.controller = null;
        state.com_initialized = false;
    }
}

/// Register IPC handler for WebView2.
///
/// Uses ICoreWebView2::add_WebMessageReceived to listen for messages
/// posted via `window.chrome.webview.postMessage(msg)` from JavaScript.
///
/// TODO: Implement COM callback for WebMessageReceived event.
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    // WebView2 IPC uses window.chrome.webview.postMessage()
    // Need to call ICoreWebView2::add_WebMessageReceived with a COM callback
    // that dispatches to handle.bindings by name.
    _ = state;
    _ = handle;
    // Stub — WebView2 COM vtable bindings needed
    if (state.webview == null) return PlatformError.OperationFailed;
}
