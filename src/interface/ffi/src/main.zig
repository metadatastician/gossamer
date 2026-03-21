// Gossamer Webview Shell — Zig FFI Implementation
//
// Implements the C-compatible FFI declared in src/interface/abi/Foreign.idr.
// All types and result codes must match the Idris2 ABI definitions exactly.
//
// Platform-specific webview implementations are dispatched at compile time:
// - Linux:   webview_gtk.zig  (WebKitGTK)
// - macOS:   webview_cocoa.zig (WKWebView)   [Phase 2]
// - Windows: webview_win32.zig (WebView2)    [Phase 2]
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");

// Version information
const VERSION = "0.1.0";
const BUILD_INFO = "Gossamer " ++ VERSION ++ " built with Zig " ++ @import("builtin").zig_version_string;

/// Platform-specific webview implementation.
/// Compile-time dispatch — no runtime overhead.
const platform = switch (builtin.os.tag) {
    .linux => @import("webview_gtk.zig"),
    // .macos => @import("webview_cocoa.zig"),   // Phase 2
    // .windows => @import("webview_win32.zig"), // Phase 2
    else => @compileError("Gossamer: unsupported platform. Supported: linux (Phase 1), macOS/Windows (Phase 2)"),
};

//==============================================================================
// Thread-Local Error Storage
//==============================================================================

/// Thread-local error message storage.
/// Access via gossamer_last_error().
threadlocal var last_error: ?[]const u8 = null;

/// Set the last error message.
fn setError(msg: []const u8) void {
    last_error = msg;
}

/// Clear the last error.
fn clearError() void {
    last_error = null;
}

//==============================================================================
// Core Types (must match Gossamer.ABI.Types)
//==============================================================================

/// Result codes matching the Idris2 Result type.
/// Keep in exact sync with Types.idr resultToInt.
pub const Result = enum(c_int) {
    ok = 0,
    @"error" = 1,
    invalid_param = 2,
    out_of_memory = 3,
    null_pointer = 4,
    already_consumed = 5,
    resource_leaked = 6,
    double_free = 7,
    webview_unavailable = 8,
    ipc_protocol_error = 9,
    capability_denied = 10,
};

/// Opaque webview handle.
/// Internal structure is hidden from C callers.
pub const GossamerHandle = struct {
    /// Platform-specific webview state
    webview: platform.WebviewState,
    /// Whether the handle has been initialised
    initialized: bool,
    /// Whether the event loop has been started
    running: bool,
    /// Allocator used for this handle (for cleanup)
    allocator: std.mem.Allocator,
    /// IPC callback bindings (name -> callback fn pointer)
    bindings: std.StringHashMap(BindingCallback),
};

/// IPC callback function type (C ABI).
/// Receives a JSON-encoded request string, returns a JSON-encoded response string.
pub const BindingCallback = *const fn ([*:0]const u8) callconv(.C) [*:0]const u8;

/// Opaque channel handle.
/// In v0.1, channels are lightweight wrappers around the webview's JS bridge.
pub const ChannelHandle = struct {
    /// Back-reference to parent webview
    parent: *GossamerHandle,
    /// Whether the channel is open
    open: bool,
    /// Allocator
    allocator: std.mem.Allocator,
};

//==============================================================================
// Webview Lifecycle
//==============================================================================

/// Create a new webview window.
///
/// Returns a pointer to GossamerHandle, or null on failure.
/// Must be called from the main/UI thread.
///
/// Matches: Gossamer.ABI.Foreign.prim__create
export fn gossamer_create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: u8,
    decorations: u8,
    fullscreen: u8,
) ?*GossamerHandle {
    const allocator = std.heap.c_allocator;

    const handle = allocator.create(GossamerHandle) catch {
        setError("Failed to allocate GossamerHandle");
        return null;
    };

    const webview_state = platform.create(
        title,
        width,
        height,
        resizable != 0,
        decorations != 0,
        fullscreen != 0,
    ) catch {
        setError("Failed to create platform webview");
        allocator.destroy(handle);
        return null;
    };

    handle.* = .{
        .webview = webview_state,
        .initialized = true,
        .running = false,
        .allocator = allocator,
        .bindings = std.StringHashMap(BindingCallback).init(allocator),
    };

    clearError();
    return handle;
}

