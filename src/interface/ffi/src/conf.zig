// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Conf FFI Implementation
//
// Real JSON loader for gossamer.conf.json, replacing the hand-rolled
// string-scan parser in cli/src/main.zig (parseConfig + extractStringField
// + extractIntField + extractBoolField). Three goals:
//
//   1. Parse a single source of truth correctly (the old scanner found
//      the first matching key regardless of nesting — fragile when a
//      key name appears in multiple places).
//   2. Expose dotted-path lookups so callers can target nested keys
//      explicitly (`build.devUrl`, `app.windows.0.width`).
//   3. Give the upcoming Ephapax-wasm CLI a config-reading FFI it can
//      call without re-implementing JSON parsing inside the wasm guest.
//
// Surface (capability-gated on FileSystem, kind=0):
//   • gossamer_conf_load(path, cap)      -> opaque*   (or null on error)
//   • gossamer_conf_get_string(c*, path) -> *char     (null on missing /
//                                                       wrong type)
//   • gossamer_conf_get_int(c*, path, default)  -> i64
//   • gossamer_conf_get_bool(c*, path, default) -> i32  (0/1)
//   • gossamer_conf_has(c*, path)        -> i32       (0/1)
//   • gossamer_conf_free(c*)             -> void
//
// String returns are null-terminated dupes owned by the Conf wrapper.
// They are freed when gossamer_conf_free is called; do not free them
// individually.
//
// Path syntax: dot-separated keys; numeric segments index arrays.
//   "productName"            top-level string
//   "build.devUrl"           nested string
//   "app.windows.0.width"    nested int inside the first array element
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const main = @import("main.zig");

/// Heap-allocated wrapper handed back to C callers as `opaque*`. Owns
/// the parsed JSON tree and any null-terminated string dupes returned
/// from gossamer_conf_get_string.
const Conf = struct {
    parsed: std.json.Parsed(std.json.Value),
    /// Null-terminated dupes returned from get_string. Freed together
    /// in gossamer_conf_free so the C caller never has to free them
    /// individually.
    string_dupes: std.ArrayListUnmanaged([:0]u8) = .empty,
};

/// Walk a dotted path through a json.Value tree. Returns the resolved
/// node, or null if any segment is missing or steps through the wrong
/// kind (e.g. indexing a string, dotting into an array without an
/// integer index).
fn walkPath(root: std.json.Value, path: []const u8) ?std.json.Value {
    var current = root;
    var it = std.mem.splitScalar(u8, path, '.');
    while (it.next()) |seg| {
        if (seg.len == 0) return null;
        switch (current) {
            .object => |obj| {
                current = obj.get(seg) orelse return null;
            },
            .array => |arr| {
                const idx = std.fmt.parseInt(usize, seg, 10) catch return null;
                if (idx >= arr.items.len) return null;
                current = arr.items[idx];
            },
            else => return null,
        }
    }
    return current;
}

/// Load gossamer.conf.json (or any JSON file) and return an opaque
/// handle suitable for the gossamer_conf_get_* family. Caller must
/// pass the handle to gossamer_conf_free when done.
///
/// Validates the capability token is active and of type FileSystem (0).
/// Returns null on failure (check gossamer_last_error).
export fn gossamer_conf_load(
    path: [*:0]const u8,
    cap_token: u64,
) ?*anyopaque {
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied — call gossamer_cap_grant(0) first");
        return null;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return null;
    }

    const allocator = std.heap.c_allocator;
    const path_slice = std.mem.span(path);

    const file = std.fs.cwd().openFile(path_slice, .{}) catch {
        main.setError("Failed to open config file");
        return null;
    };
    defer file.close();

    // 256 KB cap matches the existing CLI limit.
    const bytes = file.readToEndAlloc(allocator, 256 * 1024) catch {
        main.setError("Failed to read config file (or > 256 KB)");
        return null;
    };
    defer allocator.free(bytes);

    const parsed = std.json.parseFromSlice(std.json.Value, allocator, bytes, .{}) catch {
        main.setError("Failed to parse config JSON");
        return null;
    };

    const conf = allocator.create(Conf) catch {
        parsed.deinit();
        main.setError("Failed to allocate conf wrapper");
        return null;
    };
    conf.* = .{ .parsed = parsed };

    main.clearError();
    return @ptrCast(conf);
}

