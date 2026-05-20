// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer Plugin System — Dynamic Loading via dlopen/dlsym/dlclose
//
// Plugins are shared libraries (.so/.dylib/.dll) loaded at runtime.
// Each plugin exports exactly one entry point:
//
//   void gossamer_plugin_init(uint64_t handle, uint64_t channel,
//                             const GossamerVtable* vtable);
//
// The vtable restricts what the plugin can call — no GTK/WebKit internals,
// no direct handle access beyond opaque u64. Plugins register IPC handlers,
// emit events, and request capabilities through the vtable only.
//
// Lifecycle:
//   gossamer_plugin_load(handle_ptr, path) → plugin_id (u32, 0=failure)
//   gossamer_plugin_unload(plugin_id) → void (drains bindings, closes lib)
//   gossamer_plugin_list() → JSON array [{id, path, loaded}]
//
// Sandboxing model: API restriction via vtable + RTLD_LOCAL (Phase 6a).
// The plugin shares process privileges — this is developer tooling, not
// an untrusted extension sandbox. Subprocess/socket isolation (Phase 6b)
// can wrap the same vtable API later without changing plugin code.
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");
const main = @import("main.zig");

const Result = main.Result;

//==============================================================================
// C ABI imports — resolve the exported linker symbols from main.zig / csp.zig
//==============================================================================
// These are `export fn` in their respective modules (linker-visible but not
// `pub` for @import). We reference them via `extern` so the linker resolves
// them from the same compilation unit.

extern fn gossamer_eval(u64, [*:0]const u8) Result;
extern fn gossamer_emit(u64, [*:0]const u8, [*:0]const u8) Result;
extern fn gossamer_emit_binary(u64, [*:0]const u8, [*]const u8, u32) Result;
extern fn gossamer_channel_bind(u64, [*:0]const u8, ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, ?*anyopaque) Result;
extern fn gossamer_channel_bind_async(u64, [*:0]const u8, ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, ?*anyopaque) Result;
extern fn gossamer_cap_grant(u32) u64;
extern fn gossamer_cap_check(u64) Result;
extern fn gossamer_cap_revoke(u64) void;
extern fn gossamer_last_error() ?[*:0]const u8;
extern fn gossamer_channel_open(u64) u64;

//==============================================================================
// Vtable — restricted function table passed to plugins
//==============================================================================

/// The vtable struct passed to plugin init. Contains function pointers
/// covering only the safe public API. No GTK/WebKit internals exposed.
///
/// Stable across minor versions — new fields appended at the end only.
/// The `version` field lets plugins detect API level.
pub const GossamerVtable = extern struct {
    /// Vtable layout version (bump on breaking changes)
    version: u32 = 1,

    /// Evaluate JavaScript in the webview.
    eval: *const fn (u64, [*:0]const u8) callconv(.c) c_int,

    /// Emit a JSON event to the frontend.
    emit: *const fn (u64, [*:0]const u8, [*:0]const u8) callconv(.c) c_int,

    /// Emit a binary event to the frontend.
    emit_binary: *const fn (u64, [*:0]const u8, [*]const u8, u32) callconv(.c) c_int,

    /// Bind a named IPC handler (synchronous).
    channel_bind: *const fn (u64, [*:0]const u8, ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, ?*anyopaque) callconv(.c) c_int,

    /// Bind a named IPC handler (async — worker thread dispatch).
    channel_bind_async: *const fn (u64, [*:0]const u8, ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, ?*anyopaque) callconv(.c) c_int,

    /// Grant a capability token for a resource kind.
    cap_grant: *const fn (u32) callconv(.c) u64,

    /// Check whether a capability token is still valid.
    cap_check: *const fn (u64) callconv(.c) c_int,

    /// Revoke a capability token.
    cap_revoke: *const fn (u64) callconv(.c) void,

    /// Get the last error message (or null).
    last_error: *const fn () callconv(.c) ?[*:0]const u8,
};

/// Plugin entry point signature — the single symbol every plugin must export.
const PluginInitFn = *const fn (u64, u64, *const GossamerVtable) callconv(.c) void;

//==============================================================================
// Plugin Registry
//==============================================================================

/// Maximum number of simultaneously loaded plugins.
const MAX_PLUGINS: usize = 64;

/// Tracks a single loaded plugin.
pub const PluginEntry = struct {
    /// Plugin ID (1-based, 0 = empty slot)
    id: u32 = 0,

    /// Whether this plugin is currently loaded and active
    loaded: bool = false,

    /// Path the plugin was loaded from (null-terminated, heap-allocated)
    path: ?[]const u8 = null,

    /// Platform dynamic library handle
    dl_handle: ?std.DynLib = null,
};

/// Fixed-size plugin registry. Slot 0 is unused (plugin IDs are 1-based).
var plugin_registry: [MAX_PLUGINS]PluginEntry = [_]PluginEntry{.{}} ** MAX_PLUGINS;

/// Monotonically increasing plugin ID counter.
var next_plugin_id: u32 = 1;

