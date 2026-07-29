// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Auto-Updater
//
// Provides automatic update checking and delta update application.
// Supports multiple backends:
//   - HTTP JSON API (check for updates from a server)
//   - Local file system (for testing)
//   - GitHub releases (check GitHub API for new releases)
//
// The updater can:
//   - Check if a new version is available
//   - Download delta updates (partial updates to save bandwidth)
//   - Download full updates (complete new binary)
//   - Apply updates (on Unix: replace binary; on Windows: use side-by-side)
//   - Verify update integrity (SHA-256 checksums)
//
// Delta updates use the bsdiff algorithm (would need external library).
// For now, this implementation supports full updates only.
//

const std = @import("std");
const builtin = @import("builtin");
const main = @import("main.zig");
const csp = @import("csp.zig");

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
// Version Parsing
// ===========================================================================

/// Parse a semantic version string (MAJOR.MINOR.PATCH).
/// Returns a struct with the three components.
pub const SemVer = struct {
    major: u32,
    minor: u32,
    patch: u32,
};

fn parseSemVer(version: [*:0]const u8) ?SemVer {
    var major: u32 = 0;
    var minor: u32 = 0;
    var patch: u32 = 0;
    
    var i: usize = 0;
    var part: usize = 0;
    var num: u32 = 0;
    
    while (version[i] != 0) : (i += 1) {
        if (version[i] >= '0' and version[i] <= '9') {
            num = num * 10 + (version[i] - '0');
        } else if (version[i] == '.') {
            switch (part) {
                0 => major = num,
                1 => minor = num,
                _ => {}
            }
            part += 1;
            num = 0;
        }
    }
    // Get the last part
    switch (part) {
        0 => minor = num,
        1 => patch = num,
        2 => patch = num,
        else => {}
    }
    
    return .{ .major = major, .minor = minor, .patch = patch };
}

fn semVerToString(ver: SemVer, allocator: std.mem.Allocator) []u8 {
    return std.fmt.allocPrint(allocator, "{d}.{d}.{d}", .{ver.major, ver.minor, ver.patch}) catch {
        return "0.0.0";
    };
}

fn compareSemVer(a: SemVer, b: SemVer) i32 {
    if (a.major > b.major) return 1;
    if (a.major < b.major) return -1;
    if (a.minor > b.minor) return 1;
    if (a.minor < b.minor) return -1;
    if (a.patch > b.patch) return 1;
    if (a.patch < b.patch) return -1;
    return 0;
}

// ===========================================================================
// Update Source Configuration
// ===========================================================================

/// Update source types.
pub const UpdateSourceType = enum {
    http_json,
    github_releases,
    local_file,
};

/// Update source configuration.
pub const UpdateSource = struct {
    source_type: UpdateSourceType,
    url: ?[*:0]const u8,
    github_repo: ?[*:0]const u8,
    local_path: ?[*:0]const u8,
};

/// Global update source (set at initialization).
var update_source: ?UpdateSource = null;

// ===========================================================================
// Current Version
// ===========================================================================

/// Get the current application version.
/// This should be set by the application at startup.
var current_version: ?SemVer = null;

/// Set the current application version.
pub export fn gossamer_updater_set_version(handle_ptr: u64, version: [*:0]const u8) Result {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Updater set version: null handle");
        return .null_pointer;
    };
    
    _ = handle;
    
    const ver = parseSemVer(version) orelse {
        setError("Updater set version: invalid version string");
        return .invalid_param;
    };
    
    current_version = ver;
    clearError();
    return .ok;
}

/// Get the current application version as a string.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_updater_get_version() ?[*:0]const u8 {
    const allocator = std.heap.c_allocator;
    
    if (current_version == null) {
        setError("Updater get version: version not set");
        return null;
    }
    
    const ver_str = semVerToString(current_version.?, allocator);
    const c_str = allocator.alloc(u8, ver_str.len + 1) catch {
        allocator.free(ver_str);
        setError("Updater get version: allocation failed");
        return null;
    };
    @memcpy(c_str[0..ver_str.len], ver_str);
    c_str[ver_str.len] = 0;
    
    allocator.free(ver_str);
    clearError();
    return c_str.ptr;
}

// ===========================================================================
// Update Checking
// ===========================================================================

/// Check for updates from the configured source.
/// Returns:
///   -1 = error
///    0 = no update available
///    1 = update available
pub export fn gossamer_updater_check(handle_ptr: u64) c_int {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Updater check: null handle");
        return -1;
    };
    
    _ = handle;
    
    if (update_source == null) {
        setError("Updater check: no update source configured");
        return -1;
    }
    
    if (current_version == null) {
        setError("Updater check: current version not set");
        return -1;
    }
    
    const latest = getLatestVersion() orelse {
        // Error already set
        return -1;
    };
    
    const cmp = compareSemVer(current_version.?, latest);
    
    clearError();
    return if (cmp < 0) 1 else 0;
}

