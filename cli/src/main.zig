// Gossamer CLI — Development and build tool for Gossamer webview apps
//
// Reads gossamer.conf.json, orchestrates the build pipeline, and launches
// the webview with the frontend content. Links against libgossamer for
// the native webview shell.
//
// Commands:
//   gossamer dev     — Run beforeDevCommand, load devUrl in webview
//   gossamer build   — Run beforeBuildCommand, bundle with frontendDist
//   gossamer init    — Create a new gossamer.conf.json from template
//   gossamer info    — Show project info from gossamer.conf.json
//   gossamer run     — Load frontendDist in webview (no build step)
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const file_watcher = @import("file_watcher.zig");

//==============================================================================
// I/O helpers (Zig 0.15 — File.writeAll + fmt.bufPrint)
//==============================================================================

fn out(comptime fmt: []const u8, args: anytype) void {
    var buf: [4096]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch return;
    std.fs.File.stdout().writeAll(msg) catch {};
}

fn err(comptime fmt: []const u8, args: anytype) void {
    var buf: [4096]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch return;
    std.fs.File.stderr().writeAll(msg) catch {};
}

//==============================================================================
// libgossamer FFI bindings (linked at build time)
//==============================================================================

extern fn gossamer_create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: u8,
    decorations: u8,
    fullscreen: u8,
) ?*anyopaque;

extern fn gossamer_create_ex(
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
) ?*anyopaque;

extern fn gossamer_navigate(handle: u64, url: [*:0]const u8) c_int;
extern fn gossamer_load_html(handle: u64, html: [*:0]const u8) c_int;
extern fn gossamer_channel_open(handle: u64) u64;
extern fn gossamer_channel_bind(channel: u64, name: [*:0]const u8, cb: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) c_int;
extern fn gossamer_channel_bind_async(channel: u64, name: [*:0]const u8, cb: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) c_int;
extern fn gossamer_eval(handle: u64, js: [*:0]const u8) c_int;
extern fn gossamer_run(handle: u64) void;
extern fn gossamer_destroy(handle: u64) void;
extern fn gossamer_version() [*:0]const u8;
extern fn gossamer_build_info() [*:0]const u8;
extern fn gossamer_last_error() ?[*:0]const u8;
extern fn gossamer_set_title(handle: u64, title: [*:0]const u8) c_int;
extern fn gossamer_set_csp(handle: u64, csp: [*:0]const u8) c_int;
extern fn gossamer_emit(handle: u64, event_name: [*:0]const u8, payload_json: [*:0]const u8) c_int;
extern fn gossamer_groove_discover() u32;
extern fn gossamer_groove_status(target_id: u32) u32;

const AppMode = enum {
    gui,
    panel_host,
    headless,
    cli,
    tui,
};

const PANLL_GROOVE_ID: u32 = 4;

//==============================================================================
// Shell-exec IPC handler for OPSM runtime commands
//==============================================================================

