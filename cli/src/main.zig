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

// Window control operations (exposed via IPC to JavaScript)
extern fn gossamer_show(handle: u64) c_int;
extern fn gossamer_hide(handle: u64) c_int;
extern fn gossamer_minimize(handle: u64) c_int;
extern fn gossamer_maximize(handle: u64) c_int;
extern fn gossamer_restore(handle: u64) c_int;
extern fn gossamer_resize(handle: u64, width: u32, height: u32) c_int;
extern fn gossamer_request_close(handle: u64) c_int;

// Window guard (anti-close lock)
extern fn gossamer_guard_set(handle: u64, mode: c_int) c_int;
extern fn gossamer_guard_get(handle: u64) c_int;

// Window registry (multi-window)
extern fn gossamer_registry_add(handle: u64) u32;
extern fn gossamer_registry_remove(handle: u64) void;
extern fn gossamer_registry_count() u32;

// Window grouping
extern fn gossamer_group_create(label: ?[*:0]const u8) u32;
extern fn gossamer_group_add(group_id: u32, window_id: u32) c_int;
extern fn gossamer_group_remove(group_id: u32, window_id: u32) c_int;
extern fn gossamer_group_destroy(group_id: u32) void;
extern fn gossamer_group_apply(group_id: u32, op: u32) c_int;

// Z-order
extern fn gossamer_raise(handle: u64) c_int;
extern fn gossamer_lower(handle: u64) c_int;

// Cross-window communication
extern fn gossamer_broadcast(event_name: [*:0]const u8, payload_json: [*:0]const u8) u32;
extern fn gossamer_send_to(target_id: u32, event_name: [*:0]const u8, payload_json: [*:0]const u8) c_int;

// Auto-arrange
extern fn gossamer_arrange(strategy: u32) c_int;

// Transmute (mode switching)
extern fn gossamer_transmute(handle: u64, mode: c_int) c_int;
extern fn gossamer_transmute_get(handle: u64) c_int;

// Activity throttling
extern fn gossamer_activity_set(handle: u64, level: c_int) c_int;
extern fn gossamer_activity_get(handle: u64) c_int;

// Debug drawer
extern fn gossamer_debug_open(handle: u64) c_int;
extern fn gossamer_debug_close(handle: u64) c_int;
extern fn gossamer_debug_toggle(handle: u64) c_int;

// Groove typed connections
extern fn gossamer_groove_connect_typed(target_id: u32, groove_type: c_int, ttl: u32) c_int;
extern fn gossamer_groove_disconnect_typed(target_id: u32) c_int;
extern fn gossamer_groove_query_type(target_id: u32) c_int;

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
// Window Control IPC Handlers
//==============================================================================
//
// These handlers expose native window operations to JavaScript via the IPC
// bridge. Each handler receives the webview handle pointer via user_data
// and dispatches to the corresponding gossamer_* FFI function.
//
// JS usage: gossamer.window_minimize(), gossamer.window_resize({width:800,height:600})

/// Helper: format a window control result as a JSON response string.
/// Returns a static string for success, or a JSON error for failure.
fn windowResultJson(rc: c_int) [*:0]const u8 {
    return if (rc == 0)
        @ptrCast(@constCast("{\"ok\":true}"))
    else
        @ptrCast(@constCast("{\"ok\":false,\"error\":\"window operation failed\"}"));
}

/// IPC handler: minimize the window.
/// JS: gossamer.window_minimize()
fn windowMinimizeHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_minimize(handle));
}

/// IPC handler: maximize the window.
/// JS: gossamer.window_maximize()
fn windowMaximizeHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_maximize(handle));
}

/// IPC handler: restore the window from minimized/maximized state.
/// JS: gossamer.window_restore()
fn windowRestoreHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_restore(handle));
}

/// IPC handler: show a hidden window.
/// JS: gossamer.window_show()
fn windowShowHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_show(handle));
}

/// IPC handler: hide the window (remains in taskbar/dock).
/// JS: gossamer.window_hide()
fn windowHideHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_hide(handle));
}

/// IPC handler: request window close.
/// JS: gossamer.window_close()
fn windowCloseHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_request_close(handle));
}

/// IPC handler: resize the window.
/// JS: gossamer.window_resize({width: 1024, height: 768})
/// Payload: {"width":"1024","height":"768"}
fn windowResizeHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);

    const width_str = extractSimpleJsonField(payload_slice, "width") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing width\"}"));
    };
    const height_str = extractSimpleJsonField(payload_slice, "height") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing height\"}"));
    };

    const width = std.fmt.parseInt(u32, width_str, 10) catch {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid width\"}"));
    };
    const height = std.fmt.parseInt(u32, height_str, 10) catch {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid height\"}"));
    };

    return windowResultJson(gossamer_resize(handle, width, height));
}

