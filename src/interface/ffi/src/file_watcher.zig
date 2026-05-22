// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer libgossamer — File Watcher for Hot Reload
//
// Polling-based file watcher that monitors directories for changes to
// frontend assets (.html, .js, .css, .res.js). When a change is detected,
// it schedules a webview reload on the GTK main thread via g_idle_add().
//
// Lives in the FFI layer (rather than in cli/) so any libgossamer
// consumer — the legacy native Zig CLI, the future Ephapax-wasm CLI
// behind a host launcher, third-party embedders — can use the same
// hot-reload path. Exposed to C as gossamer_watcher_start /
// gossamer_watcher_stop (see C-ABI exports at the end of this file).
//
// Design:
//   - Runs on a dedicated std.Thread, separate from the GTK event loop.
//   - Polls watched directories every `poll_interval_ms` milliseconds.
//   - Tracks per-file mtime to detect changes with file-level granularity.
//   - Debounces rapid successive changes (e.g. build tools writing multiple
//     files) by requiring `debounce_ms` of quiet time before triggering.
//   - Marshals the reload call to the GTK main thread via g_idle_add(),
//     which is the only thread-safe way to interact with WebKitGTK.
//
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

/// GLib C bindings for g_idle_add — thread-safe GTK main loop scheduling.
/// The CLI already links glib-2.0 (see build.zig), so these symbols resolve.
const glib = @cImport({
    @cInclude("glib.h");
});

//==============================================================================
// Configuration
//==============================================================================

/// Maximum number of watch paths supported.
const MAX_WATCH_PATHS = 16;

/// Maximum number of watched file extensions.
const MAX_EXTENSIONS = 16;

/// Maximum number of tracked files across all watched directories.
const MAX_TRACKED_FILES = 4096;

/// Default poll interval in milliseconds.
const DEFAULT_POLL_MS = 500;

/// Default debounce interval in milliseconds.
const DEFAULT_DEBOUNCE_MS = 300;

/// Default file extensions to watch for changes.
const DEFAULT_EXTENSIONS = [_][]const u8{
    ".html",
    ".js",
    ".css",
    ".res.js",
    ".json",
};

//==============================================================================
// Watch configuration (parsed from gossamer.conf.json build.watch)
//==============================================================================

/// Configuration for the file watcher, parsed from the `build.watch` section
/// of gossamer.conf.json. Falls back to sensible defaults when absent.
pub const WatchConfig = struct {
    /// Directories to watch for file changes (relative to project root).
    paths: [MAX_WATCH_PATHS][]const u8 = undefined,
    path_count: usize = 0,

    /// File extensions that trigger a reload when modified.
    extensions: [MAX_EXTENSIONS][]const u8 = undefined,
    extension_count: usize = 0,

    /// Minimum quiet time (ms) after last change before triggering reload.
    debounce_ms: u32 = DEFAULT_DEBOUNCE_MS,

    /// How often (ms) the watcher polls the filesystem for changes.
    poll_ms: u32 = DEFAULT_POLL_MS,
};

//==============================================================================
// Tracked file entry — stores path hash + last known mtime
//==============================================================================

/// A single tracked file with its last-observed modification time.
/// Uses a path hash to avoid storing full path strings.
const TrackedFile = struct {
    /// FNV-1a hash of the relative file path (for identity).
    path_hash: u64,
    /// Last observed mtime in nanoseconds since epoch.
    mtime_ns: i128,
};

//==============================================================================
// Reload context — passed through g_idle_add to the GTK main thread
//==============================================================================

/// Context for the g_idle_add callback that triggers webview reload.
/// Heap-allocated by the watcher thread, freed by the idle callback.
const ReloadContext = struct {
    /// Webview handle (opaque u64 from gossamer_create).
    handle: u64,
    /// The JavaScript to evaluate for reloading.
    js: [*:0]const u8,
};

//==============================================================================
// FFI imports — gossamer_eval is linked from libgossamer
//==============================================================================

extern fn gossamer_eval(handle: u64, js: [*:0]const u8) c_int;

