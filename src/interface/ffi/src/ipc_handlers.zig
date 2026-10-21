// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
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
extern fn gossamer_cap_check(token: u64) c_int;
extern fn gossamer_cap_resource_kind(token: u64) u32;
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
extern fn gossamer_last_error() ?[*:0]const u8;
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

/// Validate that an OPSM argument token contains only safe characters
/// (`[A-Za-z0-9._:@/-]`), does not start with `-` (no flag injection), and
/// contains no `..` traversal sequence. Tokens must contain 1–256 bytes.
fn isSafeOpsmToken(tok: []const u8) bool {
    if (tok.len == 0 or tok.len > 256) return false;
    if (tok[0] == '-') return false;
    if (std.mem.indexOf(u8, tok, "..") != null) return false;
    for (tok) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or
            (ch >= 'A' and ch <= 'Z') or
            (ch >= '0' and ch <= '9') or
            ch == '.' or ch == '_' or ch == '-' or ch == ':' or ch == '@' or ch == '/';
        if (!ok) return false;
    }
    return true;
}

threadlocal var shell_resp_buf: [65536]u8 = undefined;
threadlocal var group_resp_buf: [64]u8 = undefined;

const MAX_OPSM_SLOTS: usize = 64;

const OpsmAuthSlot = struct {
    active: bool = false,
    channel: u64 = 0,
    shell_token: u64 = 0,
};

var opsm_slots: [MAX_OPSM_SLOTS]OpsmAuthSlot = [_]OpsmAuthSlot{.{}} ** MAX_OPSM_SLOTS;
var opsm_auth_mutex: std.Thread.Mutex = .{};

/// Resolve the 64-bit Shell capability token associated with an opsm_runtime
/// callback invocation. When user_data points to an OpsmAuthSlot managed by
/// gossamer_channel_authorize_opsm, reads the full u64 token without pointer
/// truncation or alignment constraints; otherwise falls back to interpreting
/// user_data as an integer token for direct unit-test invocations.
fn resolveOpsmToken(user_data: ?*anyopaque) u64 {
    const ud = user_data orelse return 0;
    const addr = @intFromPtr(ud);
    const start = @intFromPtr(&opsm_slots[0]);
    const end = start + @sizeOf(@TypeOf(opsm_slots));
    if (addr >= start and addr < end and (addr - start) % @sizeOf(OpsmAuthSlot) == 0) {
        opsm_auth_mutex.lock();
        defer opsm_auth_mutex.unlock();
        const slot: *const OpsmAuthSlot = @ptrFromInt(addr);
        return if (slot.active) slot.shell_token else 0;
    }
    return @as(u64, addr);
}

fn clearOpsmSlotForChannel(channel: u64) void {
    opsm_auth_mutex.lock();
    defer opsm_auth_mutex.unlock();
    for (&opsm_slots) |*slot| {
        if (slot.active and slot.channel == channel) {
            slot.* = .{};
        }
    }
}

/// Accept exactly install, remove, update, list, search, or info as command names.
fn isAllowedOpsmCommand(cmd: []const u8) bool {
    return std.mem.eql(u8, cmd, "install") or
        std.mem.eql(u8, cmd, "remove") or
        std.mem.eql(u8, cmd, "update") or
        std.mem.eql(u8, cmd, "list") or
        std.mem.eql(u8, cmd, "search") or
        std.mem.eql(u8, cmd, "info");
}