/// IPC handler: set the window title.
/// JS: gossamer.window_set_title({title: "New Title"})
/// Payload: {"title":"New Title"}
fn windowSetTitleHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);

    const title = extractSimpleJsonField(payload_slice, "title") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing title\"}"));
    };

    // Build a null-terminated title string on the stack
    var title_buf: [512]u8 = undefined;
    if (title.len >= title_buf.len) {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"title too long\"}"));
    }
    @memcpy(title_buf[0..title.len], title);
    title_buf[title.len] = 0;
    const title_z: [*:0]const u8 = title_buf[0..title.len :0];

    return windowResultJson(gossamer_set_title(handle, title_z));
}

//==============================================================================
// Window Guard IPC Handlers
//==============================================================================

/// IPC handler: set the window guard mode.
/// JS: gossamer.window_guard_set({mode: "locked"})
/// Modes: "free" (0), "locked" (1), "read_only" (2)
fn windowGuardSetHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);

    const mode_str = extractSimpleJsonField(payload_slice, "mode") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing mode\"}"));
    };

    var mode: c_int = 0;
    if (std.mem.eql(u8, mode_str, "free")) {
        mode = 0;
    } else if (std.mem.eql(u8, mode_str, "locked")) {
        mode = 1;
    } else if (std.mem.eql(u8, mode_str, "read_only")) {
        mode = 2;
    } else {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid mode (use free/locked/read_only)\"}"));
    }

    return windowResultJson(gossamer_guard_set(handle, mode));
}

/// IPC handler: get the current guard mode.
/// JS: gossamer.window_guard_get()
fn windowGuardGetHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const mode = gossamer_guard_get(handle);
    return switch (mode) {
        0 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"free\"}")),
        1 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"locked\"}")),
        2 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"read_only\"}")),
        else => @ptrCast(@constCast("{\"ok\":false,\"error\":\"unknown mode\"}")),
    };
}

//==============================================================================
// Z-Order IPC Handlers
//==============================================================================

/// IPC handler: raise window to front.
/// JS: gossamer.window_raise()
fn windowRaiseHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_raise(handle));
}

/// IPC handler: lower window to back.
/// JS: gossamer.window_lower()
fn windowLowerHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_lower(handle));
}

//==============================================================================
// Grouping IPC Handlers
//==============================================================================

/// IPC handler: create a window group.
/// JS: gossamer.group_create({label: "My Group"})
fn groupCreateHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const payload_slice = std.mem.span(payload);
    const label = extractSimpleJsonField(payload_slice, "label");

    var label_buf: [64]u8 = undefined;
    var label_z: ?[*:0]const u8 = null;
    if (label) |l| {
        const len = @min(l.len, label_buf.len - 1);
        @memcpy(label_buf[0..len], l[0..len]);
        label_buf[len] = 0;
        label_z = label_buf[0..len :0];
    }

    const gid = gossamer_group_create(label_z);
    if (gid == 0) {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"group limit reached\"}"));
    }

    // Return the group ID in the response
    const allocator = std.heap.c_allocator;
    var buf = allocator.alloc(u8, 64) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"alloc\"}"));
    const resp = std.fmt.bufPrint(buf, "{{\"ok\":true,\"group_id\":{d}}}", .{gid}) catch return @ptrCast(@constCast("{\"ok\":false}"));
    buf[resp.len] = 0;
    return @ptrCast(buf.ptr);
}

/// IPC handler: add current window to a group.
/// JS: gossamer.group_join({group_id: 1})
fn groupJoinHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    _ = user_data;
    const payload_slice = std.mem.span(payload);
    const gid_str = extractSimpleJsonField(payload_slice, "group_id") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing group_id\"}"));
    };
    const wid_str = extractSimpleJsonField(payload_slice, "window_id") orelse {
        return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing window_id\"}"));
    };
    const gid = std.fmt.parseInt(u32, gid_str, 10) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid group_id\"}"));
    const wid = std.fmt.parseInt(u32, wid_str, 10) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid window_id\"}"));
    return windowResultJson(gossamer_group_add(gid, wid));
}

/// IPC handler: remove a window from a group.
/// JS: gossamer.group_leave({group_id: 1, window_id: 1})
fn groupLeaveHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const payload_slice = std.mem.span(payload);
    const gid_str = extractSimpleJsonField(payload_slice, "group_id") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing group_id\"}"));
    const wid_str = extractSimpleJsonField(payload_slice, "window_id") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing window_id\"}"));
    const gid = std.fmt.parseInt(u32, gid_str, 10) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid group_id\"}"));
    const wid = std.fmt.parseInt(u32, wid_str, 10) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid window_id\"}"));
    return windowResultJson(gossamer_group_remove(gid, wid));
}

