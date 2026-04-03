// Gossamer Display Integration Tests
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// These tests require a running display server (X11/Wayland) or Xvfb.
// They exercise the real GTK/WebKitGTK code path: webview creation,
// HTML loading, navigation, IPC channel setup, and capability lifecycle.
//
// Run via: xvfb-run -a zig build test-display
// Or with a live display: DISPLAY=:0 zig build test-display
//
// If no display is available, tests skip gracefully with a diagnostic message
// rather than crashing.

const std = @import("std");
const testing = std.testing;

// Import the Gossamer module for pub types (Result, GossamerHandle)
const gossamer = @import("gossamer");
const Result = gossamer.Result;

//==============================================================================
// C ABI Extern Declarations
//==============================================================================
//
// The Gossamer FFI uses `export fn` (not `pub export fn`) for most functions,
// making them C-linkage symbols but not Zig-module-visible. We declare them
// as extern here, mirroring how a C consumer would call libgossamer.

extern fn gossamer_create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: u8,
    decorations: u8,
    fullscreen: u8,
) ?*gossamer.GossamerHandle;

extern fn gossamer_create_ex(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    min_width: u32,
    min_height: u32,
    max_width: u32,
    max_height: u32,
    resizable: u8,
    decorations: u8,
    fullscreen: u8,
    visible: u8,
) ?*gossamer.GossamerHandle;

extern fn gossamer_load_html(handle_ptr: u64, html: [*:0]const u8) Result;
extern fn gossamer_navigate(handle_ptr: u64, url: [*:0]const u8) Result;
extern fn gossamer_eval(handle_ptr: u64, js: [*:0]const u8) Result;
extern fn gossamer_set_title(handle_ptr: u64, title: [*:0]const u8) Result;
extern fn gossamer_resize(handle_ptr: u64, width: u32, height: u32) Result;
extern fn gossamer_show(handle_ptr: u64) Result;
extern fn gossamer_hide(handle_ptr: u64) Result;
extern fn gossamer_minimize(handle_ptr: u64) Result;
extern fn gossamer_maximize(handle_ptr: u64) Result;
extern fn gossamer_restore(handle_ptr: u64) Result;
extern fn gossamer_request_close(handle_ptr: u64) Result;
extern fn gossamer_destroy(handle_ptr: u64) void;
extern fn gossamer_run(handle_ptr: u64) void;

extern fn gossamer_channel_open(handle_ptr: u64) u64;
extern fn gossamer_channel_bind(
    channel_ptr: u64,
    name: [*:0]const u8,
    callback: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8,
    user_data: ?*anyopaque,
) Result;
extern fn gossamer_channel_close(channel_ptr: u64) void;
extern fn gossamer_async_inflight_count() u32;

extern fn gossamer_last_error() ?[*:0]const u8;
extern fn gossamer_version() [*:0]const u8;
extern fn gossamer_build_info() [*:0]const u8;

// These are pub export fn, so they're accessible via the module too,
// but we declare extern for consistency with the C ABI testing approach.
extern fn gossamer_cap_grant(resource_kind: u32) u64;
extern fn gossamer_cap_check(token: u64) Result;
extern fn gossamer_cap_resource_kind(token: u64) u32;
extern fn gossamer_cap_revoke(token: u64) void;

//==============================================================================
// Display Detection Helper
//==============================================================================

/// Check whether a display server is available by inspecting DISPLAY and
/// WAYLAND_DISPLAY environment variables. Returns false if neither is set,
/// which means GTK will fail to initialise.
fn displayAvailable() bool {
    const display = std.posix.getenv("DISPLAY");
    const wayland = std.posix.getenv("WAYLAND_DISPLAY");
    return (display != null) or (wayland != null);
}

/// Convert a GossamerHandle pointer to its u64 representation for FFI calls.
/// Matches the ptrFromU64/u64FromPtr pattern in main.zig.
fn handleToU64(handle: *gossamer.GossamerHandle) u64 {
    return @intCast(@intFromPtr(handle));
}

//==============================================================================
// Webview Creation & Destruction Tests
//==============================================================================

test "display: create webview returns non-null handle" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available (set DISPLAY or WAYLAND_DISPLAY)\n", .{});
        return;
    }

    const handle = gossamer_create("Test Window", 400, 300, 1, 1, 0);
    try testing.expect(handle != null);

    // Clean up without running the event loop
    if (handle) |h| {
        gossamer_destroy(handleToU64(h));
    }
}