//==============================================================================
// g_idle_add callback — runs on GTK main thread
//==============================================================================

/// Called by g_idle_add on the GTK main thread. Evaluates the reload JS
/// in the webview and frees the context.
///
/// Returns 0 (G_SOURCE_REMOVE) to run only once.
fn reloadIdleCallback(user_data: ?*anyopaque) callconv(.c) c_int {
    const ctx: *ReloadContext = @alignCast(@ptrCast(user_data orelse return 0));
    _ = gossamer_eval(ctx.handle, ctx.js);
    std.heap.c_allocator.destroy(ctx);
    return 0; // G_SOURCE_REMOVE — do not repeat
}

//==============================================================================
// Watcher state — owned by the watcher thread
//==============================================================================

/// Mutable state for the polling file watcher. Created on the heap by
/// `start()` and owned by the watcher thread for its entire lifetime.
const WatcherState = struct {
    /// Webview handle to reload when changes are detected.
    handle: u64,

    /// Watch configuration (paths, extensions, timing).
    config: WatchConfig,

    /// Tracked files — ring buffer of path hashes and mtimes.
    files: [MAX_TRACKED_FILES]TrackedFile = undefined,
    file_count: usize = 0,

    /// Timestamp (ns) of the last detected change, for debouncing.
    last_change_ns: i128 = 0,

    /// Whether a change has been detected but not yet dispatched
    /// (waiting for debounce window to close).
    pending_reload: bool = false,

    /// Set to true to signal the watcher thread to exit.
    should_stop: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),

    /// Thread handle for join on shutdown.
    thread: ?std.Thread = null,

    /// Caller-owned buffer copies kept alive for the lifetime of the
    /// watcher. The WatchConfig holds slices into these. Non-null only
    /// when the watcher was started via the C-ABI `gossamer_watcher_start`
    /// export (which dupes its inputs); the Zig-native `start()` path
    /// leaves them null because the caller manages buffer lifetime.
    owned_json: ?[]u8 = null,
    owned_frontend_dist: ?[]u8 = null,
};

//==============================================================================
// Public API
//==============================================================================

/// Opaque handle returned by start(), used to stop the watcher.
pub const WatcherHandle = *WatcherState;

/// Start the file watcher on a dedicated thread.
///
/// Arguments:
///   handle     — webview handle (from gossamer_create)
///   config     — watch configuration (paths, extensions, timing)
///
/// Returns a WatcherHandle that must be passed to stop() for cleanup.
pub fn start(handle: u64, config: WatchConfig) !WatcherHandle {
    const state = try std.heap.c_allocator.create(WatcherState);
    state.* = .{
        .handle = handle,
        .config = config,
    };

    // Initial scan — populate the tracked file list with current mtimes.
    scanAllPaths(state);

    // Spawn the watcher thread.
    state.thread = try std.Thread.spawn(.{}, watcherThreadFn, .{state});
    return state;
}

/// Stop the file watcher and clean up resources.
/// Blocks until the watcher thread exits (bounded by one poll interval).
pub fn stop(watcher: WatcherHandle) void {
    watcher.should_stop.store(true, .release);
    if (watcher.thread) |t| {
        t.join();
    }
    if (watcher.owned_json) |j| std.heap.c_allocator.free(j);
    if (watcher.owned_frontend_dist) |fd| std.heap.c_allocator.free(fd);
    std.heap.c_allocator.destroy(watcher);
}

//==============================================================================
// Watcher thread main loop
//==============================================================================

