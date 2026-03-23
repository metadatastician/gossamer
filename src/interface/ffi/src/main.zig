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

// Static Site Generator FFI functions (gossamer_ssg_*).
// Imported here to ensure all exports are included in the shared library.
comptime {
    _ = @import("ssg.zig");
}

// Game Server Admin Bridge FFI functions (bridge_*, ssh_exec, json_field).
// Imported here to ensure all exports are included in the shared library.
comptime {
    _ = @import("bridge_game_server.zig");
}

// System tray + notification FFI functions (gossamer_tray_*, gossamer_notify).
// Replaces the Phase 2 stubs below with real GTK StatusIcon implementation.
comptime {
    _ = @import("tray.zig");
}

// File dialog FFI functions (gossamer_dialog_open, gossamer_dialog_save, etc.).
// GTK FileChooserDialog implementation for open/save/directory/multi-select.
comptime {
    _ = @import("dialog.zig");
}

// Filesystem FFI functions (gossamer_fs_*).
// Capability-gated file I/O operations for the IPC bridge and Ephapax.
comptime {
    _ = @import("filesystem.zig");
}

// Groove discovery FFI functions (gossamer_groove_*).
// Lightweight service discovery for composable integration.
// Probes well-known ports for Burble (voice), Vext (integrity),
// VeriSimDB (storage), Hypatia (scanning), PanLL (panels), and more.
// Type safety enforced at the Idris2 ABI level (Groove.idr).
comptime {
    _ = @import("groove.zig");
}

// Version information
const VERSION = "0.1.0";
const BUILD_INFO = "Gossamer " ++ VERSION ++ " built with Zig " ++ @import("builtin").zig_version_string;

/// Platform-specific webview implementation.
/// Compile-time dispatch — no runtime overhead.
const platform = switch (builtin.os.tag) {
    .linux, .freebsd, .openbsd, .netbsd => @import("webview_gtk.zig"),
    .macos => @import("webview_cocoa.zig"),
    .windows => @import("webview_win32.zig"),
    .ios => @import("webview_ios.zig"),
    else => @compileError("Gossamer: unsupported platform. Supported: linux, BSD, macOS, Windows, iOS. Android requires NDK target."),
};

//==============================================================================
// Thread-Local Error Storage
//==============================================================================

/// Thread-local error message storage.
/// Access via gossamer_last_error().
threadlocal var last_error: ?[]const u8 = null;

/// Set the last error message.
/// Public so that sub-modules (dialog.zig, tray.zig, etc.) can report errors
/// through the same thread-local channel.
pub fn setError(msg: []const u8) void {
    last_error = msg;
}

/// Clear the last error.
pub fn clearError() void {
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
    /// IPC callback bindings (name -> callback + user data)
    bindings: std.StringHashMap(BindingEntry),
};

/// IPC callback function type (C ABI).
/// Receives a JSON-encoded request string and optional user data pointer,
/// returns a JSON-encoded response string.
/// The user_data parameter enables language bindings (Rust, etc.) to pass
/// closure context through the C ABI without global state.
pub const BindingCallback = *const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8;

/// Entry in the IPC bindings map — pairs a callback with its user data.
/// The `run_async` flag controls dispatch behaviour:
///   false (default) — callback runs synchronously on the GTK main thread
///   true            — callback is spawned on a worker thread; response is
///                     delivered back to JS via g_idle_add when it completes
pub const BindingEntry = struct {
    callback: BindingCallback,
    user_data: ?*anyopaque,
    /// When true, the callback is dispatched to a worker thread so that
    /// I/O-heavy operations do not block the GTK event loop.
    run_async: bool = false,
};

//==============================================================================
// Async IPC Inflight Tracking
//==============================================================================

/// Maximum number of concurrent async IPC calls.
/// Prevents unbounded thread spawning from rapid-fire JS invocations.
const MAX_INFLIGHT_ASYNC = 256;

