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
fn getCacheDir(app_name: [*:0]const u8) ?[]const u8 {
    const allocator = std.heap.page_allocator;
    
    if (builtin.abi == .android) return null;
    
    return switch (builtin.os.tag) {
        .linux, .freebsd, .openbsd, .netbsd => {
            const xdg = std.process.getEnvVar(allocator, "XDG_CACHE_HOME");
            if (xdg) |cache| {
                const path = std.fmt.allocPrint(allocator, "{s}/gossamer-bundler/{s}", .{cache, app_name}) catch {
                    allocator.free(cache);
                    return null;
                };
                return path;
            }
            std.fmt.allocPrint(allocator, "/tmp/gossamer-bundler/{s}", .{app_name}) catch null
        },
        .macos => {
            const home = std.process.getEnvVar(allocator, "HOME");
            if (home) |h| {
                const path = std.fmt.allocPrint(allocator, "{s}/Library/Caches/gossamer-bundler/{s}", .{h, app_name}) catch {
                    allocator.free(h);
                    return null;
                };
                return path;
            }
            null
        },
        .windows => {
            const local_appdata = std.process.getEnvVar(allocator, "LOCALAPPDATA");
            if (local_appdata) |appdata| {
                const path = std.fmt.allocPrint(allocator, "{s}\\gossamer-bundler\\{s}", .{appdata, app_name}) catch {
                    allocator.free(appdata);
                    return null;
                };
                return path;
            }
            null
        },
        else => null,
    };
}

/// Create directory and all parents.
fn createDir(path: []const u8) bool {
    const dir = std.mem.as([*]u8, @ptrCast([*]const u8, path));
    return std.fs.createDirsAbsolute(dir) catch false;
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
fn initExtraction(app_name: [*:0]const u8) ?[]u8 {
    if (global_state.initialized and std.mem.eql(u8, global_state.app_name orelse "", app_name)) {
        return global_state.dir;
    }
    
    const allocator = std.heap.page_allocator;
    const dir = getCacheDir(app_name) orelse return null;
    
    // Create the directory
    if (!createDir(dir)) {
        allocator.free(dir);
        return null;
    }
    
    // Store in global state
    global_state.dir = dir;
    global_state.app_name = std.mem.dupe(allocator, u8, app_name);
    global_state.initialized = true;
    
    return dir;
}

// ===========================================================================
// Public C ABI
// ===========================================================================

/// Initialize the bundler for an application.
/// Must be called before extracting assets.
/// Returns GOSSAMER_OK on success.
pub export fn gossamer_bundler_init(handle_ptr: u64, app_name: [*:0]const u8) Result {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Bundler init: null handle");
        return .null_pointer;
    };
    
    _ = handle;
    
    const dir = initExtraction(app_name);
    if (dir == null) {
        setError("Bundler init: failed to initialize extraction directory");
        return .error;
    }
    
    clearError();
    return .ok;
}

/// Get the extraction directory path.
/// Returns a C string that the caller must free with gossamer_free().
/// Caller owns the returned string.
pub export fn gossamer_bundler_get_dir(handle_ptr: u64, app_name: [*:0]const u8) ?[*:0]const u8 {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Bundler get dir: null handle");
        return null;
    };
    
    _ = handle;
    
    const allocator = std.heap.c_allocator;
    const dir = initExtraction(app_name) orelse {
        setError("Bundler get dir: extraction not initialized");
        return null;
    };
    
    // Convert to C string (caller frees)
    const c_dir = allocator.alloc(u8, dir.len + 1) catch {
        setError("Bundler get dir: allocation failed");
        return null;
    };
    @memcpy(c_dir[0..dir.len], dir);
    c_dir[dir.len] = 0;
    
    clearError();
    return c_dir.ptr;
}

/// Get the full path to an asset in the extraction directory.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_bundler_get_path(handle_ptr: u64, app_name: [*:0]const u8, asset_name: [*:0]const u8) ?[*:0]const u8 {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Bundler get path: null handle");
        return null;
    };
    
    _ = handle;
    
    const allocator = std.heap.c_allocator;
    const dir = initExtraction(app_name) orelse {
        setError("Bundler get path: extraction not initialized");
        return null;
    };
    
    // Build full path
    const full = std.fmt.allocPrint(allocator, "{s}/{s}", .{dir, asset_name}) catch {
        setError("Bundler get path: allocation failed");
        return null;
    };
    
    // Convert to C string (caller frees)
    const c_full = allocator.alloc(u8, full.len + 1) catch {
        allocator.free(full);
        setError("Bundler get path: allocation failed");
        return null;
    };
    @memcpy(c_full[0..full.len], full);
    c_full[full.len] = 0;
    
    allocator.free(full);
    clearError();
    return c_full.ptr;
}

/// Get a file:// URL for an asset.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_bundler_get_url(handle_ptr: u64, app_name: [*:0]const u8, asset_name: [*:0]const u8) ?[*:0]const u8 {
    const path = gossamer_bundler_get_path(handle_ptr, app_name, asset_name) orelse {
        return null;
    };
    
    const allocator = std.heap.c_allocator;
    
    const url = if (builtin.abi == .windows)
        convertWindowsPathToFileUrl(path)
    else
        std.fmt.allocPrint(allocator, "file://{s}", .{path}) catch null;
    
    if (url) |u| {
        const c_url = allocator.alloc(u8, u.len + 1) catch {
            allocator.free(u);
            std.heap.c_allocator.free(path);
            setError("Bundler get URL: allocation failed");
            return null;
        };
        @memcpy(c_url[0..u.len], u);
        c_url[u.len] = 0;
        
        allocator.free(u);
        std.heap.c_allocator.free(path);
        
        clearError();
        return c_url.ptr;
    }
    
    std.heap.c_allocator.free(path);
    setError("Bundler get URL: allocation failed");
    return null;
}

/// Convert a Windows path to a file:// URL.
fn convertWindowsPathToFileUrl(path: [*:0]const u8) ?[]u8 {
    const allocator = std.heap.page_allocator;
    
    // Convert backslashes to forward slashes
    var temp: [1024]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;
    
    while (path[i] != 0 and j < temp.len - 1) : (i += 1) {
        if (path[i] == '\\') {
            temp[j] = '/';
        } else if (path[i] == ':') {
            // Drive letter: C: -> C|
            temp[j] = '|';
        } else {
            temp[j] = path[i];
        }
        j += 1;
    }
    temp[j] = 0;
    
    // Add file:/// prefix (three slashes for Windows absolute paths)
    return std.fmt.allocPrint(allocator, "file:///{s}", .{temp[0..j]}) catch null;
}

/// Clean up the extraction directory.
/// Removes all extracted files.
pub export fn gossamer_bundler_cleanup(app_name: [*:0]const u8) void {
    const allocator = std.heap.page_allocator;
    const dir = getCacheDir(app_name) orelse return;
    
    const dir_mut = std.mem.as([*]u8, @ptrCast([*]const u8, dir));
    _ = std.fs.rmTreeAbsolute(dir_mut) catch {};
    
    allocator.free(dir);
    
    // Reset global state
    if (std.mem.eql(u8, global_state.app_name orelse "", app_name)) {
        allocator.free(global_state.app_name orelse "");
        allocator.free(global_state.dir orelse "");
        global_state = .{};
    }
}