/// Execute a shell command and return stdout as a JSON-escaped string.
/// The payload is a JSON object: {"cmd":"list"} or {"cmd":"install","tool":"deno","version":"2.6.10"}
fn shellExecHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const allocator = std.heap.c_allocator;
    const payload_slice = std.mem.span(payload);

    // Minimal JSON parsing: extract "cmd" field
    const cmd_str = extractSimpleJsonField(payload_slice, "cmd") orelse {
        return @ptrCast(@constCast("{\"error\":\"missing cmd field\"}"));
    };
    const tool_str = extractSimpleJsonField(payload_slice, "tool");
    const version_str = extractSimpleJsonField(payload_slice, "version");

    // Build the opsm-runtime command
    var cmd_buf: [2048]u8 = undefined;
    var cmd_len: usize = 0;
    const prefix = "opsm-runtime ";

    @memcpy(cmd_buf[cmd_len..][0..prefix.len], prefix);
    cmd_len += prefix.len;
    @memcpy(cmd_buf[cmd_len..][0..cmd_str.len], cmd_str);
    cmd_len += cmd_str.len;

    if (tool_str) |t| {
        cmd_buf[cmd_len] = ' ';
        cmd_len += 1;
        @memcpy(cmd_buf[cmd_len..][0..t.len], t);
        cmd_len += t.len;
    }
    if (version_str) |v| {
        cmd_buf[cmd_len] = ' ';
        cmd_len += 1;
        @memcpy(cmd_buf[cmd_len..][0..v.len], v);
        cmd_len += v.len;
    }
    cmd_buf[cmd_len] = 0;

    // Execute via /bin/sh
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "/bin/sh", "-c", cmd_buf[0..cmd_len] },
    }) catch {
        return @ptrCast(@constCast("{\"error\":\"exec failed\"}"));
    };
    defer allocator.free(result.stderr);

    // Wrap stdout in JSON (escape newlines)
    const stdout = result.stdout;
    defer allocator.free(stdout);

    // Build JSON response: {"output":"...","exit_code":0}
    var resp_buf = allocator.alloc(u8, stdout.len * 2 + 64) catch {
        return @ptrCast(@constCast("{\"error\":\"out of memory\"}"));
    };
    var pos: usize = 0;
    const hdr = "{\"output\":\"";
    @memcpy(resp_buf[pos..][0..hdr.len], hdr);
    pos += hdr.len;

    for (stdout) |ch| {
        switch (ch) {
            '\n' => { resp_buf[pos] = '\\'; resp_buf[pos + 1] = 'n'; pos += 2; },
            '\r' => { resp_buf[pos] = '\\'; resp_buf[pos + 1] = 'r'; pos += 2; },
            '"' => { resp_buf[pos] = '\\'; resp_buf[pos + 1] = '"'; pos += 2; },
            '\\' => { resp_buf[pos] = '\\'; resp_buf[pos + 1] = '\\'; pos += 2; },
            else => { resp_buf[pos] = ch; pos += 1; },
        }
    }

    const exit_str = switch (result.term.Exited) {
        0 => "\",\"exit_code\":0}",
        else => "\",\"exit_code\":1}",
    };
    @memcpy(resp_buf[pos..][0..exit_str.len], exit_str);
    pos += exit_str.len;
    resp_buf[pos] = 0;

    return @ptrCast(resp_buf.ptr);
}

/// Extract a simple string value from JSON like {"key":"value"}.
/// Stack-only, no allocations. Returns null if not found.
fn extractSimpleJsonField(json: []const u8, key: []const u8) ?[]const u8 {
    // Search for "key":"
    var i: usize = 0;
    while (i + key.len + 4 < json.len) : (i += 1) {
        if (json[i] == '"' and i + key.len + 1 < json.len) {
            if (std.mem.eql(u8, json[i + 1 ..][0..key.len], key) and
                json[i + 1 + key.len] == '"')
            {
                // Found "key" — now look for :"
                var j = i + 1 + key.len + 1;
                while (j < json.len and json[j] == ' ') : (j += 1) {}
                if (j < json.len and json[j] == ':') {
                    j += 1;
                    while (j < json.len and json[j] == ' ') : (j += 1) {}
                    if (j < json.len and json[j] == '"') {
                        j += 1;
                        const start = j;
                        while (j < json.len and json[j] != '"') : (j += 1) {}
                        return json[start..j];
                    }
                }
            }
        }
    }
    return null;
}

//==============================================================================
// Config types (matching gossamer.conf.json schema)
//==============================================================================

const Config = struct {
    product_name: []const u8 = "Gossamer App",
    version: []const u8 = "0.1.0",
    identifier: []const u8 = "com.example.app",
    frontend_dist: []const u8 = "../public",
    dev_url: []const u8 = "http://localhost:4040/",
    before_dev_command: ?[]const u8 = null,
    before_build_command: ?[]const u8 = null,
    title: []const u8 = "Gossamer App",
    width: u32 = 800,
    height: u32 = 600,
    min_width: ?u32 = null,
    min_height: ?u32 = null,
    max_width: ?u32 = null,
    max_height: ?u32 = null,
    resizable: bool = true,
    fullscreen: bool = false,
    decorations: bool = true,
    mode: AppMode = .gui,
    visible: bool = true,
    /// Content-Security-Policy directive from gossamer.conf.json security.csp.
    /// When non-null, injected as a <meta> CSP tag after the IPC bridge is set up.
    csp: ?[]const u8 = null,
};