/// IPC handler: apply operation to all windows in a group.
/// JS: gossamer.group_apply({group_id: 1, op: "minimize"})
/// ops: minimize(0), maximize(1), restore(2), show(3), hide(4), close(5)
fn groupApplyHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const payload_slice = std.mem.span(payload);
    const gid_str = extractSimpleJsonField(payload_slice, "group_id") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing group_id\"}"));
    const op_str = extractSimpleJsonField(payload_slice, "op") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing op\"}"));
    const gid = std.fmt.parseInt(u32, gid_str, 10) catch return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid group_id\"}"));

    var op: u32 = 0;
    if (std.mem.eql(u8, op_str, "minimize")) { op = 0; }
    else if (std.mem.eql(u8, op_str, "maximize")) { op = 1; }
    else if (std.mem.eql(u8, op_str, "restore")) { op = 2; }
    else if (std.mem.eql(u8, op_str, "show")) { op = 3; }
    else if (std.mem.eql(u8, op_str, "hide")) { op = 4; }
    else if (std.mem.eql(u8, op_str, "close")) { op = 5; }
    else { return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid op\"}")); }

    return windowResultJson(gossamer_group_apply(gid, op));
}

//==============================================================================
// Cross-Communication + Arrange IPC Handlers
//==============================================================================

/// IPC handler: broadcast an event to all windows.
/// JS: gossamer.broadcast({event: "data_updated", payload: {...}})
fn broadcastHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const payload_slice = std.mem.span(payload);
    const event = extractSimpleJsonField(payload_slice, "event") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing event\"}"));
    const data = extractSimpleJsonField(payload_slice, "payload") orelse "{}";

    var event_buf: [256]u8 = undefined;
    if (event.len >= event_buf.len) return @ptrCast(@constCast("{\"ok\":false,\"error\":\"event name too long\"}"));
    @memcpy(event_buf[0..event.len], event);
    event_buf[event.len] = 0;

    var data_buf: [2048]u8 = undefined;
    if (data.len >= data_buf.len) return @ptrCast(@constCast("{\"ok\":false,\"error\":\"payload too large\"}"));
    @memcpy(data_buf[0..data.len], data);
    data_buf[data.len] = 0;

    const count = gossamer_broadcast(event_buf[0..event.len :0], data_buf[0..data.len :0]);
    _ = count;
    return @ptrCast(@constCast("{\"ok\":true}"));
}

/// IPC handler: auto-arrange all windows.
/// JS: gossamer.arrange({strategy: "grid"})
/// strategies: tile_horizontal(0), tile_vertical(1), cascade(2), grid(3)
fn arrangeHandler(payload: [*:0]const u8, _: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const payload_slice = std.mem.span(payload);
    const strat = extractSimpleJsonField(payload_slice, "strategy") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing strategy\"}"));

    var s: u32 = 3; // default grid
    if (std.mem.eql(u8, strat, "tile_horizontal")) { s = 0; }
    else if (std.mem.eql(u8, strat, "tile_vertical")) { s = 1; }
    else if (std.mem.eql(u8, strat, "cascade")) { s = 2; }
    else if (std.mem.eql(u8, strat, "grid")) { s = 3; }

    return windowResultJson(gossamer_arrange(s));
}

//==============================================================================
// Transmute IPC Handlers
//==============================================================================

/// IPC handler: transmute the window to a different mode.
/// JS: gossamer.transmute({mode: "tui"})
/// Modes: gui(0), tui(1), cli(2), terminal_export(3), panll_attach(4), panll_detach(5)
fn transmuteHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);
    const mode_str = extractSimpleJsonField(payload_slice, "mode") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing mode\"}"));

    var mode: c_int = 0;
    if (std.mem.eql(u8, mode_str, "gui")) { mode = 0; }
    else if (std.mem.eql(u8, mode_str, "tui")) { mode = 1; }
    else if (std.mem.eql(u8, mode_str, "cli")) { mode = 2; }
    else if (std.mem.eql(u8, mode_str, "terminal_export")) { mode = 3; }
    else if (std.mem.eql(u8, mode_str, "panll_attach")) { mode = 4; }
    else if (std.mem.eql(u8, mode_str, "panll_detach")) { mode = 5; }
    else { return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid mode\"}")); }

    return windowResultJson(gossamer_transmute(handle, mode));
}

/// IPC handler: get current transmute mode.
fn transmuteGetHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const mode = gossamer_transmute_get(handle);
    return switch (mode) {
        0 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"gui\"}")),
        1 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"tui\"}")),
        2 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"cli\"}")),
        3 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"terminal_export\"}")),
        4 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"panll_attach\"}")),
        5 => @ptrCast(@constCast("{\"ok\":true,\"mode\":\"panll_detach\"}")),
        else => @ptrCast(@constCast("{\"ok\":false,\"error\":\"unknown\"}")),
    };
}

