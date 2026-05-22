// Gossamer Webview Lifecycle E2E Tests (Mocked FFI)
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Ported 1:1 from tests/e2e/webview_lifecycle_test.ts.
//
// Simulates the full webview lifecycle and integration flows using a mock FFI
// layer — NO real native code is invoked, so this is "e2e" only in the sense
// that it exercises multi-component interactions (state machine + IPC + caps).
// Despite the e2e name no display server is required.
//
// Covered:
//   - WebviewHandle state machine: Created → Loaded → Running → Destroyed
//   - IPC channel open / bind / close round-trip
//   - Capability grant → use → revoke sequence
//   - Error propagation through the handle lifecycle
//
// Run via:
//   zig test src/interface/ffi/test/webview_lifecycle_test.zig

const std = @import("std");
const testing = std.testing;

//==============================================================================
// WebviewState — mirrors Types.idr WebviewState
//==============================================================================

const WebviewState = enum { Created, Loaded, Running, Destroyed };

fn isValidTransition(from: WebviewState, to: WebviewState) bool {
    return switch (from) {
        .Created   => to == .Loaded or to == .Destroyed,
        .Loaded    => to == .Loaded or to == .Running or to == .Destroyed,
        .Running   => to == .Destroyed,
        .Destroyed => false,
    };
}

const LifecycleError = error{ InvalidTransition, CreateFailed };

//==============================================================================
// Mock FFI — intercepts gossamer_* calls
//==============================================================================

const FFICall = struct {
    fn_name: []const u8,
};

const MockFFI = struct {
    allocator: std.mem.Allocator,
    calls: std.ArrayList(FFICall),
    handle_counter: u64 = 1000,
    channel_counter: u64 = 2000,
    cap_counter: u64 = 3000,
    revoked_caps: std.AutoHashMap(u64, void),
    fail_on_next: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator) MockFFI {
        return .{
            .allocator = allocator,
            .calls = .empty,
            .revoked_caps = std.AutoHashMap(u64, void).init(allocator),
        };
    }

    pub fn deinit(self: *MockFFI) void {
        self.calls.deinit(self.allocator);
        self.revoked_caps.deinit();
    }

    pub fn setFailNext(self: *MockFFI, fn_name: []const u8) void {
        self.fail_on_next = fn_name;
    }

    fn record(self: *MockFFI, fn_name: []const u8) !void {
        try self.calls.append(self.allocator, .{ .fn_name = fn_name });
    }

    fn shouldFail(self: *MockFFI, fn_name: []const u8) bool {
        if (self.fail_on_next) |target| {
            if (std.mem.eql(u8, target, fn_name)) {
                self.fail_on_next = null;
                return true;
            }
        }
        return false;
    }

    pub fn gossamer_create(self: *MockFFI, _: []const u8, _: u32, _: u32) !u64 {
        try self.record("gossamer_create");
        if (self.shouldFail("gossamer_create")) return 0;
        self.handle_counter += 1;
        return self.handle_counter - 1;
    }

    pub fn gossamer_load_html(self: *MockFFI, _: u64, _: []const u8) !c_int {
        try self.record("gossamer_load_html");
        if (self.shouldFail("gossamer_load_html")) return 1;
        return 0;
    }

    pub fn gossamer_navigate(self: *MockFFI, _: u64, _: []const u8) !c_int {
        try self.record("gossamer_navigate");
        if (self.shouldFail("gossamer_navigate")) return 1;
        return 0;
    }

    pub fn gossamer_eval(self: *MockFFI, _: u64, _: []const u8) !c_int {
        try self.record("gossamer_eval");
        return 0;
    }

    pub fn gossamer_set_title(self: *MockFFI, _: u64, _: []const u8) !c_int {
        try self.record("gossamer_set_title");
        return 0;
    }

    pub fn gossamer_run(self: *MockFFI, _: u64) !void {
        try self.record("gossamer_run");
    }

    pub fn gossamer_destroy(self: *MockFFI, _: u64) !void {
        try self.record("gossamer_destroy");
    }

    pub fn gossamer_channel_open(self: *MockFFI, _: u64) !u64 {
        try self.record("gossamer_channel_open");
        self.channel_counter += 1;
        return self.channel_counter - 1;
    }

    pub fn gossamer_channel_bind(self: *MockFFI, _: u64, _: []const u8, _: u64, _: u64) !c_int {
        try self.record("gossamer_channel_bind");
        return 0;
    }

    pub fn gossamer_channel_close(self: *MockFFI, _: u64) !void {
        try self.record("gossamer_channel_close");
    }

    pub fn gossamer_cap_grant(self: *MockFFI, _: u32) !u64 {
        try self.record("gossamer_cap_grant");
        if (self.shouldFail("gossamer_cap_grant")) return 0;
        self.cap_counter += 1;
        return self.cap_counter - 1;
    }

    pub fn gossamer_cap_check(self: *MockFFI, token: u64) !c_int {
        try self.record("gossamer_cap_check");
        if (token == 0) return 10; // CapabilityDenied
        if (self.revoked_caps.contains(token)) return 10;
        return 0; // Ok
    }

    pub fn gossamer_cap_revoke(self: *MockFFI, token: u64) !void {
        try self.record("gossamer_cap_revoke");
        try self.revoked_caps.put(token, {});
    }

    pub fn countCalls(self: *const MockFFI, fn_name: []const u8) usize {
        var n: usize = 0;
        for (self.calls.items) |c| {
            if (std.mem.eql(u8, c.fn_name, fn_name)) n += 1;
        }
        return n;
    }
};