/// Main function for the watcher thread. Polls watched directories at the
/// configured interval, detects file changes, and schedules reloads via
/// g_idle_add when the debounce window closes.
fn watcherThreadFn(state: *WatcherState) void {
    const poll_ns: u64 = @as(u64, state.config.poll_ms) * std.time.ns_per_ms;
    const debounce_ns: i128 = @as(i128, state.config.debounce_ms) * std.time.ns_per_ms;

    while (!state.should_stop.load(.acquire)) {
        std.Thread.sleep(poll_ns);

        if (state.should_stop.load(.acquire)) break;

        const changed = scanForChanges(state);
        const now_ns = std.time.nanoTimestamp();

        if (changed) {
            state.last_change_ns = now_ns;
            state.pending_reload = true;
        }

        // Check if debounce window has elapsed since the last change.
        if (state.pending_reload) {
            const elapsed = now_ns - state.last_change_ns;
            if (elapsed >= debounce_ns) {
                state.pending_reload = false;
                scheduleReload(state.handle);
            }
        }
    }
}

//==============================================================================
// Directory scanning
//==============================================================================

/// Perform the initial scan of all watched paths, populating the tracked
/// file list with current mtimes. No reload is triggered.
fn scanAllPaths(state: *WatcherState) void {
    state.file_count = 0;
    for (state.config.paths[0..state.config.path_count]) |watch_path| {
        _ = scanDirectory(state, watch_path, false);
    }
}

/// Scan all watched paths and return true if any file has changed (new,
/// modified, or deleted).
fn scanForChanges(state: *WatcherState) bool {
    var any_changed = false;

    // Scan each watched path for files matching the configured extensions.
    for (state.config.paths[0..state.config.path_count]) |watch_path| {
        if (scanDirectory(state, watch_path, true)) {
            any_changed = true;
        }
    }

    return any_changed;
}

/// Scan a single directory (non-recursively) for files matching the watched
/// extensions. In check mode, compares mtimes against tracked state.
/// In populate mode (check=false), adds entries without checking.
///
/// Returns true if any change was detected (only meaningful when check=true).
fn scanDirectory(state: *WatcherState, path: []const u8, check: bool) bool {
    var dir = std.fs.cwd().openDir(path, .{ .iterate = true }) catch return false;
    defer dir.close();

    var any_changed = false;
    var iter = dir.iterate();

    while (iter.next() catch null) |entry| {
        // Skip directories — we only watch files at the top level of each
        // configured path. Recursive watching would require a queue/stack
        // and is left for a future enhancement.
        if (entry.kind == .directory) {
            // Recurse into subdirectories for broader coverage.
            var sub_path_buf: [1024]u8 = undefined;
            const sub_path = std.fmt.bufPrint(&sub_path_buf, "{s}/{s}", .{ path, entry.name }) catch continue;
            if (scanDirectory(state, sub_path, check)) {
                any_changed = true;
            }
            continue;
        }

        if (entry.kind != .file) continue;

        // Check if the file extension matches any watched extension.
        if (!matchesExtension(entry.name, state.config.extensions[0..state.config.extension_count])) {
            continue;
        }

        // Stat the file for mtime.
        const stat = dir.statFile(entry.name) catch continue;
        const mtime_ns = stat.mtime;
        const path_hash = hashPath(path, entry.name);

        if (check) {
            // Look up existing entry.
            if (findTrackedFile(state, path_hash)) |idx| {
                if (state.files[idx].mtime_ns != mtime_ns) {
                    state.files[idx].mtime_ns = mtime_ns;
                    any_changed = true;
                }
            } else {
                // New file appeared — track it and report as changed.
                addTrackedFile(state, path_hash, mtime_ns);
                any_changed = true;
            }
        } else {
            // Initial population — just add without flagging as changed.
            addTrackedFile(state, path_hash, mtime_ns);
        }
    }

    return any_changed;
}

/// Check whether a filename ends with any of the watched extensions.
fn matchesExtension(name: []const u8, extensions: []const []const u8) bool {
    for (extensions) |ext| {
        if (name.len >= ext.len and std.mem.eql(u8, name[name.len - ext.len ..], ext)) {
            return true;
        }
    }
    return false;
}

/// FNV-1a hash of the concatenation of directory path and filename.
/// Used as a lightweight identifier for tracked files.
fn hashPath(dir_path: []const u8, file_name: []const u8) u64 {
    var h = std.hash.Fnv1a_64.init();
    h.update(dir_path);
    h.update("/");
    h.update(file_name);
    return h.final();
}

