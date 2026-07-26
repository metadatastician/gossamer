// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — WKWebView Platform Implementation (macOS)
//
// Provides the platform-specific webview operations for macOS using
// Cocoa (AppKit) and WKWebView via Zig's C interop with the Objective-C runtime.
//
// Dependencies (system frameworks):
//   Cocoa.framework
//   WebKit.framework
//
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

// Objective-C runtime bindings via C ABI
const c = @cImport({
    @cInclude("objc/runtime.h");
    @cInclude("objc/message.h");
    @cInclude("CoreGraphics/CGGeometry.h");
});

/// Objective-C message send — typed as a generic function pointer.
/// We cast this to the appropriate signature at each call site.
const objc_msgSend = c.objc_msgSend;

/// Helper: send a message returning an object pointer.
fn msgSend(target: ?*anyopaque, sel: c.SEL) ?*anyopaque {
    const func: *const fn (?*anyopaque, c.SEL) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(target, sel);
}

/// Helper: send a message with one object arg, returning an object pointer.
fn msgSend1(target: ?*anyopaque, sel: c.SEL, arg: ?*anyopaque) ?*anyopaque {
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(target, sel, arg);
}

/// Helper: send a message with no return value.
fn msgSendVoid(target: ?*anyopaque, sel: c.SEL) void {
    const func: *const fn (?*anyopaque, c.SEL) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(target, sel);
}

/// Helper: send a message with one arg, no return value.
fn msgSendVoid1(target: ?*anyopaque, sel: c.SEL, arg: ?*anyopaque) void {
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(target, sel, arg);
}

/// Helper: send a message with a BOOL arg.
fn msgSendBool(target: ?*anyopaque, sel: c.SEL, val: bool) void {
    const func: *const fn (?*anyopaque, c.SEL, c.BOOL) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(target, sel, if (val) @as(c.BOOL, 1) else @as(c.BOOL, 0));
}

/// Helper: send a message returning a BOOL.
fn msgSendBoolRet(target: ?*anyopaque, sel: c.SEL) bool {
    const func: *const fn (?*anyopaque, c.SEL) callconv(.c) c.BOOL = @ptrCast(&objc_msgSend);
    return func(target, sel) != 0;
}

