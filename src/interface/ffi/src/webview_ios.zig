// Gossamer — WKWebView Platform Implementation (iOS)
//
// Provides platform-specific webview operations for iOS using
// UIKit and WKWebView via Zig's C interop with the Objective-C runtime.
//
// Shares the WKWebView/WKUserContentController IPC mechanism with macOS,
// but uses UIKit (UIWindow, UIViewController) instead of AppKit (NSWindow).
//
// Dependencies (system frameworks):
//   UIKit.framework
//   WebKit.framework
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

// Objective-C runtime bindings via C ABI
const c = @cImport({
    @cInclude("objc/runtime.h");
    @cInclude("objc/message.h");
});

const objc_msgSend = c.objc_msgSend;

/// Helper: send a message returning an object pointer.
fn msgSend(target: ?*anyopaque, sel: c.SEL) ?*anyopaque {
    const func: *const fn (?*anyopaque, c.SEL) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(target, sel);
}

/// Helper: send a message with one arg, returning an object pointer.
fn msgSend1(target: ?*anyopaque, sel: c.SEL, arg: ?*anyopaque) ?*anyopaque {
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(target, sel, arg);
}

/// Helper: send a void message.
fn msgSendVoid(target: ?*anyopaque, sel: c.SEL) void {
    const func: *const fn (?*anyopaque, c.SEL) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(target, sel);
}

/// Helper: send a void message with one arg.
fn msgSendVoid1(target: ?*anyopaque, sel: c.SEL, arg: ?*anyopaque) void {
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) void = @ptrCast(&objc_msgSend);
    func(target, sel, arg);
}

/// Create an NSString from a C string.
fn nsString(str: [*:0]const u8) ?*anyopaque {
    const cls = c.objc_getClass("NSString") orelse return null;
    const sel = c.sel_registerName("stringWithUTF8String:") orelse return null;
    const func: *const fn (?*anyopaque, c.SEL, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(&objc_msgSend);
    return func(@ptrCast(cls), sel, str);
}

/// Platform-specific webview state for iOS/WKWebView.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// UIWindow pointer (opaque)
    window: ?*anyopaque,
    /// WKWebView pointer (opaque)
    webview: ?*anyopaque,
    /// UIViewController pointer (opaque)
    view_controller: ?*anyopaque,
    /// Whether UIKit has been initialised
    uikit_initialized: bool,
};

/// Error type for platform operations.
pub const PlatformError = error{
    UIKitInitFailed,
    WindowCreateFailed,
    WebviewCreateFailed,
    OperationFailed,
};

/// Opaque reference to GossamerHandle from main.zig.
const GossamerHandle = @import("main.zig").GossamerHandle;