/// Find the index of a tracked file by its path hash.
fn findTrackedFile(state: *WatcherState, path_hash: u64) ?usize {
    for (state.files[0..state.file_count], 0..) |file, i| {
        if (file.path_hash == path_hash) return i;
    }
    return null;
}

/// Add a new tracked file entry. If the table is full, wraps around
/// (evicts oldest entry). This is a simple bounded ring buffer.
fn addTrackedFile(state: *WatcherState, path_hash: u64, mtime_ns: i128) void {
    if (state.file_count < MAX_TRACKED_FILES) {
        state.files[state.file_count] = .{
            .path_hash = path_hash,
            .mtime_ns = mtime_ns,
        };
        state.file_count += 1;
    }
    // If full, silently drop — bounded by MAX_TRACKED_FILES.
}

//==============================================================================
// Reload scheduling
//==============================================================================

/// Schedule a webview reload on the GTK main thread via g_idle_add.
/// Allocates a small context on the heap that the idle callback frees.
fn scheduleReload(handle: u64) void {
    const ctx = std.heap.c_allocator.create(ReloadContext) catch return;
    ctx.* = .{
        .handle = handle,
        .js = "location.reload(true)",
    };
    _ = glib.g_idle_add(@ptrCast(&reloadIdleCallback), @ptrCast(ctx));
}

//==============================================================================
// Config parsing helpers
//==============================================================================

/// Parse a WatchConfig from the raw gossamer.conf.json content.
/// Looks for `"watch": { "paths": [...], "extensions": [...], "debounceMs": N }`.
/// Falls back to `frontendDist` as the sole watch path and DEFAULT_EXTENSIONS
/// when the watch section is absent.
pub fn parseWatchConfig(json: []const u8, frontend_dist: []const u8) WatchConfig {
    var config = WatchConfig{};

    // Try to find "watch" section and parse paths/extensions from it.
    const watch_section = findObjectValue(json, "watch");

    if (watch_section) |section| {
        // Parse "paths" array.
        config.path_count = parseStringArray(section, "paths", &config.paths);

        // Parse "extensions" array.
        config.extension_count = parseStringArray(section, "extensions", &config.extensions);

        // Parse "debounceMs" integer.
        if (extractSimpleInt(section, "debounceMs")) |val| {
            config.debounce_ms = val;
        }

        // Parse "pollMs" integer (optional, for power users).
        if (extractSimpleInt(section, "pollMs")) |val| {
            config.poll_ms = val;
        }
    }

    // Fallback: if no paths configured, watch frontendDist.
    if (config.path_count == 0) {
        config.paths[0] = frontend_dist;
        config.path_count = 1;
    }

    // Fallback: if no extensions configured, use defaults.
    if (config.extension_count == 0) {
        for (DEFAULT_EXTENSIONS, 0..) |ext, i| {
            config.extensions[i] = ext;
        }
        config.extension_count = DEFAULT_EXTENSIONS.len;
    }

    return config;
}

/// Find the start of a JSON object value for a given key.
/// Returns a slice starting after the opening '{' of the object.
/// Minimal parser — assumes well-formed JSON.
fn findObjectValue(json: []const u8, key: []const u8) ?[]const u8 {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\"", .{key}) catch return null;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return null;
    const after = json[key_pos + search.len ..];

    // Skip whitespace and colon.
    var i: usize = 0;
    while (i < after.len and (after[i] == ' ' or after[i] == '\t' or after[i] == '\n' or after[i] == '\r' or after[i] == ':')) : (i += 1) {}

    if (i >= after.len or after[i] != '{') return null;

    // Find matching closing brace (simple depth counter).
    var depth: u32 = 0;
    var j = i;
    while (j < after.len) : (j += 1) {
        if (after[j] == '{') depth += 1;
        if (after[j] == '}') {
            depth -= 1;
            if (depth == 0) return after[i .. j + 1];
        }
    }
    return null;
}