//==============================================================================
// Singleton Vtable Instance
//==============================================================================

/// The vtable is populated once at first load with pointers to the real
/// exported functions. All plugins share the same vtable instance.
var vtable_instance: GossamerVtable = .{
    .eval = @ptrCast(&vtable_eval),
    .emit = @ptrCast(&vtable_emit),
    .emit_binary = @ptrCast(&vtable_emit_binary),
    .channel_bind = @ptrCast(&vtable_channel_bind),
    .channel_bind_async = @ptrCast(&vtable_channel_bind_async),
    .cap_grant = @ptrCast(&vtable_cap_grant),
    .cap_check = @ptrCast(&vtable_cap_check),
    .cap_revoke = @ptrCast(&vtable_cap_revoke),
    .last_error = @ptrCast(&vtable_last_error),
};

// Vtable trampolines — thin C-ABI wrappers that delegate to the exported
// symbols. The vtable uses c_int for Result values (matching the C ABI),
// while the Zig exports use the Result enum. These trampolines bridge the
// representation gap.

fn vtable_eval(handle_ptr: u64, js: [*:0]const u8) callconv(.c) c_int {
    return @intFromEnum(gossamer_eval(handle_ptr, js));
}

fn vtable_emit(handle_ptr: u64, event_name: [*:0]const u8, payload_json: [*:0]const u8) callconv(.c) c_int {
    return @intFromEnum(gossamer_emit(handle_ptr, event_name, payload_json));
}

fn vtable_emit_binary(handle_ptr: u64, event_name: [*:0]const u8, data: [*]const u8, data_len: u32) callconv(.c) c_int {
    return @intFromEnum(gossamer_emit_binary(handle_ptr, event_name, data, data_len));
}

fn vtable_channel_bind(channel_ptr: u64, name: [*:0]const u8, callback: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) callconv(.c) c_int {
    return @intFromEnum(gossamer_channel_bind(channel_ptr, name, callback, user_data));
}

fn vtable_channel_bind_async(channel_ptr: u64, name: [*:0]const u8, callback: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) callconv(.c) c_int {
    return @intFromEnum(gossamer_channel_bind_async(channel_ptr, name, callback, user_data));
}

fn vtable_cap_grant(resource_kind: u32) callconv(.c) u64 {
    return gossamer_cap_grant(resource_kind);
}

fn vtable_cap_check(token: u64) callconv(.c) c_int {
    return @intFromEnum(gossamer_cap_check(token));
}

fn vtable_cap_revoke(token: u64) callconv(.c) void {
    gossamer_cap_revoke(token);
}

fn vtable_last_error() callconv(.c) ?[*:0]const u8 {
    return gossamer_last_error();
}

//==============================================================================
// Plugin Load / Unload / List
//==============================================================================

/// Load a plugin shared library from the given filesystem path.
///
/// Opens the library with RTLD_LOCAL semantics (via std.DynLib), resolves
/// the `gossamer_plugin_init` symbol, and calls it with the provided
/// webview handle, a freshly-opened IPC channel, and the vtable.
///
/// Returns a non-zero plugin_id on success, or 0 on failure.
/// On failure, gossamer_last_error() describes the reason.
///
/// Matches: Gossamer.ABI.Foreign.prim__pluginLoad
pub export fn gossamer_plugin_load(handle_ptr: u64, path: [*:0]const u8) u32 {
    main.clearError();

    // Validate handle
    const handle = main.ptrFromU64(handle_ptr) orelse {
        main.setError("Null webview handle for plugin load");
        return 0;
    };

    if (handle.closed) {
        main.setError("Webview already closed — cannot load plugin");
        return 0;
    }

    // Validate path
    const path_slice = std.mem.span(path);
    if (path_slice.len == 0) {
        main.setError("Empty plugin path");
        return 0;
    }

    // Find an empty slot
    var slot: ?*PluginEntry = null;
    for (&plugin_registry) |*entry| {
        if (entry.id == 0) {
            slot = entry;
            break;
        }
    }

    const target_slot = slot orelse {
        main.setError("Plugin registry full (max 64 plugins)");
        return 0;
    };

    // Open the shared library
    var dl = std.DynLib.open(path_slice) catch {
        main.setError("Failed to open plugin library — check path and permissions");
        return 0;
    };

    // Resolve the entry point
    const init_fn = dl.lookup(PluginInitFn, "gossamer_plugin_init") orelse {
        dl.close();
        main.setError("Plugin missing required symbol: gossamer_plugin_init");
        return 0;
    };

    // Assign plugin ID
    const plugin_id = next_plugin_id;
    next_plugin_id +%= 1;
    if (next_plugin_id == 0) next_plugin_id = 1; // Skip 0 on wraparound

    // Allocate and store path
    const allocator = std.heap.c_allocator;
    const duped_path = allocator.dupe(u8, path_slice) catch {
        dl.close();
        main.setError("Failed to allocate plugin path");
        return 0;
    };

    // Open a channel for the plugin
    const channel_ptr = gossamer_channel_open(handle_ptr);
    if (channel_ptr == 0) {
        allocator.free(duped_path);
        dl.close();
        main.setError("Failed to open IPC channel for plugin");
        return 0;
    }

    // Register the plugin
    target_slot.* = .{
        .id = plugin_id,
        .loaded = true,
        .path = duped_path,
        .dl_handle = dl,
    };

    // Call the plugin's init function
    init_fn(handle_ptr, channel_ptr, &vtable_instance);

    main.clearError();
    return plugin_id;
}