/// Thread-safe inflight slot registry for async IPC calls.
/// Bounded at MAX_INFLIGHT_ASYNC (256) to prevent unbounded memory growth
/// and provide back-pressure when the system is overloaded.
///
/// Public so that the platform module (webview_gtk.zig) can acquire/release
/// slots from the worker thread dispatch path.
///
/// Thread safety: all slot operations are guarded by a Mutex because
/// acquireSlot() is called on the GTK main thread and releaseSlot()
/// is called from the g_idle_add callback (also main thread, but after
/// the worker thread has completed). The mutex also protects against
/// potential future multi-webview scenarios.
pub const async_ipc = struct {
    /// Slot occupancy bitfield — true means the slot is in use.
    var slots: [MAX_INFLIGHT_ASYNC]bool = [_]bool{false} ** MAX_INFLIGHT_ASYNC;

    /// Mutex protecting the slots array and count.
    /// Worker threads and the GTK main thread may access concurrently.
    var mutex: std.Thread.Mutex = .{};

    /// Number of currently occupied slots (cached for fast queries).
    var count: u32 = 0;

    /// Acquire a free slot. Returns the slot index, or null if all slots
    /// are occupied (back-pressure — caller should reject the IPC call).
    pub fn acquireSlot() ?usize {
        mutex.lock();
        defer mutex.unlock();

        for (&slots, 0..) |*slot, i| {
            if (!slot.*) {
                slot.* = true;
                count += 1;
                return i;
            }
        }
        return null; // All slots occupied
    }

    /// Release a previously acquired slot. Called by the g_idle_add
    /// callback after the response has been delivered to JavaScript.
    pub fn releaseSlot(index: usize) void {
        mutex.lock();
        defer mutex.unlock();

        if (index < MAX_INFLIGHT_ASYNC and slots[index]) {
            slots[index] = false;
            if (count > 0) count -= 1;
        }
    }

    /// Query the current number of inflight async calls.
    pub fn inflightCount() u32 {
        mutex.lock();
        defer mutex.unlock();
        return count;
    }

    /// Reset all slots to free. Used in tests and cleanup.
    pub fn reset() void {
        mutex.lock();
        defer mutex.unlock();
        for (&slots) |*slot| {
            slot.* = false;
        }
        count = 0;
    }
};

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
    clearError();
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
        .bindings = std.StringHashMap(BindingEntry).init(allocator),
    };

    clearError();
    return handle;
}

