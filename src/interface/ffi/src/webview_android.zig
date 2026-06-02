// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android WebView Platform Implementation
//
// Platform-specific webview operations for Android, driven over JNI against
// android.webkit.WebView. Compiled when targeting *-linux-android via the NDK
// (selected in main.zig by `builtin.abi == .android`).
//
// This file was rewritten to call REAL JNI. The previous version declared
// `extern fn jni_FindClass(...)` and friends — symbols defined nowhere, so the
// shell could never link. All JNI now goes through `jni.zig`, which models the
// per-thread JNIEnv function table directly (see that file for the rationale).
//
// Correctness fixes folded into the rewrite:
//   * nativeInit now promotes the Activity/WebView to GLOBAL refs. The old code
//     stored the raw local refs Java handed in; those are invalid the moment
//     nativeInit returns, so every later call dereferenced freed handles.
//   * The process JavaVM is cached so native threads (the run() loop, async IPC
//     workers) can attach and obtain a valid env instead of reusing a stored
//     env from another thread (JNIEnv is strictly thread-local).
//   * IPC registration no longer constructs a second GossamerBridge and calls
//     addJavascriptInterface a second time — the generated GossamerActivity
//     already registers the bridge in onCreate. The native side only records
//     the dispatch handle, removing the double-registration.
//
// Dependencies at link time (NDK): liblog, libandroid. No webview .so is linked
// — android.webkit.WebView is reached entirely through JNI.

const std = @import("std");
const jni = @import("jni.zig");
const comp = @import("android_components.zig");

// Force the non-UI component hosts (Service/Receiver/Widget) and their
// `gossamer_*_bind` exports into the Android image. They are reachable only
// through this platform module, so referencing them here is what makes their
// `export fn`s part of libgossamer.so on Android — and only on Android.
// (A `///` doc comment cannot attach to a comptime block — must be `//`.)
comptime {
    _ = @import("android_service.zig");
    _ = @import("android_receiver.zig");
    _ = @import("android_widget.zig");
}

/// Platform-specific webview state for Android.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// JNIEnv captured at nativeInit — valid on the JVM UI thread. Off-thread
    /// callers must obtain their own env via `currentEnv()` instead.
    jni_env: ?jni.JNIEnv,
    /// Global reference to the Android Activity (jobject).
    activity: jni.jobject,
    /// Global reference to the Android WebView (jobject).
    webview: jni.jobject,
    /// Cached class ref for android.webkit.WebView.
    webview_class: jni.jclass,
    /// Cached method IDs for WebView methods.
    mid_loadData: jni.jmethodID,
    mid_loadUrl: jni.jmethodID,
    mid_evaluateJavascript: jni.jmethodID,
    /// Cached method ID for Activity.setTitle.
    mid_setTitle: jni.jmethodID,
    /// Whether JNI has been initialised.
    jni_initialized: bool,
    /// Shutdown signal — set by Java when Activity.onDestroy fires.
    shutdown: bool,
};

/// Error type for platform operations.
pub const PlatformError = error{
    JniInitFailed,
    WindowCreateFailed,
    WebviewCreateFailed,
    OperationFailed,
};

/// Opaque reference to GossamerHandle from main.zig.
const GossamerHandle = @import("main.zig").GossamerHandle;

/// Obtain a JNIEnv valid on the CURRENT thread: prefer the already-attached
/// env, otherwise attach via the cached JavaVM. Returns null if no VM is known.
fn currentEnv() ?jni.JNIEnv {
    const vm = android_vm orelse return android_jni_env;
    return jni.getEnv(vm, jni.JNI_VERSION_1_6) orelse jni.attachCurrentThread(vm);
}

/// Create a new Android WebView binding.
///
/// On Android the Activity and WebView already exist (constructed by the
/// generated GossamerActivity). This attaches to them via JNI and caches the
/// method IDs used on the hot path.
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
    _ = title; // Applied via Activity.setTitle after creation.
    _ = width; // Android fills the Activity.
    _ = height;
    _ = min_width;
    _ = min_height;
    _ = max_width;
    _ = max_height;
    _ = resizable;
    _ = decorations;
    _ = fullscreen;
    _ = visible;

    const env = android_jni_env orelse return PlatformError.JniInitFailed;
    const activity = android_activity orelse return PlatformError.JniInitFailed;
    const webview = android_webview orelse return PlatformError.WebviewCreateFailed;

    const wv_cls = jni.findClass(env, "android/webkit/WebView");
    if (wv_cls == null) return PlatformError.WebviewCreateFailed;

    const mid_loadData = jni.getMethodID(
        env,
        wv_cls,
        "loadDataWithBaseURL",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
    );
    const mid_loadUrl = jni.getMethodID(env, wv_cls, "loadUrl", "(Ljava/lang/String;)V");
    const mid_eval = jni.getMethodID(
        env,
        wv_cls,
        "evaluateJavascript",
        "(Ljava/lang/String;Landroid/webkit/ValueCallback;)V",
    );

    const act_cls = jni.findClass(env, "android/app/Activity");
    const mid_setTitle = if (act_cls != null)
        jni.getMethodID(env, act_cls, "setTitle", "(Ljava/lang/CharSequence;)V")
    else
        null;

    return WebviewState{
        .jni_env = env,
        .activity = activity,
        .webview = webview,
        .webview_class = wv_cls,
        .mid_loadData = mid_loadData,
        .mid_loadUrl = mid_loadUrl,
        .mid_evaluateJavascript = mid_eval,
        .mid_setTitle = mid_setTitle,
        .jni_initialized = true,
        .shutdown = false,
    };
}

