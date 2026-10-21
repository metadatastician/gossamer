// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Filesystem FFI Implementation
//
// Provides file I/O operations gated by capability tokens. Each operation
// validates the caller holds a FileSystem capability before performing I/O.
//
// These functions are called from the IPC bridge when the JS frontend
// invokes __gossamer_fs_* commands, or directly from Ephapax via __ffi().
//

const std = @import("std");
const main = @import("main.zig");
const fs = @import("unified_api_adapter.zig").fs;

/// Accept absolute paths with no `..` component when split on `/` or `\`.
/// Names containing `..` within a larger component are allowed.
fn isValidFsPath(path_slice: []const u8) bool {
    if (!fs.path.isAbsolute(path_slice)) return false;
    var it = std.mem.tokenizeAny(u8, path_slice, "/\\");
    while (it.next()) |part| {
        if (std.mem.eql(u8, part, "..")) return false;
    }
    return true;
}

/// Read at most 64 MiB from a text file and return its contents as a C string.
/// The caller is responsible for freeing the returned string via std.heap.c_allocator.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
///
/// The path must be absolute and have no `..` component when split on `/` or `\`.
/// Returns null for capability, path, I/O, size-limit, or allocation errors
/// (check gossamer_last_error).
pub export fn gossamer_fs_read_text(
    path: [*:0]const u8,
    cap_token: u64,
) ?[*:0]u8 {
    // Validate capability
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
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return null;
    }

    const file = fs.openFileAbsolute(path_slice, .{}) catch {
        main.setError("Failed to open file for reading");
        return null;
    };
    defer file.close();

    // Read up to 64 MB (safety limit for text files)
    const contents = file.readToEndAlloc(allocator, 64 * 1024 * 1024) catch {
        main.setError("Failed to read file contents");
        return null;
    };

    // Append null terminator
    const result = allocator.allocSentinel(u8, contents.len, 0) catch {
        allocator.free(contents);
        main.setError("Failed to allocate result string");
        return null;
    };
    @memcpy(result[0..contents.len], contents);
    allocator.free(contents);

    main.clearError();
    return result.ptr;
}

/// Write text to a file. Creates the file if it doesn't exist, truncates if it does.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
///
/// The path must be absolute and have no `..` component when split on `/` or `\`.
/// Returns ok, capability_denied for an inactive or wrong-kind token,
/// invalid_param for a rejected path, or error for create/write failures.
/// Failures set gossamer_last_error; a write failure may leave a partial file.
pub export fn gossamer_fs_write_text(
    path: [*:0]const u8,
    contents: [*:0]const u8,
    cap_token: u64,
) main.Result {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied — call gossamer_cap_grant(0) first");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return .capability_denied;
    }

    const path_slice = std.mem.span(path);
    const contents_slice = std.mem.span(contents);
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return .invalid_param;
    }

    const file = fs.createFileAbsolute(path_slice, .{ .truncate = true }) catch {
        main.setError("Failed to create/open file for writing");
        return .@"error";
    };
    defer file.close();

    file.writeAll(contents_slice) catch {
        main.setError("Failed to write file contents");
        return .@"error";
    };

    main.clearError();
    return .ok;
}

/// Check if a file or directory exists.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
///
/// The path must be absolute and have no `..` component when split on `/` or `\`.
/// Returns 1 when accessible, 0 on any filesystem access failure (including
/// absence or permission denial), or 0xFFFFFFFF for a rejected token or path.
/// Only token and path failures set gossamer_last_error.
pub export fn gossamer_fs_exists(
    path: [*:0]const u8,
    cap_token: u64,
) u32 {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied");
        return 0xFFFFFFFF;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return 0xFFFFFFFF;
    }

    const path_slice = std.mem.span(path);
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return 0xFFFFFFFF;
    }

    // Use accessAbsolute to check existence without opening
    fs.accessAbsolute(path_slice, .{}) catch {
        return 0; // Does not exist (or no access)
    };

    return 1; // Exists
}