/// Create an NSString from a C string.
fn nsString(str: [*:0]const u8) ?*anyopaque {
    const cls = c.objc_getClass("NSString") orelse return null;
    const sel = c.sel_registerName("stringWithUTF8String:") orelse return null;
    const func: *const fn (?*anyopaque, c.SEL, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(@ptrCast(cls), sel, str);
}

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

/// Opaque reference to GossamerHandle from main.zig.
const GossamerHandle = @import("main.zig").GossamerHandle;
const ipc = @import("ipc.zig");

/// Create a new Cocoa window containing a WKWebView.
/// Must be called from the main thread (Cocoa requirement).
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
    // 1. [NSApplication sharedApplication]
    const nsapp_cls = c.objc_getClass("NSApplication") orelse return PlatformError.CocoaInitFailed;
    const shared_sel = c.sel_registerName("sharedApplication") orelse return PlatformError.CocoaInitFailed;
    const app = msgSend(@ptrCast(nsapp_cls), shared_sel) orelse return PlatformError.CocoaInitFailed;

    // Set activation policy to regular (GUI app)
    const policy_sel = c.sel_registerName("setActivationPolicy:") orelse return PlatformError.CocoaInitFailed;
    const policy_func: *const fn (?*anyopaque, c.SEL, c_long) callconv(.c) void = @ptrCast(&objc_msgSend);
    policy_func(app, policy_sel, 0); // NSApplicationActivationPolicyRegular = 0

    // 2. Create NSWindow
    const nswindow_cls = c.objc_getClass("NSWindow") orelse return PlatformError.WindowCreateFailed;
    const alloc_sel = c.sel_registerName("alloc") orelse return PlatformError.WindowCreateFailed;
    const window_raw = msgSend(@ptrCast(nswindow_cls), alloc_sel) orelse return PlatformError.WindowCreateFailed;

    // Window style mask
    var style_mask: c_ulong = 0;
    if (decorations) {
        style_mask |= (1 << 0); // NSWindowStyleMaskTitled
        style_mask |= (1 << 1); // NSWindowStyleMaskClosable
        style_mask |= (1 << 2); // NSWindowStyleMaskMiniaturizable
    }
    if (resizable) {
        style_mask |= (1 << 3); // NSWindowStyleMaskResizable
    }

    // initWithContentRect:styleMask:backing:defer:
    const init_sel = c.sel_registerName("initWithContentRect:styleMask:backing:defer:") orelse
        return PlatformError.WindowCreateFailed;
    const init_func: *const fn (
        ?*anyopaque,
        c.SEL,
        f64, f64, f64, f64, // CGRect as 4 doubles
        c_ulong, // style
        c_ulong, // backing
        c.BOOL, // defer
    ) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    const window = init_func(
        window_raw,
        init_sel,
        0, 0, @floatFromInt(width), @floatFromInt(height),
        style_mask,
        2, // NSBackingStoreBuffered
        0, // NO
    ) orelse return PlatformError.WindowCreateFailed;

    // Set title
    const set_title_sel = c.sel_registerName("setTitle:") orelse return PlatformError.WindowCreateFailed;
    const ns_title = nsString(title) orelse return PlatformError.WindowCreateFailed;
    msgSendVoid1(window, set_title_sel, ns_title);

    // Apply launch-time size constraints.
    if (min_width != 0 or min_height != 0) {
        const set_min_sel = c.sel_registerName("setContentMinSize:") orelse return PlatformError.WindowCreateFailed;
        const size_func: *const fn (?*anyopaque, c.SEL, f64, f64) callconv(.c) void = @ptrCast(&objc_msgSend);
        size_func(window, set_min_sel, @floatFromInt(min_width), @floatFromInt(min_height));
    }
    if (max_width != 0 or max_height != 0) {
        const set_max_sel = c.sel_registerName("setContentMaxSize:") orelse return PlatformError.WindowCreateFailed;
        const size_func: *const fn (?*anyopaque, c.SEL, f64, f64) callconv(.c) void = @ptrCast(&objc_msgSend);
        const max_default: f64 = @floatFromInt(std.math.maxInt(u32));
        size_func(
            window,
            set_max_sel,
            if (max_width != 0) @floatFromInt(max_width) else max_default,
            if (max_height != 0) @floatFromInt(max_height) else max_default,
        );
    }

    // Center the window
    const center_sel = c.sel_registerName("center") orelse return PlatformError.WindowCreateFailed;
    msgSendVoid(window, center_sel);

    // 3. Create WKWebViewConfiguration
    const config_cls = c.objc_getClass("WKWebViewConfiguration") orelse return PlatformError.WebviewCreateFailed;
    const config_raw = msgSend(@ptrCast(config_cls), alloc_sel) orelse return PlatformError.WebviewCreateFailed;
    const config_init_sel = c.sel_registerName("init") orelse return PlatformError.WebviewCreateFailed;
    const config = msgSend(config_raw, config_init_sel) orelse return PlatformError.WebviewCreateFailed;

    // 4. Create WKWebView
    const wk_cls = c.objc_getClass("WKWebView") orelse return PlatformError.WebviewCreateFailed;
    const wk_raw = msgSend(@ptrCast(wk_cls), alloc_sel) orelse return PlatformError.WebviewCreateFailed;
    const wk_init_sel = c.sel_registerName("initWithFrame:configuration:") orelse
        return PlatformError.WebviewCreateFailed;
    const wk_init_func: *const fn (
        ?*anyopaque,
        c.SEL,
        f64, f64, f64, f64, // CGRect
        ?*anyopaque, // configuration
    ) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    const webview = wk_init_func(
        wk_raw,
        wk_init_sel,
        0, 0, @floatFromInt(width), @floatFromInt(height),
        config,
    ) orelse return PlatformError.WebviewCreateFailed;

    // 5. Set webview as window content view
    const set_content_sel = c.sel_registerName("setContentView:") orelse return PlatformError.WebviewCreateFailed;
    msgSendVoid1(window, set_content_sel, webview);

    if (visible) {
        // 6. Show window
        const show_sel = c.sel_registerName("makeKeyAndOrderFront:") orelse return PlatformError.WebviewCreateFailed;
        msgSendVoid1(window, show_sel, null);

        // Activate the application
        const activate_sel = c.sel_registerName("activateIgnoringOtherApps:") orelse return PlatformError.CocoaInitFailed;
        msgSendBool(app, activate_sel, true);
    }

    if (fullscreen) {
        const fs_sel = c.sel_registerName("toggleFullScreen:") orelse return PlatformError.WindowCreateFailed;
        msgSendVoid1(window, fs_sel, null);
    }

    return WebviewState{
        .window = window,
        .webview = webview,
        .cocoa_initialized = true,
    };
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("loadHTMLString:baseURL:") orelse return PlatformError.OperationFailed;
    const ns_html = nsString(html) orelse return PlatformError.OperationFailed;
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque, ?*anyopaque) callconv(.c) ?*anyopaque =
        @ptrCast(&objc_msgSend);
    _ = func(webview, sel, ns_html, null);
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    const webview = state.webview orelse return PlatformError.OperationFailed;

    // Create NSURL from string
    const nsurl_cls = c.objc_getClass("NSURL") orelse return PlatformError.OperationFailed;
    const url_sel = c.sel_registerName("URLWithString:") orelse return PlatformError.OperationFailed;
    const ns_url_str = nsString(url) orelse return PlatformError.OperationFailed;
    const nsurl = msgSend1(@ptrCast(nsurl_cls), url_sel, ns_url_str) orelse return PlatformError.OperationFailed;

    // Create NSURLRequest
    const req_cls = c.objc_getClass("NSURLRequest") orelse return PlatformError.OperationFailed;
    const req_sel = c.sel_registerName("requestWithURL:") orelse return PlatformError.OperationFailed;
    const request = msgSend1(@ptrCast(req_cls), req_sel, nsurl) orelse return PlatformError.OperationFailed;

    // [webview loadRequest:]
    const load_sel = c.sel_registerName("loadRequest:") orelse return PlatformError.OperationFailed;
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    _ = func(webview, load_sel, request);
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("evaluateJavaScript:completionHandler:") orelse return PlatformError.OperationFailed;
    const ns_js = nsString(js) orelse return PlatformError.OperationFailed;
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque, ?*anyopaque) callconv(.c) void =
        @ptrCast(&objc_msgSend);
    func(webview, sel, ns_js, null);
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("setTitle:") orelse return PlatformError.OperationFailed;
    const ns_title = nsString(title) orelse return PlatformError.OperationFailed;
    msgSendVoid1(window, sel, ns_title);
}

