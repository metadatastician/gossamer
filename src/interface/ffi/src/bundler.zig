// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Application Bundler
//
// Embeds static assets into the binary and extracts them at runtime.
// This enables single-binary distribution of Gossamer applications.
//
// How it works:
//   1. At build time: Use `embedAsset` in your build.zig to embed files
//   2. At runtime: Call `gossamer_bundler_extract_all()` to extract to temp dir
//   3. Use returned directory path to construct file:// URLs
//
// The embedded assets are stored in the binary's data section and
// extracted to a platform-specific cache directory.
//

const std = @import("std");
const builtin = @import("builtin");
const main = @import("main.zig");

const Result = main.Result;

// ===========================================================================
// Error Handling
// ===========================================================================

fn setError(msg: []const u8) void {
    main.setError(msg);
}

fn clearError() void {
    main.clearError();
}

// ===========================================================================
// Platform-Specific Paths
// ===========================================================================

/// Get the platform-specific cache directory for an app.
/// Linux: $XDG_CACHE_HOME/gossamer-bundler/<app> or /tmp/gossamer-bundler/<app>
/// macOS: ~/Library/Caches/gossamer-bundler/<app>
/// Windows: %LOCALAPPDATA%\gossamer-bundler\<app>
/// Android: Not supported (returns null)
fn getCacheDir(allocator: std.mem.Allocator, app_name: []const u8) ?[]u8 {
    if (builtin.abi == .android) return null;

    switch (builtin.os.tag) {
        .linux, .freebsd, .openbsd, .netbsd => {
            if (std.process.getEnvVarOwned(allocator, "XDG_CACHE_HOME")) |cache| {
                defer allocator.free(cache);
                return std.fmt.allocPrint(allocator, "{s}/gossamer-bundler/{s}", .{ cache, app_name }) catch null;
            } else |_| {
                return std.fmt.allocPrint(allocator, "/tmp/gossamer-bundler/{s}", .{app_name}) catch null;
            }
        },
        .macos => {
            if (std.process.getEnvVarOwned(allocator, "HOME")) |home| {
                defer allocator.free(home);
                return std.fmt.allocPrint(allocator, "{s}/Library/Caches/gossamer-bundler/{s}", .{ home, app_name }) catch null;
            } else |_| {
                return null;
            }
        },
        .windows => {
            if (std.process.getEnvVarOwned(allocator, "LOCALAPPDATA")) |appdata| {
                defer allocator.free(appdata);
                return std.fmt.allocPrint(allocator, "{s}\\gossamer-bundler\\{s}", .{ appdata, app_name }) catch null;
            } else |_| {
                return null;
            }
        },
        else => return null,
    }
}

/// Create directory and all parents.
fn createDir(path: []const u8) bool {
    std.fs.cwd().makePath(path) catch return false;
    return true;
}

// ===========================================================================
// Extraction Directory Management
// ===========================================================================

/// Extraction state (singleton per app).
const ExtractionState = struct {
    dir: ?[]u8 = null,
    app_name: ?[]u8 = null,
    initialized: bool = false,
};

var global_state: ExtractionState = .{};

/// Initialize extraction for an app.
/// Creates the extraction directory.
fn initExtraction(app_name_z: [*:0]const u8) ?[]u8 {
    const app_name = std.mem.span(app_name_z);
    if (global_state.initialized) {
        if (global_state.app_name) |stored| {
            if (std.mem.eql(u8, stored, app_name)) {
                return global_state.dir;
            }
        }
    }

    const allocator = std.heap.c_allocator;
    const dir = getCacheDir(allocator, app_name) orelse return null;

    // Create the directory
    if (!createDir(dir)) {
        allocator.free(dir);
        return null;
    }

    const name_copy = allocator.dupe(u8, app_name) catch {
        allocator.free(dir);
        return null;
    };

    // Store in global state (freeing any previous app's state)
    if (global_state.dir) |d| allocator.free(d);
    if (global_state.app_name) |n| allocator.free(n);
    global_state.dir = dir;
    global_state.app_name = name_copy;
    global_state.initialized = true;

    return dir;
}

/// Build the full path of an asset inside the extraction directory.
/// Caller frees the returned slice with `allocator`.
fn assetFullPath(allocator: std.mem.Allocator, app_name: [*:0]const u8, asset_name: [*:0]const u8) ?[]u8 {
    const dir = initExtraction(app_name) orelse return null;
    return std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir, std.mem.span(asset_name) }) catch null;
}