/// Create a new UIWindow containing a WKWebView.
///
/// On iOS, the app lifecycle is managed by UIApplicationMain.
/// This function creates the window and webview programmatically,
/// bypassing storyboards/XIBs.
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
    _ = title; // iOS doesn't have window titles
    _ = width; // iOS uses full screen
    _ = height;
    _ = min_width;
    _ = min_height;
    _ = max_width;
    _ = max_height;
    _ = resizable; // Always full screen
    _ = decorations; // No window decorations
    _ = fullscreen; // Always full screen

    const alloc_sel = c.sel_registerName("alloc") orelse return PlatformError.UIKitInitFailed;
    const init_sel = c.sel_registerName("init") orelse return PlatformError.UIKitInitFailed;

    // Get the main screen bounds
    const screen_cls = c.objc_getClass("UIScreen") orelse return PlatformError.UIKitInitFailed;
    const main_sel = c.sel_registerName("mainScreen") orelse return PlatformError.UIKitInitFailed;
    const screen = msgSend(@ptrCast(screen_cls), main_sel) orelse return PlatformError.UIKitInitFailed;
    _ = screen;

    // Create UIWindow with screen bounds
    // [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds]
    const window_cls = c.objc_getClass("UIWindow") orelse return PlatformError.WindowCreateFailed;
    const window_raw = msgSend(@ptrCast(window_cls), alloc_sel) orelse return PlatformError.WindowCreateFailed;
    // initWithFrame: requires CGRect — use screen bounds
    const bounds_sel = c.sel_registerName("bounds") orelse return PlatformError.WindowCreateFailed;
    _ = bounds_sel;
    const init_frame_sel = c.sel_registerName("initWithFrame:") orelse return PlatformError.WindowCreateFailed;
    // CGRect{0, 0, screenWidth, screenHeight} — on iOS we use full screen
    const init_func: *const fn (?*anyopaque, c.SEL, f64, f64, f64, f64) callconv(.c) ?*anyopaque =
        @ptrCast(&objc_msgSend);
    const window = init_func(window_raw, init_frame_sel, 0, 0, 390, 844) // Default iPhone dimensions
        orelse return PlatformError.WindowCreateFailed;

    // Create WKWebViewConfiguration
    const config_cls = c.objc_getClass("WKWebViewConfiguration") orelse return PlatformError.WebviewCreateFailed;
    const config_raw = msgSend(@ptrCast(config_cls), alloc_sel) orelse return PlatformError.WebviewCreateFailed;
    const config = msgSend(config_raw, init_sel) orelse return PlatformError.WebviewCreateFailed;

    // Create WKWebView
    const wk_cls = c.objc_getClass("WKWebView") orelse return PlatformError.WebviewCreateFailed;
    const wk_raw = msgSend(@ptrCast(wk_cls), alloc_sel) orelse return PlatformError.WebviewCreateFailed;
    const wk_init_sel = c.sel_registerName("initWithFrame:configuration:") orelse
        return PlatformError.WebviewCreateFailed;
    const wk_init_func: *const fn (?*anyopaque, c.SEL, f64, f64, f64, f64, ?*anyopaque) callconv(.c) ?*anyopaque =
        @ptrCast(&objc_msgSend);
    const webview = wk_init_func(wk_raw, wk_init_sel, 0, 0, 390, 844, config) orelse
        return PlatformError.WebviewCreateFailed;

    // Create a UIViewController and set the webview as its view
    const vc_cls = c.objc_getClass("UIViewController") orelse return PlatformError.WindowCreateFailed;
    const vc_raw = msgSend(@ptrCast(vc_cls), alloc_sel) orelse return PlatformError.WindowCreateFailed;
    const vc = msgSend(vc_raw, init_sel) orelse return PlatformError.WindowCreateFailed;

    // [viewController setView:webview]
    const set_view_sel = c.sel_registerName("setView:") orelse return PlatformError.WindowCreateFailed;
    msgSendVoid1(vc, set_view_sel, webview);

    // [window setRootViewController:vc]
    const set_root_sel = c.sel_registerName("setRootViewController:") orelse return PlatformError.WindowCreateFailed;
    msgSendVoid1(window, set_root_sel, vc);

    if (visible) {
        // [window makeKeyAndVisible]
        const visible_sel = c.sel_registerName("makeKeyAndVisible") orelse return PlatformError.WindowCreateFailed;
        msgSendVoid(window, visible_sel);
    }

    return WebviewState{
        .window = window,
        .webview = webview,
        .view_controller = vc,
        .uikit_initialized = true,
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
    const nsurl_cls = c.objc_getClass("NSURL") orelse return PlatformError.OperationFailed;
    const url_sel = c.sel_registerName("URLWithString:") orelse return PlatformError.OperationFailed;
    const ns_url_str = nsString(url) orelse return PlatformError.OperationFailed;
    const nsurl = msgSend1(@ptrCast(nsurl_cls), url_sel, ns_url_str) orelse return PlatformError.OperationFailed;
    const req_cls = c.objc_getClass("NSURLRequest") orelse return PlatformError.OperationFailed;
    const req_sel = c.sel_registerName("requestWithURL:") orelse return PlatformError.OperationFailed;
    const request = msgSend1(@ptrCast(req_cls), req_sel, nsurl) orelse return PlatformError.OperationFailed;
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

/// Set the title (navigation bar title on iOS).
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const vc = state.view_controller orelse return PlatformError.OperationFailed;
    const sel = c.sel_registerName("setTitle:") orelse return PlatformError.OperationFailed;
    const ns_title = nsString(title) orelse return PlatformError.OperationFailed;
    msgSendVoid1(vc, sel, ns_title);
}

/// Resize (no-op on iOS — always fills the screen).
pub fn resize(_: *WebviewState, _: u32, _: u32) PlatformError!void {
    // iOS apps always fill the screen
}