/// Load HTML content. JNI: webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null).
/// loadDataWithBaseURL is used over loadData so that document.origin is stable
/// and the JS bridge / fetch behave consistently.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_loadData orelse return PlatformError.OperationFailed;

    const j_html = jni.newStringUTF(env, html);
    const j_mime = jni.newStringUTF(env, "text/html");
    const j_enc = jni.newStringUTF(env, "UTF-8");
    if (j_html == null or j_mime == null or j_enc == null) return PlatformError.OperationFailed;

    jni.callVoidMethod(env, webview, mid, &.{
        jni.vObj(null), // baseUrl
        jni.vObj(j_html),
        jni.vObj(j_mime),
        jni.vObj(j_enc),
        jni.vObj(null), // historyUrl
    });
    _ = jni.clearPendingException(env);
}

/// Navigate to a URL. JNI: webView.loadUrl(url).
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_loadUrl orelse return PlatformError.OperationFailed;

    const j_url = jni.newStringUTF(env, url);
    if (j_url == null) return PlatformError.OperationFailed;
    jni.callVoidMethod(env, webview, mid, &.{jni.vObj(j_url)});
    _ = jni.clearPendingException(env);
}

/// Evaluate JavaScript. JNI: webView.evaluateJavascript(js, null).
/// Uses an env valid on the current thread (the JS bridge callback runs on a
/// binder thread, not the UI thread).
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    const env = currentEnv() orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_evaluateJavascript orelse return PlatformError.OperationFailed;

    const j_js = jni.newStringUTF(env, js);
    if (j_js == null) return PlatformError.OperationFailed;
    jni.callVoidMethod(env, webview, mid, &.{ jni.vObj(j_js), jni.vObj(null) });
    _ = jni.clearPendingException(env);
}

/// Set the window title (Activity title on Android). JNI: activity.setTitle(title).
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const activity = state.activity orelse return PlatformError.OperationFailed;
    const mid = state.mid_setTitle orelse return PlatformError.OperationFailed;

    const j_title = jni.newStringUTF(env, title);
    if (j_title == null) return PlatformError.OperationFailed;
    jni.callVoidMethod(env, activity, mid, &.{jni.vObj(j_title)});
    _ = jni.clearPendingException(env);
}

/// Resize is a no-op on Android — the WebView fills the Activity.
pub fn resize(_: *WebviewState, _: u32, _: u32) PlatformError!void {}

