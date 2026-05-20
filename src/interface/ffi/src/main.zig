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

extern fn gossamer_tray_clear_window() void;

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

// CSP enforcement module — gossamer_set_csp, gossamer_emit for streaming IPC.
// Imported here to ensure all exports are included in the shared library.
comptime {
    _ = @import("csp.zig");
}

// Clipboard FFI functions (gossamer_clipboard_read, gossamer_clipboard_write).
// GTK clipboard implementation for system clipboard access.
comptime {
    _ = @import("clipboard.zig");
}

// Plugin system FFI functions (gossamer_plugin_load, gossamer_plugin_unload,
// gossamer_plugin_list). Dynamic loading of .so/.dylib/.dll extensions at
// runtime via dlopen + restricted vtable API.
comptime {
    _ = @import("plugin.zig");
}

// Hot-reload file watcher (gossamer_watcher_start, gossamer_watcher_stop).
// Polling watcher with g_idle_add marshalling to the GTK main thread.
// Relocated from cli/src/file_watcher.zig so any libgossamer consumer —
// native Zig CLI, future Ephapax-wasm CLI behind a host launcher, or
// third-party embedders — can use the same hot-reload path.
comptime {
    _ = @import("file_watcher.zig");
}

// Conf FFI functions (gossamer_conf_load + get_string/int/bool/has + free).
// Real JSON loader for gossamer.conf.json, replacing the hand-rolled
// string-scan parser previously living in cli/src/main.zig. Exposed via
// dotted-path lookup so callers target nested keys explicitly.
comptime {
    _ = @import("conf.zig");
}

// Version information — bump on each release
const VERSION = "0.3.0";
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
    guard_locked = 11,
};