//==============================================================================
// WebviewShell — thin wrapper exercising the FFI via state machine
//==============================================================================

const WebviewShell = struct {
    ffi: *MockFFI,
    state: WebviewState = .Created,
    handle: u64,

    pub fn init(ffi: *MockFFI, title: []const u8) !WebviewShell {
        const h = try ffi.gossamer_create(title, 800, 600);
        if (h == 0) return LifecycleError.CreateFailed;
        return .{ .ffi = ffi, .state = .Created, .handle = h };
    }

    pub fn getState(self: *const WebviewShell) WebviewState {
        return self.state;
    }

    fn assertValidTransition(self: *const WebviewShell, to: WebviewState) !void {
        if (!isValidTransition(self.state, to)) return LifecycleError.InvalidTransition;
    }

    pub fn loadHTML(self: *WebviewShell, html: []const u8) !c_int {
        try self.assertValidTransition(.Loaded);
        const r = try self.ffi.gossamer_load_html(self.handle, html);
        if (r == 0) self.state = .Loaded;
        return r;
    }

    pub fn navigate(self: *WebviewShell, url: []const u8) !c_int {
        try self.assertValidTransition(.Loaded);
        const r = try self.ffi.gossamer_navigate(self.handle, url);
        if (r == 0) self.state = .Loaded;
        return r;
    }

    pub fn eval(self: *WebviewShell, js: []const u8) !c_int {
        return self.ffi.gossamer_eval(self.handle, js);
    }

    pub fn setTitle(self: *WebviewShell, title: []const u8) !c_int {
        return self.ffi.gossamer_set_title(self.handle, title);
    }

    pub fn run(self: *WebviewShell) !void {
        try self.assertValidTransition(.Running);
        try self.ffi.gossamer_run(self.handle);
        self.state = .Destroyed;
    }

    pub fn destroy(self: *WebviewShell) !void {
        try self.assertValidTransition(.Destroyed);
        try self.ffi.gossamer_destroy(self.handle);
        self.state = .Destroyed;
    }
};

//==============================================================================
// Tests: webview lifecycle state machine
//==============================================================================

test "e2e/lifecycle: Created → Loaded → Running → Destroyed" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Test Window");

    try testing.expectEqual(WebviewState.Created, w.getState());

    const r = try w.loadHTML("<html><body>Hello</body></html>");
    try testing.expectEqual(@as(c_int, 0), r);
    try testing.expectEqual(WebviewState.Loaded, w.getState());

    try w.run();
    try testing.expectEqual(WebviewState.Destroyed, w.getState());

    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_create"));
    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_load_html"));
    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_run"));
}

test "e2e/lifecycle: Created → navigate → Running → Destroyed" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Nav Window");

    try testing.expectEqual(WebviewState.Created, w.getState());
    const r = try w.navigate("https://example.com");
    try testing.expectEqual(@as(c_int, 0), r);
    try testing.expectEqual(WebviewState.Loaded, w.getState());

    try w.run();
    try testing.expectEqual(WebviewState.Destroyed, w.getState());
}

test "e2e/lifecycle: Created → Loaded → Destroyed (without run)" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Destroy Window");

    _ = try w.loadHTML("<html></html>");
    try testing.expectEqual(WebviewState.Loaded, w.getState());

    try w.destroy();
    try testing.expectEqual(WebviewState.Destroyed, w.getState());
    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_destroy"));
}

test "e2e/lifecycle: Created → Destroyed (skip load)" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Empty");

    try testing.expectEqual(WebviewState.Created, w.getState());
    try w.destroy();
    try testing.expectEqual(WebviewState.Destroyed, w.getState());
}

test "e2e/lifecycle: Loaded → Loaded (reload content)" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Reload");

    _ = try w.loadHTML("<h1>First</h1>");
    try testing.expectEqual(WebviewState.Loaded, w.getState());

    _ = try w.loadHTML("<h1>Second</h1>");
    try testing.expectEqual(WebviewState.Loaded, w.getState());

    try testing.expectEqual(@as(usize, 2), ffi.countCalls("gossamer_load_html"));
}

test "e2e/lifecycle: invalid transition throws" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "BadTransition");

    _ = try w.loadHTML("<html></html>");
    try w.run(); // → Destroyed

    // Destroyed → Loaded must error
    try testing.expectError(LifecycleError.InvalidTransition, w.loadHTML("<html>after destroy</html>"));
}

