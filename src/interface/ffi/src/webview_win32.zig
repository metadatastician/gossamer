// Gossamer — WebView2 Platform Implementation (Windows)
//
// Provides the platform-specific webview operations for Windows using
// Win32 API and WebView2 (Edge/Chromium).
//
// WebView2 is async (COM callbacks), so create() uses a Windows event
// object to block until the webview environment is ready, matching the
// synchronous C ABI contract.
//
// Architecture:
//   1. Win32 window created via CreateWindowExW (standard)
//   2. WebView2Loader.dll loaded via LoadLibraryW / GetProcAddress
//   3. CreateCoreWebView2EnvironmentWithOptions called (async)
//   4. COM callback receives ICoreWebView2Environment
//   5. Environment::CreateCoreWebView2Controller called (async)
//   6. COM callback receives ICoreWebView2Controller + ICoreWebView2
//   7. Windows event signalled → create() returns with populated state
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
const HRESULT = i32;
const GUID = extern struct { d1: u32, d2: u16, d3: u16, d4: [8]u8 };
const HANDLE = *anyopaque;
const HMODULE = ?*anyopaque;
const LPCWSTR = [*:0]const u16;
const LPWSTR = [*:0]u16;

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
extern "user32" fn GetClientRect(hWnd: HWND, lpRect: *RECT) callconv(.c) BOOL;
extern "user32" fn SetForegroundWindow(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn BringWindowToTop(hWnd: HWND) callconv(.c) BOOL;
extern "user32" fn SetWindowPos(hWnd: HWND, hWndInsertAfter: ?HWND, x: i32, y: i32, cx: i32, cy: i32, uFlags: u32) callconv(.c) BOOL;

const HWND_BOTTOM: ?HWND = @ptrFromInt(1);
const SWP_NOMOVE: u32 = 0x0002;
const SWP_NOSIZE: u32 = 0x0001;
const SWP_NOACTIVATE: u32 = 0x0010;
const SWP_NOZORDER: u32 = 0x0004;

extern "ole32" fn CoInitializeEx(pvReserved: ?*anyopaque, dwCoInit: u32) callconv(.c) HRESULT;
extern "ole32" fn CoUninitialize() callconv(.c) void;

extern "kernel32" fn GetModuleHandleW(lpModuleName: ?[*:0]const u16) callconv(.c) ?HINSTANCE;
extern "kernel32" fn LoadLibraryW(lpLibFileName: [*:0]const u16) callconv(.c) HMODULE;
extern "kernel32" fn GetProcAddress(hModule: *anyopaque, lpProcName: [*:0]const u8) callconv(.c) ?*anyopaque;
extern "kernel32" fn CreateEventW(lpEventAttributes: ?*anyopaque, bManualReset: BOOL, bInitialState: BOOL, lpName: ?[*:0]const u16) callconv(.c) ?HANDLE;
extern "kernel32" fn SetEvent(hEvent: HANDLE) callconv(.c) BOOL;
extern "kernel32" fn WaitForSingleObject(hHandle: HANDLE, dwMilliseconds: u32) callconv(.c) u32;
extern "kernel32" fn CloseHandle(hObject: HANDLE) callconv(.c) BOOL;

const MSG = extern struct {
    hwnd: ?HWND,
    message: u32,
    wParam: WPARAM,
    lParam: LPARAM,
    time: u32,
    pt_x: i32,
    pt_y: i32,
};

const RECT = extern struct {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,
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
const WM_SIZE: u32 = 0x0005;
const WM_GETMINMAXINFO: u32 = 0x0024;
const WS_OVERLAPPEDWINDOW: u32 = 0x00CF0000;
const WS_VISIBLE: u32 = 0x10000000;
const CW_USEDEFAULT: i32 = @as(i32, @bitCast(@as(u32, 0x80000000)));
const SW_HIDE: i32 = 0;
const SW_SHOW: i32 = 5;
const SW_MINIMIZE: i32 = 6;
const SW_RESTORE: i32 = 9;
const SW_MAXIMIZE: i32 = 3;
const COINIT_APARTMENTTHREADED: u32 = 0x2;
const WAIT_OBJECT_0: u32 = 0;
const INFINITE: u32 = 0xFFFFFFFF;
const S_OK: HRESULT = 0;

const POINT = extern struct {
    x: i32,
    y: i32,
};

const MINMAXINFO = extern struct {
    ptReserved: POINT,
    ptMaxSize: POINT,
    ptMaxPosition: POINT,
    ptMinTrackSize: POINT,
    ptMaxTrackSize: POINT,
};

const WindowConstraints = struct {
    min_width: u32 = 0,
    min_height: u32 = 0,
    max_width: u32 = 0,
    max_height: u32 = 0,
};

threadlocal var window_constraints: WindowConstraints = .{};

//==============================================================================
// WebView2 COM Interface Definitions (Vtable-based)
//==============================================================================

/// IUnknown vtable — base for all COM interfaces.
const IUnknownVtbl = extern struct {
    QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
    AddRef: *const fn (*anyopaque) callconv(.c) u32,
    Release: *const fn (*anyopaque) callconv(.c) u32,
};

/// ICoreWebView2Environment — creates controllers and webviews.
/// We only use CreateCoreWebView2Controller from this interface.
const ICoreWebView2EnvironmentVtbl = extern struct {
    // IUnknown (3 methods)
    QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
    AddRef: *const fn (*anyopaque) callconv(.c) u32,
    Release: *const fn (*anyopaque) callconv(.c) u32,
    // ICoreWebView2Environment (1 method we use)
    CreateCoreWebView2Controller: *const fn (*anyopaque, ?HWND, ?*anyopaque) callconv(.c) HRESULT,
};

/// ICoreWebView2Controller — manages the webview display.
/// We use put_Bounds and get_CoreWebView2.
const ICoreWebView2ControllerVtbl = extern struct {
    // IUnknown (3)
    QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
    AddRef: *const fn (*anyopaque) callconv(.c) u32,
    Release: *const fn (*anyopaque) callconv(.c) u32,
    // ICoreWebView2Controller
    get_IsVisible: *const fn (*anyopaque, *BOOL) callconv(.c) HRESULT,
    put_IsVisible: *const fn (*anyopaque, BOOL) callconv(.c) HRESULT,
    get_Bounds: *const fn (*anyopaque, *RECT) callconv(.c) HRESULT,
    put_Bounds: *const fn (*anyopaque, RECT) callconv(.c) HRESULT,
    get_ZoomFactor: *const fn (*anyopaque, *f64) callconv(.c) HRESULT,
    put_ZoomFactor: *const fn (*anyopaque, f64) callconv(.c) HRESULT,
    // ... (skipping event handlers we don't use)
    add_ZoomFactorChanged: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_ZoomFactorChanged: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    SetBoundsAndZoomFactor: *const fn (*anyopaque, RECT, f64) callconv(.c) HRESULT,
    MoveFocus: *const fn (*anyopaque, i32) callconv(.c) HRESULT,
    add_MoveFocusRequested: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_MoveFocusRequested: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_GotFocus: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_GotFocus: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_LostFocus: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_LostFocus: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_AcceleratorKeyPressed: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_AcceleratorKeyPressed: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    get_ParentWindow: *const fn (*anyopaque, *?HWND) callconv(.c) HRESULT,
    put_ParentWindow: *const fn (*anyopaque, ?HWND) callconv(.c) HRESULT,
    NotifyParentWindowPositionChanged: *const fn (*anyopaque) callconv(.c) HRESULT,
    Close: *const fn (*anyopaque) callconv(.c) HRESULT,
    get_CoreWebView2: *const fn (*anyopaque, *?*anyopaque) callconv(.c) HRESULT,
};

/// ICoreWebView2 — the core webview interface.
/// Navigate, NavigateToString, ExecuteScript, add_WebMessageReceived.
const ICoreWebView2Vtbl = extern struct {
    // IUnknown (3)
    QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
    AddRef: *const fn (*anyopaque) callconv(.c) u32,
    Release: *const fn (*anyopaque) callconv(.c) u32,
    // ICoreWebView2 settings/source
    get_Settings: *const fn (*anyopaque, *?*anyopaque) callconv(.c) HRESULT,
    get_Source: *const fn (*anyopaque, *?LPWSTR) callconv(.c) HRESULT,
    Navigate: *const fn (*anyopaque, LPCWSTR) callconv(.c) HRESULT,
    NavigateToString: *const fn (*anyopaque, LPCWSTR) callconv(.c) HRESULT,
    // Events
    add_NavigationStarting: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_NavigationStarting: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_ContentLoading: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_ContentLoading: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_SourceChanged: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_SourceChanged: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_HistoryChanged: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_HistoryChanged: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_NavigationCompleted: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_NavigationCompleted: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_FrameNavigationStarting: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_FrameNavigationStarting: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_FrameNavigationCompleted: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_FrameNavigationCompleted: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_ScriptDialogOpening: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_ScriptDialogOpening: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_PermissionRequested: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_PermissionRequested: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    add_ProcessFailed: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_ProcessFailed: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
    AddScriptToExecuteOnDocumentCreated: *const fn (*anyopaque, LPCWSTR, ?*anyopaque) callconv(.c) HRESULT,
    RemoveScriptToExecuteOnDocumentCreated: *const fn (*anyopaque, LPCWSTR) callconv(.c) HRESULT,
    ExecuteScript: *const fn (*anyopaque, LPCWSTR, ?*anyopaque) callconv(.c) HRESULT,
    CapturePreview: *const fn (*anyopaque, i32, ?*anyopaque, ?*anyopaque) callconv(.c) HRESULT,
    Reload: *const fn (*anyopaque) callconv(.c) HRESULT,
    PostWebMessageAsJson: *const fn (*anyopaque, LPCWSTR) callconv(.c) HRESULT,
    PostWebMessageAsString: *const fn (*anyopaque, LPCWSTR) callconv(.c) HRESULT,
    add_WebMessageReceived: *const fn (*anyopaque, ?*anyopaque, *i64) callconv(.c) HRESULT,
    remove_WebMessageReceived: *const fn (*anyopaque, i64) callconv(.c) HRESULT,
};

/// COM interface pointer — points to a vtable pointer.
fn ComPtr(comptime VtblType: type) type {
    return *align(1) const struct {
        vtbl: *const VtblType,
    };
}

//==============================================================================
// Platform State
//==============================================================================

/// Platform-specific webview state for Win32/WebView2.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// HWND (window handle)
    hwnd: ?HWND,
    /// ICoreWebView2 pointer (populated asynchronously)
    webview: ?*anyopaque,
    /// ICoreWebView2Controller pointer (populated asynchronously)
    controller: ?*anyopaque,
    /// Whether COM has been initialised
    com_initialized: bool,
    /// WebView2Loader.dll handle
    loader_handle: HMODULE,
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

//==============================================================================
// UTF-8 to UTF-16 Conversion Helper
//==============================================================================

/// Convert a null-terminated UTF-8 string to a stack-allocated UTF-16 buffer.
/// Returns a null-terminated UTF-16 slice, or null on failure.
fn utf8ToUtf16(input: [*:0]const u8, buf: []u16) ?[*:0]const u16 {
    const slice = std.mem.span(input);
    const len = std.unicode.utf8ToUtf16Le(buf, slice) catch return null;
    if (len >= buf.len) return null;
    buf[len] = 0;
    return buf[0..len :0];
}

//==============================================================================
// WebView2 Vtable Accessors
//==============================================================================

/// Get the ICoreWebView2 vtable from an opaque pointer.
fn wv2Vtbl(ptr: *anyopaque) *const ICoreWebView2Vtbl {
    const com: *const struct { vtbl: *const ICoreWebView2Vtbl } = @ptrCast(@alignCast(ptr));
    return com.vtbl;
}

/// Get the ICoreWebView2Controller vtable from an opaque pointer.
fn controllerVtbl(ptr: *anyopaque) *const ICoreWebView2ControllerVtbl {
    const com: *const struct { vtbl: *const ICoreWebView2ControllerVtbl } = @ptrCast(@alignCast(ptr));
    return com.vtbl;
}

//==============================================================================
// Window Procedure
//==============================================================================

/// Window procedure callback.
fn wndProc(hwnd: HWND, msg: u32, wParam: WPARAM, lParam: LPARAM) callconv(.c) LRESULT {
    switch (msg) {
        WM_GETMINMAXINFO => {
            const mmi: *MINMAXINFO = @ptrFromInt(@as(usize, @intCast(lParam)));

            if (window_constraints.min_width != 0) {
                mmi.ptMinTrackSize.x = @intCast(window_constraints.min_width);
            }
            if (window_constraints.min_height != 0) {
                mmi.ptMinTrackSize.y = @intCast(window_constraints.min_height);
            }
            if (window_constraints.max_width != 0) {
                mmi.ptMaxTrackSize.x = @intCast(window_constraints.max_width);
            }
            if (window_constraints.max_height != 0) {
                mmi.ptMaxTrackSize.y = @intCast(window_constraints.max_height);
            }

            return 0;
        },
        WM_DESTROY => {
            PostQuitMessage(0);
            return 0;
        },
        else => return DefWindowProcW(hwnd, msg, wParam, lParam),
    }
}

//==============================================================================
// Platform API Implementation
//==============================================================================

/// Create a new Win32 window and initialise WebView2.
///
/// Loads WebView2Loader.dll dynamically and calls
/// CreateCoreWebView2EnvironmentWithOptions. The function blocks
/// (via a Windows event object) until the WebView2 environment and
/// controller are fully initialised.
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    min_width: u32,
    min_height: u32,
    max_width: u32,
    max_height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
    visible: bool,
) PlatformError!WebviewState {
    _ = resizable;
    _ = fullscreen;

    // Initialise COM (apartment-threaded for UI)
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
    const title_w = utf8ToUtf16(title, &title_buf) orelse
        return PlatformError.WindowCreateFailed;

    // Window style
    var style: u32 = WS_VISIBLE;
    if (decorations) {
        style |= WS_OVERLAPPEDWINDOW;
    }
    if (visible) {
        style |= WS_VISIBLE;
    }

    window_constraints = .{
        .min_width = min_width,
        .min_height = min_height,
        .max_width = max_width,
        .max_height = max_height,
    };

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

    if (visible) {
        _ = ShowWindow(hwnd, SW_SHOW);
    }

    // Load WebView2Loader.dll dynamically.
    // This DLL is part of the Microsoft Edge WebView2 Runtime.
    const loader_name = std.unicode.utf8ToUtf16LeStringLiteral("WebView2Loader.dll");
    const loader = LoadLibraryW(loader_name);

    var state = WebviewState{
        .hwnd = hwnd,
        .webview = null,
        .controller = null,
        .com_initialized = true,
        .loader_handle = loader,
    };

    // If WebView2Loader.dll is available, initialise WebView2 synchronously.
    // Uses a Windows event object to block until the async COM callbacks complete.
    // If the loader is not available, the window exists but webview operations
    // will return errors (graceful degradation for systems without Edge WebView2 Runtime).
    if (loader) |loader_dll| {
        const create_fn_ptr = GetProcAddress(
            loader_dll,
            "CreateCoreWebView2EnvironmentWithOptions",
        );
        if (create_fn_ptr) |raw_fn| {
            // Cast to the correct function signature.
            // CreateCoreWebView2EnvironmentWithOptions(
            //   browserDir: ?LPCWSTR,
            //   userDataDir: ?LPCWSTR,
            //   options: ?*anyopaque,
            //   handler: *anyopaque  // ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
            // ) -> HRESULT
            const CreateEnvFn = *const fn (
                ?LPCWSTR,
                ?LPCWSTR,
                ?*anyopaque,
                *anyopaque,
            ) callconv(.c) HRESULT;
            const create_env_fn: CreateEnvFn = @ptrCast(raw_fn);

            // Create an event to synchronise the async COM callbacks.
            // The callback chain signals this event when initialisation completes.
            const ready_event = CreateEventW(null, 1, 0, null);
            if (ready_event) |event| {
                // Store the pending state in thread-local storage so
                // the COM callbacks can write back into our state struct.
                pending_state = &state;
                pending_hwnd = hwnd;
                pending_event = event;

                // Allocate the environment-completed handler on the heap.
                // COM AddRef/Release manage the lifetime.
                const env_handler = std.heap.c_allocator.create(EnvCompletedHandler) catch {
                    _ = CloseHandle(event);
                    return state;
                };
                env_handler.* = EnvCompletedHandler{};

                // Call CreateCoreWebView2EnvironmentWithOptions.
                // This is asynchronous — it returns immediately and invokes
                // the handler when the environment is ready.
                const hr2 = create_env_fn(null, null, null, @ptrCast(env_handler));
                if (hr2 == S_OK) {
                    // Block until the callback chain signals the event.
                    // Timeout after 10 seconds to prevent infinite hangs.
                    _ = WaitForSingleObject(event, 10000);
                }

                _ = CloseHandle(event);
                pending_state = null;
                pending_hwnd = null;
                pending_event = null;
            }
        }
    }

    return state;
}

/// Load HTML content into the webview.
///
/// Calls ICoreWebView2::NavigateToString with the UTF-16 encoded HTML.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    const wv = state.webview orelse return PlatformError.OperationFailed;
    const vtbl = wv2Vtbl(wv);

    // Convert HTML to UTF-16 (allocate for potentially large content)
    var html_buf: [32768]u16 = undefined;
    const html_w = utf8ToUtf16(html, &html_buf) orelse
        return PlatformError.OperationFailed;

    const hr = vtbl.NavigateToString(wv, html_w);
    if (hr != S_OK) return PlatformError.OperationFailed;
}

