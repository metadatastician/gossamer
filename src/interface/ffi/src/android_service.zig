// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android foreground Service host
//
// Native side of the generated `io.gossamer.GossamerService` (a subclass of
// android.app.Service). The JVM owns the Service lifecycle; this module turns
// each lifecycle callback into a dispatch to an app-registered handler and
// returns a directive the generated Java applies.
//
//   onCreate        -> handler "onCreate"        -> directive (e.g. channel setup)
//   onStartCommand  -> handler "onStartCommand"  -> directive (foreground notif + sticky)
//   onDestroy       -> handler "onDestroy"       -> (teardown; directive ignored)
//
// The foreground-notification directive understood by the generated Java:
//   foreground   1            (start in foreground; 0/absent = background)
//   channelId    <id>         (notification channel; created if absent)
//   channelName  <label>
//   title        <text>
//   text         <body>
//   fgType       dataSync|location|connectedDevice|none   (SDK 34+ type)
//   sticky       1            (START_STICKY; 0/absent = START_NOT_STICKY)
//
// Lifecycle/linearity note: a Service is the long-lived, JVM-owned analogue of
// the webview handle. Its formal model lives in
// Gossamer.ABI.AndroidComponents (SvcCreated -> SvcStarted* -> SvcDestroyed,
// Destroyed terminal). The native invariant enforced here mirrors the plugin
// liveness check: no dispatch occurs once the JVM has driven the Service to
// onDestroy, because the generated Java stops calling in and any late handler
// is simply absent from the registry.

const std = @import("std");
const jni = @import("jni.zig");
const comp = @import("android_components.zig");

const c_alloc = std.heap.c_allocator;

/// Build the inbound event JSON for a Service lifecycle callback and dispatch
/// it, returning the directive as a freshly-allocated Java String (or null,
/// meaning "host default").
fn dispatchService(env: jni.JNIEnv, event: []const u8, action_j: jni.jstring, flags: jni.jint, start_id: jni.jint) jni.jstring {
    // Read the optional Intent action string (may be null on bare restarts).
    var action_slice: []const u8 = "";
    var action_chars: ?[*:0]const u8 = null;
    if (action_j != null) {
        action_chars = jni.getStringUTFChars(env, action_j);
        if (action_chars) |ch| action_slice = std.mem.span(ch);
    }
    defer if (action_chars) |ch| jni.releaseStringUTFChars(env, action_j, ch);

    const event_json = std.fmt.allocPrintZ(
        c_alloc,
        "{{\"event\":\"{s}\",\"action\":\"{s}\",\"flags\":\"{d}\",\"startId\":\"{d}\"}}",
        .{ event, action_slice, flags, start_id },
    ) catch return null;
    defer c_alloc.free(event_json);

    const directive = comp.dispatch(.service, event, event_json) orelse return null;
    const result = jni.newStringUTF(env, directive);
    // A bridged native method must never return to the JVM with a pending
    // exception (e.g. OOM from NewStringUTF); clear defensively.
    _ = jni.clearPendingException(env);
    return result;
}

export fn Java_io_gossamer_GossamerService_nativeOnCreate(
    env: jni.JNIEnv,
    _: jni.jobject,
) jni.jstring {
    return dispatchService(env, "onCreate", null, 0, 0);
}

export fn Java_io_gossamer_GossamerService_nativeOnStartCommand(
    env: jni.JNIEnv,
    _: jni.jobject,
    action: jni.jstring,
    flags: jni.jint,
    start_id: jni.jint,
) jni.jstring {
    return dispatchService(env, "onStartCommand", action, flags, start_id);
}

export fn Java_io_gossamer_GossamerService_nativeOnDestroy(
    env: jni.JNIEnv,
    _: jni.jobject,
) void {
    // onDestroy is terminal: dispatch for teardown, ignore any directive.
    _ = dispatchService(env, "onDestroy", null, 0, 0);
}

/// App-facing registration: bind a handler for a Service lifecycle event
/// ("onCreate" | "onStartCommand" | "onDestroy"). Mirrors gossamer_channel_bind.
export fn gossamer_service_bind(
    event: [*:0]const u8,
    callback: ?comp.ComponentCallback,
    user_data: ?*anyopaque,
) comp.BindResult {
    const cb = callback orelse return .invalid_param;
    return comp.bind(.service, std.mem.span(event), cb, user_data);
}

//==============================================================================
// Tests (host-runnable — exercise the registry path, not the JNI calls)
//==============================================================================

const testing = std.testing;

fn fgHandler(_: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    return "foreground\t1\ntitle\tNeuroPhone\ntext\tListening\nfgType\tdataSync\nsticky\t1\n";
}

test "gossamer_service_bind registers an onStartCommand handler" {
    comp.resetForTest(.service);
    try testing.expectEqual(comp.BindResult.ok, gossamer_service_bind("onStartCommand", &fgHandler, null));
    const out = comp.dispatch(.service, "onStartCommand", "{\"event\":\"onStartCommand\"}");
    try testing.expect(out != null);
    // The directive carries a foreground record the generated Java will apply.
    try testing.expect(std.mem.indexOf(u8, std.mem.span(out.?), "foreground\t1") != null);
}

test "gossamer_service_bind rejects a null callback" {
    comp.resetForTest(.service);
    try testing.expectEqual(comp.BindResult.invalid_param, gossamer_service_bind("onCreate", null, null));
}