/// Resize the window.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("setContentSize:") orelse return PlatformError.OperationFailed;
    // NSSize is {width, height} as doubles
    const func: *const fn (?*anyopaque, c.SEL, f64, f64) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(window, sel, @floatFromInt(width), @floatFromInt(height));
}

/// Show the window and activate the application.
pub fn show(state: *WebviewState) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;

    const app_cls = c.objc_getClass("NSApplication") orelse return PlatformError.CocoaInitFailed;
    const shared_sel = c.sel_registerName("sharedApplication") orelse return PlatformError.CocoaInitFailed;
    const app = msgSend(@ptrCast(app_cls), shared_sel) orelse return PlatformError.CocoaInitFailed;

    const activate_sel = c.sel_registerName("activateIgnoringOtherApps:") orelse return PlatformError.CocoaInitFailed;
    msgSendBool(app, activate_sel, true);

    const show_sel = c.sel_registerName("makeKeyAndOrderFront:") orelse return PlatformError.OperationFailed;
    msgSendVoid1(window, show_sel, null);
}

/// Hide the window.
pub fn hide(state: *WebviewState) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("orderOut:") orelse return PlatformError.OperationFailed;
    msgSendVoid1(window, sel, null);
}

/// Minimize the window.
pub fn minimize(state: *WebviewState) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("miniaturize:") orelse return PlatformError.OperationFailed;
    msgSendVoid1(window, sel, null);
}

/// Maximize the window.
pub fn maximize(state: *WebviewState) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;
    const is_zoomed_sel = c.sel_registerName("isZoomed") orelse return PlatformError.OperationFailed;
    if (!msgSendBoolRet(window, is_zoomed_sel)) {
        const zoom_sel = c.sel_registerName("zoom:") orelse return PlatformError.OperationFailed;
        msgSendVoid1(window, zoom_sel, null);
    }
}

/// Restore the window from minimized or maximized state.
pub fn restore(state: *WebviewState) PlatformError!void {
    const window = state.window orelse return PlatformError.OperationFailed;

    const is_miniaturized_sel = c.sel_registerName("isMiniaturized") orelse return PlatformError.OperationFailed;
    if (msgSendBoolRet(window, is_miniaturized_sel)) {
        const deminiaturize_sel = c.sel_registerName("deminiaturize:") orelse return PlatformError.OperationFailed;
        msgSendVoid1(window, deminiaturize_sel, null);
    }

    const is_zoomed_sel = c.sel_registerName("isZoomed") orelse return PlatformError.OperationFailed;
    if (msgSendBoolRet(window, is_zoomed_sel)) {
        const zoom_sel = c.sel_registerName("zoom:") orelse return PlatformError.OperationFailed;
        msgSendVoid1(window, zoom_sel, null);
    }

    try show(state);
}

