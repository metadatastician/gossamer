// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Android non-UI component dispatch core
//
// Gossamer hosts a WebView inside an Activity, but a real Android app also
// needs background components that have NO webview and NO Activity in scope:
//
//   * a foreground Service        (long-running work, notification)
//   * a BroadcastReceiver         (boot-completed, custom actions)
//   * an AppWidgetProvider        (home-screen widget)
//
// This module is the shared dispatch core those three hosts sit on. It lets a
// downstream app register PURE handlers — the exact same C-ABI callback shape
// already used for webview IPC (`fn(json) -> directive`) — against component
// lifecycle events, WITHOUT the app touching JNI. Gossamer owns every JNI call;
// the app writes Rust/Idris/Zig that receives a JSON event string and returns a
// directive string.
//
// Two wire formats cross this boundary, each trivially parseable by the side
// that must read it:
//
//   * INBOUND event  (JVM -> handler): a flat JSON object, e.g.
//       {"event":"onStartCommand","action":"","startId":"1"}
//     Native already has a minimal JSON field reader, so JSON costs nothing
//     here and stays consistent with the webview IPC protocol.
//
//   * OUTBOUND directive (handler -> JVM): newline/tab `key\tvalue` records,
//     e.g.
//       foreground\t1
//       title\tNeuroPhone
//       text\tListening
//       fgType\tdataSync
//       sticky\t1
//     The GENERATED Java parses this with a four-line splitter — no JSON
//     reader, no escaping ambiguity, nothing for a downstream app to hand-roll.
//
// Registration is process-global on purpose: a BroadcastReceiver can fire when
// no Activity (hence no GossamerHandle) exists. Handlers are typically bound
// once from the app's `JNI_OnLoad` / init and live for the process.
//
// Pure Zig: compiles on any target, so its `test` blocks run on host CI.

const std = @import("std");

/// Component callback ABI — identical to `main.BindingCallback`. A handler
/// receives a NUL-terminated JSON event string (plus its registration user
/// data) and returns a NUL-terminated directive string. The returned pointer
/// is owned by the handler (static, arena, or leak-by-design — same contract
/// as the existing webview IPC callbacks); gossamer only reads it.
pub const ComponentCallback = *const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8;

/// The three component namespaces. Kept distinct so their lifecycles (and the
/// Idris linear models in Gossamer.ABI.AndroidComponents) stay separable.
pub const Component = enum { service, receiver, widget };

/// Result codes mirror `main.Result` numeric values so the C ABI is uniform.
pub const BindResult = enum(c_int) {
    ok = 0,
    @"error" = 1,
    invalid_param = 2,
    out_of_memory = 3,
};

const MAX_HANDLERS_PER_COMPONENT = 64;
const MAX_KEY_LEN = 128;

const Handler = struct {
    used: bool = false,
    key_buf: [MAX_KEY_LEN]u8 = undefined,
    key_len: usize = 0,
    callback: ?ComponentCallback = null,
    user_data: ?*anyopaque = null,

    fn keyMatches(self: *const Handler, key: []const u8) bool {
        return self.used and self.key_len == key.len and
            std.mem.eql(u8, self.key_buf[0..self.key_len], key);
    }
};

const Registry = struct {
    slots: [MAX_HANDLERS_PER_COMPONENT]Handler = [_]Handler{.{}} ** MAX_HANDLERS_PER_COMPONENT,

    fn find(self: *Registry, key: []const u8) ?*Handler {
        for (&self.slots) |*h| {
            if (h.keyMatches(key)) return h;
        }
        return null;
    }

    fn freeSlot(self: *Registry) ?*Handler {
        for (&self.slots) |*h| {
            if (!h.used) return h;
        }
        return null;
    }

    fn put(self: *Registry, key: []const u8, cb: ComponentCallback, user: ?*anyopaque) BindResult {
        if (key.len == 0 or key.len > MAX_KEY_LEN) return .invalid_param;
        // Re-binding the same key overwrites in place (idempotent registration).
        const dst = self.find(key) orelse (self.freeSlot() orelse return .out_of_memory);
        @memcpy(dst.key_buf[0..key.len], key);
        dst.key_len = key.len;
        dst.callback = cb;
        dst.user_data = user;
        dst.used = true;
        return .ok;
    }

    fn count(self: *Registry) usize {
        var n: usize = 0;
        for (&self.slots) |*h| {
            if (h.used) n += 1;
        }
        return n;
    }

    fn clear(self: *Registry) void {
        for (&self.slots) |*h| h.* = .{};
    }
};

var g_service = Registry{};
var g_receiver = Registry{};
var g_widget = Registry{};

fn registryFor(component: Component) *Registry {
    return switch (component) {
        .service => &g_service,
        .receiver => &g_receiver,
        .widget => &g_widget,
    };
}

/// Bind a handler for `key` on `component`. `key` is copied (the caller may
/// free it after this returns). Returns `.ok` on success.
pub fn bind(component: Component, key: []const u8, cb: ComponentCallback, user: ?*anyopaque) BindResult {
    return registryFor(component).put(key, cb, user);
}