//==============================================================================
// Activity Throttling IPC Handlers
//==============================================================================

/// IPC handler: set activity level.
/// JS: gossamer.activity_set({level: "paused"})
fn activitySetHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);
    const level_str = extractSimpleJsonField(payload_slice, "level") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing level\"}"));

    var level: c_int = 4;
    if (std.mem.eql(u8, level_str, "paused")) { level = 0; }
    else if (std.mem.eql(u8, level_str, "low")) { level = 1; }
    else if (std.mem.eql(u8, level_str, "mid")) { level = 2; }
    else if (std.mem.eql(u8, level_str, "high")) { level = 3; }
    else if (std.mem.eql(u8, level_str, "realtime")) { level = 4; }
    else { return @ptrCast(@constCast("{\"ok\":false,\"error\":\"invalid level\"}")); }

    return windowResultJson(gossamer_activity_set(handle, level));
}

/// IPC handler: get activity level.
fn activityGetHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const level = gossamer_activity_get(handle);
    return switch (level) {
        0 => @ptrCast(@constCast("{\"ok\":true,\"level\":\"paused\"}")),
        1 => @ptrCast(@constCast("{\"ok\":true,\"level\":\"low\"}")),
        2 => @ptrCast(@constCast("{\"ok\":true,\"level\":\"mid\"}")),
        3 => @ptrCast(@constCast("{\"ok\":true,\"level\":\"high\"}")),
        4 => @ptrCast(@constCast("{\"ok\":true,\"level\":\"realtime\"}")),
        else => @ptrCast(@constCast("{\"ok\":false,\"error\":\"unknown\"}")),
    };
}

//==============================================================================
// Debug Drawer IPC Handlers
//==============================================================================

fn debugOpenHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_debug_open(handle));
}

fn debugCloseHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_debug_close(handle));
}

fn debugToggleHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_debug_toggle(handle));
}

/// Register all window control and management IPC handlers on the given channel.
/// The handle_ptr is passed as user_data so handlers can dispatch FFI calls.
fn bindWindowControlHandlers(channel: u64, handle_ptr: ?*anyopaque) void {
    // Basic window controls (8 handlers)
    _ = gossamer_channel_bind(channel, "window_minimize", &windowMinimizeHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_maximize", &windowMaximizeHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_restore", &windowRestoreHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_show", &windowShowHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_hide", &windowHideHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_close", &windowCloseHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_resize", &windowResizeHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_set_title", &windowSetTitleHandler, handle_ptr);

    // Window guard / anti-close lock (2 handlers)
    _ = gossamer_channel_bind(channel, "window_guard_set", &windowGuardSetHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_guard_get", &windowGuardGetHandler, handle_ptr);

    // Z-order (2 handlers)
    _ = gossamer_channel_bind(channel, "window_raise", &windowRaiseHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "window_lower", &windowLowerHandler, handle_ptr);

    // Grouping (4 handlers)
    _ = gossamer_channel_bind(channel, "group_create", &groupCreateHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "group_join", &groupJoinHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "group_leave", &groupLeaveHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "group_apply", &groupApplyHandler, handle_ptr);

    // Cross-communication + arrange (2 handlers)
    _ = gossamer_channel_bind(channel, "broadcast", &broadcastHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "arrange", &arrangeHandler, handle_ptr);

    // Transmute (2 handlers)
    _ = gossamer_channel_bind(channel, "transmute", &transmuteHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "transmute_get", &transmuteGetHandler, handle_ptr);

    // Activity throttling (2 handlers)
    _ = gossamer_channel_bind(channel, "activity_set", &activitySetHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "activity_get", &activityGetHandler, handle_ptr);

    // Debug drawer (3 handlers)
    _ = gossamer_channel_bind(channel, "debug_open", &debugOpenHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "debug_close", &debugCloseHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "debug_toggle", &debugToggleHandler, handle_ptr);
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

        // Register window control + management IPC handlers (sync — all are fast GTK calls)
        bindWindowControlHandlers(channel, handle_ptr.?);
        out("  \x1b[32m✓\x1b[0m Window management handlers bound (25 operations)\n", .{});

        // Register in the global window registry (multi-window foundation)
        const wid = gossamer_registry_add(handle);
        if (wid > 0) {
            out("  \x1b[32m✓\x1b[0m Window registered (id={d})\n", .{wid});
        }
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

    const channel = gossamer_channel_open(handle);
    if (channel != 0) {
        bindWindowControlHandlers(channel, handle_ptr.?);
        _ = gossamer_registry_add(handle);
    }

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
            \\      "decorations": true,
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
