// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android WebView Platform Implementation
//
// Provides platform-specific webview operations for Android using JNI
// to interface with android.webkit.WebView.
//
// This file is compiled when targeting aarch64-linux-android or
// x86_64-linux-android via the Android NDK.
//
// Dependencies:
//   Android NDK (libjnigraphics, libandroid, liblog)
//   Android SDK WebView component (API level 24+)
//

const std = @import("std");

//==============================================================================
// JNI Type Definitions
//==============================================================================

/// JNI environment pointer — wraps the function table used for all JNI calls.
/// On Android, each thread has its own JNIEnv obtained via AttachCurrentThread.
const JNIEnv = anyopaque;
/// Java object reference (opaque)
const jobject = ?*anyopaque;
/// Java class reference (opaque)
const jclass = ?*anyopaque;
/// Java method ID (opaque)
const jmethodID = ?*anyopaque;
/// Java string reference (opaque)
const jstring = ?*anyopaque;

/// JNI function table pointers — accessed via double indirection on JNIEnv.
/// These are declared as extern C functions for Zig to call through.
extern fn jni_FindClass(env: *JNIEnv, name: [*:0]const u8) jclass;
extern fn jni_GetMethodID(env: *JNIEnv, cls: jclass, name: [*:0]const u8, sig: [*:0]const u8) jmethodID;
extern fn jni_NewStringUTF(env: *JNIEnv, str: [*:0]const u8) jstring;
extern fn jni_CallVoidMethod(env: *JNIEnv, obj: jobject, method: jmethodID, ...) void;
extern fn jni_NewObject(env: *JNIEnv, cls: jclass, method: jmethodID, ...) jobject;
extern fn jni_DeleteGlobalRef(env: *JNIEnv, ref: jobject) void;
extern fn jni_NewGlobalRef(env: *JNIEnv, ref: jobject) jobject;
extern fn jni_GetStringUTFChars(env: *JNIEnv, str: jstring, isCopy: ?*u8) ?[*:0]const u8;
extern fn jni_ReleaseStringUTFChars(env: *JNIEnv, str: jstring, chars: [*:0]const u8) void;

/// Platform-specific webview state for Android.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// JNIEnv pointer — valid only on the thread that attached it
    jni_env: ?*JNIEnv,
    /// Global reference to the Android Activity (jobject)
    activity: jobject,
    /// Global reference to the Android WebView (jobject)
    webview: jobject,
    /// Cached class ref for android.webkit.WebView
    webview_class: jclass,
    /// Cached method IDs for WebView methods
    mid_loadData: jmethodID,
    mid_loadUrl: jmethodID,
    mid_evaluateJavascript: jmethodID,
    mid_addJavascriptInterface: jmethodID,
    /// Cached method ID for Activity.setTitle
    mid_setTitle: jmethodID,
    /// Whether JNI has been initialised
    jni_initialized: bool,
    /// Shutdown signal — set by Java when Activity.onDestroy fires
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

/// Create a new Android WebView.
///
/// On Android, the Activity must already exist (created by the Java launcher).
/// This function attaches to the existing Activity's WebView via JNI and
/// caches all method IDs for fast subsequent calls.
///
/// NOTE: Android apps are launched by the Java runtime, not by native code.
/// The native library is loaded via System.loadLibrary("gossamer") from
/// a GossamerActivity Java class. The JNIEnv and Activity reference are
/// passed to JNI_OnLoad / native method calls.
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
    _ = title; // Set via Activity.setTitle after creation
    _ = width; // Android fills the Activity
    _ = height;
    _ = min_width;
    _ = min_height;
    _ = max_width;
    _ = max_height;
    _ = resizable;
    _ = decorations;
    _ = fullscreen;
    _ = visible;

    // Check if JNI references have been provided by the Java launcher
    const env = android_jni_env orelse return PlatformError.JniInitFailed;
    const activity = android_activity orelse return PlatformError.JniInitFailed;
    const webview = android_webview orelse return PlatformError.WebviewCreateFailed;

    // Cache WebView class and method IDs for performance
    const wv_cls = jni_FindClass(env, "android/webkit/WebView");
    if (wv_cls == null) return PlatformError.WebviewCreateFailed;

    const mid_loadData = jni_GetMethodID(
        env,
        wv_cls,
        "loadData",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
    );
    const mid_loadUrl = jni_GetMethodID(
        env,
        wv_cls,
        "loadUrl",
        "(Ljava/lang/String;)V",
    );
    const mid_evaluateJavascript = jni_GetMethodID(
        env,
        wv_cls,
        "evaluateJavascript",
        "(Ljava/lang/String;Landroid/webkit/ValueCallback;)V",
    );
    const mid_addJsi = jni_GetMethodID(
        env,
        wv_cls,
        "addJavascriptInterface",
        "(Ljava/lang/Object;Ljava/lang/String;)V",
    );

    // Cache Activity.setTitle method ID
    const act_cls = jni_FindClass(env, "android/app/Activity");
    const mid_setTitle = if (act_cls != null)
        jni_GetMethodID(env, act_cls, "setTitle", "(Ljava/lang/CharSequence;)V")
    else
        null;

    return WebviewState{
        .jni_env = env,
        .activity = activity,
        .webview = webview,
        .webview_class = wv_cls,
        .mid_loadData = mid_loadData,
        .mid_loadUrl = mid_loadUrl,
        .mid_evaluateJavascript = mid_evaluateJavascript,
        .mid_addJavascriptInterface = mid_addJsi,
        .mid_setTitle = mid_setTitle,
        .jni_initialized = true,
        .shutdown = false,
    };
}