// ===========================================================================
// Public C ABI
// ===========================================================================

/// Initialize the bundler for an application.
/// Must be called before extracting assets.
/// Returns GOSSAMER_OK on success.
pub export fn gossamer_bundler_init(handle_ptr: u64, app_name: [*:0]const u8) Result {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Bundler init: null handle");
        return .null_pointer;
    }

    if (initExtraction(app_name) == null) {
        setError("Bundler init: failed to initialize extraction directory");
        return .@"error";
    }

    clearError();
    return .ok;
}

/// Get the extraction directory path.
/// Returns a C string that the caller must free with gossamer_free().
/// Caller owns the returned string.
pub export fn gossamer_bundler_get_dir(handle_ptr: u64, app_name: [*:0]const u8) ?[*:0]const u8 {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Bundler get dir: null handle");
        return null;
    }

    const allocator = std.heap.c_allocator;
    const dir = initExtraction(app_name) orelse {
        setError("Bundler get dir: extraction not initialized");
        return null;
    };

    // Convert to C string (caller frees with gossamer_free)
    const c_dir = allocator.dupeZ(u8, dir) catch {
        setError("Bundler get dir: allocation failed");
        return null;
    };

    clearError();
    return c_dir.ptr;
}

/// Get the full path to an asset in the extraction directory.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_bundler_get_path(handle_ptr: u64, app_name: [*:0]const u8, asset_name: [*:0]const u8) ?[*:0]const u8 {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Bundler get path: null handle");
        return null;
    }

    const allocator = std.heap.c_allocator;
    const full = assetFullPath(allocator, app_name, asset_name) orelse {
        setError("Bundler get path: extraction not initialized or allocation failed");
        return null;
    };
    defer allocator.free(full);

    // Convert to C string (caller frees with gossamer_free)
    const c_full = allocator.dupeZ(u8, full) catch {
        setError("Bundler get path: allocation failed");
        return null;
    };

    clearError();
    return c_full.ptr;
}

/// Get a file:// URL for an asset.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_bundler_get_url(handle_ptr: u64, app_name: [*:0]const u8, asset_name: [*:0]const u8) ?[*:0]const u8 {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Bundler get URL: null handle");
        return null;
    }

    const allocator = std.heap.c_allocator;
    const path = assetFullPath(allocator, app_name, asset_name) orelse {
        setError("Bundler get URL: extraction not initialized or allocation failed");
        return null;
    };
    defer allocator.free(path);

    const url = if (builtin.os.tag == .windows)
        convertWindowsPathToFileUrl(allocator, path)
    else
        std.fmt.allocPrint(allocator, "file://{s}", .{path}) catch null;

    const url_body = url orelse {
        setError("Bundler get URL: allocation failed");
        return null;
    };
    defer allocator.free(url_body);

    const c_url = allocator.dupeZ(u8, url_body) catch {
        setError("Bundler get URL: allocation failed");
        return null;
    };

    clearError();
    return c_url.ptr;
}

/// Convert a Windows path to a file:// URL.
fn convertWindowsPathToFileUrl(allocator: std.mem.Allocator, path: []const u8) ?[]u8 {
    // Convert backslashes to forward slashes, drive-letter colon to '|'
    var temp: [1024]u8 = undefined;
    var j: usize = 0;

    for (path) |ch| {
        if (j >= temp.len - 1) break;
        temp[j] = switch (ch) {
            '\\' => '/',
            ':' => '|',
            else => ch,
        };
        j += 1;
    }

    // Add file:/// prefix (three slashes for Windows absolute paths)
    return std.fmt.allocPrint(allocator, "file:///{s}", .{temp[0..j]}) catch null;
}

/// Clean up the extraction directory.
/// Removes all extracted files.
pub export fn gossamer_bundler_cleanup(app_name_z: [*:0]const u8) void {
    const allocator = std.heap.c_allocator;
    const app_name = std.mem.span(app_name_z);
    const dir = getCacheDir(allocator, app_name) orelse return;
    defer allocator.free(dir);

    std.fs.deleteTreeAbsolute(dir) catch {};

    // Reset global state
    if (global_state.app_name) |stored| {
        if (std.mem.eql(u8, stored, app_name)) {
            allocator.free(stored);
            if (global_state.dir) |d| allocator.free(d);
            global_state = .{};
        }
    }
}