/// Load HTML content into the webview.
///
/// Matches: Gossamer.ABI.Foreign.prim__loadHTML
export fn gossamer_load_html(handle_ptr: u64, html: [*:0]const u8) Result {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    platform.loadHTML(&handle.webview, html) catch {
        setError("Failed to load HTML into webview");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Navigate the webview to a URL.
///
/// Matches: Gossamer.ABI.Foreign.prim__navigate
export fn gossamer_navigate(handle_ptr: u64, url: [*:0]const u8) Result {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    platform.navigate(&handle.webview, url) catch {
        setError("Failed to navigate");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Evaluate JavaScript in the webview context.
///
/// Matches: Gossamer.ABI.Foreign.prim__eval
export fn gossamer_eval(handle_ptr: u64, js: [*:0]const u8) Result {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    platform.eval(&handle.webview, js) catch {
        setError("Failed to evaluate JavaScript");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Set the window title.
///
/// Matches: Gossamer.ABI.Foreign.prim__setTitle
export fn gossamer_set_title(handle_ptr: u64, title: [*:0]const u8) Result {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    platform.setTitle(&handle.webview, title) catch {
        setError("Failed to set window title");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Resize the webview window.
///
/// Matches: Gossamer.ABI.Foreign.prim__resize
export fn gossamer_resize(handle_ptr: u64, width: u32, height: u32) Result {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    platform.resize(&handle.webview, width, height) catch {
        setError("Failed to resize window");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Run the webview event loop. Blocks until the window is closed.
/// After this returns, the handle is CONSUMED — the webview is destroyed.
///
/// Matches: Gossamer.ABI.Foreign.prim__run
export fn gossamer_run(handle_ptr: u64) void {
    const handle = ptrFromU64(handle_ptr) orelse return;

    if (!handle.initialized) return;

    handle.running = true;
    platform.run(&handle.webview);
    // Event loop returned — window is closed. Clean up.
    handle.running = false;
    cleanup(handle);
}

/// Destroy the webview without running the event loop.
/// Alternative to gossamer_run for cases where you need teardown only.
///
/// Matches: Gossamer.ABI.Foreign.prim__destroy
export fn gossamer_destroy(handle_ptr: u64) void {
    const handle = ptrFromU64(handle_ptr) orelse return;
    cleanup(handle);
}

//==============================================================================
// IPC Channel Operations
//==============================================================================

/// Open a typed IPC channel on the webview.
/// Returns a pointer to ChannelHandle, or 0 on failure.
///
/// Matches: Gossamer.ABI.Foreign.prim__channelOpen
export fn gossamer_channel_open(handle_ptr: u64) u64 {
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return 0;
    };

    if (!handle.initialized) {
        setError("Webview not initialized");
        return 0;
    }

    const allocator = std.heap.c_allocator;
    const channel = allocator.create(ChannelHandle) catch {
        setError("Failed to allocate channel");
        return 0;
    };

    channel.* = .{
        .parent = handle,
        .open = true,
        .allocator = allocator,
    };

    // Inject the Gossamer IPC bridge JavaScript into the webview
    const bridge_js =
        \\window.__gossamer_callbacks = {};
        \\window.__gossamer_invoke = function(name, payload) {
        \\  return new Promise(function(resolve, reject) {
        \\    var id = Date.now().toString(36) + Math.random().toString(36);
        \\    window.__gossamer_callbacks[id] = { resolve: resolve, reject: reject };
        \\    window.__gossamer_ipc_send(JSON.stringify({
        \\      id: id, name: name, payload: JSON.stringify(payload)
        \\    }));
        \\  });
        \\};
        \\window.gossamer = new Proxy({}, {
        \\  get: function(target, name) {
        \\    return function(payload) {
        \\      return window.__gossamer_invoke(name, payload);
        \\    };
        \\  }
        \\});
    ;

    platform.eval(&handle.webview, bridge_js) catch {
        setError("Failed to inject IPC bridge");
        allocator.destroy(channel);
        return 0;
    };

    clearError();
    return u64FromPtr(channel);
}

/// Bind a named command handler to the IPC channel.
///
/// Matches: Gossamer.ABI.Foreign.prim__channelBind
export fn gossamer_channel_bind(
    channel_ptr: u64,
    name: [*:0]const u8,
    callback: ?*const fn ([*:0]const u8) callconv(.C) [*:0]const u8,
) Result {
    _ = channel_ptr;
    _ = name;
    _ = callback;
    // TODO: implement binding registration
    // Store the callback in the parent handle's bindings map,
    // keyed by name. When the webview sends an IPC message with
    // this name, dispatch to the callback.
    setError("Channel bind not yet implemented");
    return .@"error";
}

/// Close the IPC channel. Consumes the channel handle.
///
/// Matches: Gossamer.ABI.Foreign.prim__channelClose
export fn gossamer_channel_close(channel_ptr: u64) void {
    const raw_ptr = @as(?*ChannelHandle, @ptrFromInt(@as(usize, @intCast(channel_ptr)))) orelse return;
    raw_ptr.open = false;
    raw_ptr.allocator.destroy(raw_ptr);
}

//==============================================================================
// Capability Operations
//==============================================================================

/// Grant a capability token.
/// resource_kind is the ordinal of ResourceKind in Types.idr.
/// Returns a unique token ID, or 0 on failure.
///
/// Matches: Gossamer.ABI.Foreign.prim__capGrant
export fn gossamer_cap_grant(resource_kind: u32) u64 {
    _ = resource_kind;
    // TODO: implement capability token generation
    // In v0.1, this is a stub — capabilities are enforced by the
    // Ephapax type system, not at the FFI level. The FFI layer
    // just provides token lifecycle management.
    //
    // Generate a unique token ID (cryptographic randomness in production)
    var buf: [8]u8 = undefined;
    std.crypto.random.bytes(&buf);
    return std.mem.readInt(u64, &buf, .little);
}

/// Check a capability before a gated operation.
///
/// Matches: Gossamer.ABI.Foreign.prim__capCheck
export fn gossamer_cap_check(token: u64) Result {
    if (token == 0) {
        setError("Invalid capability token");
        return .capability_denied;
    }
    // In v0.1, all non-zero tokens are valid.
    // The real enforcement is in the Ephapax type system.
    clearError();
    return .ok;
}

/// Revoke a capability token. Consumes it.
///
/// Matches: Gossamer.ABI.Foreign.prim__capRevoke
export fn gossamer_cap_revoke(token: u64) void {
    _ = token;
    // TODO: add to revocation set so future checks fail
    clearError();
}

//==============================================================================
// System Integration (Stubs — Phase 2)
//==============================================================================

/// Create a system tray icon.
export fn gossamer_tray_create(tooltip: [*:0]const u8) u64 {
    _ = tooltip;
    setError("System tray not yet implemented");
    return 0;
}

/// Show a desktop notification.
export fn gossamer_notify(title: [*:0]const u8, body: [*:0]const u8) Result {
    _ = title;
    _ = body;
    setError("Notifications not yet implemented");
    return .@"error";
}

/// Show a file open dialog.
export fn gossamer_dialog_open(title: [*:0]const u8, filters: [*:0]const u8) u64 {
    _ = title;
    _ = filters;
    setError("File dialogs not yet implemented");
    return 0;
}

/// Show a file save dialog.
export fn gossamer_dialog_save(title: [*:0]const u8, filters: [*:0]const u8) u64 {
    _ = title;
    _ = filters;
    setError("File dialogs not yet implemented");
    return 0;
}

//==============================================================================
// Error Handling
//==============================================================================

/// Get the last error message.
/// Returns null if no error is set.
///
/// Matches: Gossamer.ABI.Foreign.prim__lastError
export fn gossamer_last_error() ?[*:0]const u8 {
    const err = last_error orelse return null;
    const allocator = std.heap.c_allocator;
    const c_str = allocator.dupeZ(u8, err) catch return null;
    return c_str.ptr;
}

//==============================================================================
// Version Information
//==============================================================================

/// Get the library version string.
export fn gossamer_version() [*:0]const u8 {
    return VERSION;
}

/// Get build information string.
export fn gossamer_build_info() [*:0]const u8 {
    return BUILD_INFO;
}

//==============================================================================
// Internal Helpers
//==============================================================================

/// Convert a u64 from Idris2 FFI to a typed pointer.
fn ptrFromU64(val: u64) ?*GossamerHandle {
    if (val == 0) return null;
    return @ptrFromInt(@as(usize, @intCast(val)));
}

/// Convert a typed pointer to a u64 for Idris2 FFI.
fn u64FromPtr(ptr: anytype) u64 {
    return @intCast(@intFromPtr(ptr));
}

/// Clean up a GossamerHandle and free all resources.
fn cleanup(handle: *GossamerHandle) void {
    if (!handle.initialized) return;

    // Destroy platform webview
    platform.destroy(&handle.webview);

    // Clean up bindings map
    handle.bindings.deinit();

    handle.initialized = false;
    handle.allocator.destroy(handle);
}

//==============================================================================
// Tests
//==============================================================================

test "result code mapping matches Idris2" {
    // Verify our Result enum values match Types.idr resultToInt
    try std.testing.expectEqual(@as(c_int, 0), @intFromEnum(Result.ok));
    try std.testing.expectEqual(@as(c_int, 1), @intFromEnum(Result.@"error"));
    try std.testing.expectEqual(@as(c_int, 4), @intFromEnum(Result.null_pointer));
    try std.testing.expectEqual(@as(c_int, 5), @intFromEnum(Result.already_consumed));
    try std.testing.expectEqual(@as(c_int, 8), @intFromEnum(Result.webview_unavailable));
    try std.testing.expectEqual(@as(c_int, 10), @intFromEnum(Result.capability_denied));
}

test "null handle returns null_pointer" {
    const result = gossamer_load_html(0, "");
    try std.testing.expectEqual(Result.null_pointer, result);

    const err = gossamer_last_error();
    try std.testing.expect(err != null);
}

test "version string" {
    const ver = gossamer_version();
    const ver_str = std.mem.span(ver);
    try std.testing.expectEqualStrings("0.1.0", ver_str);
}

test "capability grant returns non-zero token" {
    const token = gossamer_cap_grant(0);
    try std.testing.expect(token != 0);
}

test "capability check with zero token fails" {
    const result = gossamer_cap_check(0);
    try std.testing.expectEqual(Result.capability_denied, result);
}