test "e2e/lifecycle: create failure throws" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    ffi.setFailNext("gossamer_create");

    try testing.expectError(LifecycleError.CreateFailed, WebviewShell.init(&ffi, "FailCreate"));
}

//==============================================================================
// Tests: IPC round-trip
//==============================================================================

test "e2e/ipc: open channel → bind → simulate round-trip → close" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "IPC Window");
    _ = try w.loadHTML("<html></html>");

    const channel = try ffi.gossamer_channel_open(1000);
    try testing.expect(channel != 0);

    const bind_r = try ffi.gossamer_channel_bind(channel, "open-file", 0, 0);
    try testing.expectEqual(@as(c_int, 0), bind_r);

    const eval_r = try w.eval("window.__gossamer.send('open-file', {})");
    try testing.expectEqual(@as(c_int, 0), eval_r);

    try ffi.gossamer_channel_close(channel);
    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_channel_close"));

    try w.destroy();
}

test "e2e/ipc: multiple commands can be bound" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Multi IPC");
    _ = try w.loadHTML("<html></html>");

    const channel = try ffi.gossamer_channel_open(1000);
    const commands = [_][]const u8{ "open-file", "save-file", "close-dialog", "list-dir" };

    for (commands) |cmd| {
        const r = try ffi.gossamer_channel_bind(channel, cmd, 0, 0);
        try testing.expectEqual(@as(c_int, 0), r);
    }

    try testing.expectEqual(@as(usize, commands.len), ffi.countCalls("gossamer_channel_bind"));

    try ffi.gossamer_channel_close(channel);
    try w.destroy();
}

//==============================================================================
// Tests: capability lifecycle
//==============================================================================

test "e2e/capability: grant → check → use → revoke" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();

    const token = try ffi.gossamer_cap_grant(0); // Filesystem
    try testing.expect(token != 0);

    try testing.expectEqual(@as(c_int, 0), try ffi.gossamer_cap_check(token));

    var w = try WebviewShell.init(&ffi, "Cap Window");
    _ = try w.loadHTML("<html></html>");
    _ = try w.eval("// gated filesystem read");

    try ffi.gossamer_cap_revoke(token);

    try testing.expectEqual(@as(c_int, 10), try ffi.gossamer_cap_check(token));

    try w.destroy();
}

test "e2e/capability: revoke blocks subsequent operations" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    const shell_token = try ffi.gossamer_cap_grant(2);
    const fs_token = try ffi.gossamer_cap_grant(0);

    try testing.expectEqual(@as(c_int, 0), try ffi.gossamer_cap_check(shell_token));
    try testing.expectEqual(@as(c_int, 0), try ffi.gossamer_cap_check(fs_token));

    try ffi.gossamer_cap_revoke(shell_token);

    try testing.expectEqual(@as(c_int, 10), try ffi.gossamer_cap_check(shell_token));
    try testing.expectEqual(@as(c_int, 0), try ffi.gossamer_cap_check(fs_token));
}

test "e2e/capability: grant failure (0) must be handled" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    ffi.setFailNext("gossamer_cap_grant");

    const token = try ffi.gossamer_cap_grant(0);
    try testing.expectEqual(@as(u64, 0), token);

    try testing.expectEqual(@as(c_int, 10), try ffi.gossamer_cap_check(0));
}

//==============================================================================
// Tests: window control operations
//==============================================================================

test "e2e/window: set title after load succeeds" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "Original Title");
    _ = try w.loadHTML("<html></html>");

    const r = try w.setTitle("New Title");
    try testing.expectEqual(@as(c_int, 0), r);
    try testing.expectEqual(@as(usize, 1), ffi.countCalls("gossamer_set_title"));

    try w.destroy();
}

test "e2e/window: eval JS after load succeeds" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w = try WebviewShell.init(&ffi, "JS Window");
    _ = try w.loadHTML("<html><body><div id='app'></div></body></html>");

    const r = try w.eval("document.getElementById('app').textContent = 'Gossamer';");
    try testing.expectEqual(@as(c_int, 0), r);

    try w.run();
}

//==============================================================================
// Tests: multi-window independence
//==============================================================================

test "e2e/multi-window: two windows have independent state machines" {
    var ffi = MockFFI.init(testing.allocator);
    defer ffi.deinit();
    var w1 = try WebviewShell.init(&ffi, "Window 1");
    var w2 = try WebviewShell.init(&ffi, "Window 2");

    _ = try w1.loadHTML("<h1>W1</h1>");
    try testing.expectEqual(WebviewState.Loaded, w1.getState());
    try testing.expectEqual(WebviewState.Created, w2.getState());

    _ = try w2.navigate("https://gossamer.example");
    try testing.expectEqual(WebviewState.Loaded, w2.getState());

    try w1.destroy();
    try testing.expectEqual(WebviewState.Destroyed, w1.getState());
    try testing.expectEqual(WebviewState.Loaded, w2.getState());

    try w2.run();
    try testing.expectEqual(WebviewState.Destroyed, w2.getState());

    try testing.expectEqual(@as(usize, 2), ffi.countCalls("gossamer_create"));
}