/// Execute an opsm-runtime command and return stdout as a JSON-escaped string.
/// The payload is a JSON object: {"cmd":"list"} or {"cmd":"install","tool":"bun","version":"1.3.0"}
/// Returns an error object when the capability gate denies the call, cmd is
/// missing or not allowed, a cmd/tool/version token is invalid, or execution fails.
/// Commands are limited to install, remove, update, list, search, and info.
/// Blocks until the child finishes; stderr is discarded.
/// Otherwise returns output (truncated to fit a 64 KiB response buffer) and
/// exit_code, normalized to 0 for successful exit and 1 for all other terminations.
/// The result is borrowed; copy it before the next call on the same thread
/// or before thread exit.
fn shellExecHandler(payload: [*:0]const u8, user_data: ?*anyopaque) callconv(.c) [*:0]const u8 {
    const allocator = std.heap.c_allocator;
    const payload_slice = std.mem.span(payload);

    const token: u64 = resolveOpsmToken(user_data);
    if (token == 0 or gossamer_cap_check(token) != 0 or gossamer_cap_resource_kind(token) != 2) {
        return @ptrCast(@constCast("{\"error\":\"capability denied\"}"));
    }

    // Minimal JSON parsing: extract "cmd" field
    const cmd_str = extractSimpleJsonField(payload_slice, "cmd") orelse {
        return @ptrCast(@constCast("{\"error\":\"missing cmd field\"}"));
    };
    if (!isSafeOpsmToken(cmd_str) or !isAllowedOpsmCommand(cmd_str)) {
        return @ptrCast(@constCast("{\"error\":\"invalid cmd field\"}"));
    }

    const tool_str = extractSimpleJsonField(payload_slice, "tool");
    if (tool_str) |t| {
        if (!isSafeOpsmToken(t)) {
            return @ptrCast(@constCast("{\"error\":\"invalid tool field\"}"));
        }
    }

    const version_str = extractSimpleJsonField(payload_slice, "version");
    if (version_str) |v| {
        if (!isSafeOpsmToken(v)) {
            return @ptrCast(@constCast("{\"error\":\"invalid version field\"}"));
        }
    }

    // Build argv array directly (no /bin/sh -c shell interpretation)
    var argv_buf: [4][]const u8 = undefined;
    var argc: usize = 0;
    argv_buf[argc] = "opsm-runtime";
    argc += 1;
    argv_buf[argc] = cmd_str;
    argc += 1;
    if (tool_str) |t| {
        argv_buf[argc] = t;
        argc += 1;
    }
    if (version_str) |v| {
        argv_buf[argc] = v;
        argc += 1;
    }

    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv_buf[0..argc],
    }) catch {
        return @ptrCast(@constCast("{\"error\":\"exec failed\"}"));
    };
    defer allocator.free(result.stderr);

    // Wrap stdout in JSON (escape newlines)
    const stdout = result.stdout;
    defer allocator.free(stdout);

    // Build JSON response in thread-local buffer: {"output":"...","exit_code":0}
    var pos: usize = 0;
    const hdr = "{\"output\":\"";
    @memcpy(shell_resp_buf[pos..][0..hdr.len], hdr);
    pos += hdr.len;

    const max_body = shell_resp_buf.len - 32;
    for (stdout) |ch| {
        if (pos + 2 >= max_body) break;
        switch (ch) {
            '\n' => { shell_resp_buf[pos] = '\\'; shell_resp_buf[pos + 1] = 'n'; pos += 2; },
            '\r' => { shell_resp_buf[pos] = '\\'; shell_resp_buf[pos + 1] = 'r'; pos += 2; },
            '\t' => { shell_resp_buf[pos] = '\\'; shell_resp_buf[pos + 1] = 't'; pos += 2; },
            '"' => { shell_resp_buf[pos] = '\\'; shell_resp_buf[pos + 1] = '"'; pos += 2; },
            '\\' => { shell_resp_buf[pos] = '\\'; shell_resp_buf[pos + 1] = '\\'; pos += 2; },
            else => { shell_resp_buf[pos] = ch; pos += 1; },
        }
    }

    const exited_zero = switch (result.term) {
        .Exited => |code| code == 0,
        else => false,
    };
    const exit_str = if (exited_zero) "\",\"exit_code\":0}" else "\",\"exit_code\":1}";
    @memcpy(shell_resp_buf[pos..][0..exit_str.len], exit_str);
    pos += exit_str.len;
    shell_resp_buf[pos] = 0;

    return shell_resp_buf[0..pos :0];
}