//==============================================================================
// Config parser
//==============================================================================

fn parseConfig(json_str: []const u8) Config {
    var config = Config{};
    config.product_name = extractStringField(json_str, "productName") orelse config.product_name;
    config.version = extractStringField(json_str, "version") orelse config.version;
    config.identifier = extractStringField(json_str, "identifier") orelse config.identifier;
    config.frontend_dist = extractStringField(json_str, "frontendDist") orelse config.frontend_dist;
    config.dev_url = extractStringField(json_str, "devUrl") orelse config.dev_url;
    config.before_dev_command = extractStringField(json_str, "beforeDevCommand");
    config.before_build_command = extractStringField(json_str, "beforeBuildCommand");
    config.title = extractStringField(json_str, "title") orelse config.title;
    config.width = extractIntField(json_str, "width") orelse config.width;
    config.height = extractIntField(json_str, "height") orelse config.height;
    config.min_width = extractIntField(json_str, "minWidth");
    config.min_height = extractIntField(json_str, "minHeight");
    config.max_width = extractIntField(json_str, "maxWidth");
    config.max_height = extractIntField(json_str, "maxHeight");
    config.resizable = extractBoolField(json_str, "resizable") orelse config.resizable;
    config.fullscreen = extractBoolField(json_str, "fullscreen") orelse config.fullscreen;
    config.decorations = extractBoolField(json_str, "decorations") orelse config.decorations;
    config.visible = extractBoolField(json_str, "visible") orelse config.visible;
    config.mode = parseAppMode(extractStringField(json_str, "mode")) orelse config.mode;
    // Parse security.csp — the field is "csp":"..." inside the "security" block.
    // extractStringField finds the first match, which works since "csp" only appears in security.
    config.csp = extractStringField(json_str, "csp");
    return config;
}

fn extractStringField(json: []const u8, key: []const u8) ?[]const u8 {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\":", .{key}) catch return null;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return null;
    const after_key = json[key_pos + search.len ..];
    var i: usize = 0;
    while (i < after_key.len and (after_key[i] == ' ' or after_key[i] == '\t' or after_key[i] == '\n' or after_key[i] == '\r')) : (i += 1) {}
    if (i >= after_key.len or after_key[i] != '"') return null;
    i += 1;
    const value_start = i;
    while (i < after_key.len) : (i += 1) {
        if (after_key[i] == '"' and (i == 0 or after_key[i - 1] != '\\')) {
            return after_key[value_start..i];
        }
    }
    return null;
}

fn extractIntField(json: []const u8, key: []const u8) ?u32 {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\":", .{key}) catch return null;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return null;
    const after_key = json[key_pos + search.len ..];
    var i: usize = 0;
    while (i < after_key.len and (after_key[i] == ' ' or after_key[i] == '\t')) : (i += 1) {}
    const num_start = i;
    while (i < after_key.len and after_key[i] >= '0' and after_key[i] <= '9') : (i += 1) {}
    if (i == num_start) return null;
    return std.fmt.parseInt(u32, after_key[num_start..i], 10) catch null;
}

fn extractBoolField(json: []const u8, key: []const u8) ?bool {
    var search_buf: [256]u8 = undefined;
    const search = std.fmt.bufPrint(&search_buf, "\"{s}\":", .{key}) catch return null;
    const key_pos = std.mem.indexOf(u8, json, search) orelse return null;
    const after_key = json[key_pos + search.len ..];
    var i: usize = 0;
    while (i < after_key.len and (after_key[i] == ' ' or after_key[i] == '\t')) : (i += 1) {}
    if (i + 4 <= after_key.len and std.mem.eql(u8, after_key[i .. i + 4], "true")) return true;
    if (i + 5 <= after_key.len and std.mem.eql(u8, after_key[i .. i + 5], "false")) return false;
    return null;
}

