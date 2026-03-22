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
//   Android SDK WebView component
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

//==============================================================================
// JNI Type Definitions
//==============================================================================

/// JNI environment pointer (opaque — actual type from jni.h)
const JNIEnv = anyopaque;
/// Java object reference (opaque)
const jobject = ?*anyopaque;
/// Java class reference (opaque)
const jclass = ?*anyopaque;
/// Java method ID (opaque)
const jmethodID = ?*anyopaque;
/// Java string reference (opaque)
const jstring = ?*anyopaque;

/// Platform-specific webview state for Android.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// JNIEnv pointer — valid only on the thread that attached it
    jni_env: ?*JNIEnv,
    /// Reference to the Android Activity (jobject)
    activity: jobject,
    /// Reference to the Android WebView (jobject)
    webview: jobject,
    /// Whether JNI has been initialised
    jni_initialized: bool,
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
/// This function attaches to the existing Activity's WebView via JNI.
///
/// NOTE: Android apps are launched by the Java runtime, not by native code.
/// The native library is loaded via System.loadLibrary("gossamer") from
/// a GossamerActivity Java class. The JNIEnv and Activity reference are
/// passed to JNI_OnLoad / native method calls.
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
) PlatformError!WebviewState {
    // Android creates its Activity and WebView from Java.
    // The native side receives references via JNI callbacks.
    // This function is called from Gossamer's main entry point,
    // but on Android we must wait for the Java side to provide
    // the Activity and WebView references.
    _ = title;
    _ = width;
    _ = height;
    _ = resizable;
    _ = decorations;
    _ = fullscreen;

    // Check if JNI references have been provided by the Java launcher
    const env = android_jni_env orelse return PlatformError.JniInitFailed;
    const activity = android_activity orelse return PlatformError.JniInitFailed;
    const webview = android_webview orelse return PlatformError.WebviewCreateFailed;

    return WebviewState{
        .jni_env = env,
        .activity = activity,
        .webview = webview,
        .jni_initialized = true,
    };
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    // JNI call: webView.loadData(html, "text/html", "UTF-8")
    const env = state.jni_env orelse return PlatformError.OperationFailed;
    const webview = state.webview orelse return PlatformError.OperationFailed;
    _ = env;
    _ = webview;
    _ = html;
    // TODO: JNI FindClass("android/webkit/WebView"),
    //       GetMethodID("loadData", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"),
    //       NewStringUTF(html), CallVoidMethod(webview, loadData, htmlStr, mimeStr, encStr)
    return PlatformError.OperationFailed;
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    // JNI call: webView.loadUrl(url)
    _ = state;
    _ = url;
    return PlatformError.OperationFailed;
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    // JNI call: webView.evaluateJavascript(js, null)
    // Requires API level 19+
    _ = state;
    _ = js;
    return PlatformError.OperationFailed;
}

/// Set the window title (Activity title on Android).
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    // JNI call: activity.setTitle(title)
    _ = state;
    _ = title;
    return PlatformError.OperationFailed;
}

/// Resize the window (no-op on Android — WebView fills the Activity).
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    _ = state;
    _ = width;
    _ = height;
    // Android WebView fills the Activity — resize is not applicable
}

/// Run the event loop (no-op on Android — the Java runtime owns the loop).
pub fn run(_: *WebviewState) void {
    // On Android, the event loop is managed by the Android runtime.
    // This function blocks until the Activity is destroyed, using
    // the JNI-provided shutdown signal.
    // TODO: Wait on android_shutdown_event
}

/// Destroy the webview and release JNI references.
pub fn destroy(state: *WebviewState) void {
    if (state.jni_initialized) {
        // TODO: Delete global refs via JNI
        state.jni_env = null;
        state.activity = null;
        state.webview = null;
        state.jni_initialized = false;
    }
}

/// Register IPC handler for Android WebView.
///
/// Uses WebView.addJavascriptInterface() to expose a "GossamerBridge"
/// object to JavaScript. The bridge's postMessage method dispatches
/// to bound callbacks.
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    // TODO: JNI call:
    //   1. Create a Java class "GossamerBridge" with @JavascriptInterface postMessage(String)
    //   2. webView.addJavascriptInterface(bridge, "GossamerBridge")
    //   3. In postMessage, parse JSON and dispatch to handle.bindings
    _ = state;
    _ = handle;
    return PlatformError.OperationFailed;
}

//==============================================================================
// JNI Entry Points
//==============================================================================

/// Thread-local JNI references set by the Java launcher.
/// These are populated when the GossamerActivity calls native methods.
var android_jni_env: ?*JNIEnv = null;
var android_activity: jobject = null;
var android_webview: jobject = null;

/// Called by Java via JNI to provide the Activity and WebView references.
/// Java signature: native void nativeInit(Activity activity, WebView webview)
export fn Java_io_gossamer_GossamerActivity_nativeInit(
    env: ?*JNIEnv,
    _: jobject, // this (GossamerActivity)
    activity: jobject,
    webview: jobject,
) void {
    android_jni_env = env;
    android_activity = activity;
    android_webview = webview;
}

/// Called by Java when the Activity is destroyed.
export fn Java_io_gossamer_GossamerActivity_nativeDestroy(
    _: ?*JNIEnv,
    _: jobject,
) void {
    android_jni_env = null;
    android_activity = null;
    android_webview = null;
}