/// Parse a JSON string array like `"key": ["a", "b", "c"]` and populate
/// the output buffer. Returns the number of elements parsed.
fn parseStringArray(json: []const u8, key: []const u8, out_buf: *[MAX_WATCH_PATHS][]const u8) usize {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\"", .{key}) catch return 0;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return 0;
    const after = json[key_pos + search.len ..];

    // Skip to opening bracket.
    var i: usize = 0;
    while (i < after.len and after[i] != '[') : (i += 1) {}
    if (i >= after.len) return 0;
    i += 1; // Skip '['

    var count: usize = 0;
    while (i < after.len and count < MAX_WATCH_PATHS) {
        // Skip whitespace and commas.
        while (i < after.len and (after[i] == ' ' or after[i] == '\t' or after[i] == '\n' or after[i] == '\r' or after[i] == ',')) : (i += 1) {}

        if (i >= after.len or after[i] == ']') break;

        if (after[i] == '"') {
            i += 1;
            const str_start = i;
            while (i < after.len and after[i] != '"') : (i += 1) {}
            if (i < after.len) {
                out_buf[count] = after[str_start..i];
                count += 1;
                i += 1; // Skip closing quote
            }
        } else {
            i += 1; // Skip unexpected character
        }
    }

    return count;
}

/// Extract a simple integer value from JSON: "key": 123
fn extractSimpleInt(json: []const u8, key: []const u8) ?u32 {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\"", .{key}) catch return null;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return null;
    const after = json[key_pos + search.len ..];

    var i: usize = 0;
    while (i < after.len and (after[i] == ' ' or after[i] == '\t' or after[i] == ':')) : (i += 1) {}
    const num_start = i;
    while (i < after.len and after[i] >= '0' and after[i] <= '9') : (i += 1) {}
    if (i == num_start) return null;
    return std.fmt.parseInt(u32, after[num_start..i], 10) catch null;
}

//==============================================================================
// C ABI — exported as gossamer_watcher_* in libgossamer
//==============================================================================

/// Start the hot-reload file watcher.
///
/// Both `config_json` (the full gossamer.conf.json content, used to extract
/// the optional `"watch"` block) and `frontend_dist` (used as the fallback
/// watch path) are copied into watcher-owned memory, so callers may free
/// their buffers immediately after this returns.
///
/// Returns an opaque pointer to be passed to gossamer_watcher_stop, or
/// null if the watcher could not be started.
export fn gossamer_watcher_start(
    handle: u64,
    config_json: [*:0]const u8,
    frontend_dist: [*:0]const u8,
) ?*anyopaque {
    const json_in = std.mem.span(config_json);
    const fd_in = std.mem.span(frontend_dist);

    const json_copy = std.heap.c_allocator.dupe(u8, json_in) catch return null;
    const fd_copy = std.heap.c_allocator.dupe(u8, fd_in) catch {
        std.heap.c_allocator.free(json_copy);
        return null;
    };

    const cfg = parseWatchConfig(json_copy, fd_copy);

    const state = std.heap.c_allocator.create(WatcherState) catch {
        std.heap.c_allocator.free(json_copy);
        std.heap.c_allocator.free(fd_copy);
        return null;
    };
    state.* = .{
        .handle = handle,
        .config = cfg,
        .owned_json = json_copy,
        .owned_frontend_dist = fd_copy,
    };

    scanAllPaths(state);

    state.thread = std.Thread.spawn(.{}, watcherThreadFn, .{state}) catch {
        std.heap.c_allocator.free(json_copy);
        std.heap.c_allocator.free(fd_copy);
        std.heap.c_allocator.destroy(state);
        return null;
    };
    return @ptrCast(state);
}

/// Stop the watcher started by gossamer_watcher_start. Blocks until the
/// poll thread exits (bounded by one poll interval) and frees all
/// watcher-owned resources. Safe to call with null (no-op).
export fn gossamer_watcher_stop(opaque_handle: ?*anyopaque) void {
    const p = opaque_handle orelse return;
    const state: *WatcherState = @alignCast(@ptrCast(p));
    stop(state);
}