test "display: create and immediately destroy is safe" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Destroy Test", 200, 200, 1, 1, 0);
    try testing.expect(handle != null);

    if (handle) |h| {
        const ptr = handleToU64(h);
        gossamer_destroy(ptr);
        // Double-destroy of the same raw pointer would be UB, so we do NOT
        // call destroy again. This test verifies single destroy is safe.
    }
}

//==============================================================================
// HTML Loading Tests
//==============================================================================

test "display: load HTML into webview returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("HTML Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null (display init failed?)\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_load_html(
        ptr,
        "<html><body><h1>Gossamer Display Test</h1></body></html>",
    );
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

test "display: load empty HTML returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Empty HTML", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_load_html(ptr, "");
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

//==============================================================================
// Navigation Tests
//==============================================================================

test "display: navigate to data URI returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Navigate Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_navigate(
        ptr,
        "data:text/html,<h1>Hello%20from%20data%20URI</h1>",
    );
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

test "display: navigate to about:blank returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Blank Nav", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_navigate(ptr, "about:blank");
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

//==============================================================================
// JavaScript Evaluation Tests
//==============================================================================

test "display: eval JavaScript returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Eval Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    // Load some content first so the JS context exists
    _ = gossamer_load_html(ptr, "<html><body></body></html>");

    // Evaluate a simple JS expression
    const result = gossamer_eval(ptr, "document.title = 'Gossamer Test';");
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

//==============================================================================
// Window Property Tests
//==============================================================================

test "display: set title on live webview returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Original Title", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_set_title(ptr, "Updated Title");
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

test "display: resize live webview returns ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Resize Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_resize(ptr, 1024, 768);
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

test "display: create_ex supports launch-time constraints and hidden start" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create_ex(
        "Constrained",
        640,
        480,
        320,
        240,
        1280,
        960,
        1,
        1,
        0,
        0,
    ) orelse {
        std.debug.print("SKIP: gossamer_create_ex returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_load_html(ptr, "<html><body><h1>Hidden</h1></body></html>");
    try testing.expectEqual(Result.ok, result);
    try testing.expectEqual(Result.ok, gossamer_show(ptr));
    try testing.expectEqual(Result.ok, gossamer_hide(ptr));

    gossamer_destroy(ptr);
}

test "display: window state controls return ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Window State", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    try testing.expectEqual(Result.ok, gossamer_show(ptr));
    try testing.expectEqual(Result.ok, gossamer_hide(ptr));
    try testing.expectEqual(Result.ok, gossamer_show(ptr));
    try testing.expectEqual(Result.ok, gossamer_minimize(ptr));
    try testing.expectEqual(Result.ok, gossamer_restore(ptr));
    try testing.expectEqual(Result.ok, gossamer_maximize(ptr));
    try testing.expectEqual(Result.ok, gossamer_restore(ptr));
    try testing.expectEqual(Result.ok, gossamer_request_close(ptr));
    try testing.expectEqual(Result.already_consumed, gossamer_show(ptr));

    // The handle remains valid for final teardown even after request_close.
    gossamer_destroy(ptr);
}

//==============================================================================
// IPC Channel Tests (with real webview)
//==============================================================================

test "display: channel open on live webview returns non-zero" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("IPC Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    // Load content before opening IPC channel (WebKit needs a page context)
    _ = gossamer_load_html(ptr, "<html><body>IPC Test</body></html>");

    const channel = gossamer_channel_open(ptr);
    try testing.expect(channel != 0);

    // Clean up channel then webview
    gossamer_channel_close(channel);
    gossamer_destroy(ptr);
}

/// Dummy IPC callback for testing channel_bind. Returns a static JSON response.
fn testIPCCallback(_: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    return "{\"status\":\"ok\"}";
}

test "display: channel bind registers handler without error" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Bind Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    _ = gossamer_load_html(ptr, "<html><body>Bind</body></html>");

    const channel = gossamer_channel_open(ptr);
    try testing.expect(channel != 0);

    // Bind a test command handler
    const bind_result = gossamer_channel_bind(
        channel,
        "test_command",
        &testIPCCallback,
        null,
    );
    try testing.expectEqual(Result.ok, bind_result);

    gossamer_channel_close(channel);
    gossamer_destroy(ptr);
}

//==============================================================================
// Capability Round-Trip Tests (with display context)
//==============================================================================