/// Window visibility/state controls are not applicable to a single-Activity
/// Android shell.
pub fn show(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}
pub fn hide(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}
pub fn minimize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}
pub fn maximize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}
pub fn restore(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Dock/undock not applicable on mobile.
pub fn dock(_: *WebviewState, _: [*:0]const u8, _: u32) PlatformError!void {}
pub fn undock(_: *WebviewState) void {}

/// Query screen dimensions — returns values cached from nativeInit().
pub fn getScreenSize(_: *WebviewState) [2]u32 {
    return .{ android_screen_width, android_screen_height };
}

/// User scripts are not yet wired on Android (would require WebViewClient
/// onPageFinished injection in the generated Java).
pub fn addUserScript(_: *WebviewState, _: [*:0]const u8) PlatformError!void {}

/// Z-order and move are not applicable on Android (single-activity model).
pub fn raise(_: *WebviewState) PlatformError!void {}
pub fn lower(_: *WebviewState) PlatformError!void {}
pub fn moveTo(_: *WebviewState, _: i32, _: i32) PlatformError!void {}

/// Requesting close from the native shell layer is not supported on Android.
pub fn requestClose(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Run the event loop. On Android the JVM owns the loop; this blocks the
/// native run-thread until Activity.onDestroy sets the shutdown flag.
pub fn run(state: *WebviewState) void {
    while (!state.shutdown) {
        std.time.sleep(50 * std.time.ns_per_ms);
    }
}

/// Destroy the webview binding and release JNI global references.
pub fn destroy(state: *WebviewState) void {
    if (state.jni_initialized) {
        if (currentEnv()) |env| {
            if (state.activity) |activity| jni.deleteGlobalRef(env, activity);
            if (state.webview) |webview| jni.deleteGlobalRef(env, webview);
        }
        state.jni_env = null;
        state.activity = null;
        state.webview = null;
        state.webview_class = null;
        state.jni_initialized = false;
    }
}

/// Register the IPC dispatch handle for the Android WebView.
///
/// The generated GossamerActivity already registered the GossamerBridge JS
/// interface in onCreate, so this only records the native handle that
/// GossamerBridge.nativePostMessage dispatches against. (The old code
/// constructed a second bridge and re-registered it — a double registration
/// that this removes.)
pub fn registerIPCHandler(_: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    ipc_handle = handle;
}

//==============================================================================
// IPC Message Handling
//==============================================================================

/// Dispatch handle for the Java bridge callback.
var ipc_handle: ?*GossamerHandle = null;

/// Called from Java GossamerBridge.postMessage (@JavascriptInterface).
/// Parses the JSON IPC message, dispatches to the bound callback, and sends the
/// response back via evaluateJavascript.
export fn Java_io_gossamer_GossamerBridge_nativePostMessage(
    env: jni.JNIEnv,
    _: jni.jobject, // this (GossamerBridge instance)
    message: jni.jstring,
) void {
    const handle = ipc_handle orelse return;
    const msg = message orelse return;

    const msg_chars = jni.getStringUTFChars(env, msg) orelse return;
    defer jni.releaseStringUTFChars(env, msg, msg_chars);
    const msg_slice = std.mem.span(msg_chars);

    const id = comp.extractJsonField(msg_slice, "id") orelse return;
    const name = comp.extractJsonField(msg_slice, "name") orelse return;
    const payload = comp.extractJsonField(msg_slice, "payload") orelse "";

    const entry = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    const allocator = std.heap.c_allocator;
    const payload_z = allocator.dupeZ(u8, payload) catch return;
    defer allocator.free(payload_z);
    const response_ptr = entry.callback(payload_z, entry.user_data);
    const response = std.mem.span(response_ptr);
    sendIPCResponse(handle, id, response);
}

//==============================================================================
// IPC Response Helpers
//==============================================================================

fn sendIPCResponse(handle: *GossamerHandle, id: []const u8, response: []const u8) void {
    const allocator = std.heap.c_allocator;
    const escaped = escapeForJS(allocator, response) catch return;
    defer allocator.free(escaped);
    const js = std.fmt.allocPrintSentinel(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].resolve(JSON.parse(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, escaped, id },
        0,
    ) catch return;
    defer allocator.free(js);
    eval(&handle.webview, js) catch {};
}

fn sendIPCError(handle: *GossamerHandle, id: []const u8, msg_text: []const u8) void {
    const allocator = std.heap.c_allocator;
    const js = std.fmt.allocPrintSentinel(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].reject(new Error(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, msg_text, id },
        0,
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

//==============================================================================
// JNI Entry Points (Activity lifecycle)
//==============================================================================

/// Cached references set by the Java launcher at nativeInit.
var android_jni_env: ?jni.JNIEnv = null;
var android_vm: ?jni.JavaVM = null;
var android_activity: jni.jobject = null;
var android_webview: jni.jobject = null;
/// Screen pixel dimensions cached from nativeInit (populated by Java).
var android_screen_width: u32 = 1080;
var android_screen_height: u32 = 1920;

/// Called by Java to hand over the Activity, WebView, and screen dimensions.
///
/// Java signature (generated GossamerActivity):
///   native void nativeInit(Activity activity, WebView webview, int w, int h)
///
/// The local refs Java passes are valid only for this call, so we promote them
/// to GLOBAL refs before storing. We also cache the process JavaVM so other
/// threads can attach.
export fn Java_io_gossamer_GossamerActivity_nativeInit(
    env: jni.JNIEnv,
    _: jni.jobject, // this (GossamerActivity)
    activity: jni.jobject,
    webview: jni.jobject,
    screen_width: jni.jint,
    screen_height: jni.jint,
) void {
    android_jni_env = env;
    android_vm = jni.getJavaVM(env);
    android_activity = jni.newGlobalRef(env, activity);
    android_webview = jni.newGlobalRef(env, webview);
    if (screen_width > 0) android_screen_width = @intCast(screen_width);
    if (screen_height > 0) android_screen_height = @intCast(screen_height);
}

/// Called by Java when the Activity is destroyed. Signals the native run loop
/// to exit and clears references.
export fn Java_io_gossamer_GossamerActivity_nativeDestroy(
    _: jni.JNIEnv,
    _: jni.jobject,
) void {
    if (ipc_handle) |handle| handle.webview.shutdown = true;
    android_jni_env = null;
    android_activity = null;
    android_webview = null;
}