/// Resolve a dotted path. Returns a null-terminated dupe of the string
/// value, or null if the path is missing or the value isn't a string.
/// The returned pointer is owned by the Conf and freed by
/// gossamer_conf_free.
export fn gossamer_conf_get_string(
    opaque_conf: ?*anyopaque,
    path: [*:0]const u8,
) ?[*:0]const u8 {
    const p = opaque_conf orelse return null;
    const conf: *Conf = @alignCast(@ptrCast(p));
    const path_slice = std.mem.span(path);

    const node = walkPath(conf.parsed.value, path_slice) orelse return null;
    const str = switch (node) {
        .string => |s| s,
        else => return null,
    };

    const allocator = std.heap.c_allocator;
    const dupe = allocator.allocSentinel(u8, str.len, 0) catch return null;
    @memcpy(dupe[0..str.len], str);
    conf.string_dupes.append(allocator, dupe) catch {
        allocator.free(dupe);
        return null;
    };
    return dupe.ptr;
}

/// Resolve a dotted path and return its integer value. Accepts JSON
/// integer and (truncated) float values. Returns `default_value` if
/// the path is missing or holds a non-numeric value.
export fn gossamer_conf_get_int(
    opaque_conf: ?*anyopaque,
    path: [*:0]const u8,
    default_value: i64,
) i64 {
    const p = opaque_conf orelse return default_value;
    const conf: *Conf = @alignCast(@ptrCast(p));
    const path_slice = std.mem.span(path);

    const node = walkPath(conf.parsed.value, path_slice) orelse return default_value;
    return switch (node) {
        .integer => |i| i,
        .float => |f| @intFromFloat(f),
        else => default_value,
    };
}

/// Resolve a dotted path and return its boolean value as 0 (false) or
/// 1 (true). Returns `default_value` (also 0/1) if the path is missing
/// or holds a non-boolean value.
export fn gossamer_conf_get_bool(
    opaque_conf: ?*anyopaque,
    path: [*:0]const u8,
    default_value: i32,
) i32 {
    const p = opaque_conf orelse return default_value;
    const conf: *Conf = @alignCast(@ptrCast(p));
    const path_slice = std.mem.span(path);

    const node = walkPath(conf.parsed.value, path_slice) orelse return default_value;
    return switch (node) {
        .bool => |b| if (b) 1 else 0,
        else => default_value,
    };
}

/// Returns 1 if the path resolves to any value (including null/false),
/// 0 if the path is missing or steps through the wrong kind.
export fn gossamer_conf_has(
    opaque_conf: ?*anyopaque,
    path: [*:0]const u8,
) i32 {
    const p = opaque_conf orelse return 0;
    const conf: *Conf = @alignCast(@ptrCast(p));
    const path_slice = std.mem.span(path);
    return if (walkPath(conf.parsed.value, path_slice) != null) 1 else 0;
}

/// Free a conf returned by gossamer_conf_load. Frees the parsed tree
/// and every string previously handed out by gossamer_conf_get_string.
/// Safe to call with null (no-op).
export fn gossamer_conf_free(opaque_conf: ?*anyopaque) void {
    const p = opaque_conf orelse return;
    const conf: *Conf = @alignCast(@ptrCast(p));
    const allocator = std.heap.c_allocator;

    for (conf.string_dupes.items) |dupe| {
        allocator.free(dupe);
    }
    conf.string_dupes.deinit(allocator);
    conf.parsed.deinit();
    allocator.destroy(conf);
}