test "display: capability grant-check-revoke round-trip" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    // Capabilities are global (not tied to a webview handle), but we test
    // them in the display test suite to verify they work when GTK is
    // initialised — catching any unexpected interactions.

    // Grant a FileSystem capability (kind 0)
    const token = gossamer_cap_grant(0);
    try testing.expect(token != 0);

    // Check: should succeed
    const check_result = gossamer_cap_check(token);
    try testing.expectEqual(Result.ok, check_result);

    // Verify resource kind
    const kind = gossamer_cap_resource_kind(token);
    try testing.expectEqual(@as(u32, 0), kind);

    // Revoke
    gossamer_cap_revoke(token);

    // Check after revocation: should be denied
    const denied = gossamer_cap_check(token);
    try testing.expectEqual(Result.capability_denied, denied);
}

test "display: all six capability kinds work with GTK initialised" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    // Create and immediately destroy a webview to force GTK init
    const handle = gossamer_create("Cap Init", 200, 200, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    gossamer_destroy(handleToU64(handle));

    // Now test all 6 resource kinds (FileSystem, Network, Shell, Clipboard,
    // Notification, Tray) with GTK having been initialised
    var tokens: [6]u64 = undefined;
    for (0..6) |i| {
        tokens[i] = gossamer_cap_grant(@intCast(i));
        try testing.expect(tokens[i] != 0);

        const check = gossamer_cap_check(tokens[i]);
        try testing.expectEqual(Result.ok, check);

        const kind = gossamer_cap_resource_kind(tokens[i]);
        try testing.expectEqual(@as(u32, @intCast(i)), kind);
    }

    // Clean up all tokens
    for (tokens) |t| gossamer_cap_revoke(t);
}

//==============================================================================
// Version & Build Info Tests (with display context)
//==============================================================================

test "display: version string is valid with display initialised" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    // Force GTK init via webview creation
    const handle = gossamer_create("Version", 200, 200, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    gossamer_destroy(handleToU64(handle));

    const ver = gossamer_version();
    const ver_str = std.mem.span(ver);
    try testing.expectEqualStrings("0.3.0", ver_str);
}

test "display: build info contains Gossamer and version" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Build Info", 200, 200, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    gossamer_destroy(handleToU64(handle));

    const info = gossamer_build_info();
    const info_str = std.mem.span(info);
    try testing.expect(std.mem.indexOf(u8, info_str, "Gossamer") != null);
    try testing.expect(std.mem.indexOf(u8, info_str, "0.3.0") != null);
}

//==============================================================================
// Error Propagation Tests (with display context)
//==============================================================================

test "display: last_error is null after successful webview creation" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Error Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    // After a successful operation, last_error should be null
    const err = gossamer_last_error();
    try testing.expect(err == null);

    gossamer_destroy(ptr);
}

//==============================================================================
// Async Inflight Counter Tests (with display context)
//==============================================================================

test "display: async inflight count is zero with no async calls" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Async Test", 200, 200, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    gossamer_destroy(handleToU64(handle));

    const count = gossamer_async_inflight_count();
    try testing.expectEqual(@as(u32, 0), count);
}

//==============================================================================
// Multiple Webview Lifecycle Tests
//==============================================================================

test "display: create multiple webviews sequentially" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    // Create, use, and destroy three webviews in sequence to verify
    // that GTK state is properly cleaned up between instances
    for (0..3) |i| {
        _ = i;
        const handle = gossamer_create("Multi Test", 300, 200, 1, 1, 0) orelse {
            std.debug.print("SKIP: gossamer_create returned null on iteration\n", .{});
            return;
        };
        const ptr = handleToU64(handle);

        _ = gossamer_load_html(ptr, "<html><body>Sequential</body></html>");
        gossamer_destroy(ptr);
    }
}

test "display: create non-resizable non-decorated webview" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    // Test with different window configuration flags
    const handle = gossamer_create(
        "Kiosk Style",
        800,
        600,
        0, // not resizable
        0, // no decorations
        0, // not fullscreen
    ) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const result = gossamer_load_html(
        ptr,
        "<html><body style='margin:0;background:#111;color:#0f0'><h1>Kiosk</h1></body></html>",
    );
    try testing.expectEqual(Result.ok, result);

    gossamer_destroy(ptr);
}

//==============================================================================
// Window Guard Tests
//==============================================================================