/// Navigate the webview to a URL.
///
/// Calls ICoreWebView2::Navigate with the UTF-16 encoded URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    const wv = state.webview orelse return PlatformError.OperationFailed;
    const vtbl = wv2Vtbl(wv);

    var url_buf: [4096]u16 = undefined;
    const url_w = utf8ToUtf16(url, &url_buf) orelse
        return PlatformError.OperationFailed;

    const hr = vtbl.Navigate(wv, url_w);
    if (hr != S_OK) return PlatformError.OperationFailed;
}

/// Evaluate JavaScript in the webview context.
///
/// Calls ICoreWebView2::ExecuteScript with the UTF-16 encoded JS.
/// The callback parameter is null (fire-and-forget execution).
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    const wv = state.webview orelse return PlatformError.OperationFailed;
    const vtbl = wv2Vtbl(wv);

    var js_buf: [65536]u16 = undefined;
    const js_w = utf8ToUtf16(js, &js_buf) orelse
        return PlatformError.OperationFailed;

    const hr = vtbl.ExecuteScript(wv, js_w, null);
    if (hr != S_OK) return PlatformError.OperationFailed;
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    var title_buf: [256]u16 = undefined;
    const title_w = utf8ToUtf16(title, &title_buf) orelse
        return PlatformError.OperationFailed;
    _ = SetWindowTextW(hwnd, title_w);
}

