// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android BroadcastReceiver host
//
// Native side of the generated `io.gossamer.GossamerReceiver` (a subclass of
// android.content.BroadcastReceiver). A BroadcastReceiver is the transient,
// JVM-owned opposite of the Service: the JVM constructs it, calls onReceive
// exactly once, and discards it. There is no Activity and no webview in scope.
//
//   onReceive(action, extrasJson) -> handler keyed by `action` -> directive
//
// Handlers are keyed by the Intent action they care about (e.g.
// "android.intent.action.BOOT_COMPLETED"), so an app binds one handler per
// action and gossamer routes precisely.
//
// Directive verbs understood by the generated Java (one per line):
//   startService            io.gossamer.GossamerService
//   startForegroundService  io.gossamer.GossamerService
//   updateWidgets           1        (broadcast an AppWidget update)
//   log                     <text>
//
// Linearity note: each onReceive is a single scoped borrow that must complete
// within the call window (Android tears the receiver down on return). The
// formal model is the one-shot RcvLive -> RcvComplete machine in
// Gossamer.ABI.AndroidComponents.

const std = @import("std");
const jni = @import("jni.zig");
const comp = @import("android_components.zig");

const c_alloc = std.heap.c_allocator;

export fn Java_io_gossamer_GossamerReceiver_nativeOnReceive(
    env: jni.JNIEnv,
    _: jni.jobject,
    action_j: jni.jstring,
    extras_j: jni.jstring,
) jni.jstring {
    if (action_j == null) return null;
    const action_chars = jni.getStringUTFChars(env, action_j) orelse return null;
    defer jni.releaseStringUTFChars(env, action_j, action_chars);
    const action = std.mem.span(action_chars);

    var extras_slice: []const u8 = "{}";
    var extras_chars: ?[*:0]const u8 = null;
    if (extras_j != null) {
        extras_chars = jni.getStringUTFChars(env, extras_j);
        if (extras_chars) |ch| extras_slice = std.mem.span(ch);
    }
    defer if (extras_chars) |ch| jni.releaseStringUTFChars(env, extras_j, ch);

    const event_json = std.fmt.allocPrintZ(
        c_alloc,
        "{{\"event\":\"onReceive\",\"action\":\"{s}\",\"extras\":{s}}}",
        .{ action, extras_slice },
    ) catch return null;
    defer c_alloc.free(event_json);

    const directive = comp.dispatch(.receiver, action, event_json) orelse return null;
    const result = jni.newStringUTF(env, directive);
    _ = jni.clearPendingException(env);
    return result;
}

/// App-facing registration: bind a handler for a specific Intent action.
export fn gossamer_receiver_bind(
    action: [*:0]const u8,
    callback: ?comp.ComponentCallback,
    user_data: ?*anyopaque,
) comp.BindResult {
    const cb = callback orelse return .invalid_param;
    return comp.bind(.receiver, std.mem.span(action), cb, user_data);
}

//==============================================================================
// Tests (host-runnable)
//==============================================================================

const testing = std.testing;

fn bootHandler(_: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    return "startForegroundService\tio.gossamer.GossamerService\n";
}

test "gossamer_receiver_bind routes by action" {
    comp.resetForTest(.receiver);
    try testing.expectEqual(
        comp.BindResult.ok,
        gossamer_receiver_bind("android.intent.action.BOOT_COMPLETED", &bootHandler, null),
    );
    const hit = comp.dispatch(.receiver, "android.intent.action.BOOT_COMPLETED", "{\"event\":\"onReceive\"}");
    try testing.expect(hit != null);
    try testing.expect(std.mem.indexOf(u8, std.mem.span(hit.?), "startForegroundService") != null);
    // A different action with no binding falls through to host default.
    try testing.expect(comp.dispatch(.receiver, "android.intent.action.SCREEN_ON", "{}") == null);
}