/// List directory contents as a JSON array of filenames.
/// Returns a null-terminated C string (caller frees with std.heap.c_allocator),
/// or null for token, path, directory-open, or allocation failures.
/// The path must be absolute and have no `..` component when split on `/` or `\`. An iteration
/// error ends the listing and returns the filenames collected so far.
/// Allocation failures return null without setting a new last error.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
pub export fn gossamer_fs_list_dir(
    path: [*:0]const u8,
    cap_token: u64,
) ?[*:0]u8 {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied");
        return null;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return null;
    }

    const allocator = std.heap.c_allocator;
    const path_slice = std.mem.span(path);
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return null;
    }

    var dir = fs.openDirAbsolute(path_slice, .{ .iterate = true }) catch {
        main.setError("Failed to open directory");
        return null;
    };
    defer dir.close();

    // Build JSON array of filenames
    var json = std.ArrayListUnmanaged(u8){};
    defer json.deinit(allocator);
    json.appendSlice(allocator, "[") catch return null;

    var first = true;
    var iter = dir.iterate();
    while (iter.next() catch null) |entry| {
        if (!first) json.appendSlice(allocator, ",") catch return null;
        first = false;
        json.appendSlice(allocator, "\"") catch return null;
        // Escape special characters in filenames
        for (entry.name) |ch| {
            switch (ch) {
                '"' => json.appendSlice(allocator, "\\\"") catch return null,
                '\\' => json.appendSlice(allocator, "\\\\") catch return null,
                else => json.append(allocator, ch) catch return null,
            }
        }
        json.appendSlice(allocator, "\"") catch return null;
    }
    json.appendSlice(allocator, "]") catch return null;

    const result = allocator.allocSentinel(u8, json.items.len, 0) catch return null;
    @memcpy(result[0..json.items.len], json.items);

    main.clearError();
    return result.ptr;
}

/// Remove a file. Directories are not removed.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
/// Paths must be absolute and have no `..` component when split on `/` or `\`.
/// Returns ok, capability_denied for an inactive or wrong-kind token,
/// invalid_param for a rejected path, or error for filesystem failures.
/// Failures set gossamer_last_error.
pub export fn gossamer_fs_remove(
    path: [*:0]const u8,
    cap_token: u64,
) main.Result {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return .capability_denied;
    }

    const path_slice = std.mem.span(path);
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return .invalid_param;
    }

    fs.deleteFileAbsolute(path_slice) catch {
        main.setError("Failed to delete file");
        return .@"error";
    };

    main.clearError();
    return .ok;
}

/// Create a directory recursively (equivalent of `mkdir -p`).
/// Succeeds when the directory already exists.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
/// Paths must be absolute and have no `..` component when split on `/` or `\`.
/// Returns ok, capability_denied for an inactive or wrong-kind token,
/// invalid_param for a rejected path, or error for filesystem failures.
/// Failures set gossamer_last_error.
pub export fn gossamer_fs_mkdir_p(
    path: [*:0]const u8,
    cap_token: u64,
) main.Result {
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return .capability_denied;
    }

    const path_slice = std.mem.span(path);
    if (!isValidFsPath(path_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return .invalid_param;
    }

    fs.cwd().makePath(path_slice) catch |e| {
        switch (e) {
            error.PathAlreadyExists => {
                main.clearError();
                return .ok;
            },
            else => {
                main.setError("Failed to create directory");
                return .@"error";
            },
        }
    };

    main.clearError();
    return .ok;
}

/// Copy a file from `src` to `dst`. Overwrites the destination if it
/// exists. Parent directory of `dst` must already exist — call
/// gossamer_fs_mkdir_p first if needed.
///
/// Validates the capability token is active and of type FileSystem (kind=0).
/// Paths must be absolute and have no `..` component when split on `/` or `\`.
/// Returns ok, capability_denied for an inactive or wrong-kind token,
/// invalid_param for a rejected path, or error for filesystem failures.
/// Failures set gossamer_last_error.
pub export fn gossamer_fs_copy_file(
    src: [*:0]const u8,
    dst: [*:0]const u8,
    cap_token: u64,
) main.Result {
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("FileSystem capability denied");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 0) {
        main.setError("Wrong capability kind — expected FileSystem (0)");
        return .capability_denied;
    }

    const src_slice = std.mem.span(src);
    const dst_slice = std.mem.span(dst);
    if (!isValidFsPath(src_slice) or !isValidFsPath(dst_slice)) {
        main.setError("Invalid filesystem path — must be absolute and traversal-free");
        return .invalid_param;
    }

    fs.cwd().copyFile(src_slice, fs.cwd(), dst_slice, .{}) catch {
        main.setError("Failed to copy file");
        return .@"error";
    };

    main.clearError();
    return .ok;
}