/// Resize the window and update WebView2 controller bounds.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = MoveWindow(hwnd, 0, 0, @intCast(width), @intCast(height), 1);

    // Update WebView2 controller bounds to match new window size
    if (state.controller) |ctrl| {
        const vtbl = controllerVtbl(ctrl);
        const bounds = RECT{
            .left = 0,
            .top = 0,
            .right = @intCast(width),
            .bottom = @intCast(height),
        };
        _ = vtbl.put_Bounds(ctrl, bounds);
    }
}

/// Show the window.
pub fn show(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = ShowWindow(hwnd, SW_SHOW);
}

/// Hide the window.
pub fn hide(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = ShowWindow(hwnd, SW_HIDE);
}

/// Minimize the window.
pub fn minimize(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = ShowWindow(hwnd, SW_MINIMIZE);
}

/// Maximize the window.
pub fn maximize(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = ShowWindow(hwnd, SW_MAXIMIZE);
}

/// Restore the window.
pub fn restore(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = ShowWindow(hwnd, SW_RESTORE);
}

/// Register a persistent user script (re-injected on every page load).
pub fn addUserScript(_: *WebviewState, _: [*:0]const u8) PlatformError!void {
    // TODO: Use ICoreWebView2.AddScriptToExecuteOnDocumentCreated on Windows
}