/// Extract a simple string or primitive value from JSON like {"key":"value"} or {"key":1024}.
/// Returns a borrowed slice without unescaping strings or validating JSON structure.
/// Unquoted values end at whitespace, a comma, or a closing brace/bracket;
/// an unterminated quoted value extends to the end of the input.
/// Returns null when no field value is found; performs no allocations.
fn extractSimpleJsonField(json: []const u8, key: []const u8) ?[]const u8 {
    // Search for "key":
    var i: usize = 0;
    while (i + key.len + 3 <= json.len) : (i += 1) {
        if (json[i] == '"' and i + key.len + 1 < json.len) {
            if (std.mem.eql(u8, json[i + 1 ..][0..key.len], key) and
                json[i + 1 + key.len] == '"')
            {
                // Found "key" — now look for :
                var j = i + 1 + key.len + 1;
                while (j < json.len and (json[j] == ' ' or json[j] == '\t' or json[j] == '\n' or json[j] == '\r')) : (j += 1) {}
                if (j < json.len and json[j] == ':') {
                    j += 1;
                    while (j < json.len and (json[j] == ' ' or json[j] == '\t' or json[j] == '\n' or json[j] == '\r')) : (j += 1) {}
                    if (j >= json.len) return null;
                    if (json[j] == '"') {
                        j += 1;
                        const start = j;
                        while (j < json.len and json[j] != '"') : (j += 1) {
                            if (json[j] == '\\' and j + 1 < json.len) j += 1;
                        }
                        return json[start..j];
                    } else {
                        // Unquoted primitive (number / bool) or object
                        const start = j;
                        while (j < json.len and json[j] != ',' and json[j] != '}' and json[j] != ']' and
                            json[j] != ' ' and json[j] != '\t' and json[j] != '\n' and json[j] != '\r') : (j += 1)
                        {}
                        if (j > start) return json[start..j];
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
/// The optional label is truncated to 63 bytes. Returns an ok object with
/// group_id, or an error object if the group limit is reached.
/// The success response is borrowed until the next call on the same thread
/// or thread exit.
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

    // Return the group ID in the response (using thread-local buffer to avoid leak)
    const resp = std.fmt.bufPrint(group_resp_buf[0 .. group_resp_buf.len - 1], "{{\"ok\":true,\"group_id\":{d}}}", .{gid}) catch return @ptrCast(@constCast("{\"ok\":false}"));
    group_resp_buf[resp.len] = 0;
    return group_resp_buf[0..resp.len :0];
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

    const rc = gossamer_transmute(handle, mode);
    if (rc != 0) {
        // Surface the specific failure ("Illegal transmute transition:
        // gui -> panll_detach", "PanLL attach failed", ...) instead of a
        // bare result code. The message is controlled ASCII from setError —
        // no JSON escaping needed.
        if (gossamer_last_error()) |err| {
            const msg = std.fmt.bufPrint(&transmute_json_buf,
                "{{\"ok\":false,\"error\":\"{s}\"}}", .{std.mem.span(err)},
            ) catch return windowResultJson(rc);
            transmute_json_buf[msg.len] = 0;
            return transmute_json_buf[0..msg.len :0];
        }
    }
    return windowResultJson(rc);
}

/// Buffer for the formatted transmute error JSON (the returned pointer must
/// outlive the handler call; threadlocal like the FFI's own error state).
threadlocal var transmute_json_buf: [192]u8 = undefined;

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
    clearOpsmSlotForChannel(channel);
    _ = gossamer_channel_bind_async(channel, "opsm_runtime", &shellExecHandler, null);
}

/// Authorize the opsm_runtime handler on `channel` using a valid 64-bit Shell
/// capability token (`resource_kind == 2`).
///
/// Stores the full u64 token in a dedicated slot table so that 32-bit targets
/// and odd token values never suffer pointer truncation or alignment faults,
/// then rebinds `opsm_runtime` on `channel` to that slot.
///
/// Returns:
///   •  0 (ok) on success
///   • -1 (invalid_handle) if `channel == 0` or binding fails
///   • -7 (capability_denied) if `shell_token` is 0, revoked, or not a Shell capability
///   • -99 (unknown_error) if all authorization slots are exhausted
pub export fn gossamer_channel_authorize_opsm(channel: u64, shell_token: u64) callconv(.c) c_int {
    if (channel == 0) return -1;
    if (shell_token == 0 or gossamer_cap_check(shell_token) != 0 or gossamer_cap_resource_kind(shell_token) != 2) {
        return -7;
    }

    var slot_ptr: ?*OpsmAuthSlot = null;
    {
        opsm_auth_mutex.lock();
        defer opsm_auth_mutex.unlock();

        for (&opsm_slots) |*slot| {
            if (slot.active and slot.channel == channel) {
                slot.shell_token = shell_token;
                slot_ptr = slot;
                break;
            }
        }
        if (slot_ptr == null) {
            for (&opsm_slots) |*slot| {
                if (!slot.active) {
                    slot.* = .{
                        .active = true,
                        .channel = channel,
                        .shell_token = shell_token,
                    };
                    slot_ptr = slot;
                    break;
                }
            }
        }
    }

    const sp = slot_ptr orelse return -99;
    return gossamer_channel_bind_async(channel, "opsm_runtime", &shellExecHandler, @ptrCast(sp));
}

//==============================================================================
// Tests
//==============================================================================

test "gossamer_channel_authorize_opsm rejects invalid channel and non-Shell tokens" {
    try std.testing.expectEqual(@as(c_int, -1), gossamer_channel_authorize_opsm(0, 123));
    try std.testing.expectEqual(@as(c_int, -7), gossamer_channel_authorize_opsm(1, 0));
    try std.testing.expectEqual(@as(c_int, -7), gossamer_channel_authorize_opsm(1, 0xDEAD_BEEF_CAFE_0001));
}

test "resolveOpsmToken preserves full 64-bit odd token in slot and clears on register_defaults" {
    const channel: u64 = 0x1234_5678;
    const odd_64bit_token: u64 = 0xFEDC_BA98_7654_3211;
    {
        opsm_auth_mutex.lock();
        defer opsm_auth_mutex.unlock();
        opsm_slots[0] = .{
            .active = true,
            .channel = channel,
            .shell_token = odd_64bit_token,
        };
    }
    const slot_ud: ?*anyopaque = @ptrCast(&opsm_slots[0]);
    try std.testing.expectEqual(odd_64bit_token, resolveOpsmToken(slot_ud));

    clearOpsmSlotForChannel(channel);
    try std.testing.expectEqual(@as(u64, 0), resolveOpsmToken(slot_ud));
}