/// Load HTML content into the webview.
/// JNI call: webView.loadData(html, "text/html", "UTF-8")
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_loadData orelse return PlatformError.OperationFailed;

    const j_html = jni_NewStringUTF(env, html);
    const j_mime = jni_NewStringUTF(env, "text/html");
    const j_enc = jni_NewStringUTF(env, "UTF-8");

    if (j_html == null or j_mime == null or j_enc == null) {
        return PlatformError.OperationFailed;
    }

    jni_CallVoidMethod(env, webview, mid, j_html, j_mime, j_enc);
}

/// Navigate to a URL.
/// JNI call: webView.loadUrl(url)
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_loadUrl orelse return PlatformError.OperationFailed;

    const j_url = jni_NewStringUTF(env, url);
    if (j_url == null) return PlatformError.OperationFailed;

    jni_CallVoidMethod(env, webview, mid, j_url);
}

/// Evaluate JavaScript in the webview context.
/// JNI call: webView.evaluateJavascript(js, null)
/// Requires API level 19+ (minSdk 24 guarantees this).
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_evaluateJavascript orelse return PlatformError.OperationFailed;

    const j_js = jni_NewStringUTF(env, js);
    if (j_js == null) return PlatformError.OperationFailed;

    // null ValueCallback — fire and forget (response comes via IPC bridge)
    jni_CallVoidMethod(env, webview, mid, j_js, @as(jobject, null));
}

/// Set the window title (Activity title on Android).
/// JNI call: activity.setTitle(title)
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const activity = state.activity orelse return PlatformError.OperationFailed;
    const mid = state.mid_setTitle orelse return PlatformError.OperationFailed;

    const j_title = jni_NewStringUTF(env, title);
    if (j_title == null) return PlatformError.OperationFailed;

    jni_CallVoidMethod(env, activity, mid, j_title);
}

/// Resize the window (no-op on Android — WebView fills the Activity).
pub fn resize(_: *WebviewState, _: u32, _: u32) PlatformError!void {
    // Android WebView fills the Activity — resize is not applicable
}