/// Raise the window to the front of the z-order.
pub fn raise(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = SetForegroundWindow(hwnd);
    _ = BringWindowToTop(hwnd);
}

/// Lower the window to the back of the z-order.
pub fn lower(state: *WebviewState) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = SetWindowPos(hwnd, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
}

/// Move the window to absolute screen coordinates.
pub fn moveTo(state: *WebviewState, x: i32, y: i32) PlatformError!void {
    const hwnd = state.hwnd orelse return PlatformError.OperationFailed;
    _ = SetWindowPos(hwnd, null, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

/// Request that the window close.
pub fn requestClose(state: *WebviewState) PlatformError!void {
    if (state.hwnd) |hwnd| {
        if (DestroyWindow(hwnd) == 0) {
            return PlatformError.OperationFailed;
        }
        state.hwnd = null;
    }
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
        // Release WebView2 COM objects
        if (state.controller) |ctrl| {
            const vtbl = controllerVtbl(ctrl);
            _ = vtbl.Close(ctrl);
            _ = vtbl.Release(ctrl);
        }
        if (state.webview) |wv| {
            const unk: *const struct { vtbl: *const IUnknownVtbl } = @ptrCast(@alignCast(wv));
            _ = unk.vtbl.Release(wv);
        }

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
/// Messages are dispatched to the GossamerHandle's bindings map.
///
/// The handler is a COM object implementing ICoreWebView2WebMessageReceivedEventHandler.
/// When JavaScript calls `window.chrome.webview.postMessage(msg)`, the Invoke
/// method is called with the message args. We extract the JSON string, parse it,
/// look up the command name in the bindings map, invoke the callback, and send
/// the response back via ExecuteScript.
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    const wv = state.webview orelse return PlatformError.OperationFailed;
    const vtbl = wv2Vtbl(wv);

    // Store the handle in thread-local storage for the callback.
    // WebView2 is single-threaded (STA), so thread-local is safe.
    ipc_handle = handle;

    // Allocate the WebMessageReceived event handler COM object.
    const msg_handler = std.heap.c_allocator.create(WebMessageHandler) catch
        return PlatformError.OperationFailed;
    msg_handler.* = WebMessageHandler{};

    var token: i64 = 0;
    const hr = vtbl.add_WebMessageReceived(wv, @ptrCast(msg_handler), &token);
    if (hr != S_OK) {
        std.heap.c_allocator.destroy(msg_handler);
        return PlatformError.OperationFailed;
    }
}

//==============================================================================
// COM Callback Handlers for WebView2 Initialisation
//==============================================================================
//
// WebView2 initialisation is asynchronous via COM callbacks:
//   1. CreateCoreWebView2EnvironmentWithOptions calls EnvCompletedHandler.Invoke
//   2. EnvCompletedHandler calls env.CreateCoreWebView2Controller
//   3. ControllerCompletedHandler.Invoke receives the controller + webview
//   4. Controller.get_CoreWebView2 extracts the ICoreWebView2
//   5. Controller.put_Bounds sets the webview to fill the window
//   6. The ready event is signalled, unblocking create()
//
// Each handler implements a minimal COM interface (QueryInterface/AddRef/Release/Invoke).

/// Thread-local state for the WebView2 initialisation callback chain.
/// Set by create(), read by COM callbacks, cleared after WaitForSingleObject.
var pending_state: ?*WebviewState = null;
var pending_hwnd: ?HWND = null;
var pending_event: ?HANDLE = null;

/// ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler.
/// COM callback invoked when the WebView2 environment is ready.
const EnvCompletedHandler = extern struct {
    vtbl_ptr: *const EnvCompletedVtbl = &env_completed_vtbl,
    ref_count: u32 = 1,

    const EnvCompletedVtbl = extern struct {
        QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
        AddRef: *const fn (*anyopaque) callconv(.c) u32,
        Release: *const fn (*anyopaque) callconv(.c) u32,
        Invoke: *const fn (*anyopaque, HRESULT, ?*anyopaque) callconv(.c) HRESULT,
    };

    const env_completed_vtbl = EnvCompletedVtbl{
        .QueryInterface = &envQueryInterface,
        .AddRef = &envAddRef,
        .Release = &envRelease,
        .Invoke = &envInvoke,
    };

    fn envQueryInterface(_: *anyopaque, _: *const GUID, ppv: *?*anyopaque) callconv(.c) HRESULT {
        ppv.* = null;
        return @as(HRESULT, @bitCast(@as(u32, 0x80004002))); // E_NOINTERFACE
    }

    fn envAddRef(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *EnvCompletedHandler = @ptrCast(@alignCast(self_raw));
        self.ref_count += 1;
        return self.ref_count;
    }

    fn envRelease(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *EnvCompletedHandler = @ptrCast(@alignCast(self_raw));
        if (self.ref_count > 0) self.ref_count -= 1;
        if (self.ref_count == 0) {
            std.heap.c_allocator.destroy(self);
            return 0;
        }
        return self.ref_count;
    }

    /// Called when the WebView2 environment is created.
    /// Asks the environment to create a controller (the next async step).
    fn envInvoke(_: *anyopaque, result_hr: HRESULT, env_raw: ?*anyopaque) callconv(.c) HRESULT {
        if (result_hr != S_OK) {
            // Environment creation failed — signal the event so create() unblocks
            if (pending_event) |event| _ = SetEvent(event);
            return S_OK;
        }

        const env = env_raw orelse {
            if (pending_event) |event| _ = SetEvent(event);
            return S_OK;
        };

        // Allocate the controller-completed handler
        const ctrl_handler = std.heap.c_allocator.create(ControllerCompletedHandler) catch {
            if (pending_event) |event| _ = SetEvent(event);
            return S_OK;
        };
        ctrl_handler.* = ControllerCompletedHandler{};

        // ICoreWebView2Environment::CreateCoreWebView2Controller(hwnd, handler)
        const env_vtbl: *const ICoreWebView2EnvironmentVtbl = blk: {
            const com: *const struct { vtbl: *const ICoreWebView2EnvironmentVtbl } =
                @ptrCast(@alignCast(env));
            break :blk com.vtbl;
        };
        const hr = env_vtbl.CreateCoreWebView2Controller(env, pending_hwnd, @ptrCast(ctrl_handler));
        if (hr != S_OK) {
            std.heap.c_allocator.destroy(ctrl_handler);
            if (pending_event) |event| _ = SetEvent(event);
        }

        return S_OK;
    }
};

/// ICoreWebView2CreateCoreWebView2ControllerCompletedHandler.
/// COM callback invoked when the WebView2 controller is ready.
const ControllerCompletedHandler = extern struct {
    vtbl_ptr: *const CtrlCompletedVtbl = &ctrl_completed_vtbl,
    ref_count: u32 = 1,

    const CtrlCompletedVtbl = extern struct {
        QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
        AddRef: *const fn (*anyopaque) callconv(.c) u32,
        Release: *const fn (*anyopaque) callconv(.c) u32,
        Invoke: *const fn (*anyopaque, HRESULT, ?*anyopaque) callconv(.c) HRESULT,
    };

    const ctrl_completed_vtbl = CtrlCompletedVtbl{
        .QueryInterface = &ctrlQueryInterface,
        .AddRef = &ctrlAddRef,
        .Release = &ctrlRelease,
        .Invoke = &ctrlInvoke,
    };

    fn ctrlQueryInterface(_: *anyopaque, _: *const GUID, ppv: *?*anyopaque) callconv(.c) HRESULT {
        ppv.* = null;
        return @as(HRESULT, @bitCast(@as(u32, 0x80004002))); // E_NOINTERFACE
    }

    fn ctrlAddRef(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *ControllerCompletedHandler = @ptrCast(@alignCast(self_raw));
        self.ref_count += 1;
        return self.ref_count;
    }

    fn ctrlRelease(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *ControllerCompletedHandler = @ptrCast(@alignCast(self_raw));
        if (self.ref_count > 0) self.ref_count -= 1;
        if (self.ref_count == 0) {
            std.heap.c_allocator.destroy(self);
            return 0;
        }
        return self.ref_count;
    }

    /// Called when the WebView2 controller is created.
    /// Extracts ICoreWebView2, sets bounds, and signals the ready event.
    fn ctrlInvoke(_: *anyopaque, result_hr: HRESULT, controller_raw: ?*anyopaque) callconv(.c) HRESULT {
        defer {
            // Always signal the event so create() unblocks
            if (pending_event) |event| _ = SetEvent(event);
        }

        if (result_hr != S_OK) return S_OK;
        const controller = controller_raw orelse return S_OK;
        const state = pending_state orelse return S_OK;
        const hwnd = pending_hwnd orelse return S_OK;

        // Store the controller
        state.controller = controller;

        // Extract ICoreWebView2 from the controller
        const ctrl_vtbl = controllerVtbl(controller);
        var wv_ptr: ?*anyopaque = null;
        const hr = ctrl_vtbl.get_CoreWebView2(controller, &wv_ptr);
        if (hr == S_OK) {
            state.webview = wv_ptr;
        }

        // Set the webview bounds to fill the client area of the window
        var rect: RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 };
        _ = GetClientRect(hwnd, &rect);
        _ = ctrl_vtbl.put_Bounds(controller, rect);

        return S_OK;
    }
};

//==============================================================================
// WebMessageReceived Event Handler (IPC)
//==============================================================================
//
// COM object implementing ICoreWebView2WebMessageReceivedEventHandler.
// Dispatches incoming IPC messages from JavaScript to the bound callbacks.

/// Thread-local handle for IPC dispatch. Set by registerIPCHandler.
var ipc_handle: ?*GossamerHandle = null;

/// ICoreWebView2WebMessageReceivedEventHandler implementation.
/// Receives messages posted via `window.chrome.webview.postMessage(msg)`.
const WebMessageHandler = extern struct {
    vtbl_ptr: *const WebMsgVtbl = &web_msg_vtbl,
    ref_count: u32 = 1,

    const WebMsgVtbl = extern struct {
        QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
        AddRef: *const fn (*anyopaque) callconv(.c) u32,
        Release: *const fn (*anyopaque) callconv(.c) u32,
        Invoke: *const fn (*anyopaque, ?*anyopaque, ?*anyopaque) callconv(.c) HRESULT,
    };

    const web_msg_vtbl = WebMsgVtbl{
        .QueryInterface = &msgQueryInterface,
        .AddRef = &msgAddRef,
        .Release = &msgRelease,
        .Invoke = &msgInvoke,
    };

    fn msgQueryInterface(_: *anyopaque, _: *const GUID, ppv: *?*anyopaque) callconv(.c) HRESULT {
        ppv.* = null;
        return @as(HRESULT, @bitCast(@as(u32, 0x80004002))); // E_NOINTERFACE
    }

    fn msgAddRef(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *WebMessageHandler = @ptrCast(@alignCast(self_raw));
        self.ref_count += 1;
        return self.ref_count;
    }

    fn msgRelease(self_raw: *anyopaque) callconv(.c) u32 {
        const self: *WebMessageHandler = @ptrCast(@alignCast(self_raw));
        if (self.ref_count > 0) self.ref_count -= 1;
        if (self.ref_count == 0) {
            std.heap.c_allocator.destroy(self);
            return 0;
        }
        return self.ref_count;
    }

    /// Called when JavaScript posts a message via chrome.webview.postMessage().
    /// Extracts the JSON message, parses {id, name, payload}, dispatches to
    /// the registered callback, and sends the response back via ExecuteScript.
    fn msgInvoke(_: *anyopaque, _: ?*anyopaque, args_raw: ?*anyopaque) callconv(.c) HRESULT {
        const handle = ipc_handle orelse return S_OK;
        const args = args_raw orelse return S_OK;

        // ICoreWebView2WebMessageReceivedEventArgs::TryGetWebMessageAsString
        // Vtable layout: IUnknown (3) + get_Source (1) + TryGetWebMessageAsString (1)
        const ArgsVtbl = extern struct {
            // IUnknown
            QueryInterface: *const fn (*anyopaque, *const GUID, *?*anyopaque) callconv(.c) HRESULT,
            AddRef: *const fn (*anyopaque) callconv(.c) u32,
            Release: *const fn (*anyopaque) callconv(.c) u32,
            // ICoreWebView2WebMessageReceivedEventArgs
            get_Source: *const fn (*anyopaque, *?LPWSTR) callconv(.c) HRESULT,
            TryGetWebMessageAsString: *const fn (*anyopaque, *?LPWSTR) callconv(.c) HRESULT,
        };

        const args_com: *const struct { vtbl: *const ArgsVtbl } = @ptrCast(@alignCast(args));
        var msg_ptr: ?LPWSTR = null;
        const hr = args_com.vtbl.TryGetWebMessageAsString(args, &msg_ptr);
        if (hr != S_OK) return S_OK;
        const msg_w = msg_ptr orelse return S_OK;

        // Convert UTF-16 message to UTF-8
        const allocator = std.heap.c_allocator;
        var utf8_buf: [65536]u8 = undefined;
        const msg_len = blk: {
            var i: usize = 0;
            while (msg_w[i] != 0 and i < 32768) : (i += 1) {}
            break :blk i;
        };
        const utf16_slice = msg_w[0..msg_len];
        const utf8_len = std.unicode.utf16LeToUtf8(&utf8_buf, utf16_slice) catch return S_OK;
        const msg_slice = utf8_buf[0..utf8_len];

        // Parse JSON fields
        const id = extractJsonField(msg_slice, "id") orelse return S_OK;
        const name = extractJsonField(msg_slice, "name") orelse {
            sendIPCError(handle, id, "Missing 'name' field in IPC message");
            return S_OK;
        };
        const payload = extractJsonField(msg_slice, "payload") orelse "";

        // Look up the binding
        const callback = handle.bindings.get(name) orelse {
            sendIPCError(handle, id, "No handler bound for command");
            return S_OK;
        };

        // Invoke the callback
        const payload_z = allocator.dupeZ(u8, payload) catch return S_OK;
        defer allocator.free(payload_z);

        const response_ptr = callback.callback(payload_z, callback.user_data);
        const response = std.mem.span(response_ptr);
        sendIPCResponse(handle, id, response);

        return S_OK;
    }
};

//==============================================================================
// IPC Response Helpers (Windows)
//==============================================================================

/// Send a success response back to the JavaScript IPC bridge.
fn sendIPCResponse(handle: *GossamerHandle, id: []const u8, response: []const u8) void {
    const allocator = std.heap.c_allocator;
    const escaped = escapeForJS(allocator, response) catch return;
    defer allocator.free(escaped);
    const js = std.fmt.allocPrintZ(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].resolve(JSON.parse(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, escaped, id },
    ) catch return;
    defer allocator.free(js);
    eval(&handle.webview, js) catch {};
}

/// Send an error response back to the JavaScript IPC bridge.
fn sendIPCError(handle: *GossamerHandle, id: []const u8, msg_text: []const u8) void {
    const allocator = std.heap.c_allocator;
    const js = std.fmt.allocPrintZ(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].reject(new Error(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, msg_text, id },
    ) catch return;
    defer allocator.free(js);
    eval(&handle.webview, js) catch {};
}

/// Extract a JSON string field value by key name.
fn extractJsonField(json: []const u8, key: []const u8) ?[]const u8 {
    const allocator = std.heap.c_allocator;
    const search = std.fmt.allocPrint(allocator, "\"{s}\":\"", .{key}) catch return null;
    defer allocator.free(search);
    const start_idx = std.mem.indexOf(u8, json, search) orelse return null;
    const value_start = start_idx + search.len;
    var i: usize = value_start;
    while (i < json.len) : (i += 1) {
        if (json[i] == '"' and (i == 0 or json[i - 1] != '\\')) {
            return json[value_start..i];
        }
    }
    return null;
}

/// Escape a string for embedding inside a JavaScript double-quoted string.
fn escapeForJS(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var result = std.ArrayListUnmanaged(u8){};
    errdefer result.deinit(allocator);
    for (input) |ch| {
        switch (ch) {
            '"' => try result.appendSlice(allocator, "\\\""),
            '\\' => try result.appendSlice(allocator, "\\\\"),
            '\n' => try result.appendSlice(allocator, "\\n"),
            '\r' => try result.appendSlice(allocator, "\\r"),
            '\t' => try result.appendSlice(allocator, "\\t"),
            else => try result.append(allocator, ch),
        }
    }
    return result.toOwnedSlice(allocator);
}

/// Handle WM_SIZE messages by resizing the WebView2 controller bounds.
/// Called from the window procedure when the window is resized.
fn onResize(hwnd: HWND, state_ptr: ?*WebviewState) void {
    const state = state_ptr orelse return;
    if (state.controller) |ctrl| {
        var rect: RECT = .{ .left = 0, .top = 0, .right = 0, .bottom = 0 };
        _ = GetClientRect(hwnd, &rect);
        const vtbl = controllerVtbl(ctrl);
        _ = vtbl.put_Bounds(ctrl, rect);
    }
}