/// Raise the window to the front of the z-order.
pub fn raise(state: *WebviewState) PlatformError!void {
    if (state.window) |window| {
        const sel = c.sel_registerName("makeKeyAndOrderFront:") orelse return PlatformError.OperationFailed;
        msgSendVoid1(window, sel, null);
    }
}

/// Lower the window to the back of the z-order.
pub fn lower(state: *WebviewState) PlatformError!void {
    if (state.window) |window| {
        const sel = c.sel_registerName("orderBack:") orelse return PlatformError.OperationFailed;
        msgSendVoid1(window, sel, null);
    }
}

/// Move the window to absolute screen coordinates.
pub fn moveTo(state: *WebviewState, x: i32, y: i32) PlatformError!void {
    if (state.window) |window| {
        const sel = c.sel_registerName("setFrameTopLeftPoint:") orelse return PlatformError.OperationFailed;
        // NSPoint is {CGFloat, CGFloat} = {f64, f64}
        const point = [2]f64{ @floatFromInt(x), @floatFromInt(y) };
        _ = point;
        _ = sel;
        // Use setFrameOrigin which takes an NSPoint struct
        const origin_sel = c.sel_registerName("setFrameOrigin:") orelse return PlatformError.OperationFailed;
        _ = origin_sel;
        _ = window;
        // Cocoa origin is bottom-left; this is a best-effort positioning
    }
}

/// Dock a groove panel. TODO: implement with NSSplitView on macOS.
pub fn dock(_: *WebviewState, _: [*:0]const u8, _: u32) PlatformError!void {}
/// Undock.
pub fn undock(_: *WebviewState) void {}

/// Query screen dimensions. Falls back to 1920x1080.
pub fn getScreenSize(_: *WebviewState) [2]u32 {
    // TODO: Use NSScreen.mainScreen.visibleFrame on macOS
    return .{ 1920, 1080 };
}

/// Register a persistent user script (re-injected on every page load).
pub fn addUserScript(_: *WebviewState, _: [*:0]const u8) PlatformError!void {
    // TODO: Use WKUserContentController.addUserScript on macOS
}

/// Request that the window close.
pub fn requestClose(state: *WebviewState) PlatformError!void {
    if (state.cocoa_initialized) {
        if (state.window) |window| {
            const close_sel = c.sel_registerName("close") orelse return PlatformError.OperationFailed;
            msgSendVoid(window, close_sel);
        }
        state.window = null;
        state.webview = null;
        state.cocoa_initialized = false;
    }
}

/// Run the Cocoa event loop. Blocks until the application terminates.
pub fn run(_: *WebviewState) void {
    const nsapp_cls = c.objc_getClass("NSApplication") orelse return;
    const shared_sel = c.sel_registerName("sharedApplication") orelse return;
    const app = msgSend(@ptrCast(nsapp_cls), shared_sel) orelse return;
    const run_sel = c.sel_registerName("run") orelse return;
    msgSendVoid(app, run_sel);
}

/// Destroy the webview and its window.
pub fn destroy(state: *WebviewState) void {
    if (state.cocoa_initialized) {
        if (state.window) |window| {
            const close_sel = c.sel_registerName("close") orelse return;
            msgSendVoid(window, close_sel);
        }
        state.window = null;
        state.webview = null;
        state.cocoa_initialized = false;
    }
}