/// Load HTML content into the webview.
///
/// Matches: Gossamer.ABI.Foreign.prim__loadHTML
export fn gossamer_load_html(handle_ptr: u64, html: [*:0]const u8) Result {
    clearError();
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
    clearError();
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
    clearError();
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
    clearError();
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
    clearError();
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
    clearError();
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
    clearError();
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
    clearError();
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

    // Register the platform-specific IPC message handler BEFORE injecting JS.
    // On GTK this sets up webkit_user_content_manager_register_script_message_handler.
    // The handler dispatches incoming messages to bound callbacks.
    platform.registerIPCHandler(&handle.webview, handle) catch {
        setError("Failed to register IPC handler");
        allocator.destroy(channel);
        return 0;
    };

    // Inject the Gossamer IPC bridge JavaScript into the webview.
    // Uses platform-specific message passing:
    //   GTK:     window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)
    //   Cocoa:   window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)
    //   Win32:   window.chrome.webview.postMessage(msg)
    //   Android: GossamerBridge.postMessage(msg)
    const bridge_js =
        \\window.__gossamer_callbacks = {};
        \\window.__gossamer_invoke = function(name, payload) {
        \\  return new Promise(function(resolve, reject) {
        \\    var id = Date.now().toString(36) + Math.random().toString(36);
        \\    window.__gossamer_callbacks[id] = { resolve: resolve, reject: reject };
        \\    var msg = JSON.stringify({
        \\      id: id, name: name, payload: JSON.stringify(payload || {})
        \\    });
        \\    if (window.webkit && window.webkit.messageHandlers &&
        \\        window.webkit.messageHandlers.gossamer_ipc) {
        \\      window.webkit.messageHandlers.gossamer_ipc.postMessage(msg);
        \\    } else if (window.chrome && window.chrome.webview) {
        \\      window.chrome.webview.postMessage(msg);
        \\    } else if (window.GossamerBridge) {
        \\      window.GossamerBridge.postMessage(msg);
        \\    } else {
        \\      reject(new Error("Gossamer IPC transport not available"));
        \\    }
        \\  });
        \\};
        \\window.gossamer = new Proxy({}, {
        \\  get: function(target, name) {
        \\    if (typeof name !== "string") return undefined;
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
/// Stores the callback in the parent handle's bindings map, keyed by name.
/// When the webview sends an IPC message with this name via
/// `window.gossamer.commandName(payload)`, the callback is invoked with
/// the JSON-encoded payload and its return value is sent back to JS.
///
/// Matches: Gossamer.ABI.Foreign.prim__channelBind
export fn gossamer_channel_bind(
    channel_ptr: u64,
    name: [*:0]const u8,
    callback: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8,
    user_data: ?*anyopaque,
) Result {
    clearError();
    const channel = channelFromU64(channel_ptr) orelse {
        setError("Null channel handle");
        return .null_pointer;
    };

    if (!channel.open) {
        setError("Channel is closed");
        return .@"error";
    }

    const cb = callback orelse {
        setError("Null callback");
        return .invalid_param;
    };

    // Duplicate the name string — caller may free it after this returns
    const name_slice = std.mem.span(name);
    const duped_name = channel.allocator.dupeZ(u8, name_slice) catch {
        setError("Failed to allocate name string");
        return .out_of_memory;
    };

    // Register the callback + user data in the parent handle's bindings map
    channel.parent.bindings.put(duped_name, .{
        .callback = cb,
        .user_data = user_data,
    }) catch {
        channel.allocator.free(duped_name);
        setError("Failed to register binding");
        return .out_of_memory;
    };

    clearError();
    return .ok;
}

/// Bind a named command handler for ASYNC dispatch on the IPC channel.
///
/// Identical to gossamer_channel_bind except the callback will run on a
/// worker thread instead of the GTK main thread. When the callback returns,
/// the response is posted back to the main thread via g_idle_add.
///
/// Use this for I/O-heavy commands (HTTP requests, file reads, database
/// queries) that would otherwise block the GTK event loop and freeze the UI.
///
/// Maximum inflight async calls: 256 (MAX_INFLIGHT_ASYNC).
///
/// Matches: Gossamer.ABI.Foreign.prim__channelBindAsync
export fn gossamer_channel_bind_async(
    channel_ptr: u64,
    name: [*:0]const u8,
    callback: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8,
    user_data: ?*anyopaque,
) Result {
    clearError();
    const channel = channelFromU64(channel_ptr) orelse {
        setError("Null channel handle");
        return .null_pointer;
    };

    if (!channel.open) {
        setError("Channel is closed");
        return .@"error";
    }

    const cb = callback orelse {
        setError("Null callback");
        return .invalid_param;
    };

    // Duplicate the name string — caller may free it after this returns
    const name_slice = std.mem.span(name);
    const duped_name = channel.allocator.dupeZ(u8, name_slice) catch {
        setError("Failed to allocate name string");
        return .out_of_memory;
    };

    // Register the callback with run_async=true so the IPC dispatcher
    // spawns a worker thread instead of running inline on the GTK thread
    channel.parent.bindings.put(duped_name, .{
        .callback = cb,
        .user_data = user_data,
        .run_async = true,
    }) catch {
        channel.allocator.free(duped_name);
        setError("Failed to register async binding");
        return .out_of_memory;
    };

    clearError();
    return .ok;
}

/// Close the IPC channel. Consumes the channel handle.
///
/// Matches: Gossamer.ABI.Foreign.prim__channelClose
export fn gossamer_channel_close(channel_ptr: u64) void {
    clearError();
    const raw_ptr = @as(?*ChannelHandle, @ptrFromInt(@as(usize, @intCast(channel_ptr)))) orelse return;
    raw_ptr.open = false;
    raw_ptr.allocator.destroy(raw_ptr);
}

/// Query the number of currently inflight async IPC calls.
/// Returns 0..256. Useful for diagnostics and back-pressure monitoring.
export fn gossamer_async_inflight_count() u32 {
    return async_ipc.inflightCount();
}

//==============================================================================
// Capability Operations
//==============================================================================

/// Maximum number of active capability tokens.
/// Keeps memory bounded without dynamic allocation for the cap registry.
const MAX_CAPABILITIES = 256;

/// Maximum number of revoked tokens to track.
/// Once full, oldest revocations are evicted (safe — prevents re-use
/// only as a belt-and-suspenders check alongside Ephapax linear types).
const MAX_REVOKED = 512;

/// Registry entry mapping a token to its resource kind.
const CapEntry = struct {
    token: u64,
    resource_kind: u32,
    active: bool,
};

/// Active capability registry.
/// Fixed-size array avoids dynamic allocation in the capability hot path.
var cap_registry: [MAX_CAPABILITIES]CapEntry = [_]CapEntry{.{
    .token = 0,
    .resource_kind = 0,
    .active = false,
}} ** MAX_CAPABILITIES;

/// Number of active capabilities.
var cap_count: usize = 0;

/// Revocation set — tokens that have been revoked.
/// Checked on gossamer_cap_check to reject revoked tokens.
var revoked_tokens: [MAX_REVOKED]u64 = [_]u64{0} ** MAX_REVOKED;

/// Number of revoked tokens currently tracked.
var revoked_count: usize = 0;

/// Grant a capability token for the given resource kind.
/// resource_kind is the ordinal of ResourceKind in Types.idr:
///   0=FileSystem, 1=Network, 2=Shell, 3=Clipboard, 4=Notification, 5=Tray
/// Returns a unique token ID, or 0 on failure.
///
/// Matches: Gossamer.ABI.Foreign.prim__capGrant
pub export fn gossamer_cap_grant(resource_kind: u32) u64 {
    clearError();
    // Validate resource kind (0..5 matches Types.idr ResourceKind constructors)
    if (resource_kind > 5) {
        setError("Invalid resource kind (must be 0-5)");
        return 0;
    }

    // Check capacity
    if (cap_count >= MAX_CAPABILITIES) {
        setError("Capability registry full (256 slots)");
        return 0;
    }

    // Generate a unique token ID using cryptographic randomness
    var buf: [8]u8 = undefined;
    std.crypto.random.bytes(&buf);
    var token = std.mem.readInt(u64, &buf, .little);

    // Ensure non-zero (zero is the null/invalid sentinel)
    if (token == 0) token = 1;

    // Find an empty slot in the registry
    for (&cap_registry) |*entry| {
        if (!entry.active) {
            entry.* = .{
                .token = token,
                .resource_kind = resource_kind,
                .active = true,
            };
            cap_count += 1;
            clearError();
            return token;
        }
    }

    // Should not reach here given the count check above
    setError("Capability registry inconsistency");
    return 0;
}

/// Check a capability token before a gated operation.
/// Verifies the token is active and not revoked.
///
/// Matches: Gossamer.ABI.Foreign.prim__capCheck
pub export fn gossamer_cap_check(token: u64) Result {
    clearError();
    if (token == 0) {
        setError("Invalid capability token (null)");
        return .capability_denied;
    }

    // Check the revocation set first (fast rejection)
    for (revoked_tokens[0..revoked_count]) |revoked| {
        if (revoked == token) {
            setError("Capability token has been revoked");
            return .capability_denied;
        }
    }

    // Verify the token exists in the active registry
    for (cap_registry[0..]) |entry| {
        if (entry.active and entry.token == token) {
            clearError();
            return .ok;
        }
    }

    setError("Capability token not found in registry");
    return .capability_denied;
}

/// Query the resource kind associated with a capability token.
/// Returns the resource kind ordinal, or 0xFFFFFFFF if the token is invalid.
///
/// This allows callers to verify a token grants the expected permission
/// without exposing the full registry.
pub export fn gossamer_cap_resource_kind(token: u64) u32 {
    clearError();
    if (token == 0) return 0xFFFFFFFF;

    for (cap_registry[0..]) |entry| {
        if (entry.active and entry.token == token) {
            return entry.resource_kind;
        }
    }
    return 0xFFFFFFFF;
}

/// Revoke a capability token. Consumes it — future checks will fail.
///
/// Matches: Gossamer.ABI.Foreign.prim__capRevoke
export fn gossamer_cap_revoke(token: u64) void {
    clearError();
    if (token == 0) return;

    // Remove from active registry
    for (&cap_registry) |*entry| {
        if (entry.active and entry.token == token) {
            entry.active = false;
            if (cap_count > 0) cap_count -= 1;
            break;
        }
    }

    // Add to revocation set (belt-and-suspenders alongside Ephapax linear types)
    if (revoked_count < MAX_REVOKED) {
        revoked_tokens[revoked_count] = token;
        revoked_count += 1;
    } else {
        // Evict oldest revocation to make room
        // Safe: the primary enforcement is Ephapax's linear type system;
        // the revocation set is a runtime safety net, not the authority.
        std.mem.copyForwards(u64, revoked_tokens[0 .. MAX_REVOKED - 1], revoked_tokens[1..MAX_REVOKED]);
        revoked_tokens[MAX_REVOKED - 1] = token;
    }

    clearError();
}

//==============================================================================
// System Integration
//==============================================================================

// Tray and notifications: implemented in tray.zig (gossamer_tray_*, gossamer_notify).
// File dialogs: implemented in dialog.zig (gossamer_dialog_open, gossamer_dialog_save,
//   gossamer_dialog_open_directory, gossamer_dialog_open_multiple, gossamer_dialog_free_path).

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

/// Convert a u64 from Idris2 FFI to a typed GossamerHandle pointer.
fn ptrFromU64(val: u64) ?*GossamerHandle {
    if (val == 0) return null;
    return @ptrFromInt(@as(usize, @intCast(val)));
}

/// Convert a u64 from Idris2 FFI to a typed ChannelHandle pointer.
fn channelFromU64(val: u64) ?*ChannelHandle {
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
    const token = gossamer_cap_grant(0); // FileSystem
    try std.testing.expect(token != 0);
    // Clean up
    gossamer_cap_revoke(token);
}

test "capability check with zero token fails" {
    const result = gossamer_cap_check(0);
    try std.testing.expectEqual(Result.capability_denied, result);
}

test "capability grant-check-revoke lifecycle" {
    // Grant a Network capability (kind=1)
    const token = gossamer_cap_grant(1);
    try std.testing.expect(token != 0);

    // Check should succeed while active
    try std.testing.expectEqual(Result.ok, gossamer_cap_check(token));

    // Resource kind should be Network (1)
    try std.testing.expectEqual(@as(u32, 1), gossamer_cap_resource_kind(token));

    // Revoke the token
    gossamer_cap_revoke(token);

    // Check should fail after revocation
    try std.testing.expectEqual(Result.capability_denied, gossamer_cap_check(token));

    // Resource kind should be invalid after revocation
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), gossamer_cap_resource_kind(token));
}

test "capability grant rejects invalid resource kind" {
    const token = gossamer_cap_grant(99); // Invalid kind
    try std.testing.expectEqual(@as(u64, 0), token);
}