/// Dispatch an event to the handler registered under `key`. Returns the
/// directive the handler produced (borrowed, handler-owned), or null when no
/// handler is bound for `key` — in which case the JVM host applies its default
/// behaviour (e.g. START_STICKY with no foreground change).
pub fn dispatch(component: Component, key: []const u8, event_json: [*:0]const u8) ?[*:0]const u8 {
    const h = registryFor(component).find(key) orelse return null;
    const cb = h.callback orelse return null;
    return cb(event_json, h.user_data);
}

/// Number of handlers currently bound for a component (diagnostics/tests).
pub fn handlerCount(component: Component) usize {
    return registryFor(component).count();
}

/// Drop every binding for a component. Exposed for tests and for a clean
/// teardown path; not part of the app-facing ABI.
pub fn resetForTest(component: Component) void {
    registryFor(component).clear();
}

//==============================================================================
// Shared parsing helpers (reused by the webview bridge and the component hosts)
//==============================================================================

/// Extract a string field from a flat `{"key":"value", ...}` JSON object.
/// Minimal by design — the IPC/event envelopes gossamer emits are flat and
/// machine-generated, so a full JSON parser is unnecessary at this boundary.
pub fn extractJsonField(json: []const u8, key: []const u8) ?[]const u8 {
    var search_buf: [MAX_KEY_LEN + 4]u8 = undefined;
    if (key.len + 3 > search_buf.len) return null;
    search_buf[0] = '"';
    @memcpy(search_buf[1 .. 1 + key.len], key);
    search_buf[1 + key.len] = '"';
    search_buf[2 + key.len] = ':';
    const needle = search_buf[0 .. 3 + key.len];

    const at = std.mem.indexOf(u8, json, needle) orelse return null;
    var i = at + needle.len;
    // Skip optional whitespace and the opening quote of the value.
    while (i < json.len and (json[i] == ' ' or json[i] == '\t')) : (i += 1) {}
    if (i >= json.len or json[i] != '"') return null;
    i += 1;
    const value_start = i;
    while (i < json.len) : (i += 1) {
        if (json[i] == '"' and json[i - 1] != '\\') return json[value_start..i];
    }
    return null;
}

/// Append a `key\tvalue` record (newline-terminated) to a directive builder.
/// This is the canonical way the component hosts assemble what they pass to the
/// generated Java; exposing it keeps the wire format in exactly one place.
pub fn appendDirective(buf: *std.ArrayListUnmanaged(u8), allocator: std.mem.Allocator, key: []const u8, value: []const u8) !void {
    try buf.appendSlice(allocator, key);
    try buf.append(allocator, '\t');
    // Tabs/newlines in a value would corrupt the record grid; replace them.
    for (value) |ch| {
        const safe: u8 = switch (ch) {
            '\t', '\n', '\r' => ' ',
            else => ch,
        };
        try buf.append(allocator, safe);
    }
    try buf.append(allocator, '\n');
}

//==============================================================================
// Tests (host-runnable)
//==============================================================================

const testing = std.testing;

fn echoHandler(_: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    return "ok\t1\n";
}

test "bind then dispatch invokes the registered handler" {
    resetForTest(.service);
    try testing.expectEqual(BindResult.ok, bind(.service, "onStartCommand", &echoHandler, null));
    try testing.expectEqual(@as(usize, 1), handlerCount(.service));
    const out = dispatch(.service, "onStartCommand", "{\"event\":\"onStartCommand\"}");
    try testing.expect(out != null);
    try testing.expectEqualStrings("ok\t1\n", std.mem.span(out.?));
}

test "dispatch with no binding returns null (host applies default)" {
    resetForTest(.receiver);
    try testing.expect(dispatch(.receiver, "android.intent.action.BOOT_COMPLETED", "{}") == null);
}

test "re-binding the same key overwrites in place (idempotent)" {
    resetForTest(.widget);
    try testing.expectEqual(BindResult.ok, bind(.widget, "onUpdate", &echoHandler, null));
    try testing.expectEqual(BindResult.ok, bind(.widget, "onUpdate", &echoHandler, null));
    try testing.expectEqual(@as(usize, 1), handlerCount(.widget));
}

test "registries are independent per component" {
    resetForTest(.service);
    resetForTest(.receiver);
    _ = bind(.service, "onCreate", &echoHandler, null);
    try testing.expectEqual(@as(usize, 1), handlerCount(.service));
    try testing.expectEqual(@as(usize, 0), handlerCount(.receiver));
}

test "empty key is rejected" {
    resetForTest(.service);
    try testing.expectEqual(BindResult.invalid_param, bind(.service, "", &echoHandler, null));
}

test "extractJsonField reads flat string fields" {
    const j = "{\"event\":\"onReceive\",\"action\":\"android.intent.action.BOOT_COMPLETED\"}";
    try testing.expectEqualStrings("onReceive", extractJsonField(j, "event").?);
    try testing.expectEqualStrings("android.intent.action.BOOT_COMPLETED", extractJsonField(j, "action").?);
    try testing.expect(extractJsonField(j, "missing") == null);
}

test "appendDirective builds tab/newline records and sanitises control chars" {
    var buf = std.ArrayListUnmanaged(u8){};
    defer buf.deinit(testing.allocator);
    try appendDirective(&buf, testing.allocator, "title", "Neuro\tPhone");
    try appendDirective(&buf, testing.allocator, "sticky", "1");
    try testing.expectEqualStrings("title\tNeuro Phone\nsticky\t1\n", buf.items);
}