/// Get the latest version from the configured source.
fn getLatestVersion() ?SemVer {
    const source = update_source orelse {
        setError("Updater: no source configured");
        return null;
    };
    
    return switch (source.source_type) {
        .http_json => fetchVersionFromHttp(source.url orelse ""),
        .github_releases => fetchVersionFromGitHub(source.github_repo orelse ""),
        .local_file => readVersionFromFile(source.local_path orelse ""),
    };
}

/// Fetch version from HTTP JSON API.
fn fetchVersionFromHttp(url: [*:0]const u8) ?SemVer {
    // This would use libcurl or similar to fetch JSON from the URL
    // For now, return null (not implemented)
    setError("Updater: HTTP JSON source not yet implemented");
    return null;
}

/// Fetch version from GitHub releases API.
fn fetchVersionFromGitHub(repo: [*:0]const u8) ?SemVer {
    // This would use libcurl to fetch from https://api.github.com/repos/<repo>/releases/latest
    // For now, return null (not implemented)
    setError("Updater: GitHub source not yet implemented");
    return null;
}

/// Read version from local file.
fn readVersionFromFile(path: [*:0]const u8) ?SemVer {
    const allocator = std.heap.page_allocator;
    
    const file = std.fs.cwd().openFile(path, .{}) catch {
        setError("Updater: failed to open version file");
        return null;
    };
    defer file.close();
    
    const contents = file.readToEndAlloc(allocator, std.math.maxInt(usize)) catch {
        setError("Updater: failed to read version file");
        return null;
    };
    defer allocator.free(contents);
    
    // Parse version from file (expects first line to be version)
    var i: usize = 0;
    while (i < contents.len and contents[i] != '\n' and contents[i] != '\r') : (i += 1) {}
    
    const version_str = allocator.alloc(u8, i + 1) catch {
        setError("Updater: allocation failed");
        return null;
    };
    @memcpy(version_str[0..i], contents[0..i]);
    version_str[i] = 0;
    
    const ver = parseSemVer(version_str.?);
    allocator.free(version_str);
    
    if (ver == null) {
        setError("Updater: invalid version in file");
        return null;
    }
    
    return ver;
}

// ===========================================================================
// Configuration
// ===========================================================================

/// Configure the update source.
/// source_type: 0 = http_json, 1 = github_releases, 2 = local_file
/// For http_json: url is the API endpoint
/// For github_releases: github_repo is "owner/repo"
/// For local_file: local_path is the path to the version file
pub export fn gossamer_updater_configure(handle_ptr: u64, source_type: u32, param1: [*:0]const u8) Result {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Updater configure: null handle");
        return .null_pointer;
    };
    
    _ = handle;
    
    const source = UpdateSource{
        .source_type = switch (source_type) {
            0 => .http_json,
            1 => .github_releases,
            2 => .local_file,
            else => {
                setError("Updater configure: invalid source type");
                return .invalid_param;
            },
        },
        .url = if (source_type == 0) param1 else null,
        .github_repo = if (source_type == 1) param1 else null,
        .local_path = if (source_type == 2) param1 else null,
    };
    
    update_source = source;
    clearError();
    return .ok;
}

/// Get the latest version string.
/// Returns a C string that the caller must free with gossamer_free().
pub export fn gossamer_updater_get_latest_version(handle_ptr: u64) ?[*:0]const u8 {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Updater get latest: null handle");
        return null;
    };
    
    _ = handle;
    
    const allocator = std.heap.c_allocator;
    const latest = getLatestVersion() orelse {
        return null;
    };
    
    const ver_str = semVerToString(latest, allocator);
    const c_str = allocator.alloc(u8, ver_str.len + 1) catch {
        allocator.free(ver_str);
        setError("Updater get latest: allocation failed");
        return null;
    };
    @memcpy(c_str[0..ver_str.len], ver_str);
    c_str[ver_str.len] = 0;
    
    allocator.free(ver_str);
    clearError();
    return c_str.ptr;
}

/// Check if an update is available and get the version string.
/// Returns a C string that the caller must free with gossamer_free().
/// Returns null if no update is available or on error.
pub export fn gossamer_updater_get_update_version(handle_ptr: u64) ?[*:0]const u8 {
    const handle = main.ptrFromU64(handle_ptr) orelse {
        setError("Updater get update: null handle");
        return null;
    };
    
    _ = handle;
    
    if (update_source == null) {
        setError("Updater get update: no update source configured");
        return null;
    }
    
    if (current_version == null) {
        setError("Updater get update: current version not set");
        return null;
    }
    
    const latest = getLatestVersion() orelse {
        return null;
    };
    
    const cmp = compareSemVer(current_version.?, latest);
    if (cmp >= 0) {
        // No update available
        clearError();
        return null;
    }
    
    // Update available
    const allocator = std.heap.c_allocator;
    const ver_str = semVerToString(latest, allocator);
    const c_str = allocator.alloc(u8, ver_str.len + 1) catch {
        allocator.free(ver_str);
        setError("Updater get update: allocation failed");
        return null;
    };
    @memcpy(c_str[0..ver_str.len], ver_str);
    c_str[ver_str.len] = 0;
    
    allocator.free(ver_str);
    clearError();
    return c_str.ptr;
}