fn parseAppMode(value: ?[]const u8) ?AppMode {
    const mode = value orelse return null;
    if (std.mem.eql(u8, mode, "gui")) return .gui;
    if (std.mem.eql(u8, mode, "panel-host") or std.mem.eql(u8, mode, "panel_host")) return .panel_host;
    if (std.mem.eql(u8, mode, "headless")) return .headless;
    if (std.mem.eql(u8, mode, "cli")) return .cli;
    if (std.mem.eql(u8, mode, "tui")) return .tui;
    return null;
}

fn modeName(mode: AppMode) []const u8 {
    return switch (mode) {
        .gui => "gui",
        .panel_host => "panel-host",
        .headless => "headless",
        .cli => "cli",
        .tui => "tui",
    };
}

fn modeSupportsWindow(mode: AppMode) bool {
    return mode == .gui or mode == .panel_host;
}

//==============================================================================
// Shell command execution
//==============================================================================

fn runShellCommand(allocator: std.mem.Allocator, command: []const u8) !void {
    const argv = [_][]const u8{ "/bin/sh", "-c", command };
    var child = std.process.Child.init(&argv, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;
    try child.spawn();
    const result = try child.wait();
    if (result.Exited != 0) return error.CommandFailed;
}

fn runShellCommandBackground(allocator: std.mem.Allocator, command: []const u8) !std.process.Child {
    const argv = [_][]const u8{ "/bin/sh", "-c", command };
    var child = std.process.Child.init(&argv, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;
    try child.spawn();
    return child;
}

fn announcePanelHostMode() void {
    const discovered = gossamer_groove_discover();
    const panll_status = gossamer_groove_status(PANLL_GROOVE_ID);
    if (panll_status == 2 or panll_status == 3) {
        out("  \x1b[32m✓\x1b[0m PanLL groove detected ({d} groove(s) available)\n", .{discovered});
    } else {
        out("  \x1b[33m!\x1b[0m PanLL not detected ({d} groove(s) available)\n", .{discovered});
    }
}

//==============================================================================
// Commands
//==============================================================================

fn cmdDev(allocator: std.mem.Allocator, config: Config, config_data: []const u8) !void {
    out("\n  \x1b[36mGossamer\x1b[0m v{s}\n", .{std.mem.span(gossamer_version())});
    out("  \x1b[2m{s}\x1b[0m\n\n", .{config.product_name});

    if (!modeSupportsWindow(config.mode)) {
        switch (config.mode) {
            .headless => out("  \x1b[33m!\x1b[0m Headless mode selected; skipping webview launch.\n\n", .{}),
            .cli, .tui => out("  \x1b[33m!\x1b[0m Terminal mode is not implemented yet; skipping webview launch.\n\n", .{}),
            else => {},
        }
        return;
    }

    var dev_proc: ?std.process.Child = null;
    if (config.before_dev_command) |cmd| {
        out("  \x1b[33m→\x1b[0m Running: {s}\n", .{cmd});
        dev_proc = try runShellCommandBackground(allocator, cmd);
        std.Thread.sleep(2_000_000_000);
    }
    defer {
        if (dev_proc) |*proc| {
            _ = proc.kill() catch {};
        }
    }

    out("  \x1b[32m✓\x1b[0m Creating webview: {s}\n", .{config.title});
    const title_z = try allocator.dupeZ(u8, config.title);
    defer allocator.free(title_z);

    if (config.mode == .panel_host) {
        announcePanelHostMode();
    }

    const handle_ptr = gossamer_create_ex(
        title_z,
        config.width,
        config.height,
        config.min_width orelse 0,
        config.min_height orelse 0,
        config.max_width orelse 0,
        config.max_height orelse 0,
        if (config.resizable) 1 else 0,
        if (config.decorations) 1 else 0,
        if (config.fullscreen) 1 else 0,
        if (config.visible) 1 else 0,
    );

    if (handle_ptr == null) {
        if (gossamer_last_error()) |e| {
            out("  \x1b[31m✗\x1b[0m Failed: {s}\n", .{std.mem.span(e)});
        }
        return error.WebviewCreateFailed;
    }

    const handle = @intFromPtr(handle_ptr.?);
    const channel = gossamer_channel_open(handle);
    if (channel != 0) {
        out("  \x1b[32m✓\x1b[0m IPC bridge injected\n", .{});

        // Register shell-exec handler for OPSM runtime commands (async).
        // Uses async dispatch because shell commands do I/O and would
        // block the GTK event loop if run synchronously.
        // JS calls: gossamer.ipc.invoke('opsm_runtime', {cmd:'list'})
        _ = gossamer_channel_bind_async(channel, "opsm_runtime", &shellExecHandler, null);
        out("  \x1b[32m✓\x1b[0m OPSM runtime handler bound (async)\n", .{});
    }

    // Apply Content-Security-Policy from gossamer.conf.json if configured.
    // Must be called after channel_open (which injects the JS bridge).
    if (config.csp) |csp| {
        const csp_z = try allocator.dupeZ(u8, csp);
        defer allocator.free(csp_z);
        const csp_result = gossamer_set_csp(handle, csp_z);
        if (csp_result == 0) {
            out("  \x1b[32m✓\x1b[0m CSP applied: {s}\n", .{csp});
        } else {
            out("  \x1b[33m!\x1b[0m CSP injection failed\n", .{});
        }
    }

    const url_z = try allocator.dupeZ(u8, config.dev_url);
    defer allocator.free(url_z);
    out("  \x1b[32m✓\x1b[0m Loading: {s}\n\n", .{config.dev_url});
    _ = gossamer_navigate(handle, url_z);

    // Start the hot-reload file watcher.
    // Parses the optional `build.watch` section from gossamer.conf.json,
    // falling back to watching `frontendDist` with default extensions.
    const watch_config = file_watcher.parseWatchConfig(config_data, config.frontend_dist);
    var watcher: ?file_watcher.WatcherHandle = null;
    if (watch_config.path_count > 0) {
        watcher = file_watcher.start(handle, watch_config) catch blk: {
            out("  \x1b[33m!\x1b[0m Hot reload watcher failed to start\n", .{});
            break :blk null;
        };
        if (watcher != null) {
            out("  \x1b[32m✓\x1b[0m Hot reload watcher active", .{});
            out(" ({d} path(s), debounce {d}ms)\n", .{ watch_config.path_count, watch_config.debounce_ms });
        }
    }
    defer {
        if (watcher) |w| {
            file_watcher.stop(w);
        }
    }

    gossamer_run(handle);
    out("\n  \x1b[2mWindow closed.\x1b[0m\n", .{});
}

fn cmdBuild(allocator: std.mem.Allocator, config: Config) !void {
    out("\n  \x1b[36mGossamer\x1b[0m build\n", .{});
    out("  \x1b[2m{s} v{s}\x1b[0m\n\n", .{ config.product_name, config.version });

    if (config.before_build_command) |cmd| {
        out("  \x1b[33m→\x1b[0m Build: {s}\n", .{cmd});
        try runShellCommand(allocator, cmd);
        out("  \x1b[32m✓\x1b[0m Build complete\n", .{});
    }

    std.fs.cwd().access(config.frontend_dist, .{}) catch {
        out("  \x1b[31m✗\x1b[0m frontendDist not found: {s}\n", .{config.frontend_dist});
        return error.DistNotFound;
    };

    out("  \x1b[32m✓\x1b[0m Frontend dist: {s}\n", .{config.frontend_dist});
    out("  \x1b[32m✓\x1b[0m Ready for bundling ({s})\n\n", .{config.identifier});
}

fn cmdRun(allocator: std.mem.Allocator, config: Config) !void {
    out("\n  \x1b[36mGossamer\x1b[0m run\n", .{});

    if (!modeSupportsWindow(config.mode)) {
        switch (config.mode) {
            .headless => out("  \x1b[33m!\x1b[0m Headless mode selected; skipping webview launch.\n\n", .{}),
            .cli, .tui => out("  \x1b[33m!\x1b[0m Terminal mode is not implemented yet; skipping webview launch.\n\n", .{}),
            else => {},
        }
        return;
    }

    var path_buf: [4096]u8 = undefined;
    const index_path = std.fmt.bufPrint(&path_buf, "{s}/index.html", .{config.frontend_dist}) catch return error.PathTooLong;

    const html = std.fs.cwd().readFileAlloc(allocator, index_path, 1024 * 1024) catch {
        out("  \x1b[31m✗\x1b[0m Cannot read {s}\n", .{index_path});
        return error.DistNotFound;
    };
    defer allocator.free(html);

    const title_z = try allocator.dupeZ(u8, config.title);
    defer allocator.free(title_z);

    if (config.mode == .panel_host) {
        announcePanelHostMode();
    }

    const handle_ptr = gossamer_create_ex(
        title_z,
        config.width,
        config.height,
        config.min_width orelse 0,
        config.min_height orelse 0,
        config.max_width orelse 0,
        config.max_height orelse 0,
        if (config.resizable) 1 else 0,
        if (config.decorations) 1 else 0,
        if (config.fullscreen) 1 else 0,
        if (config.visible) 1 else 0,
    );
    if (handle_ptr == null) return error.WebviewCreateFailed;
    const handle = @intFromPtr(handle_ptr.?);

    _ = gossamer_channel_open(handle);

    // Apply Content-Security-Policy if configured
    if (config.csp) |csp| {
        const csp_z = try allocator.dupeZ(u8, csp);
        defer allocator.free(csp_z);
        _ = gossamer_set_csp(handle, csp_z);
    }

    const html_z = try allocator.dupeZ(u8, html);
    defer allocator.free(html_z);
    _ = gossamer_load_html(handle, html_z);

    out("  \x1b[32m✓\x1b[0m Loaded {s}\n\n", .{index_path});
    gossamer_run(handle);
}

fn cmdInfo(config: Config) void {
    out("\n  \x1b[36mGossamer\x1b[0m project info\n\n", .{});
    out("  Product:      {s}\n", .{config.product_name});
    out("  Version:      {s}\n", .{config.version});
    out("  Identifier:   {s}\n", .{config.identifier});
    out("  Frontend:     {s}\n", .{config.frontend_dist});
    out("  Dev URL:      {s}\n", .{config.dev_url});
    out("  Mode:         {s}\n", .{modeName(config.mode)});
    out("  Window:       {d}x{d}\n", .{ config.width, config.height });
    if (config.min_width != null or config.min_height != null) {
        out("  Min size:     {d}x{d}\n", .{ config.min_width orelse 0, config.min_height orelse 0 });
    } else {
        out("  Min size:     unconstrained\n", .{});
    }
    if (config.max_width != null or config.max_height != null) {
        out("  Max size:     {d}x{d}\n", .{ config.max_width orelse 0, config.max_height orelse 0 });
    } else {
        out("  Max size:     unconstrained\n", .{});
    }
    out("  Visible:      {s}\n", .{if (config.visible) "true" else "false"});
    out("  Gossamer:     {s}\n", .{std.mem.span(gossamer_version())});
    out("  Build:        {s}\n\n", .{std.mem.span(gossamer_build_info())});
}

fn cmdBundle(allocator: std.mem.Allocator, config: Config, config_data: []const u8) !void {
    out("\n  \x1b[36mGossamer\x1b[0m bundle\n", .{});
    out("  \x1b[2m{s} v{s}\x1b[0m\n\n", .{ config.product_name, config.version });

    // Run build first
    if (config.before_build_command) |cmd| {
        out("  \x1b[33m→\x1b[0m Build: {s}\n", .{cmd});
        try runShellCommand(allocator, cmd);
    }

    // Verify frontendDist
    std.fs.cwd().access(config.frontend_dist, .{}) catch {
        out("  \x1b[31m✗\x1b[0m frontendDist not found: {s}\n", .{config.frontend_dist});
        return error.DistNotFound;
    };

    // Create bundle output directory
    std.fs.cwd().makePath("target/bundle") catch {};

    // Generate .desktop entry (Linux)
    const desktop_name = extractStringField(config_data, "category") orelse "Utility";
    {
        var desktop_buf: [4096]u8 = undefined;
        const desktop_content = std.fmt.bufPrint(&desktop_buf,
            \\[Desktop Entry]
            \\Name={s}
            \\Exec=gossamer run
            \\Type=Application
            \\Categories={s};
            \\Comment=Gossamer application
            \\Terminal=false
            \\
        , .{ config.product_name, desktop_name }) catch return error.BufferTooSmall;

        var path_buf: [512]u8 = undefined;
        const id_lower = config.identifier;
        const desktop_path = std.fmt.bufPrint(&path_buf, "target/bundle/{s}.desktop", .{id_lower}) catch return error.BufferTooSmall;
        const desktop_file = try std.fs.cwd().createFile(desktop_path, .{});
        defer desktop_file.close();
        try desktop_file.writeAll(desktop_content);
        out("  \x1b[32m✓\x1b[0m Generated {s}\n", .{desktop_path});
    }

    // Generate Debian control file
    {
        var ctrl_buf: [4096]u8 = undefined;
        const ctrl_content = std.fmt.bufPrint(&ctrl_buf,
            \\Package: {s}
            \\Version: {s}
            \\Architecture: amd64
            \\Maintainer: Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
            \\Description: {s}
            \\ Gossamer desktop application.
            \\Depends: libgtk-3-0, libwebkit2gtk-4.1-0
            \\Section: utils
            \\Priority: optional
            \\
        , .{ config.product_name, config.version, config.product_name }) catch return error.BufferTooSmall;

        std.fs.cwd().makePath("target/bundle/deb/DEBIAN") catch {};
        const ctrl_file = try std.fs.cwd().createFile("target/bundle/deb/DEBIAN/control", .{});
        defer ctrl_file.close();
        try ctrl_file.writeAll(ctrl_content);
        out("  \x1b[32m✓\x1b[0m Generated DEBIAN/control\n", .{});
    }

    // Copy frontend dist into deb structure
    {
        var install_dir_buf: [512]u8 = undefined;
        const install_dir = std.fmt.bufPrint(&install_dir_buf, "target/bundle/deb/usr/share/{s}", .{config.identifier}) catch return error.BufferTooSmall;
        std.fs.cwd().makePath(install_dir) catch {};

        // Copy gossamer.conf.json into the package
        std.fs.cwd().copyFile("gossamer.conf.json", std.fs.cwd(), std.fmt.bufPrint(&install_dir_buf, "target/bundle/deb/usr/share/{s}/gossamer.conf.json", .{config.identifier}) catch return error.BufferTooSmall, .{}) catch {};

        out("  \x1b[32m✓\x1b[0m Prepared deb package structure\n", .{});
    }

    // Build the .deb if dpkg-deb is available
    {
        const argv = [_][]const u8{ "dpkg-deb", "--build", "target/bundle/deb", "target/bundle/" };
        var child = std.process.Child.init(&argv, allocator);
        child.stdin_behavior = .Inherit;
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;
        child.spawn() catch {
            out("  \x1b[33m!\x1b[0m dpkg-deb not found — .deb skipped\n", .{});
            out("  \x1b[32m✓\x1b[0m Bundle preparation complete (target/bundle/)\n\n", .{});
            return;
        };
        const result = child.wait() catch {
            out("  \x1b[33m!\x1b[0m dpkg-deb failed\n", .{});
            return;
        };
        if (result.Exited == 0) {
            out("  \x1b[32m✓\x1b[0m Built .deb package\n", .{});
        }
    }

    out("  \x1b[32m✓\x1b[0m Bundle complete (target/bundle/)\n\n", .{});
}

fn cmdInit() !void {
    std.fs.cwd().access("gossamer.conf.json", .{}) catch {
        const template =
            \\{
            \\  "$schema": "https://gossamer.dev/schemas/config/v1",
            \\  "productName": "My Gossamer App",
            \\  "version": "0.1.0",
            \\  "identifier": "com.example.myapp",
            \\  "build": {
            \\    "frontendDist": "../public",
            \\    "devUrl": "http://localhost:4040/",
            \\    "beforeDevCommand": "deno task dev",
            \\    "beforeBuildCommand": "deno task build",
            \\    "watch": {
            \\      "paths": ["public/", "src/"],
            \\      "extensions": [".html", ".js", ".css", ".res.js"],
            \\      "debounceMs": 300
            \\    }
            \\  },
            \\  "app": {
            \\    "windows": [{
            \\      "title": "My Gossamer App",
            \\      "width": 800,
            \\      "height": 600,
            \\      "minWidth": null,
            \\      "minHeight": null,
            \\      "maxWidth": null,
            \\      "maxHeight": null,
            \\      "resizable": true,
            \\      "decorations": true
            \\      "visible": true
            \\    }],
            \\    "mode": "gui",
            \\    "security": { "capabilities": ["filesystem", "network"] },
            \\    "ipc": { "protocol": "json", "bridgeInjection": true }
            \\  },
            \\  "bundle": { "active": true, "targets": ["deb", "appimage"] }
            \\}
        ;
        const file = try std.fs.cwd().createFile("gossamer.conf.json", .{});
        defer file.close();
        try file.writeAll(template);
        out("\n  \x1b[32m✓\x1b[0m Created gossamer.conf.json\n\n", .{});
        return;
    };
    out("\n  \x1b[33m!\x1b[0m gossamer.conf.json already exists\n\n", .{});
}

//==============================================================================
// Entry point
//==============================================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        out(
            \\
            \\  Gossamer — Linearly-typed webview shell
            \\
            \\  Usage:  gossamer <command>
            \\
            \\  Commands:
            \\    dev       Start development mode (webview + dev server)
            \\    build     Build frontend for production
            \\    bundle    Package as .deb / .appimage
            \\    run       Load built frontend in webview
            \\    init      Create gossamer.conf.json
            \\    info      Show project information
            \\    version   Show Gossamer version
            \\
            \\
        , .{});
        return;
    }

    const command = args[1];

    if (std.mem.eql(u8, command, "version")) {
        out("gossamer {s}\n", .{std.mem.span(gossamer_version())});
        return;
    }

    if (std.mem.eql(u8, command, "init")) {
        try cmdInit();
        return;
    }

    // All other commands need gossamer.conf.json
    const config_data = std.fs.cwd().readFileAlloc(allocator, "gossamer.conf.json", 256 * 1024) catch {
        err("\n  \x1b[31m✗\x1b[0m gossamer.conf.json not found\n  \x1b[2mRun 'gossamer init' to create one.\x1b[0m\n\n", .{});
        std.process.exit(1);
    };
    defer allocator.free(config_data);

    const config = parseConfig(config_data);

    if (std.mem.eql(u8, command, "dev")) {
        try cmdDev(allocator, config, config_data);
    } else if (std.mem.eql(u8, command, "build")) {
        try cmdBuild(allocator, config);
    } else if (std.mem.eql(u8, command, "bundle")) {
        try cmdBundle(allocator, config, config_data);
    } else if (std.mem.eql(u8, command, "run")) {
        try cmdRun(allocator, config);
    } else if (std.mem.eql(u8, command, "info")) {
        cmdInfo(config);
    } else {
        err("\n  \x1b[31m✗\x1b[0m Unknown command: {s}\n\n", .{command});
        std.process.exit(1);
    }
}