extern fn gossamer_guard_set(handle_ptr: u64, mode: c_int) Result;
extern fn gossamer_guard_get(handle_ptr: u64) c_int;
extern fn gossamer_registry_add(handle_ptr: u64) u32;
extern fn gossamer_registry_count() u32;
extern fn gossamer_transmute(handle_ptr: u64, mode: c_int) Result;
extern fn gossamer_transmute_get(handle_ptr: u64) c_int;
extern fn gossamer_activity_set(handle_ptr: u64, level: c_int) Result;
extern fn gossamer_activity_get(handle_ptr: u64) c_int;
extern fn gossamer_raise(handle_ptr: u64) Result;
extern fn gossamer_lower(handle_ptr: u64) Result;

test "display: guard set/get cycle — locked blocks close/resize/minimize" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Guard Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);
    _ = gossamer_load_html(ptr, "<html><body>Guard</body></html>");

    // Default is free (0)
    try testing.expectEqual(@as(c_int, 0), gossamer_guard_get(ptr));

    // Set to locked
    try testing.expectEqual(Result.ok, gossamer_guard_set(ptr, 1));
    try testing.expectEqual(@as(c_int, 1), gossamer_guard_get(ptr));

    // Locked: resize should be rejected
    try testing.expectEqual(Result.guard_locked, gossamer_resize(ptr, 500, 400));

    // Locked: close should be rejected
    try testing.expectEqual(Result.guard_locked, gossamer_request_close(ptr));

    // Locked: minimize should be rejected
    try testing.expectEqual(Result.guard_locked, gossamer_minimize(ptr));

    // Unlock
    try testing.expectEqual(Result.ok, gossamer_guard_set(ptr, 0));

    // Now operations work again
    try testing.expectEqual(Result.ok, gossamer_resize(ptr, 500, 400));

    gossamer_destroy(ptr);
}

test "display: transmute gui -> tui -> gui round-trip" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Transmute Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);
    _ = gossamer_load_html(ptr, "<html><body><h1>Content</h1><p>Test</p></body></html>");
    _ = gossamer_registry_add(ptr);

    try testing.expectEqual(@as(c_int, 0), gossamer_transmute_get(ptr));
    try testing.expectEqual(Result.ok, gossamer_transmute(ptr, 1)); // tui
    try testing.expectEqual(@as(c_int, 1), gossamer_transmute_get(ptr));
    try testing.expectEqual(Result.ok, gossamer_transmute(ptr, 0)); // back to gui
    try testing.expectEqual(@as(c_int, 0), gossamer_transmute_get(ptr));

    gossamer_destroy(ptr);
}

test "display: activity set/get cycle" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Activity Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);
    _ = gossamer_load_html(ptr, "<html><body>Activity</body></html>");
    _ = gossamer_registry_add(ptr);

    try testing.expectEqual(@as(c_int, 4), gossamer_activity_get(ptr)); // realtime default
    try testing.expectEqual(Result.ok, gossamer_activity_set(ptr, 0)); // pause
    try testing.expectEqual(@as(c_int, 0), gossamer_activity_get(ptr));
    try testing.expectEqual(Result.ok, gossamer_activity_set(ptr, 4)); // back to realtime

    gossamer_destroy(ptr);
}

test "display: raise and lower return ok" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Z-Order Test", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    try testing.expectEqual(Result.ok, gossamer_raise(ptr));
    try testing.expectEqual(Result.ok, gossamer_lower(ptr));

    gossamer_destroy(ptr);
}

test "display: IPC bridge survives load_html (user script persistence)" {
    if (!displayAvailable()) {
        std.debug.print("SKIP: no display server available\n", .{});
        return;
    }

    const handle = gossamer_create("Bridge Persist", 400, 300, 1, 1, 0) orelse {
        std.debug.print("SKIP: gossamer_create returned null\n", .{});
        return;
    };
    const ptr = handleToU64(handle);

    const channel = gossamer_channel_open(ptr);
    try testing.expect(channel != 0);

    const bind_result = gossamer_channel_bind(channel, "test_after_load", &testIPCCallback, null);
    try testing.expectEqual(Result.ok, bind_result);

    // Load HTML after channel setup — bridge should persist via user script
    const load_result = gossamer_load_html(ptr, "<html><body><h1>After Load</h1></body></html>");
    try testing.expectEqual(Result.ok, load_result);

    gossamer_channel_close(channel);
    gossamer_destroy(ptr);
}