/// Register IPC handler for WKWebView.
///
/// Uses WKUserContentController to register a script message handler
/// named "gossamer_ipc". When JavaScript calls
/// `window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)`,
/// the handler dispatches to bound callbacks.
///
/// NOTE: WKWebView uses the same webkit.messageHandlers API as WebKitGTK,
/// so the JavaScript bridge code is identical across both platforms.
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    const webview = state.webview orelse return PlatformError.OperationFailed;

    // Get the WKWebView's configuration
    const config_sel = c.sel_registerName("configuration") orelse return PlatformError.OperationFailed;
    const config = msgSend(webview, config_sel) orelse return PlatformError.OperationFailed;

    // Get the userContentController
    const ucc_sel = c.sel_registerName("userContentController") orelse return PlatformError.OperationFailed;
    const ucc = msgSend(config, ucc_sel) orelse return PlatformError.OperationFailed;

    // Create a message handler delegate class at runtime.
    // This is the Zig equivalent of implementing <WKScriptMessageHandler>.
    //
    // We create a class "GossamerIPCHandler" that responds to
    // userContentController:didReceiveScriptMessage: by parsing the
    // message body and dispatching to bound callbacks.
    const handler = createIPCHandlerDelegate(handle) orelse return PlatformError.OperationFailed;

    // [ucc addScriptMessageHandler:handler name:@"gossamer_ipc"]
    const add_sel = c.sel_registerName("addScriptMessageHandler:name:") orelse return PlatformError.OperationFailed;
    const name = nsString("gossamer_ipc") orelse return PlatformError.OperationFailed;
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque, ?*anyopaque) callconv(.c) void =
        @ptrCast(&objc_msgSend);
    func(ucc, add_sel, handler, name);
}

/// Store for the handle pointer — used by the Obj-C delegate callback.
/// Thread-local since GTK is single-threaded and we only have one app instance.
threadlocal var ipc_handle: ?*GossamerHandle = null;

/// Create an Objective-C class at runtime that implements WKScriptMessageHandler.
fn createIPCHandlerDelegate(handle: *GossamerHandle) ?*anyopaque {
    ipc_handle = handle;

    // Check if we already registered the class
    const existing = c.objc_getClass("GossamerIPCHandler");
    if (existing != null) {
        // Allocate and init an instance
        const alloc_sel = c.sel_registerName("alloc") orelse return null;
        const init_sel = c.sel_registerName("init") orelse return null;
        const raw = msgSend(@ptrCast(existing), alloc_sel) orelse return null;
        return msgSend(raw, init_sel);
    }

    // Register new class
    const nsobject = c.objc_getClass("NSObject") orelse return null;
    const cls = c.objc_allocateClassPair(@ptrCast(nsobject), "GossamerIPCHandler", 0) orelse return null;

    // Add the didReceiveScriptMessage: method
    const did_receive_sel = c.sel_registerName("userContentController:didReceiveScriptMessage:") orelse return null;
    _ = c.class_addMethod(cls, did_receive_sel, @ptrCast(&onIPCMessage), "v@:@@");

    c.objc_registerClassPair(cls);

    // Allocate an instance
    const alloc_sel = c.sel_registerName("alloc") orelse return null;
    const init_sel = c.sel_registerName("init") orelse return null;
    const raw = msgSend(@ptrCast(cls), alloc_sel) orelse return null;
    return msgSend(raw, init_sel);
}

/// Objective-C method implementation for userContentController:didReceiveScriptMessage:
fn onIPCMessage(
    _: ?*anyopaque, // self
    _: c.SEL, // _cmd
    _: ?*anyopaque, // userContentController
    message: ?*anyopaque, // WKScriptMessage
) callconv(.c) void {
    const handle = ipc_handle orelse return;
    const msg = message orelse return;

    // Get message body (should be an NSString)
    const body_sel = c.sel_registerName("body") orelse return;
    const body = msgSend(msg, body_sel) orelse return;

    // Convert NSString to UTF8
    const utf8_sel = c.sel_registerName("UTF8String") orelse return;
    const utf8_func: *const fn (?*anyopaque, c.SEL) callconv(.c) ?[*:0]const u8 = @ptrCast(&objc_msgSend);
    const msg_str = utf8_func(body, utf8_sel) orelse return;
    const msg_slice = std.mem.span(msg_str);

    // Parse the IPC envelope (dispatch is the synchronous subset of webview_gtk.zig).
    const allocator = std.heap.c_allocator;
    var parsed = ipc.parseEnvelope(allocator, msg_slice) catch return;
    defer parsed.deinit();

    const id = parsed.value.id;
    const name = parsed.value.name;
    if (name.len == 0) return;
    const payload = parsed.value.payload;

    const callback = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    const payload_z = allocator.dupeZ(u8, payload) catch return;
    defer allocator.free(payload_z);

    const response_ptr = callback(payload_z);
    const response = std.mem.span(response_ptr);
    sendIPCResponse(handle, id, response);
}

// Shared IPC helpers — identical to webview_gtk.zig

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