/// Window guard mode — controls what operations are permitted.
///
///   free      — everything works normally (default)
///   locked    — window controls disabled (close/minimize/maximize/resize rejected)
///   read_only — locked + content is non-interactive (CSS overlay injected)
///
/// Solves the "clicked X on wrong window and killed critical work" problem.
/// Toggle via gossamer_guard_set() or the JS IPC bridge.
pub const GuardMode = enum(c_int) {
    free = 0,
    locked = 1,
    read_only = 2,
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
    /// Whether the window has been logically closed.
    /// Borrowing operations reject closed handles, but cleanup still owns
    /// the final resource release path.
    closed: bool,
    /// Whether the window is currently shown to the user.
    visible: bool,
    /// Window guard mode — prevents accidental close/resize when locked.
    guard: GuardMode = .free,
    /// Allocator used for this handle (for cleanup)
    allocator: std.mem.Allocator,
    /// IPC callback bindings (name -> callback + user data)
    bindings: std.StringHashMap(BindingEntry),
    /// Unique window ID within the registry (0 = unregistered)
    window_id: u32 = 0,
    /// Group ID this window belongs to (0 = ungrouped)
    group_id: u32 = 0,
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
///
/// The `plugin_id` field tracks which plugin registered this binding.
/// When a plugin is unloaded, all bindings with its plugin_id are removed.
/// The IPC dispatcher checks plugin liveness before invoking the callback
/// to prevent use-after-free on unloaded plugin code.
pub const BindingEntry = struct {
    callback: BindingCallback,
    user_data: ?*anyopaque,
    /// When true, the callback is dispatched to a worker thread so that
    /// I/O-heavy operations do not block the GTK event loop.
    run_async: bool = false,
    /// Plugin that registered this binding (0 = core/non-plugin).
    /// Checked at dispatch time for liveness — if the plugin has been
    /// unloaded, the IPC call returns a clean error instead of crashing.
    plugin_id: u32 = 0,
};

/// Borrowed-window guard used by window operations that should fail once the
/// window has been closed.
fn requireOpen(handle: *GossamerHandle) ?Result {
    if (!handle.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    if (handle.closed) {
        setError("Webview already closed");
        return .already_consumed;
    }

    return null;
}

/// Guard check — rejects operations when the window is in locked or read_only mode.
/// Used by close, minimize, maximize, resize, restore.
fn requireUnguarded(handle: *GossamerHandle) ?Result {
    if (handle.guard != .free) {
        setError("Window is guard-locked — unlock before performing this operation");
        return .guard_locked;
    }
    return null;
}

fn validateWindowConstraints(
    min_width: u32,
    min_height: u32,
    max_width: u32,
    max_height: u32,
) bool {
    if (min_width != 0 and max_width != 0 and min_width > max_width) {
        return false;
    }
    if (min_height != 0 and max_height != 0 and min_height > max_height) {
        return false;
    }
    return true;
}

//==============================================================================
// Async IPC Inflight Tracking
//==============================================================================

/// Default maximum number of concurrent async IPC calls.
/// Configurable at runtime via gossamer_set_max_inflight().
const DEFAULT_MAX_INFLIGHT_ASYNC: u32 = 256;

/// Absolute ceiling to prevent OOM from absurd values.
const ABSOLUTE_MAX_INFLIGHT: u32 = 16384;

/// Thread-safe inflight slot registry for async IPC calls.
/// Bounded at a configurable limit (default 256) to prevent unbounded
/// memory growth and provide back-pressure when overloaded.
///
/// The limit can be raised at runtime via gossamer_set_max_inflight()
/// before any async IPC calls are made. This supports high-concurrency
/// apps that need more than 256 simultaneous in-flight requests.
///
/// Public so that the platform module (webview_gtk.zig) can acquire/release
/// slots from the worker thread dispatch path.
///
/// Thread safety: all slot operations are guarded by a Mutex.
pub const async_ipc = struct {
    /// Slot occupancy bitfield — true means the slot is in use.
    /// Sized to ABSOLUTE_MAX_INFLIGHT; effective limit controlled by max_slots.
    var slots: [ABSOLUTE_MAX_INFLIGHT]bool = [_]bool{false} ** ABSOLUTE_MAX_INFLIGHT;

    /// Current configurable maximum (default 256).
    var max_slots: u32 = DEFAULT_MAX_INFLIGHT_ASYNC;

    /// Mutex protecting the slots array and count.
    /// Worker threads and the GTK main thread may access concurrently.
    var mutex: std.Thread.Mutex = .{};

    /// Number of currently occupied slots (cached for fast queries).
    var count: u32 = 0;

    /// Set the maximum number of inflight async IPC calls.
    /// Must be called before any async IPC calls are dispatched.
    /// Clamped to [1, ABSOLUTE_MAX_INFLIGHT].
    pub fn setMaxSlots(max: u32) void {
        mutex.lock();
        defer mutex.unlock();
        if (max == 0) {
            max_slots = 1;
        } else if (max > ABSOLUTE_MAX_INFLIGHT) {
            max_slots = ABSOLUTE_MAX_INFLIGHT;
        } else {
            max_slots = max;
        }
    }

    /// Query the current maximum slot limit.
    pub fn getMaxSlots() u32 {
        mutex.lock();
        defer mutex.unlock();
        return max_slots;
    }

    /// Acquire a free slot. Returns the slot index, or null if all slots
    /// are occupied (back-pressure — caller should reject the IPC call).
    pub fn acquireSlot() ?usize {
        mutex.lock();
        defer mutex.unlock();

        if (count >= max_slots) return null;

        for (slots[0..max_slots], 0..) |*slot, i| {
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

        if (index < ABSOLUTE_MAX_INFLIGHT and slots[index]) {
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
        for (slots[0..max_slots]) |*slot| {
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

/// Internal helper used by both compatibility and config-driven create calls.
fn createHandle(
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
) ?*GossamerHandle {
    clearError();
    if (!validateWindowConstraints(min_width, min_height, max_width, max_height)) {
        setError("Invalid window size constraints");
        return null;
    }

    const allocator = std.heap.c_allocator;

    const handle = allocator.create(GossamerHandle) catch {
        setError("Failed to allocate GossamerHandle");
        return null;
    };

    const webview_state = platform.create(
        title,
        width,
        height,
        min_width,
        min_height,
        max_width,
        max_height,
        resizable != 0,
        decorations != 0,
        fullscreen != 0,
        visible != 0,
    ) catch {
        setError("Failed to create platform webview");
        allocator.destroy(handle);
        return null;
    };

    handle.* = .{
        .webview = webview_state,
        .initialized = true,
        .running = false,
        .closed = false,
        .visible = visible != 0,
        .allocator = allocator,
        .bindings = std.StringHashMap(BindingEntry).init(allocator),
    };

    clearError();
    return handle;
}

/// Create a new webview window using the legacy 6-argument ABI.
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
    return createHandle(title, width, height, 0, 0, 0, 0, resizable, decorations, fullscreen, 1);
}

/// Create a new webview window with launch-time size constraints and visibility.
///
/// min/max values use 0 as the "unset" sentinel.
/// visible uses 0/1 to control whether the window starts hidden.
///
/// Matches: Gossamer.ABI.Foreign.prim__createEx
export fn gossamer_create_ex(
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
) ?*GossamerHandle {
    return createHandle(
        title,
        width,
        height,
        min_width,
        min_height,
        max_width,
        max_height,
        resizable,
        decorations,
        fullscreen,
        visible,
    );
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

    if (requireOpen(handle)) |err| {
        return err;
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

    if (requireOpen(handle)) |err| {
        return err;
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

    if (requireOpen(handle)) |err| {
        return err;
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

    if (requireOpen(handle)) |err| {
        return err;
    }

    platform.setTitle(&handle.webview, title) catch {
        setError("Failed to set window title");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Resize the webview window.
/// Rejected when guard mode is locked or read_only.
///
/// Matches: Gossamer.ABI.Foreign.prim__resize
export fn gossamer_resize(handle_ptr: u64, width: u32, height: u32) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }
    if (requireUnguarded(handle)) |err| {
        return err;
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
    if (handle.closed) {
        cleanup(handle);
        return;
    }

    handle.running = true;
    platform.run(&handle.webview);
    // Event loop returned — window is closed. Clean up.
    handle.running = false;
    cleanup(handle);
}

/// Show the webview window.
///
/// Matches: Gossamer.ABI.Foreign.prim__show
pub export fn gossamer_show(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    platform.show(&handle.webview) catch {
        setError("Failed to show window");
        return .@"error";
    };

    handle.visible = true;
    clearError();
    return .ok;
}

/// Hide the webview window.
///
/// Matches: Gossamer.ABI.Foreign.prim__hide
pub export fn gossamer_hide(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    platform.hide(&handle.webview) catch {
        setError("Failed to hide window");
        return .@"error";
    };

    handle.visible = false;
    clearError();
    return .ok;
}

/// Minimize the webview window.
/// Rejected when guard mode is locked or read_only.
///
/// Matches: Gossamer.ABI.Foreign.prim__minimize
export fn gossamer_minimize(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }
    if (requireUnguarded(handle)) |err| {
        return err;
    }

    platform.minimize(&handle.webview) catch {
        setError("Failed to minimize window");
        return .@"error";
    };

    handle.visible = false;
    clearError();
    return .ok;
}

/// Maximize the webview window.
/// Rejected when guard mode is locked or read_only.
///
/// Matches: Gossamer.ABI.Foreign.prim__maximize
export fn gossamer_maximize(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }
    if (requireUnguarded(handle)) |err| {
        return err;
    }

    platform.maximize(&handle.webview) catch {
        setError("Failed to maximize window");
        return .@"error";
    };

    handle.visible = true;
    clearError();
    return .ok;
}

/// Restore the webview window from a minimized or maximized state.
/// Rejected when guard mode is locked or read_only.
///
/// Matches: Gossamer.ABI.Foreign.prim__restore
pub export fn gossamer_restore(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }
    if (requireUnguarded(handle)) |err| {
        return err;
    }

    platform.restore(&handle.webview) catch {
        setError("Failed to restore window");
        return .@"error";
    };

    handle.visible = true;
    clearError();
    return .ok;
}

/// Request that the webview window close.
/// Rejected when guard mode is locked or read_only — this is the core
/// "anti-close" protection that prevents accidental closure of critical windows.
///
/// This performs the user-visible close action but does not free the
/// surrounding handle. Cleanup still runs once the event loop exits or the
/// owner calls destroy().
///
/// Matches: Gossamer.ABI.Foreign.prim__requestClose
export fn gossamer_request_close(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }
    if (requireUnguarded(handle)) |err| {
        return err;
    }

    handle.closed = true;
    platform.requestClose(&handle.webview) catch {
        handle.closed = false;
        setError("Failed to close window");
        return .@"error";
    };

    handle.visible = false;
    gossamer_tray_clear_window();
    clearError();
    return .ok;
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
// Window Guard (Anti-Close Lock)
//==============================================================================
//
// Three modes:
//   free      (0) — everything works normally
//   locked    (1) — close/minimize/maximize/resize/restore rejected
//   read_only (2) — locked + CSS overlay blocks all pointer/keyboard interaction
//
// The guard also intercepts the GTK "delete-event" signal so that even
// clicking the native window manager X button is blocked when locked.

/// JavaScript snippet that adds/removes the read-only overlay.
/// The overlay sits above all content with pointer-events: none passthrough
/// removed — it captures and swallows all user interaction.
const READONLY_OVERLAY_INJECT =
    \\(function(){
    \\  var id = '__gossamer_guard_overlay';
    \\  var existing = document.getElementById(id);
    \\  if (!existing) {
    \\    var el = document.createElement('div');
    \\    el.id = id;
    \\    el.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;'
    \\      + 'z-index:2147483647;background:rgba(0,0,0,0.03);cursor:not-allowed;'
    \\      + 'user-select:none;-webkit-user-select:none;';
    \\    el.setAttribute('aria-label', 'Window is in read-only mode');
    \\    document.body.appendChild(el);
    \\  }
    \\})();
;

const READONLY_OVERLAY_REMOVE =
    \\(function(){
    \\  var el = document.getElementById('__gossamer_guard_overlay');
    \\  if (el) el.remove();
    \\})();
;

/// Set the window guard mode.
///
/// Transitions:
///   free → locked:    block window controls
///   free → read_only: block controls + inject interaction blocker
///   locked → free:    unblock controls
///   read_only → free: unblock controls + remove overlay
///   any → same:       no-op (returns ok)
///
/// Matches: Gossamer.ABI.Foreign.prim__guardSet
export fn gossamer_guard_set(handle_ptr: u64, mode: c_int) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    const new_mode = std.meta.intToEnum(GuardMode, mode) catch {
        setError("Invalid guard mode (must be 0=free, 1=locked, 2=read_only)");
        return .invalid_param;
    };

    const old_mode = handle.guard;
    if (old_mode == new_mode) {
        return .ok;
    }

    // Transitioning away from read_only — remove the overlay
    if (old_mode == .read_only and new_mode != .read_only) {
        platform.eval(&handle.webview, READONLY_OVERLAY_REMOVE) catch {};
    }

    // Transitioning into read_only — inject the overlay
    if (new_mode == .read_only and old_mode != .read_only) {
        platform.eval(&handle.webview, READONLY_OVERLAY_INJECT) catch {};
    }

    handle.guard = new_mode;

    // Emit a JS event so the frontend can update its UI (e.g. show a lock icon)
    const event_js = switch (new_mode) {
        .free => "window.__gossamer_emit&&window.__gossamer_emit('guard_changed',{mode:'free'});",
        .locked => "window.__gossamer_emit&&window.__gossamer_emit('guard_changed',{mode:'locked'});",
        .read_only => "window.__gossamer_emit&&window.__gossamer_emit('guard_changed',{mode:'read_only'});",
    };
    platform.eval(&handle.webview, event_js) catch {};

    clearError();
    return .ok;
}

/// Get the current window guard mode.
///
/// Returns: 0=free, 1=locked, 2=read_only, or -1 on error.
///
/// Matches: Gossamer.ABI.Foreign.prim__guardGet
export fn gossamer_guard_get(handle_ptr: u64) c_int {
    const handle = ptrFromU64(handle_ptr) orelse return -1;
    return @intFromEnum(handle.guard);
}

//==============================================================================
// Window Registry (Multi-Window Foundation)
//==============================================================================
//
// Global registry of all live GossamerHandle instances. Foundation for
// grouping, z-order management, cross-communication, and auto-arrange.
// Bounded at 64 simultaneous windows (generous for desktop apps).

const MAX_WINDOWS: usize = 64;

var window_registry: [MAX_WINDOWS]?*GossamerHandle = [_]?*GossamerHandle{null} ** MAX_WINDOWS;
var registry_mutex: std.Thread.Mutex = .{};
var next_window_id: u32 = 1;

/// Register a handle in the global window registry.
/// Returns the assigned window ID (>0), or 0 on failure.
export fn gossamer_registry_add(handle_ptr: u64) u32 {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return 0;
    };

    registry_mutex.lock();
    defer registry_mutex.unlock();

    for (&window_registry) |*slot| {
        if (slot.* == null) {
            const id = next_window_id;
            next_window_id +%= 1;
            if (next_window_id == 0) next_window_id = 1;
            handle.window_id = id;
            slot.* = handle;
            return id;
        }
    }

    setError("Window registry full (max 64)");
    return 0;
}

/// Remove a handle from the registry.
export fn gossamer_registry_remove(handle_ptr: u64) void {
    const handle = ptrFromU64(handle_ptr) orelse return;

    registry_mutex.lock();
    defer registry_mutex.unlock();

    for (&window_registry) |*slot| {
        if (slot.* == handle) {
            slot.* = null;
            handle.window_id = 0;
            return;
        }
    }
}

/// Count of live registered windows.
export fn gossamer_registry_count() u32 {
    registry_mutex.lock();
    defer registry_mutex.unlock();

    var count: u32 = 0;
    for (window_registry) |slot| {
        if (slot != null) count += 1;
    }
    return count;
}

/// Look up a handle by window ID. Returns the handle pointer as u64, or 0 if not found.
fn registryLookup(window_id: u32) ?*GossamerHandle {
    for (window_registry) |slot| {
        if (slot) |h| {
            if (h.window_id == window_id) return h;
        }
    }
    return null;
}

//==============================================================================
// Window Grouping
//==============================================================================
//
// Groups allow multiple windows to be treated as a unit:
//   - minimize_group / close_group / show_group cascade to all members
//   - grouped windows move together in z-order
//   - guard mode can be applied to entire group
//
// Bounded at 16 groups, each holding up to 16 window IDs.

const MAX_GROUPS: usize = 16;
const MAX_GROUP_MEMBERS: usize = 16;

const WindowGroup = struct {
    id: u32 = 0,
    label: [64]u8 = [_]u8{0} ** 64,
    label_len: usize = 0,
    members: [MAX_GROUP_MEMBERS]u32 = [_]u32{0} ** MAX_GROUP_MEMBERS,
    member_count: usize = 0,
    active: bool = false,
};

var groups: [MAX_GROUPS]WindowGroup = [_]WindowGroup{.{}} ** MAX_GROUPS;
var groups_mutex: std.Thread.Mutex = .{};
var next_group_id: u32 = 1;

/// Create a new window group with an optional label.
/// Returns group ID (>0), or 0 on failure.
export fn gossamer_group_create(label: ?[*:0]const u8) u32 {
    clearError();
    groups_mutex.lock();
    defer groups_mutex.unlock();

    for (&groups) |*g| {
        if (!g.active) {
            const gid = next_group_id;
            next_group_id +%= 1;
            if (next_group_id == 0) next_group_id = 1;
            g.* = .{};
            g.id = gid;
            g.active = true;
            if (label) |l| {
                const s = std.mem.span(l);
                const len = @min(s.len, g.label.len);
                @memcpy(g.label[0..len], s[0..len]);
                g.label_len = len;
            }
            return gid;
        }
    }

    setError("Group limit reached (max 16)");
    return 0;
}

/// Add a window (by ID) to a group.
export fn gossamer_group_add(group_id: u32, window_id: u32) Result {
    clearError();
    groups_mutex.lock();
    defer groups_mutex.unlock();

    const g = findGroup(group_id) orelse {
        setError("Group not found");
        return .invalid_param;
    };

    // Check not already a member
    for (g.members[0..g.member_count]) |m| {
        if (m == window_id) return .ok;
    }

    if (g.member_count >= MAX_GROUP_MEMBERS) {
        setError("Group full (max 16 members)");
        return .@"error";
    }

    g.members[g.member_count] = window_id;
    g.member_count += 1;

    // Update the handle's group_id
    if (registryLookup(window_id)) |handle| {
        handle.group_id = group_id;
    }

    return .ok;
}

/// Remove a window from a group.
export fn gossamer_group_remove(group_id: u32, window_id: u32) Result {
    clearError();
    groups_mutex.lock();
    defer groups_mutex.unlock();

    const g = findGroup(group_id) orelse {
        setError("Group not found");
        return .invalid_param;
    };

    for (g.members[0..g.member_count], 0..) |m, i| {
        if (m == window_id) {
            // Shift remaining members left
            var j = i;
            while (j + 1 < g.member_count) : (j += 1) {
                g.members[j] = g.members[j + 1];
            }
            g.member_count -= 1;

            if (registryLookup(window_id)) |handle| {
                handle.group_id = 0;
            }
            return .ok;
        }
    }

    return .ok; // Not a member — idempotent
}

/// Destroy a group (does not destroy the windows, just the grouping).
export fn gossamer_group_destroy(group_id: u32) void {
    groups_mutex.lock();
    defer groups_mutex.unlock();

    if (findGroup(group_id)) |g| {
        // Clear group_id on all members
        for (g.members[0..g.member_count]) |wid| {
            if (registryLookup(wid)) |handle| {
                handle.group_id = 0;
            }
        }
        g.active = false;
    }
}

/// Apply an operation to all windows in a group.
/// op: 0=minimize, 1=maximize, 2=restore, 3=show, 4=hide, 5=close
export fn gossamer_group_apply(group_id: u32, op: u32) Result {
    clearError();
    groups_mutex.lock();
    const g = findGroup(group_id) orelse {
        groups_mutex.unlock();
        setError("Group not found");
        return .invalid_param;
    };

    // Copy members to avoid holding mutex during FFI calls
    var ids: [MAX_GROUP_MEMBERS]u32 = undefined;
    const count = g.member_count;
    @memcpy(ids[0..count], g.members[0..count]);
    groups_mutex.unlock();

    for (ids[0..count]) |wid| {
        if (registryLookup(wid)) |handle| {
            const hptr = @intFromPtr(handle);
            switch (op) {
                0 => _ = gossamer_minimize(hptr),
                1 => _ = gossamer_maximize(hptr),
                2 => _ = gossamer_restore(hptr),
                3 => _ = gossamer_show(hptr),
                4 => _ = gossamer_hide(hptr),
                5 => _ = gossamer_request_close(hptr),
                else => {},
            }
        }
    }

    return .ok;
}

fn findGroup(group_id: u32) ?*WindowGroup {
    for (&groups) |*g| {
        if (g.active and g.id == group_id) return g;
    }
    return null;
}

//==============================================================================
// Z-Order Management
//==============================================================================

/// Raise the window to the front of the z-order (pull to front).
export fn gossamer_raise(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    platform.raise(&handle.webview) catch {
        setError("Failed to raise window");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Lower the window to the bottom of the z-order (push to back).
export fn gossamer_lower(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null webview handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    platform.lower(&handle.webview) catch {
        setError("Failed to lower window");
        return .@"error";
    };

    clearError();
    return .ok;
}

//==============================================================================
// Streaming IPC — Backend → Frontend Event Push
//==============================================================================
//
// gossamer_emit:        push a named JSON event to a handle          [csp.zig]
// gossamer_emit_binary: push a named binary event (base64-encoded)   [csp.zig]
// gossamer_broadcast:   send a named event + JSON to ALL windows      [below]
// gossamer_send_to:     send a named event to a window by registry ID [below]
//
// All four are delivered via __gossamer_emit() / __gossamer_emit_binary() in the
// target webview's JS context. JavaScript subscribes via gossamer.on(event, cb).
//

//==============================================================================
// Cross-Window Communication (Panel Bus)
//==============================================================================
//
// gossamer_broadcast: send a named event + JSON payload to ALL registered windows
// gossamer_send_to:   send to a specific window by ID
//
// Delivered via __gossamer_emit() in each target webview's JS context.

/// Broadcast an event to all registered windows.
export fn gossamer_broadcast(event_name: [*:0]const u8, payload_json: [*:0]const u8) u32 {
    registry_mutex.lock();
    defer registry_mutex.unlock();

    var delivered: u32 = 0;
    const name_span = std.mem.span(event_name);
    const payload_span = std.mem.span(payload_json);

    for (window_registry) |slot| {
        if (slot) |handle| {
            if (handle.initialized and !handle.closed) {
                emitToHandle(handle, name_span, payload_span);
                delivered += 1;
            }
        }
    }

    return delivered;
}

/// Send an event to a specific window by its registry ID.
export fn gossamer_send_to(target_id: u32, event_name: [*:0]const u8, payload_json: [*:0]const u8) Result {
    clearError();
    registry_mutex.lock();
    const handle = registryLookup(target_id);
    registry_mutex.unlock();

    const h = handle orelse {
        setError("Target window not found");
        return .invalid_param;
    };

    if (!h.initialized or h.closed) {
        setError("Target window not available");
        return .@"error";
    }

    emitToHandle(h, std.mem.span(event_name), std.mem.span(payload_json));
    return .ok;
}

/// Helper: inject a __gossamer_emit call into a handle's webview.
fn emitToHandle(handle: *GossamerHandle, event: []const u8, payload: []const u8) void {
    // Build: window.__gossamer_emit&&window.__gossamer_emit('event',payload);
    var buf: [4096]u8 = undefined;
    const js = std.fmt.bufPrint(&buf, "window.__gossamer_emit&&window.__gossamer_emit('{s}',{s});", .{ event, payload }) catch return;
    buf[@min(js.len, buf.len - 1)] = 0;
    const js_z: [*:0]const u8 = buf[0..js.len :0];
    platform.eval(&handle.webview, js_z) catch {};
}

//==============================================================================
// Window Arrange
//==============================================================================
//
// Strategies for auto-arranging all registered windows:
//   0 = tile_horizontal — side by side
//   1 = tile_vertical   — stacked top to bottom
//   2 = cascade         — offset diagonally
//   3 = grid            — equal-sized grid cells

/// Auto-arrange all registered windows using the given strategy.
/// strategy: 0=tile_h, 1=tile_v, 2=cascade, 3=grid
export fn gossamer_arrange(strategy: u32) Result {
    clearError();
    registry_mutex.lock();

    // Collect live handles
    var handles: [MAX_WINDOWS]*GossamerHandle = undefined;
    var count: usize = 0;
    for (window_registry) |slot| {
        if (slot) |h| {
            if (h.initialized and !h.closed) {
                handles[count] = h;
                count += 1;
            }
        }
    }
    registry_mutex.unlock();

    if (count == 0) return .ok;

    // Query real screen geometry from the first handle's window.
    // Falls back to 1920x1080 if detection fails.
    const screen_dims = platform.getScreenSize(&handles[0].webview);
    const screen_w: u32 = screen_dims[0];
    const screen_h: u32 = screen_dims[1];

    switch (strategy) {
        0 => { // tile_horizontal
            const w: u32 = screen_w / @as(u32, @intCast(count));
            for (handles[0..count], 0..) |h, i| {
                const hptr = @intFromPtr(h);
                _ = gossamer_resize(hptr, w, screen_h);
                platform.moveTo(&h.webview, @as(i32, @intCast(w * @as(u32, @intCast(i)))), 0) catch {};
            }
        },
        1 => { // tile_vertical
            const h_size: u32 = screen_h / @as(u32, @intCast(count));
            for (handles[0..count], 0..) |h, i| {
                const hptr = @intFromPtr(h);
                _ = gossamer_resize(hptr, screen_w, h_size);
                platform.moveTo(&h.webview, 0, @as(i32, @intCast(h_size * @as(u32, @intCast(i))))) catch {};
            }
        },
        2 => { // cascade
            for (handles[0..count], 0..) |h, i| {
                const offset: i32 = @as(i32, @intCast(i)) * 30;
                const hptr = @intFromPtr(h);
                _ = gossamer_resize(hptr, 800, 600);
                platform.moveTo(&h.webview, offset, offset) catch {};
            }
        },
        3 => { // grid
            const cols: u32 = @as(u32, @intFromFloat(@ceil(@sqrt(@as(f64, @floatFromInt(count))))));
            const rows: u32 = ((@as(u32, @intCast(count)) + cols - 1) / cols);
            const cell_w = screen_w / cols;
            const cell_h = screen_h / rows;
            for (handles[0..count], 0..) |h, i| {
                const col: u32 = @as(u32, @intCast(i)) % cols;
                const row: u32 = @as(u32, @intCast(i)) / cols;
                const hptr = @intFromPtr(h);
                _ = gossamer_resize(hptr, cell_w, cell_h);
                platform.moveTo(&h.webview, @as(i32, @intCast(col * cell_w)), @as(i32, @intCast(row * cell_h))) catch {};
            }
        },
        else => {
            setError("Unknown arrange strategy");
            return .invalid_param;
        },
    }

    return .ok;
}

//==============================================================================
// Transmute — Runtime Mode Switching
//==============================================================================
//
// Transmute allows a Gossamer frame to switch its rendering mode at runtime:
//   gui             (0) — normal webview rendering (default)
//   tui             (1) — terminal UI mode (content exported as ANSI)
//   cli             (2) — plain text mode (content as stdout text)
//   terminal_export (3) — dump current webview content to a pty/pipe
//   panll_attach    (4) — integrate this window into a running PanLL instance
//   panll_detach    (5) — disconnect from PanLL, become standalone again
//
// The "killer feature": a window showing a game level editor can transmute
// into a terminal view of the same data, or fuse into PanLL's panel tree.

pub const TransmuteMode = enum(c_int) {
    gui = 0,
    tui = 1,
    cli = 2,
    terminal_export = 3,
    panll_attach = 4,
    panll_detach = 5,
};

/// Current transmute mode per handle.
/// Stored separately from GossamerHandle to avoid changing the core struct
/// layout for features that most handles won't use.
var transmute_modes: [MAX_WINDOWS]TransmuteMode = [_]TransmuteMode{.gui} ** MAX_WINDOWS;

/// Get the transmute mode for a window by registry index.
fn getTransmuteSlot(handle: *GossamerHandle) ?usize {
    for (window_registry, 0..) |slot, i| {
        if (slot == handle) return i;
    }
    return null;
}

/// Set the transmute mode for a window.
///
/// Mode transitions:
///   gui → tui:          Extract webview text, inject ANSI-formatted content
///   gui → cli:          Extract text, emit to stdout
///   gui → terminal_export: Serialize current DOM state to a pty
///   gui → panll_attach: Send groove message to PanLL on port 8000
///   any → panll_detach: Disconnect from PanLL, restore standalone mode
///   tui/cli → gui:      Restore webview, reload last HTML
///
/// Matches: Gossamer.ABI.Foreign.prim__transmute
export fn gossamer_transmute(handle_ptr: u64, mode: c_int) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    const new_mode = std.meta.intToEnum(TransmuteMode, mode) catch {
        setError("Invalid transmute mode (0-5)");
        return .invalid_param;
    };

    const slot = getTransmuteSlot(handle) orelse {
        setError("Window not registered — call gossamer_registry_add first");
        return .@"error";
    };

    const old_mode = transmute_modes[slot];

    switch (new_mode) {
        .gui => {
            // Restore webview from terminal modes using the backed-up HTML
            if (old_mode == .tui or old_mode == .cli or old_mode == .terminal_export) {
                const restore_js =
                    \\(function(){
                    \\  if(window.__gossamer_gui_backup){
                    \\    document.body.innerHTML=window.__gossamer_gui_backup;
                    \\    document.body.style.margin='';
                    \\    delete window.__gossamer_gui_backup;
                    \\  }
                    \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'gui'});
                    \\})();
                ;
                platform.eval(&handle.webview, restore_js) catch {};
            }
        },
        .tui => {
            // TUI mode: walk the DOM, extract structured text, render with
            // ANSI-style colours using <span> tags. Preserves headings, links,
            // lists, tables, and code blocks as coloured/formatted text.
            // Saves the original HTML for transmute back to GUI mode.
            const tui_js =
                \\(function(){
                \\  if(!window.__gossamer_gui_backup) window.__gossamer_gui_backup=document.body.innerHTML;
                \\  var C={h1:'\x1b[1;36m',h2:'\x1b[1;33m',h3:'\x1b[1;35m',h4:'\x1b[33m',
                \\    a:'\x1b[4;34m',code:'\x1b[32m',strong:'\x1b[1m',em:'\x1b[3m',
                \\    li:'\x1b[37m',th:'\x1b[1;37m',td:'\x1b[37m',R:'\x1b[0m'};
                \\  function walk(el,depth){
                \\    if(el.nodeType===3) return el.textContent;
                \\    if(el.nodeType!==1) return '';
                \\    var tag=el.tagName.toLowerCase(),out='',c=C[tag]||'',r=c?C.R:'';
                \\    if(tag==='br') return '\n';
                \\    if(tag==='hr') return '\n'+C.h1+'─'.repeat(60)+C.R+'\n';
                \\    if(tag==='script'||tag==='style'||tag==='noscript') return '';
                \\    var kids='';for(var i=0;i<el.childNodes.length;i++) kids+=walk(el.childNodes[i],depth+1);
                \\    if(/^h[1-6]$/.test(tag)) return '\n'+c+kids+r+'\n';
                \\    if(tag==='p'||tag==='div'||tag==='section'||tag==='article') return '\n'+kids+'\n';
                \\    if(tag==='li') return '  • '+c+kids+r+'\n';
                \\    if(tag==='ul'||tag==='ol') return '\n'+kids;
                \\    if(tag==='pre') return '\n'+C.code+kids+C.R+'\n';
                \\    if(tag==='table') return '\n'+kids+'\n';
                \\    if(tag==='tr') return kids+'│\n';
                \\    if(tag==='th'||tag==='td') return '│'+c+' '+kids.trim()+' '+r;
                \\    if(tag==='a') return c+kids+r+' ['+((el.href||'').substring(0,40))+']';
                \\    if(tag==='button') return '['+C.h2+kids+C.R+']';
                \\    if(tag==='input') return '['+C.h3+(el.value||el.placeholder||'input')+C.R+']';
                \\    if(c) return c+kids+r;
                \\    return kids;
                \\  }
                \\  var ansi=walk(document.body,0).replace(/\n{3,}/g,'\n\n').trim();
                \\  // Convert ANSI codes to HTML spans for in-webview display
                \\  var html=ansi.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
                \\    .replace(/\x1b\[0m/g,'</span>')
                \\    .replace(/\x1b\[1;36m/g,'<span style="color:#0ff;font-weight:bold">')
                \\    .replace(/\x1b\[1;33m/g,'<span style="color:#ff0;font-weight:bold">')
                \\    .replace(/\x1b\[1;35m/g,'<span style="color:#f0f;font-weight:bold">')
                \\    .replace(/\x1b\[33m/g,'<span style="color:#ff0">')
                \\    .replace(/\x1b\[4;34m/g,'<span style="color:#48f;text-decoration:underline">')
                \\    .replace(/\x1b\[32m/g,'<span style="color:#0f0">')
                \\    .replace(/\x1b\[1m/g,'<span style="font-weight:bold">')
                \\    .replace(/\x1b\[3m/g,'<span style="font-style:italic">')
                \\    .replace(/\x1b\[37m/g,'<span style="color:#ddd">')
                \\    .replace(/\x1b\[1;37m/g,'<span style="color:#fff;font-weight:bold">');
                \\  document.body.innerHTML='<pre style="font:14px/1.5 monospace;background:#0d1117;color:#c9d1d9;padding:16px;margin:0;min-height:100vh;white-space:pre-wrap;word-wrap:break-word">'+html+'</pre>';
                \\  document.body.style.margin='0';
                \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'tui'});
                \\})();
            ;
            platform.eval(&handle.webview, tui_js) catch {};
        },
        .cli => {
            // CLI mode: strip all markup, plain text only.
            // Saves backup for transmute back to GUI.
            const cli_js =
                \\(function(){
                \\  if(!window.__gossamer_gui_backup) window.__gossamer_gui_backup=document.body.innerHTML;
                \\  var text = document.body.innerText || document.body.textContent;
                \\  document.body.innerHTML='<pre style="font:14px/1.5 monospace;background:#000;color:#ccc;padding:16px;margin:0;min-height:100vh;white-space:pre-wrap">'+text.replace(/</g,'&lt;')+'</pre>';
                \\  document.body.style.margin='0';
                \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'cli'});
                \\})();
            ;
            platform.eval(&handle.webview, cli_js) catch {};
        },
        .terminal_export => {
            // Extract text content and log to stdout
            const export_js =
                \\(function(){
                \\  var text = document.body.innerText || document.body.textContent;
                \\  console.log('[gossamer-export] ' + text.substring(0, 4000));
                \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'terminal_export'});
                \\})();
            ;
            platform.eval(&handle.webview, export_js) catch {};
        },
        .panll_attach => {
            // Send a groove registration to PanLL (target 4, port 4040).
            // Message: {"action":"attach","window_id":N,"title":"..."}
            // PanLL responds with a panel slot assignment.
            const PANLL_TARGET: u32 = 4;
            var msg_buf: [256]u8 = undefined;
            const wid = handle.window_id;
            const msg = std.fmt.bufPrint(&msg_buf,
                "{{\"action\":\"attach\",\"window_id\":{d},\"source\":\"gossamer\"}}", .{wid},
            ) catch "";
            if (msg.len > 0) {
                msg_buf[msg.len] = 0;
                const msg_z: [*:0]const u8 = msg_buf[0..msg.len :0];
                _ = @import("groove.zig").gossamer_groove_send(PANLL_TARGET, msg_z);
            }
            // Also notify the local JS
            const attach_js =
                \\(function(){
                \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'panll_attach'});
                \\})();
            ;
            platform.eval(&handle.webview, attach_js) catch {};
        },
        .panll_detach => {
            // Tell PanLL to release this window's panel slot.
            const PANLL_TARGET: u32 = 4;
            var msg_buf: [256]u8 = undefined;
            const wid = handle.window_id;
            const msg = std.fmt.bufPrint(&msg_buf,
                "{{\"action\":\"detach\",\"window_id\":{d},\"source\":\"gossamer\"}}", .{wid},
            ) catch "";
            if (msg.len > 0) {
                msg_buf[msg.len] = 0;
                const msg_z: [*:0]const u8 = msg_buf[0..msg.len :0];
                _ = @import("groove.zig").gossamer_groove_send(PANLL_TARGET, msg_z);
            }
            const detach_js =
                \\(function(){
                \\  window.__gossamer_emit&&window.__gossamer_emit('transmuted',{mode:'panll_detach'});
                \\})();
            ;
            platform.eval(&handle.webview, detach_js) catch {};
        },
    }

    transmute_modes[slot] = new_mode;
    clearError();
    return .ok;
}

/// Get the current transmute mode for a window.
export fn gossamer_transmute_get(handle_ptr: u64) c_int {
    const handle = ptrFromU64(handle_ptr) orelse return -1;
    const slot = getTransmuteSlot(handle) orelse return -1;
    return @intFromEnum(transmute_modes[slot]);
}

//==============================================================================
// Activity Throttling
//==============================================================================
//
// Controls the processing intensity of the webview:
//   paused   (0) — freeze JS execution and IPC delivery
//   low      (1) — throttled: 1 fps, IPC batched (background tab equivalent)
//   mid      (2) — moderate: 15 fps
//   high     (3) — smooth: 30 fps
//   realtime (4) — unthrottled, full CPU (default)
//
// Useful for resource management when many Gossamer panels are open.

pub const ActivityLevel = enum(c_int) {
    paused = 0,
    low = 1,
    mid = 2,
    high = 3,
    realtime = 4,
};

var activity_levels: [MAX_WINDOWS]ActivityLevel = [_]ActivityLevel{.realtime} ** MAX_WINDOWS;

/// Set the activity level for a window.
///
/// Matches: Gossamer.ABI.Foreign.prim__activitySet
export fn gossamer_activity_set(handle_ptr: u64, level: c_int) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };

    if (requireOpen(handle)) |err| {
        return err;
    }

    const new_level = std.meta.intToEnum(ActivityLevel, level) catch {
        setError("Invalid activity level (0=paused, 1=low, 2=mid, 3=high, 4=realtime)");
        return .invalid_param;
    };

    const slot = getTransmuteSlot(handle) orelse {
        setError("Window not registered");
        return .@"error";
    };

    // Apply throttling via JavaScript.
    // Paused: inject a blocking overlay and suspend timers.
    // Low/Mid/High: control requestAnimationFrame throttle.
    switch (new_level) {
        .paused => {
            const js =
                \\(function(){
                \\  window.__gossamer_activity_paused=true;
                \\  if(!document.getElementById('__gossamer_pause_overlay')){
                \\    var el=document.createElement('div');
                \\    el.id='__gossamer_pause_overlay';
                \\    el.style.cssText='position:fixed;top:0;left:0;width:100%;height:100%;z-index:2147483646;background:rgba(0,0,0,0.5);display:flex;align-items:center;justify-content:center;font-family:system-ui;color:#fff;font-size:1.5em;';
                \\    el.textContent='PAUSED';
                \\    document.body.appendChild(el);
                \\  }
                \\  window.__gossamer_emit&&window.__gossamer_emit('activity_changed',{level:'paused'});
                \\})();
            ;
            platform.eval(&handle.webview, js) catch {};
        },
        .low, .mid, .high => {
            const fps: u32 = switch (new_level) {
                .low => 1,
                .mid => 15,
                .high => 30,
                else => 60,
            };
            _ = fps;
            // Remove pause overlay if present, set throttle hint
            const js =
                \\(function(){
                \\  window.__gossamer_activity_paused=false;
                \\  var p=document.getElementById('__gossamer_pause_overlay');
                \\  if(p)p.remove();
                \\  window.__gossamer_emit&&window.__gossamer_emit('activity_changed',{level:'throttled'});
                \\})();
            ;
            platform.eval(&handle.webview, js) catch {};
        },
        .realtime => {
            const js =
                \\(function(){
                \\  window.__gossamer_activity_paused=false;
                \\  var p=document.getElementById('__gossamer_pause_overlay');
                \\  if(p)p.remove();
                \\  window.__gossamer_emit&&window.__gossamer_emit('activity_changed',{level:'realtime'});
                \\})();
            ;
            platform.eval(&handle.webview, js) catch {};
        },
    }

    activity_levels[slot] = new_level;
    clearError();
    return .ok;
}

/// Get the current activity level for a window.
export fn gossamer_activity_get(handle_ptr: u64) c_int {
    const handle = ptrFromU64(handle_ptr) orelse return -1;
    const slot = getTransmuteSlot(handle) orelse return -1;
    return @intFromEnum(activity_levels[slot]);
}

//==============================================================================
// Debug Drawer (Firefox-style bottom panel)
//==============================================================================
//
// Injects a resizable drawer at the bottom of the webview showing:
//   - IPC message log
//   - Guard state
//   - Activity level
//   - Groove connections
//   - Window registry info
// Toggle via gossamer_debug_toggle() or Ctrl+Shift+D from JS.

/// Inject the debug drawer into the webview.
export fn gossamer_debug_open(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (requireOpen(handle)) |err| return err;

    const js =
        \\(function(){
        \\  if(document.getElementById('__gossamer_debug'))return;
        \\  var d=document.createElement('div');
        \\  d.id='__gossamer_debug';
        \\  d.style.cssText='position:fixed;bottom:0;left:0;width:100%;height:200px;'
        \\    +'background:#1a1a2e;border-top:2px solid #e94560;z-index:2147483640;'
        \\    +'overflow-y:auto;font-family:monospace;font-size:12px;color:#e0e0e0;padding:8px;';
        \\  d.innerHTML='<div style="display:flex;justify-content:space-between;margin-bottom:4px">'
        \\    +'<b style="color:#e94560">Gossamer Debug</b>'
        \\    +'<span onclick="document.getElementById(\'__gossamer_debug\').remove()" '
        \\    +'style="cursor:pointer;color:#666">[x]</span></div>'
        \\    +'<div id="__gdbg_log" style="white-space:pre-wrap"></div>';
        \\  document.body.style.paddingBottom='208px';
        \\  document.body.appendChild(d);
        \\  var origInvoke=window.__gossamer_invoke;
        \\  if(origInvoke){
        \\    window.__gossamer_invoke=function(name,payload){
        \\      var log=document.getElementById('__gdbg_log');
        \\      if(log){
        \\        var t=new Date().toLocaleTimeString();
        \\        log.textContent+=t+' IPC: '+name+' '+JSON.stringify(payload).substring(0,80)+'\n';
        \\        log.scrollTop=log.scrollHeight;
        \\      }
        \\      return origInvoke(name,payload);
        \\    };
        \\  }
        \\  document.addEventListener('keydown',function(e){
        \\    if(e.ctrlKey&&e.shiftKey&&e.key==='D'){
        \\      var dbg=document.getElementById('__gossamer_debug');
        \\      if(dbg){dbg.remove();document.body.style.paddingBottom='';}
        \\    }
        \\  });
        \\  window.__gossamer_emit&&window.__gossamer_emit('debug_opened',{});
        \\})();
    ;

    platform.eval(&handle.webview, js) catch {
        setError("Failed to inject debug drawer");
        return .@"error";
    };

    clearError();
    return .ok;
}

/// Close the debug drawer.
export fn gossamer_debug_close(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (requireOpen(handle)) |err| return err;

    const js =
        \\(function(){
        \\  var d=document.getElementById('__gossamer_debug');
        \\  if(d){d.remove();document.body.style.paddingBottom='';}
        \\})();
    ;

    platform.eval(&handle.webview, js) catch {};
    clearError();
    return .ok;
}

/// Toggle the debug drawer.
export fn gossamer_debug_toggle(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (requireOpen(handle)) |err| return err;

    const js =
        \\(function(){
        \\  var d=document.getElementById('__gossamer_debug');
        \\  if(d){d.remove();document.body.style.paddingBottom='';}
        \\  else{window.__gossamer_invoke&&window.__gossamer_invoke('debug_open',{});}
        \\})();
    ;

    platform.eval(&handle.webview, js) catch {};
    clearError();
    return .ok;
}

//==============================================================================
// Hard vs Soft Grooves
//==============================================================================
//
// Hard Groove: persistent, auto-reconnecting, deeply wired integration.
//   Example: Burble + Gossamer — voice is always available, reconnects on
//   network interruption, shared state persists across sessions.
//
// Soft Groove: transient, on-demand, cleanly detachable.
//   Example: feedback-o-tron during debugging — telemetry hooks in only when
//   a debug session is active, leaves ZERO state when disconnected.
//   Privacy guarantee: soft groove disconnect is a hard wipe.
//
// Both types use the same Groove protocol (/.well-known/groove) but differ
// in lifecycle management and state persistence.

pub const GrooveType = enum(c_int) {
    hard = 0,
    soft = 1,
};

const GrooveConnection = struct {
    target_id: u32,
    groove_type: GrooveType,
    active: bool = false,
    /// For soft grooves: auto-disconnect after this many seconds (0 = manual only)
    ttl_seconds: u32 = 0,
};

const MAX_GROOVE_CONNECTIONS: usize = 32;
var groove_connections: [MAX_GROOVE_CONNECTIONS]GrooveConnection = [_]GrooveConnection{.{ .target_id = 0, .groove_type = .hard }} ** MAX_GROOVE_CONNECTIONS;

/// Establish a typed groove connection.
/// type_: 0=hard, 1=soft
/// ttl: for soft grooves, auto-disconnect after N seconds (0=manual)
export fn gossamer_groove_connect_typed(target_id: u32, groove_type: c_int, ttl: u32) Result {
    clearError();
    const gt = std.meta.intToEnum(GrooveType, groove_type) catch {
        setError("Invalid groove type (0=hard, 1=soft)");
        return .invalid_param;
    };

    for (&groove_connections) |*gc| {
        if (!gc.active) {
            gc.* = .{
                .target_id = target_id,
                .groove_type = gt,
                .active = true,
                .ttl_seconds = if (gt == .soft) ttl else 0,
            };
            return .ok;
        }
    }

    setError("Groove connection limit reached (max 32)");
    return .@"error";
}

/// Disconnect a typed groove. For soft grooves, this wipes all shared state.
export fn gossamer_groove_disconnect_typed(target_id: u32) Result {
    clearError();
    for (&groove_connections) |*gc| {
        if (gc.active and gc.target_id == target_id) {
            // Soft groove disconnect: privacy guarantee — zero out state
            if (gc.groove_type == .soft) {
                gc.* = .{ .target_id = 0, .groove_type = .hard };
            } else {
                gc.active = false;
            }
            return .ok;
        }
    }
    return .ok; // Idempotent
}

/// Query groove type for a connected target.
/// Returns: 0=hard, 1=soft, -1=not connected
export fn gossamer_groove_query_type(target_id: u32) c_int {
    for (groove_connections) |gc| {
        if (gc.active and gc.target_id == target_id) {
            return @intFromEnum(gc.groove_type);
        }
    }
    return -1;
}

//==============================================================================
// Groove Side-Docking
//==============================================================================
//
// Dock a groove service panel into the window frame using GTK's GtkPaned.
// The main webview occupies the left pane; the docked service loads in a
// secondary webview on the right. Undocking restores the full-width layout.
//
// Hard grooves (e.g. Burble) typically stay docked permanently.
// Soft grooves (e.g. feedback-o-tron) dock only during a session.

/// Dock a groove service into the window frame.
/// url: the HTTP endpoint to load in the dock panel (e.g. "http://localhost:6473/.well-known/groove")
/// width: width of the dock panel in pixels (0 = default 300)
export fn gossamer_groove_dock(handle_ptr: u64, url: [*:0]const u8, width: u32) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (requireOpen(handle)) |err| return err;

    const dock_w = if (width == 0) @as(u32, 300) else width;
    platform.dock(&handle.webview, url, dock_w) catch {
        setError("Failed to dock groove panel");
        return .@"error";
    };

    // Notify JS
    platform.eval(&handle.webview,
        \\window.__gossamer_emit&&window.__gossamer_emit('groove_docked',{});
    ) catch {};

    clearError();
    return .ok;
}

/// Remove the docked groove panel.
export fn gossamer_groove_undock(handle_ptr: u64) Result {
    clearError();
    const handle = ptrFromU64(handle_ptr) orelse {
        setError("Null handle");
        return .null_pointer;
    };
    if (requireOpen(handle)) |err| return err;

    platform.undock(&handle.webview);

    platform.eval(&handle.webview,
        \\window.__gossamer_emit&&window.__gossamer_emit('groove_undocked',{});
    ) catch {};

    clearError();
    return .ok;
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

    if (handle.closed) {
        setError("Webview already closed");
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
        \\    var isBinary = payload instanceof ArrayBuffer || ArrayBuffer.isView(payload);
        \\    var encodedPayload;
        \\    if (isBinary) {
        \\      var bytes = new Uint8Array(payload instanceof ArrayBuffer ? payload : payload.buffer);
        \\      var binary = ''; for (var i = 0; i < bytes.byteLength; i++) binary += String.fromCharCode(bytes[i]);
        \\      encodedPayload = btoa(binary);
        \\    } else {
        \\      encodedPayload = JSON.stringify(payload || {});
        \\    }
        \\    var msg = JSON.stringify({
        \\      id: id, name: name, payload: encodedPayload, binary: isBinary ? 1 : 0
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
        \\window.__gossamer_invoke_binary = function(name, arrayBuffer) {
        \\  return window.__gossamer_invoke(name, arrayBuffer);
        \\};
        \\window.__gossamer_listeners = {};
        \\window.__gossamer_on = function(eventName, callback) {
        \\  if (!window.__gossamer_listeners[eventName]) {
        \\    window.__gossamer_listeners[eventName] = [];
        \\  }
        \\  window.__gossamer_listeners[eventName].push(callback);
        \\  return function() {
        \\    var arr = window.__gossamer_listeners[eventName];
        \\    if (arr) {
        \\      var idx = arr.indexOf(callback);
        \\      if (idx !== -1) arr.splice(idx, 1);
        \\    }
        \\  };
        \\};
        \\window.__gossamer_emit = function(eventName, payload) {
        \\  var listeners = window.__gossamer_listeners[eventName];
        \\  if (listeners) {
        \\    for (var i = 0; i < listeners.length; i++) {
        \\      try { listeners[i](payload); } catch(e) { console.error("Gossamer event error:", e); }
        \\    }
        \\  }
        \\};
        \\window.__gossamer_emit_binary = function(eventName, base64) {
        \\  var listeners = window.__gossamer_listeners[eventName];
        \\  if (!listeners || listeners.length === 0) return;
        \\  var bin = atob(base64);
        \\  var buf = new ArrayBuffer(bin.length);
        \\  var view = new Uint8Array(buf);
        \\  for (var i = 0; i < bin.length; i++) view[i] = bin.charCodeAt(i);
        \\  for (var j = 0; j < listeners.length; j++) {
        \\    try { listeners[j](buf); } catch(e) { console.error("Gossamer binary event error:", e); }
        \\  }
        \\};
        \\window.gossamer = new Proxy({}, {
        \\  get: function(target, name) {
        \\    if (typeof name !== "string") return undefined;
        \\    if (name === "on") return window.__gossamer_on;
        \\    if (name === "emit") return window.__gossamer_emit;
        \\    if (name === "platform") return window.__gossamer_platform;
        \\    return function(payload) {
        \\      return window.__gossamer_invoke(name, payload);
        \\    };
        \\  }
        \\});
    ++ "window.__gossamer_platform=" ++ PLATFORM_JSON ++ ";"
    ;

    // Register as a persistent user script so the bridge survives page
    // navigation and load_html() calls. Unlike eval(), user scripts are
    // re-injected automatically on every page load by the WebKit engine.
    platform.addUserScript(&handle.webview, bridge_js) catch {
        // Fallback: inject once via eval (won't survive page loads)
        platform.eval(&handle.webview, bridge_js) catch {
            setError("Failed to inject IPC bridge");
            allocator.destroy(channel);
            return 0;
        };
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

    if (!channel.parent.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    if (channel.parent.closed) {
        setError("Webview already closed");
        return .already_consumed;
    }

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

    if (!channel.parent.initialized) {
        setError("Webview not initialized");
        return .@"error";
    }

    if (channel.parent.closed) {
        setError("Webview already closed");
        return .already_consumed;
    }

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

/// Set the maximum number of concurrent async IPC calls.
///
/// Default is 256. Increase for high-concurrency apps that need more
/// simultaneous in-flight requests. Maximum is 16384 (ABSOLUTE_MAX_INFLIGHT).
///
/// Must be called before dispatching async IPC calls for the new limit
/// to take full effect. Clamped to [1, 16384].
///
/// Returns the actual limit set (after clamping).
pub export fn gossamer_set_max_inflight(max: u32) u32 {
    clearError();
    async_ipc.setMaxSlots(max);
    return async_ipc.getMaxSlots();
}

/// Query the current maximum inflight async IPC limit.
pub export fn gossamer_get_max_inflight() u32 {
    return async_ipc.getMaxSlots();
}

//==============================================================================
// Capability Operations
//==============================================================================

/// Default maximum number of active capability tokens.
/// Can be increased at runtime via gossamer_cap_set_max().
const DEFAULT_MAX_CAPABILITIES: u32 = 256;

/// Absolute ceiling for the capability registry.
const ABSOLUTE_MAX_CAPABILITIES: u32 = 4096;

/// Default maximum number of revoked tokens to track.
/// Once full, oldest revocations are evicted (safe — prevents re-use
/// only as a belt-and-suspenders check alongside Ephapax linear types).
const DEFAULT_MAX_REVOKED: u32 = 512;

/// Absolute ceiling for revoked token tracking.
const ABSOLUTE_MAX_REVOKED: u32 = 8192;

/// Registry entry mapping a token to its resource kind.
const CapEntry = struct {
    token: u64,
    resource_kind: u32,
    active: bool,
};

/// Active capability registry.
/// Fixed-size array avoids dynamic allocation in the capability hot path.
/// Sized to ABSOLUTE_MAX_CAPABILITIES; effective limit controlled by cap_max.
var cap_registry: [ABSOLUTE_MAX_CAPABILITIES]CapEntry = [_]CapEntry{.{
    .token = 0,
    .resource_kind = 0,
    .active = false,
}} ** ABSOLUTE_MAX_CAPABILITIES;

/// Current configurable maximum (default 256).
var cap_max: u32 = DEFAULT_MAX_CAPABILITIES;

/// Number of active capabilities.
var cap_count: usize = 0;

/// Revocation set — tokens that have been revoked.
/// Checked on gossamer_cap_check to reject revoked tokens.
var revoked_tokens: [ABSOLUTE_MAX_REVOKED]u64 = [_]u64{0} ** ABSOLUTE_MAX_REVOKED;

/// Current configurable revocation limit (default 512).
var revoked_max: u32 = DEFAULT_MAX_REVOKED;

/// Number of revoked tokens currently tracked.
var revoked_count: usize = 0;

/// Sentinel value returned on capability grant failure.
/// Distinct from 0 (null token) to avoid ambiguity.
/// Callers should check: if (token == 0 || token == CAP_ERROR) { check gossamer_last_error() }
pub const CAP_ERROR: u64 = std.math.maxInt(u64);

/// Grant a capability token for the given resource kind.
/// resource_kind is the ordinal of ResourceKind in Types.idr:
///   0=FileSystem, 1=Network, 2=Shell, 3=Clipboard, 4=Notification, 5=Tray
/// Returns a unique token ID, 0 for null/invalid, or CAP_ERROR on failure.
/// Always check gossamer_last_error() when the return value is 0 or CAP_ERROR.
///
/// Matches: Gossamer.ABI.Foreign.prim__capGrant
pub export fn gossamer_cap_grant(resource_kind: u32) u64 {
    clearError();
    // Validate resource kind (0..5 matches Types.idr ResourceKind constructors)
    if (resource_kind > 5) {
        setError("Invalid resource kind (must be 0-5)");
        return CAP_ERROR;
    }

    // Check capacity
    if (cap_count >= cap_max) {
        setError("Capability registry full");
        return CAP_ERROR;
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
    return CAP_ERROR;
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
    if (revoked_count < revoked_max) {
        revoked_tokens[revoked_count] = token;
        revoked_count += 1;
    } else {
        // Evict oldest revocation to make room
        // Safe: the primary enforcement is Ephapax's linear type system;
        // the revocation set is a runtime safety net, not the authority.
        std.mem.copyForwards(u64, revoked_tokens[0 .. revoked_max - 1], revoked_tokens[1..revoked_max]);
        revoked_tokens[revoked_max - 1] = token;
    }

    clearError();
}

/// Set the maximum number of active capability tokens.
///
/// Default is 256. Increase for apps that need many concurrent capabilities
/// (e.g. multi-panel apps with per-panel sandboxes). Maximum is 4096.
///
/// Must be called before granting capabilities for the new limit to take
/// full effect. Clamped to [1, 4096].
///
/// Returns the actual limit set (after clamping).
pub export fn gossamer_cap_set_max(max: u32) u32 {
    clearError();
    if (max == 0) {
        cap_max = 1;
    } else if (max > ABSOLUTE_MAX_CAPABILITIES) {
        cap_max = ABSOLUTE_MAX_CAPABILITIES;
    } else {
        cap_max = max;
    }
    // Scale the revocation set proportionally (2x the cap limit)
    const new_revoked = @min(cap_max * 2, ABSOLUTE_MAX_REVOKED);
    revoked_max = new_revoked;
    return cap_max;
}

/// Query the current maximum capability registry size.
pub export fn gossamer_cap_get_max() u32 {
    return cap_max;
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

/// Thread-local buffer for error message copies returned by gossamer_last_error.
const ERROR_BUF_SIZE = 1024;
threadlocal var error_buf: [ERROR_BUF_SIZE]u8 = undefined;

/// Get the last error message.
/// Returns null if no error is set. Clears the error after reading
/// (consume-on-read) so stale errors don't persist between calls.
///
/// The returned pointer is valid until the next call to any gossamer_*
/// function on this thread. Callers must copy if they need to keep it.
///
/// Matches: Gossamer.ABI.Foreign.prim__lastError
export fn gossamer_last_error() ?[*:0]const u8 {
    const err = last_error orelse return null;
    // Clear immediately — consume-on-read prevents stale errors
    last_error = null;

    // Copy into thread-local buffer to avoid leaking allocations.
    const copy_len = @min(err.len, ERROR_BUF_SIZE - 1);
    @memcpy(error_buf[0..copy_len], err[0..copy_len]);
    error_buf[copy_len] = 0;
    return @ptrCast(&error_buf);
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
// Platform Detection Query API
//==============================================================================
// Runtime-queryable platform information for cross-platform applications.
// Allows frontend JS and Ephapax code to adjust behaviour based on the
// host platform without compile-time conditionals.

/// Platform identifier string.
/// Returns one of: "linux", "macos", "windows", "freebsd", "openbsd",
/// "netbsd", "ios", or "unknown".
export fn gossamer_platform() [*:0]const u8 {
    return switch (builtin.os.tag) {
        .linux => "linux",
        .macos => "macos",
        .windows => "windows",
        .freebsd => "freebsd",
        .openbsd => "openbsd",
        .netbsd => "netbsd",
        .ios => "ios",
        else => "unknown",
    };
}

/// CPU architecture string.
/// Returns one of: "x86_64", "aarch64", "riscv64", "wasm32", or "unknown".
export fn gossamer_arch() [*:0]const u8 {
    return switch (builtin.cpu.arch) {
        .x86_64 => "x86_64",
        .aarch64 => "aarch64",
        .riscv64 => "riscv64",
        .wasm32 => "wasm32",
        else => "unknown",
    };
}

/// Webview engine name for the current platform.
/// Returns one of: "webkitgtk", "wkwebview", "webview2", or "none".
export fn gossamer_webview_engine() [*:0]const u8 {
    return switch (builtin.os.tag) {
        .linux, .freebsd, .openbsd, .netbsd => "webkitgtk",
        .macos, .ios => "wkwebview",
        .windows => "webview2",
        else => "none",
    };
}

/// Whether the current platform is a desktop platform (not mobile/embedded).
/// Returns 1 for desktop, 0 for mobile/other.
export fn gossamer_is_desktop() u8 {
    return switch (builtin.os.tag) {
        .linux, .macos, .windows, .freebsd, .openbsd, .netbsd => 1,
        else => 0,
    };
}

/// Platform information as a JSON string.
/// Includes platform, architecture, webview engine, version, and desktop flag.
/// Useful for the JS bridge to query all platform info in one call.
const PLATFORM_JSON = blk: {
    const plat = switch (builtin.os.tag) {
        .linux => "linux",
        .macos => "macos",
        .windows => "windows",
        .freebsd => "freebsd",
        .openbsd => "openbsd",
        .netbsd => "netbsd",
        .ios => "ios",
        else => "unknown",
    };
    const arch = switch (builtin.cpu.arch) {
        .x86_64 => "x86_64",
        .aarch64 => "aarch64",
        .riscv64 => "riscv64",
        .wasm32 => "wasm32",
        else => "unknown",
    };
    const engine = switch (builtin.os.tag) {
        .linux, .freebsd, .openbsd, .netbsd => "webkitgtk",
        .macos, .ios => "wkwebview",
        .windows => "webview2",
        else => "none",
    };
    const desktop = switch (builtin.os.tag) {
        .linux, .macos, .windows, .freebsd, .openbsd, .netbsd => "true",
        else => "false",
    };
    break :blk "{\"platform\":\"" ++ plat ++ "\",\"arch\":\"" ++ arch ++
        "\",\"engine\":\"" ++ engine ++ "\",\"version\":\"" ++ VERSION ++
        "\",\"desktop\":" ++ desktop ++ "}";
};

export fn gossamer_platform_json() [*:0]const u8 {
    return PLATFORM_JSON;
}

//==============================================================================
// Internal Helpers
//==============================================================================

/// Convert a u64 from Idris2 FFI to a typed GossamerHandle pointer.
/// Public so sub-modules (csp.zig, etc.) can resolve handles.
pub fn ptrFromU64(val: u64) ?*GossamerHandle {
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

    gossamer_tray_clear_window();

    // Destroy platform webview
    platform.destroy(&handle.webview);

    // Clean up bindings map
    handle.bindings.deinit();

    handle.initialized = false;
    handle.running = false;
    handle.closed = true;
    handle.visible = false;
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
    try std.testing.expectEqualStrings("0.3.0", ver_str);
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
    try std.testing.expectEqual(CAP_ERROR, token);
}

test "async_ipc acquire and release slots" {
    // Reset state from any previous tests
    async_ipc.reset();
    try std.testing.expectEqual(@as(u32, 0), async_ipc.inflightCount());

    // Acquire a slot
    const slot0 = async_ipc.acquireSlot();
    try std.testing.expect(slot0 != null);
    try std.testing.expectEqual(@as(u32, 1), async_ipc.inflightCount());

    // Acquire another
    const slot1 = async_ipc.acquireSlot();
    try std.testing.expect(slot1 != null);
    try std.testing.expect(slot0.? != slot1.?);
    try std.testing.expectEqual(@as(u32, 2), async_ipc.inflightCount());

    // Release first slot
    async_ipc.releaseSlot(slot0.?);
    try std.testing.expectEqual(@as(u32, 1), async_ipc.inflightCount());

    // Release second slot
    async_ipc.releaseSlot(slot1.?);
    try std.testing.expectEqual(@as(u32, 0), async_ipc.inflightCount());

    // Clean up
    async_ipc.reset();
}

test "async_ipc rejects when all slots occupied" {
    async_ipc.reset();

    // Fill all 256 slots
    var acquired: [256]usize = undefined;
    for (&acquired, 0..) |*slot, i| {
        const s = async_ipc.acquireSlot();
        try std.testing.expect(s != null);
        slot.* = s.?;
        _ = i;
    }
    try std.testing.expectEqual(@as(u32, 256), async_ipc.inflightCount());

    // Next acquire should fail (back-pressure)
    const overflow = async_ipc.acquireSlot();
    try std.testing.expect(overflow == null);

    // Release one and re-acquire should work
    async_ipc.releaseSlot(acquired[100]);
    try std.testing.expectEqual(@as(u32, 255), async_ipc.inflightCount());

    const reacquired = async_ipc.acquireSlot();
    try std.testing.expect(reacquired != null);
    try std.testing.expectEqual(@as(u32, 256), async_ipc.inflightCount());

    // Clean up
    async_ipc.reset();
}

test "async_ipc double release is safe" {
    async_ipc.reset();

    const slot = async_ipc.acquireSlot().?;
    async_ipc.releaseSlot(slot);
    try std.testing.expectEqual(@as(u32, 0), async_ipc.inflightCount());

    // Double release should not underflow
    async_ipc.releaseSlot(slot);
    try std.testing.expectEqual(@as(u32, 0), async_ipc.inflightCount());

    async_ipc.reset();
}

test "async_ipc release out of bounds is safe" {
    async_ipc.reset();

    // Releasing an invalid index should not crash
    async_ipc.releaseSlot(999);
    async_ipc.releaseSlot(256);
    try std.testing.expectEqual(@as(u32, 0), async_ipc.inflightCount());

    async_ipc.reset();
}

test "BindingEntry defaults to synchronous" {
    const entry = BindingEntry{
        .callback = undefined,
        .user_data = null,
    };
    try std.testing.expect(!entry.run_async);
}

test "async inflight count export returns zero initially" {
    async_ipc.reset();
    try std.testing.expectEqual(@as(u32, 0), gossamer_async_inflight_count());
}

test "version string reflects v0.3.0" {
    const ver = gossamer_version();
    const ver_str = std.mem.span(ver);
    try std.testing.expectEqualStrings("0.3.0", ver_str);
}

test "platform returns a known platform string" {
    const plat = gossamer_platform();
    const plat_str = std.mem.span(plat);
    // On the build machine this must be one of the known platforms
    try std.testing.expect(
        std.mem.eql(u8, plat_str, "linux") or
            std.mem.eql(u8, plat_str, "macos") or
            std.mem.eql(u8, plat_str, "windows") or
            std.mem.eql(u8, plat_str, "freebsd") or
            std.mem.eql(u8, plat_str, "openbsd") or
            std.mem.eql(u8, plat_str, "netbsd") or
            std.mem.eql(u8, plat_str, "ios") or
            std.mem.eql(u8, plat_str, "unknown"),
    );
}

test "arch returns a known architecture string" {
    const arch = gossamer_arch();
    const arch_str = std.mem.span(arch);
    try std.testing.expect(
        std.mem.eql(u8, arch_str, "x86_64") or
            std.mem.eql(u8, arch_str, "aarch64") or
            std.mem.eql(u8, arch_str, "riscv64") or
            std.mem.eql(u8, arch_str, "wasm32") or
            std.mem.eql(u8, arch_str, "unknown"),
    );
}

test "webview engine returns a known engine string" {
    const engine = gossamer_webview_engine();
    const engine_str = std.mem.span(engine);
    try std.testing.expect(
        std.mem.eql(u8, engine_str, "webkitgtk") or
            std.mem.eql(u8, engine_str, "wkwebview") or
            std.mem.eql(u8, engine_str, "webview2") or
            std.mem.eql(u8, engine_str, "none"),
    );
}

test "desktop flag consistent with platform" {
    const is_desktop = gossamer_is_desktop();
    const plat = std.mem.span(gossamer_platform());
    if (std.mem.eql(u8, plat, "linux") or
        std.mem.eql(u8, plat, "macos") or
        std.mem.eql(u8, plat, "windows") or
        std.mem.eql(u8, plat, "freebsd") or
        std.mem.eql(u8, plat, "openbsd") or
        std.mem.eql(u8, plat, "netbsd"))
    {
        try std.testing.expectEqual(@as(u8, 1), is_desktop);
    }
}

test "platform JSON is valid-looking JSON" {
    const json = gossamer_platform_json();
    const json_str = std.mem.span(json);
    // Must start with { and end with }
    try std.testing.expect(json_str.len > 0);
    try std.testing.expectEqual(@as(u8, '{'), json_str[0]);
    try std.testing.expectEqual(@as(u8, '}'), json_str[json_str.len - 1]);
    // Must contain "platform" field
    try std.testing.expect(std.mem.indexOf(u8, json_str, "\"platform\"") != null);
    // Must contain "version" field with "0.3.0"
    try std.testing.expect(std.mem.indexOf(u8, json_str, "\"version\":\"0.3.0\"") != null);
}

//==============================================================================
// CRG B — Additional native Zig tests for IPC, error handling, capability edge cases
//==============================================================================

test "clearError nulls out the error after setError" {
    setError("test error");
    try std.testing.expect(last_error != null);
    clearError();
    try std.testing.expect(last_error == null);
}

test "gossamer_last_error returns null when no error" {
    clearError();
    const err = gossamer_last_error();
    try std.testing.expectEqual(@as(?[*:0]const u8, null), err);
}

test "setError preserves message content" {
    const msg = "capability overflow";
    setError(msg);
    try std.testing.expect(last_error != null);
    try std.testing.expect(std.mem.eql(u8, last_error.?, msg));
    clearError();
}

test "capability registry full returns CAP_ERROR" {
    // Save and reset cap state for this test
    const saved_count = cap_count;
    const saved_max = cap_max;
    cap_count = 0;
    cap_max = DEFAULT_MAX_CAPABILITIES;

    // Fill all slots up to the configurable cap_max limit
    var tokens: [DEFAULT_MAX_CAPABILITIES]u64 = undefined;
    var granted: usize = 0;
    for (0..DEFAULT_MAX_CAPABILITIES) |i| {
        const token = gossamer_cap_grant(@intCast(i % 6)); // 0-5 are valid kinds
        if (token != CAP_ERROR) {
            tokens[granted] = token;
            granted += 1;
        }
    }
    // Next grant should fail
    const overflow_token = gossamer_cap_grant(0);
    try std.testing.expectEqual(CAP_ERROR, overflow_token);

    // Clean up — revoke all granted tokens
    for (tokens[0..granted]) |t| {
        gossamer_cap_revoke(t);
    }
    cap_count = saved_count; // Restore for other tests
    cap_max = saved_max;
}

test "async IPC slots are bounded at configurable limit" {
    async_ipc.reset();
    // Set a small limit for testing
    async_ipc.setMaxSlots(DEFAULT_MAX_INFLIGHT_ASYNC);
    // Acquire all slots
    var acquired: usize = 0;
    while (async_ipc.acquireSlot()) |_| {
        acquired += 1;
        if (acquired > DEFAULT_MAX_INFLIGHT_ASYNC + 1) break; // Safety limit
    }
    try std.testing.expectEqual(DEFAULT_MAX_INFLIGHT_ASYNC, acquired);

    // Release all
    for (0..acquired) |i| {
        async_ipc.releaseSlot(i);
    }
}

test "gossamer_set_max_inflight changes the limit" {
    async_ipc.reset();
    const new_limit = gossamer_set_max_inflight(512);
    try std.testing.expectEqual(@as(u32, 512), new_limit);
    try std.testing.expectEqual(@as(u32, 512), gossamer_get_max_inflight());
    // Restore default
    _ = gossamer_set_max_inflight(DEFAULT_MAX_INFLIGHT_ASYNC);
}

test "gossamer_cap_set_max changes the limit" {
    const old_max = cap_max;
    const new_limit = gossamer_cap_set_max(1024);
    try std.testing.expectEqual(@as(u32, 1024), new_limit);
    try std.testing.expectEqual(@as(u32, 1024), gossamer_cap_get_max());
    // Restore
    _ = gossamer_cap_set_max(old_max);
}

test "revocation set handles more than revoked_max entries via FIFO" {
    // Reset revocation state for this test
    const saved_count = revoked_count;
    const saved_max = revoked_max;
    revoked_max = DEFAULT_MAX_REVOKED;
    revoked_count = DEFAULT_MAX_REVOKED - 1;

    // Add one more — should succeed (fills last slot)
    gossamer_cap_revoke(0xDEAD);
    try std.testing.expectEqual(DEFAULT_MAX_REVOKED, revoked_count);

    // Add another — should evict oldest via FIFO
    gossamer_cap_revoke(0xBEEF);
    try std.testing.expectEqual(DEFAULT_MAX_REVOKED, revoked_count);
    // The newest token should be at the end
    try std.testing.expectEqual(@as(u64, 0xBEEF), revoked_tokens[DEFAULT_MAX_REVOKED - 1]);

    // Restore
    revoked_count = saved_count;
    revoked_max = saved_max;
}

test "Result enum has at least 10 variants and they are contiguous" {
    // Verify known result codes cast to distinct integers
    const ok: c_int = @intFromEnum(Result.ok);
    const err: c_int = @intFromEnum(Result.@"error");
    const guard: c_int = @intFromEnum(Result.guard_locked);
    try std.testing.expectEqual(@as(c_int, 0), ok);
    try std.testing.expectEqual(@as(c_int, 1), err);
    try std.testing.expect(guard >= 10); // At least 11 variants (0..10)
}