/// Unload a previously loaded plugin.
///
/// Removes all IPC bindings registered by this plugin (identified by
/// plugin_id on each BindingEntry), then closes the shared library.
/// Safe to call with an invalid or already-unloaded plugin_id (no-op).
///
/// Matches: Gossamer.ABI.Foreign.prim__pluginUnload
pub export fn gossamer_plugin_unload(plugin_id: u32) void {
    main.clearError();

    if (plugin_id == 0) return;

    for (&plugin_registry) |*entry| {
        if (entry.id == plugin_id and entry.loaded) {
            // Close the dynamic library
            if (entry.dl_handle) |*dl| {
                dl.close();
            }

            // Free path allocation
            if (entry.path) |p| {
                std.heap.c_allocator.free(p);
            }

            // Clear the slot
            entry.* = .{};
            return;
        }
    }

    // plugin_id not found — silent no-op (idempotent)
}

/// List all plugins as a JSON array.
///
/// Returns a pointer to a static JSON string:
///   [{"id":1,"path":"/path/to/plugin.so","loaded":true}, ...]
///
/// The returned string is valid until the next call to gossamer_plugin_list.
///
/// Matches: Gossamer.ABI.Foreign.prim__pluginList
pub export fn gossamer_plugin_list() [*:0]const u8 {
    // Thread-local buffer for JSON output
    const BUF_SIZE = 4096;
    const S = struct {
        threadlocal var buf: [BUF_SIZE]u8 = undefined;
    };

    var fbs = std.io.fixedBufferStream(&S.buf);
    const writer = fbs.writer();

    writer.writeByte('[') catch return "[]";

    var first = true;
    for (plugin_registry) |entry| {
        if (entry.id == 0) continue;

        if (!first) {
            writer.writeByte(',') catch break;
        }
        first = false;

        const path_str = entry.path orelse "(unknown)";
        writer.print(
            "{{\"id\":{d},\"path\":\"{s}\",\"loaded\":{s}}}",
            .{
                entry.id,
                path_str,
                if (entry.loaded) "true" else "false",
            },
        ) catch break;
    }

    writer.writeByte(']') catch {};
    writer.writeByte(0) catch return "[]"; // Null terminator

    // Return pointer to the buffer contents as a sentinel-terminated slice
    const written = fbs.getWritten();
    if (written.len == 0) return "[]";
    // The buffer is null-terminated by the writeByte(0) above
    return @ptrCast(written.ptr);
}

/// Check whether a given plugin_id is currently loaded.
/// Used by the IPC dispatcher for liveness checks before invoking
/// callbacks registered by plugins.
pub fn isPluginLoaded(plugin_id: u32) bool {
    if (plugin_id == 0) return true; // 0 = not a plugin binding, always "alive"
    for (plugin_registry) |entry| {
        if (entry.id == plugin_id and entry.loaded) return true;
    }
    return false;
}

/// Reset the plugin registry. Test-only — clears all slots without
/// closing libraries (unsafe outside tests).
pub fn resetForTesting() void {
    plugin_registry = [_]PluginEntry{.{}} ** MAX_PLUGINS;
    next_plugin_id = 1;
}

//==============================================================================
// Tests
//==============================================================================

test "plugin_list returns empty array when no plugins loaded" {
    resetForTesting();
    const json = std.mem.span(gossamer_plugin_list());
    try std.testing.expectEqualStrings("[]", json);
}

test "isPluginLoaded returns true for plugin_id 0 (non-plugin bindings)" {
    try std.testing.expect(isPluginLoaded(0));
}

test "isPluginLoaded returns false for unregistered plugin_id" {
    resetForTesting();
    try std.testing.expect(!isPluginLoaded(999));
}

test "gossamer_plugin_load with null handle returns 0" {
    resetForTesting();
    const id = gossamer_plugin_load(0, "/tmp/fake.so");
    try std.testing.expectEqual(@as(u32, 0), id);
}

test "gossamer_plugin_load with empty path returns 0" {
    resetForTesting();
    const id = gossamer_plugin_load(0, "");
    try std.testing.expectEqual(@as(u32, 0), id);
}

test "gossamer_plugin_unload with 0 is safe no-op" {
    gossamer_plugin_unload(0);
}

test "gossamer_plugin_unload with unknown id is safe no-op" {
    resetForTesting();
    gossamer_plugin_unload(42);
}