/// Window visibility/state controls are not supported on Android.
pub fn show(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on Android.
pub fn hide(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on Android.
pub fn minimize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on Android.
pub fn maximize(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Window visibility/state controls are not supported on Android.
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

/// Register a persistent user script.
pub fn addUserScript(_: *WebviewState, _: [*:0]const u8) PlatformError!void {}

/// Z-order and move are not applicable on Android (single-activity model).
pub fn raise(_: *WebviewState) PlatformError!void {}
pub fn lower(_: *WebviewState) PlatformError!void {}
pub fn moveTo(_: *WebviewState, _: i32, _: i32) PlatformError!void {}

/// Requesting close is not supported on Android from the native shell layer.
pub fn requestClose(_: *WebviewState) PlatformError!void {
    return PlatformError.OperationFailed;
}

/// Run the event loop.
/// On Android, the Java runtime owns the event loop. This function blocks
/// by polling the shutdown flag, which is set when Activity.onDestroy fires.
pub fn run(state: *WebviewState) void {
    // Block until the Java side signals shutdown.
    // On Android, the native library stays loaded as long as the Activity
    // is alive. We poll with a short sleep to avoid burning CPU.
    while (!state.shutdown) {
        std.time.sleep(50 * std.time.ns_per_ms); // 50ms poll
    }
}

/// Destroy the webview and release JNI global references.
pub fn destroy(state: *WebviewState) void {
    if (state.jni_initialized) {
        if (state.jni_env) |env| {
            // Delete global references to prevent Java-side memory leaks
            if (state.activity) |activity| {
                jni_DeleteGlobalRef(env, activity);
            }
            if (state.webview) |webview| {
                jni_DeleteGlobalRef(env, webview);
            }
        }
        state.jni_env = null;
        state.activity = null;
        state.webview = null;
        state.webview_class = null;
        state.jni_initialized = false;
    }
}

/// Register IPC handler for Android WebView.
///
/// Uses WebView.addJavascriptInterface() to expose a "GossamerBridge"
/// object to JavaScript. When JS calls GossamerBridge.postMessage(msg),
/// the registered Java callback dispatches to handle.bindings.
///
/// The Java-side GossamerBridge class must exist in the APK and implement
/// @JavascriptInterface void postMessage(String msg). This is defined in
/// io.gossamer.GossamerBridge.java (shipped with the Gossamer Android SDK).
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    const mid = state.mid_addJavascriptInterface orelse return PlatformError.OperationFailed;

    // Store handle reference for the Java callback to use
    ipc_handle = handle;

    // Find the GossamerBridge Java class (must be in the APK)
    const bridge_cls = jni_FindClass(env, "io/gossamer/GossamerBridge");
    if (bridge_cls == null) return PlatformError.OperationFailed;

    // Locate constructor: GossamerBridge(long nativePtr)
    const bridge_init = jni_GetMethodID(env, bridge_cls, "<init>", "(J)V");
    if (bridge_init == null) return PlatformError.OperationFailed;

    // Construct a new GossamerBridge instance via NewObject, passing the
    // native handle pointer as the long constructor argument.
    // jni_NewObject is the correct JNI call for constructing new objects;
    // jni_CallObjectMethod would call an instance method, not a constructor.
    const native_ptr: i64 = @intCast(@intFromPtr(handle));
    const bridge = jni_NewObject(env, bridge_cls, bridge_init, native_ptr);
    if (bridge == null) return PlatformError.OperationFailed;

    // webView.addJavascriptInterface(bridge, "GossamerBridge")
    const j_name = jni_NewStringUTF(env, "GossamerBridge");
    if (j_name == null) return PlatformError.OperationFailed;

    jni_CallVoidMethod(env, webview, mid, bridge, j_name);
}

//==============================================================================
// IPC Message Handling
//==============================================================================

/// Thread-local handle reference for the Java callback.
var ipc_handle: ?*GossamerHandle = null;

/// Called from Java GossamerBridge.postMessage(@JavascriptInterface).
/// The Java side receives the JSON string from the JS bridge and forwards
/// it here via JNI. We parse the message, dispatch to the bound callback,
/// and send the response back via evaluateJavascript.
export fn Java_io_gossamer_GossamerBridge_nativePostMessage(
    env: ?*JNIEnv,
    _: jobject, // this (GossamerBridge instance)
    message: jstring,
) void {
    const handle = ipc_handle orelse return;
    const jni = env orelse return;
    const msg = message orelse return;

    // Extract UTF-8 string from Java String
    const msg_chars = jni_GetStringUTFChars(jni, msg, null) orelse return;
    defer jni_ReleaseStringUTFChars(jni, msg, msg_chars);
    const msg_slice = std.mem.span(msg_chars);

    // Parse JSON fields: id, name, payload
    const id = extractJsonField(msg_slice, "id") orelse return;
    const name = extractJsonField(msg_slice, "name") orelse return;
    const payload = extractJsonField(msg_slice, "payload") orelse "";

    // Look up the bound callback
    const callback = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    // Invoke the callback with the payload
    const allocator = std.heap.c_allocator;
    const payload_z = allocator.dupeZ(u8, payload) catch return;
    defer allocator.free(payload_z);
    const response_ptr = callback(payload_z);
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

//==============================================================================
// JNI Entry Points
//==============================================================================

/// Thread-local JNI references set by the Java launcher.
/// These are populated when the GossamerActivity calls native methods.
var android_jni_env: ?*JNIEnv = null;
var android_activity: jobject = null;
var android_webview: jobject = null;
/// Screen pixel dimensions cached from nativeInit — populated by Java before use.
var android_screen_width: u32 = 1080;
var android_screen_height: u32 = 1920;

/// Called by Java via JNI to provide the Activity, WebView, and screen dimensions.
///
/// Java signature:
///   native void nativeInit(Activity activity, WebView webview,
///                          int screenWidth, int screenHeight)
///
/// The Java side must create global references before calling this:
///   nativeInit(NewGlobalRef(activity), NewGlobalRef(webview),
///              displayMetrics.widthPixels, displayMetrics.heightPixels)
export fn Java_io_gossamer_GossamerActivity_nativeInit(
    env: ?*JNIEnv,
    _: jobject, // this (GossamerActivity)
    activity: jobject,
    webview: jobject,
    screen_width: i32,
    screen_height: i32,
) void {
    android_jni_env = env;
    android_activity = activity;
    android_webview = webview;
    // Cache screen dimensions so getScreenSize() can return meaningful values
    // without additional JNI calls on every query.
    if (screen_width > 0) android_screen_width = @intCast(screen_width);
    if (screen_height > 0) android_screen_height = @intCast(screen_height);
}

/// Called by Java when the Activity is destroyed.
/// Signals the native run loop to exit and clears references.
export fn Java_io_gossamer_GossamerActivity_nativeDestroy(
    _: ?*JNIEnv,
    _: jobject,
) void {
    // Signal shutdown to the run() poll loop
    if (ipc_handle) |handle| {
        handle.webview.shutdown = true;
    }
    android_jni_env = null;
    android_activity = null;
    android_webview = null;
}
