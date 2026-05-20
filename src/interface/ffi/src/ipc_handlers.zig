// Gossamer — Default IPC channel handlers (libgossamer)
//
// Holds the 28 channel handlers (27 window/group/transmute/etc. + 1
// shell-exec) that the native gossamer CLI used to bind directly via
// gossamer_channel_bind. Migrated here so libgossamer can register
// them automatically when a channel opens, which means the upcoming
// Ephapax-wasm CLI doesn't have to re-implement these tiny payload-
// parsing wrappers inside the wasm guest — they're just defaults.
//
// Exposed C ABI:
//   • gossamer_channel_register_defaults(channel, handle_ptr) -> void
//       Registers all default handlers on the channel. The wasm CLI
//       calls this once after gossamer_channel_open returns. Native
//       callers can call it for the same effect.
//
// Each handler is the C-ABI shape libgossamer's channel system expects:
//   fn (payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

extern fn gossamer_channel_bind(channel: u64, name: [*:0]const u8, cb: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) c_int;
extern fn gossamer_channel_bind_async(channel: u64, name: [*:0]const u8, cb: ?*const fn ([*:0]const u8, ?*anyopaque) callconv(.c) [*:0]const u8, user_data: ?*anyopaque) c_int;
extern fn gossamer_show(handle: u64) c_int;
extern fn gossamer_hide(handle: u64) c_int;
extern fn gossamer_minimize(handle: u64) c_int;
extern fn gossamer_maximize(handle: u64) c_int;
extern fn gossamer_restore(handle: u64) c_int;
extern fn gossamer_resize(handle: u64, width: u32, height: u32) c_int;
extern fn gossamer_request_close(handle: u64) c_int;
extern fn gossamer_set_title(handle: u64, title: [*:0]const u8) c_int;
extern fn gossamer_guard_set(handle: u64, mode: c_int) c_int;
extern fn gossamer_guard_get(handle: u64) c_int;
extern fn gossamer_group_create(label: ?[*:0]const u8) u32;
extern fn gossamer_group_add(group_id: u32, window_id: u32) c_int;
extern fn gossamer_group_remove(group_id: u32, window_id: u32) c_int;
extern fn gossamer_group_apply(group_id: u32, op: u32) c_int;
extern fn gossamer_broadcast(event_name: [*:0]const u8, payload_json: [*:0]const u8) u32;
extern fn gossamer_raise(handle: u64) c_int;
extern fn gossamer_lower(handle: u64) c_int;
extern fn gossamer_arrange(strategy: u32) c_int;
extern fn gossamer_transmute(handle: u64, mode: c_int) c_int;
extern fn gossamer_transmute_get(handle: u64) c_int;
extern fn gossamer_activity_set(handle: u64, level: c_int) c_int;
extern fn gossamer_activity_get(handle: u64) c_int;
extern fn gossamer_debug_open(handle: u64) c_int;
extern fn gossamer_debug_close(handle: u64) c_int;
extern fn gossamer_debug_toggle(handle: u64) c_int;
extern fn gossamer_groove_dock(handle: u64, url: [*:0]const u8, width: u32) c_int;
extern fn gossamer_groove_undock(handle: u64) c_int;

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

//==============================================================================
// Groove Docking IPC Handlers
//==============================================================================

/// IPC handler: dock a groove service panel.
/// JS: gossamer.groove_dock({url: "http://localhost:6473/.well-known/groove", width: 350})
fn grooveDockHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    const payload_slice = std.mem.span(payload);
    const url = extractSimpleJsonField(payload_slice, "url") orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"missing url\"}"));
    const width_str = extractSimpleJsonField(payload_slice, "width");
    var width: u32 = 300;
    if (width_str) |ws| {
        width = std.fmt.parseInt(u32, ws, 10) catch 300;
    }

    var url_buf: [512]u8 = undefined;
    if (url.len >= url_buf.len) return @ptrCast(@constCast("{\"ok\":false,\"error\":\"url too long\"}"));
    @memcpy(url_buf[0..url.len], url);
    url_buf[url.len] = 0;

    return windowResultJson(gossamer_groove_dock(handle, url_buf[0..url.len :0], width));
}

/// IPC handler: undock the groove panel.
/// JS: gossamer.groove_undock()
fn grooveUndockHandler(_: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const handle = @intFromPtr(user_data orelse return @ptrCast(@constCast("{\"ok\":false,\"error\":\"no handle\"}")));
    return windowResultJson(gossamer_groove_undock(handle));
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

    // Groove docking (2 handlers)
    _ = gossamer_channel_bind(channel, "groove_dock", &grooveDockHandler, handle_ptr);
    _ = gossamer_channel_bind(channel, "groove_undock", &grooveUndockHandler, handle_ptr);
}

/// Register every default channel handler — the 27 window/group/transmute/
/// debug/groove handlers plus the opsm_runtime shell-exec handler — on
/// the given channel. The handle pointer is passed as user_data so the
/// window-control handlers can dispatch FFI calls without re-resolving
/// the handle from the payload.
///
/// Returns void; failures to bind individual handlers are silently
/// ignored (matching the existing pattern in cli/src/main.zig's
/// bindWindowControlHandlers — channel_bind only fails for invalid
/// channels, which the caller already handled).
pub export fn gossamer_channel_register_defaults(channel: u64, handle_ptr: ?*anyopaque) void {
    bindWindowControlHandlers(channel, handle_ptr);
    _ = gossamer_channel_bind_async(channel, "opsm_runtime", &shellExecHandler, null);
}