/// Window visibility/state controls are not supported on iOS.
pub fn show(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on iOS.
pub fn hide(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on iOS.
pub fn minimize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on iOS.
pub fn maximize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on iOS.
pub fn restore(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Register a persistent user script.
pub fn addUserScript(_: *WebviewState, _: [*:0]const u8) PlatformError!void {}

/// Z-order and move are not applicable on iOS (single-app fullscreen).
pub fn raise(_: *WebviewState) PlatformError!void {}
pub fn lower(_: *WebviewState) PlatformError!void {}
pub fn moveTo(_: *WebviewState, _: i32, _: i32) PlatformError!void {}

/// Requesting close is not supported on iOS from the native shell layer.
pub fn requestClose(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Run the UIKit event loop.
/// On iOS, UIApplicationMain is called from the C main() function.
/// This is typically a no-op since the run loop is managed by UIKit.
pub fn run(_: *WebviewState) void {
    // UIKit manages its own run loop via UIApplicationMain.
    // In a Gossamer context, the native library is loaded into
    // an existing UIKit app, so this is effectively a no-op.
    // The webview stays alive as long as the UIWindow is visible.
}

/// Destroy the webview and release references.
pub fn destroy(state: *WebviewState) void {
    if (state.uikit_initialized) {
        // Release references (ARC handles deallocation in Obj-C)
        state.window = null;
        state.webview = null;
        state.view_controller = null;
        state.uikit_initialized = false;
    }
}

/// Register IPC handler for iOS WKWebView.
///
/// Uses WKUserContentController (same as macOS) to register a
/// "gossamer_ipc" script message handler. The JavaScript bridge
/// is identical: window.webkit.messageHandlers.gossamer_ipc.postMessage(msg).
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    const webview = state.webview orelse return PlatformError.OperationFailed;

    // Get WKWebView configuration → userContentController
    const config_sel = c.sel_registerName("configuration") orelse return PlatformError.OperationFailed;
    const config = msgSend(webview, config_sel) orelse return PlatformError.OperationFailed;
    const ucc_sel = c.sel_registerName("userContentController") orelse return PlatformError.OperationFailed;
    const ucc = msgSend(config, ucc_sel) orelse return PlatformError.OperationFailed;

    // Create GossamerIPCHandler delegate (same pattern as macOS)
    const handler = createIPCHandlerDelegate(handle) orelse return PlatformError.OperationFailed;

    // [ucc addScriptMessageHandler:handler name:@"gossamer_ipc"]
    const add_sel = c.sel_registerName("addScriptMessageHandler:name:") orelse return PlatformError.OperationFailed;
    const name = nsString("gossamer_ipc") orelse return PlatformError.OperationFailed;
    const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque, ?*anyopaque) callconv(.c) void =
        @ptrCast(&objc_msgSend);
    func(ucc, add_sel, handler, name);
}

/// Thread-local handle reference for the Obj-C delegate callback.
threadlocal var ipc_handle: ?*GossamerHandle = null;

fn createIPCHandlerDelegate(handle: *GossamerHandle) ?*anyopaque {
    ipc_handle = handle;
    const existing = c.objc_getClass("GossamerIPCHandler");
    if (existing != null) {
        const alloc_sel = c.sel_registerName("alloc") orelse return null;
        const init_sel = c.sel_registerName("init") orelse return null;
        const raw = msgSend(@ptrCast(existing), alloc_sel) orelse return null;
        return msgSend(raw, init_sel);
    }
    const nsobject = c.objc_getClass("NSObject") orelse return null;
    const cls = c.objc_allocateClassPair(@ptrCast(nsobject), "GossamerIPCHandler", 0) orelse return null;
    const did_receive_sel = c.sel_registerName("userContentController:didReceiveScriptMessage:") orelse return null;
    _ = c.class_addMethod(cls, did_receive_sel, @ptrCast(&onIPCMessage), "v@:@@");
    c.objc_registerClassPair(cls);
    const alloc_sel = c.sel_registerName("alloc") orelse return null;
    const init_sel = c.sel_registerName("init") orelse return null;
    const raw = msgSend(@ptrCast(cls), alloc_sel) orelse return null;
    return msgSend(raw, init_sel);
}

fn onIPCMessage(
    _: ?*anyopaque,
    _: c.SEL,
    _: ?*anyopaque,
    message: ?*anyopaque,
) callconv(.c) void {
    const handle = ipc_handle orelse return;
    const msg = message orelse return;

    const body_sel = c.sel_registerName("body") orelse return;
    const body = msgSend(msg, body_sel) orelse return;
    const utf8_sel = c.sel_registerName("UTF8String") orelse return;
    const utf8_func: *const fn (?*anyopaque, c.SEL) callconv(.c) ?[*:0]const u8 = @ptrCast(&objc_msgSend);
    const msg_str = utf8_func(body, utf8_sel) orelse return;
    const msg_slice = std.mem.span(msg_str);

    const id = extractJsonField(msg_slice, "id") orelse return;
    const name = extractJsonField(msg_slice, "name") orelse return;
    const payload = extractJsonField(msg_slice, "payload") orelse "";

    const callback = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    const allocator = std.heap.c_allocator;
    const payload_z = allocator.dupeZ(u8, payload) catch return;
    defer allocator.free(payload_z);
    const response_ptr = callback(payload_z);
    const response = std.mem.span(response_ptr);
    sendIPCResponse(handle, id, response);
}

// Shared IPC helpers — identical to macOS/GTK implementations

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
