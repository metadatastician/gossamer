// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android AppWidgetProvider host
//
// Native side of the generated `io.gossamer.GossamerWidget` (a subclass of
// android.appwidget.AppWidgetProvider). A home-screen widget renders through
// RemoteViews, which can only be constructed JVM-side; gossamer keeps the
// handler pure by having it return a render directive that the generated Java
// applies to the RemoteViews.
//
//   onUpdate(idsJson)   -> handler "onUpdate"   -> render directive
//   onEnabled           -> handler "onEnabled"  -> (directive ignored)
//   onDisabled          -> handler "onDisabled" -> (directive ignored)
//   onReceive(action)   -> handler keyed by `action` (custom widget taps)
//
// Render directive verbs understood by the generated Java (one per line):
//   view  <viewId>  text      <string>     (RemoteViews.setTextViewText)
//   view  <viewId>  progress  <0..100>     (RemoteViews.setProgressBar, max 100)
//   view  <viewId>  show                   (View.VISIBLE)
//   view  <viewId>  hide                   (View.GONE)
//   click <viewId>  service   <className>  (tap starts a service)
//   click <viewId>  activity  <className>  (tap opens an activity)
//   click <viewId>  action    <intentAction> (tap broadcasts a widget action)
//
// `<viewId>` is the resource ENTRY name (e.g. "widget_state"); the generated
// Java resolves it against the app package's R.id namespace. This keeps native
// free of any compiled R constants.

const std = @import("std");
const jni = @import("jni.zig");
const comp = @import("android_components.zig");

const c_alloc = std.heap.c_allocator;

fn dispatchWidget(env: jni.JNIEnv, key: []const u8, payload_j: jni.jstring) jni.jstring {
    var payload_slice: []const u8 = "{}";
    var payload_chars: ?[*:0]const u8 = null;
    if (payload_j != null) {
        payload_chars = jni.getStringUTFChars(env, payload_j);
        if (payload_chars) |ch| payload_slice = std.mem.span(ch);
    }
    defer if (payload_chars) |ch| jni.releaseStringUTFChars(env, payload_j, ch);

    const event_json = std.fmt.allocPrintZ(
        c_alloc,
        "{{\"event\":\"{s}\",\"payload\":{s}}}",
        .{ key, payload_slice },
    ) catch return null;
    defer c_alloc.free(event_json);

    const directive = comp.dispatch(.widget, key, event_json) orelse return null;
    const result = jni.newStringUTF(env, directive);
    _ = jni.clearPendingException(env);
    return result;
}

export fn Java_io_gossamer_GossamerWidget_nativeOnUpdate(
    env: jni.JNIEnv,
    _: jni.jobject,
    ids_json: jni.jstring,
) jni.jstring {
    return dispatchWidget(env, "onUpdate", ids_json);
}

export fn Java_io_gossamer_GossamerWidget_nativeOnEnabled(
    env: jni.JNIEnv,
    _: jni.jobject,
) void {
    _ = dispatchWidget(env, "onEnabled", null);
}

export fn Java_io_gossamer_GossamerWidget_nativeOnDisabled(
    env: jni.JNIEnv,
    _: jni.jobject,
) void {
    _ = dispatchWidget(env, "onDisabled", null);
}

/// Custom widget actions (button taps) arrive here keyed by Intent action.
export fn Java_io_gossamer_GossamerWidget_nativeOnReceive(
    env: jni.JNIEnv,
    _: jni.jobject,
    action_j: jni.jstring,
) jni.jstring {
    if (action_j == null) return null;
    const action_chars = jni.getStringUTFChars(env, action_j) orelse return null;
    defer jni.releaseStringUTFChars(env, action_j, action_chars);
    const action = std.mem.span(action_chars);

    const event_json = std.fmt.allocPrintZ(
        c_alloc,
        "{{\"event\":\"onReceive\",\"action\":\"{s}\"}}",
        .{action},
    ) catch return null;
    defer c_alloc.free(event_json);

    const directive = comp.dispatch(.widget, action, event_json) orelse return null;
    const result = jni.newStringUTF(env, directive);
    _ = jni.clearPendingException(env);
    return result;
}

/// App-facing registration: bind a handler for a widget event ("onUpdate",
/// "onEnabled", "onDisabled") or a custom widget action string.
export fn gossamer_widget_bind(
    event: [*:0]const u8,
    callback: ?comp.ComponentCallback,
    user_data: ?*anyopaque,
) comp.BindResult {
    const cb = callback orelse return .invalid_param;
    return comp.bind(.widget, std.mem.span(event), cb, user_data);
}

//==============================================================================
// Tests (host-runnable)
//==============================================================================

const testing = std.testing;

fn renderHandler(_: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    return "view\twidget_state\ttext\tRunning\nview\twidget_salience\tprogress\t42\n";
}

test "gossamer_widget_bind onUpdate yields a render directive" {
    comp.resetForTest(.widget);
    try testing.expectEqual(comp.BindResult.ok, gossamer_widget_bind("onUpdate", &renderHandler, null));
    const out = comp.dispatch(.widget, "onUpdate", "{\"event\":\"onUpdate\"}");
    try testing.expect(out != null);
    const s = std.mem.span(out.?);
    try testing.expect(std.mem.indexOf(u8, s, "view\twidget_state\ttext\tRunning") != null);
    try testing.expect(std.mem.indexOf(u8, s, "progress\t42") != null);
}
