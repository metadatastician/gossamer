// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Game Server Admin Bridge FFI
//
// Exports C-ABI symbols consumed by the Ephapax __ffi() intrinsic.
// Each function matches a bridge_* or utility symbol referenced in
// gossamer/examples/game-server-admin/bridge.eph.
//
// These symbols are linked into libgossamer.so and resolved at runtime
// via Ephapax's dlopen/dlsym mechanism (ephapax-interp load_ffi_library).
//
// All functions take i64 args (Ephapax FFI convention: up to 6 i64 params)
// and return i64. String arguments are passed as pointers to null-terminated
// C strings; string returns are allocated via c_allocator and must be freed
// by the caller (or, in practice, the Ephapax GC handles it).
//

const std = @import("std");

//==============================================================================
// Server Registry
//==============================================================================

/// Server entry in the registry.
const Server = struct {
    id: []const u8,
    name: []const u8,
    container: []const u8,
    port: u16,
    config: []const u8,
    format: []const u8,
};

/// Static server registry. Matches bridge.eph.
const servers = [_]Server{
    .{ .id = "barotrauma", .name = "Barotrauma", .container = "barotrauma", .port = 27015, .config = "/opt/barotrauma-game/serversettings.xml", .format = "xml" },
    .{ .id = "dst", .name = "Don't Starve Together", .container = "dst-server", .port = 10999, .config = "/opt/dst-server/DoNotStarveTogether/Cluster_1/cluster.ini", .format = "ini" },
    .{ .id = "ass", .name = "Airborne Submarine Squadron", .container = "ass-server", .port = 8081, .config = "", .format = "none" },
    .{ .id = "idaptik", .name = "IDApTIK Sync", .container = "idaptik-sync", .port = 4030, .config = "", .format = "env" },
    .{ .id = "burble", .name = "Burble", .container = "burble", .port = 4001, .config = "", .format = "env" },
    .{ .id = "voidexpanse", .name = "Void Expanse", .container = "voidexpanse", .port = 6100, .config = "/opt/voidexpanse/SettingsServer.xml", .format = "xml" },
};

/// Read GOSSAMER_VPS_HOST on POSIX systems, defaulting to localhost when unset.
/// Windows always uses localhost. The returned value is borrowed and not validated.
fn getVpsHost() []const u8 {
    if (@import("builtin").os.tag == .windows) return "localhost";
    return std.posix.getenv("GOSSAMER_VPS_HOST") orelse "localhost";
}

/// Resolve the preferred SSH binary (`GOSSAMER_SSH_BIN`, defaulting to estate `pssh`
/// with automatic fallback to `ssh` when `pssh` is not installed on PATH).
fn getSshBinary() []const u8 {
    if (@import("builtin").os.tag == .windows) return "ssh";
    if (std.posix.getenv("GOSSAMER_SSH_BIN")) |bin| {
        if (isSafeConfigIdentifier(bin) and bin[0] != '-') return bin;
    }
    return "pssh";
}

/// Return the configured VPS host (`GOSSAMER_VPS_HOST`, or `"localhost"` by default)
/// so Ephapax bridge callers and FFI helpers share a single host source of truth.
export fn bridge_get_vps_host(_: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const host = getVpsHost();
    if (!isSafeHost(host)) return allocToI64(allocator, "localhost");
    return allocToI64(allocator, host);
}

/// Accept 1–255 ASCII letters/digits or `.`, `-`, `_`, `@`, with no leading `-`.
/// Checks characters and length only.
fn isSafeHost(host: []const u8) bool {
    if (host.len == 0 or host.len > 255) return false;
    if (host[0] == '-') return false;
    for (host) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or
            (ch >= 'A' and ch <= 'Z') or
            (ch >= '0' and ch <= '9') or
            ch == '.' or ch == '-' or ch == '_' or ch == '@';
        if (!ok) return false;
    }
    return true;
}

/// Accept 1–256 ASCII letters/digits or `.`, `_`, `-` for a config token.
fn isSafeConfigIdentifier(s: []const u8) bool {
    if (s.len == 0 or s.len > 256) return false;
    for (s) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or
            (ch >= 'A' and ch <= 'Z') or
            (ch >= '0' and ch <= '9') or
            ch == '.' or ch == '_' or ch == '-';
        if (!ok) return false;
    }
    return true;
}

/// Accept 0–256 printable ASCII bytes (0x20..0x7E, including spaces and empty
/// strings) for a config value while rejecting shell, sed, and XML quote/delimiter
/// metacharacters (`'`, `"`, `` ` ``, `$`, `\`, `;`, `|`, `&`, `<`, `>`).
fn isSafeConfigValue(val: []const u8) bool {
    if (val.len > 256) return false;
    for (val) |ch| {
        if (ch < 0x20 or ch > 0x7E) return false;
        switch (ch) {
            '\'', '"', '`', '$', '\\', ';', '|', '&', '<', '>' => return false,
            else => {},
        }
    }
    return true;
}

/// Escape `/`, `&`, and `\` in a validated config value before interpolating
/// it into the RHS of a `sed` `s/.../.../` replacement expression.
fn escapeSedReplacement(allocator: std.mem.Allocator, val: []const u8) ![]u8 {
    var out = std.ArrayListUnmanaged(u8){};
    errdefer out.deinit(allocator);
    for (val) |ch| {
        if (ch == '/' or ch == '&' or ch == '\\') {
            try out.append(allocator, '\\');
        }
        try out.append(allocator, ch);
    }
    return out.toOwnedSlice(allocator);
}

/// Accept absolute paths of 1–512 bytes containing only ASCII letters/digits
/// or `/`, `.`, `-`, `_`, with no `..` substring.
fn isSafeConfigPath(p: []const u8) bool {
    if (p.len == 0 or p.len > 512) return false;
    if (p[0] != '/') return false;
    if (std.mem.indexOf(u8, p, "..") != null) return false;
    for (p) |ch| {
        const ok = (ch >= 'a' and ch <= 'z') or
            (ch >= 'A' and ch <= 'Z') or
            (ch >= '0' and ch <= '9') or
            ch == '/' or ch == '.' or ch == '-' or ch == '_';
        if (!ok) return false;
    }
    return true;
}

//==============================================================================
// SSH & PSSH Execution
//==============================================================================

/// Run an SSH/PSSH argv and convert stdout or non-zero exit status into a
/// caller-owned slice (`error: ...` on failure).
fn runRemoteArgv(allocator: std.mem.Allocator, argv: []const []const u8) ![]u8 {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });
    defer allocator.free(result.stderr);

    const exit_code: u32 = switch (result.term) {
        .Exited => |code| code,
        else => 255,
    };
    if (exit_code != 0) {
        allocator.free(result.stdout);
        return std.fmt.allocPrint(allocator, "error: remote command failed (exit {d})", .{exit_code});
    }
    return result.stdout;
}

/// Execute `cmd` on one or more hosts using `pssh` (estate standard) with
/// automatic fallback to `ssh` when `pssh` is not installed on PATH.
fn execRemoteCommandSlice(allocator: std.mem.Allocator, raw_hosts: []const u8, cmd: []const u8, prefer_pssh: bool) ?[]u8 {
    const hosts_str = if (raw_hosts.len == 0) getVpsHost() else raw_hosts;
    const trimmed_cmd = std.mem.trim(u8, cmd, " \t\r\n");
    if (trimmed_cmd.len == 0) {
        return allocator.dupe(u8, "error: empty command") catch null;
    }
    if (std.mem.startsWith(u8, trimmed_cmd, "error:")) {
        return allocator.dupe(u8, trimmed_cmd) catch null;
    }

    var hosts = std.ArrayListUnmanaged([]const u8){};
    defer hosts.deinit(allocator);

    var it = std.mem.tokenizeAny(u8, hosts_str, ", \t\r\n");
    while (it.next()) |h| {
        if (!isSafeHost(h)) {
            return allocator.dupe(u8, "error: invalid host") catch null;
        }
        hosts.append(allocator, h) catch return null;
    }
    if (hosts.items.len == 0) {
        return allocator.dupe(u8, "error: invalid host") catch null;
    }

    const ssh_bin = getSshBinary();
    const use_pssh_flags = prefer_pssh or std.mem.eql(u8, ssh_bin, "pssh") or std.mem.eql(u8, ssh_bin, "parallel-ssh") or hosts.items.len > 1;

    if (use_pssh_flags) {
        const pssh_bin = if (std.mem.eql(u8, ssh_bin, "ssh")) "pssh" else ssh_bin;
        var pssh_argv = std.ArrayListUnmanaged([]const u8){};
        defer pssh_argv.deinit(allocator);

        pssh_argv.append(allocator, pssh_bin) catch return null;
        for (hosts.items) |h| {
            pssh_argv.append(allocator, "-H") catch return null;
            pssh_argv.append(allocator, h) catch return null;
        }
        pssh_argv.appendSlice(allocator, &[_][]const u8{
            "-t",
            "5",
            "-i",
            "-O",
            "BatchMode=yes",
            "-O",
            "ConnectTimeout=5",
            "-O",
            "StrictHostKeyChecking=accept-new",
            "--",
            trimmed_cmd,
        }) catch return null;

        if (runRemoteArgv(allocator, pssh_argv.items)) |stdout| {
            return stdout;
        } else |err| {
            if (err != error.FileNotFound) {
                return std.fmt.allocPrint(allocator, "error: pssh exec failed: {}", .{err}) catch null;
            }
        }
    }

    // Fallback (or single-host OpenSSH mode): execute sequentially via `ssh`
    var combined = std.ArrayListUnmanaged(u8){};
    defer combined.deinit(allocator);

    const fallback_bin = if (std.mem.eql(u8, ssh_bin, "pssh") or std.mem.eql(u8, ssh_bin, "parallel-ssh")) "ssh" else ssh_bin;
    for (hosts.items, 0..) |host, idx| {
        const argv = [_][]const u8{
            fallback_bin,
            "-o",
            "BatchMode=yes",
            "-o",
            "ConnectTimeout=5",
            "-o",
            "StrictHostKeyChecking=accept-new",
            "--",
            host,
            trimmed_cmd,
        };
        const out = runRemoteArgv(allocator, &argv) catch |e| {
            return std.fmt.allocPrint(allocator, "error: ssh exec failed: {}", .{e}) catch null;
        };
        defer allocator.free(out);

        if (std.mem.startsWith(u8, out, "error:")) {
            return allocator.dupe(u8, out) catch null;
        }
        if (idx > 0 and combined.items.len > 0 and combined.items[combined.items.len - 1] != '\n') {
            combined.append(allocator, '\n') catch return null;
        }
        combined.appendSlice(allocator, out) catch return null;
    }

    return combined.toOwnedSlice(allocator) catch null;
}

/// Execute a command on the VPS via SSH/PSSH.
/// Args: host (i64 ptr to cstr), command (i64 ptr to cstr)
/// When `host` is empty, defaults to `getVpsHost()`. Rejects commands that are
/// empty or start with `"error:"` before spawning a process.
export fn ssh_exec(host_ptr: i64, cmd_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const host = ptrToSlice(host_ptr) orelse return allocToI64(allocator, "error: null host");
    const cmd = ptrToSlice(cmd_ptr) orelse return allocToI64(allocator, "error: null command");

    const out = execRemoteCommandSlice(allocator, host, cmd, false) orelse return 0;
    defer allocator.free(out);
    return allocToI64(allocator, out);
}

/// Execute a command across one or more hosts via estate-standard `pssh`
/// (falling back to `ssh` if `pssh` is not installed on PATH).
/// Args: hosts (i64 ptr to comma/space-separated host list cstr), command (i64 ptr to cstr)
export fn pssh_exec(hosts_ptr: i64, cmd_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const hosts = ptrToSlice(hosts_ptr) orelse return allocToI64(allocator, "error: null host");
    const cmd = ptrToSlice(cmd_ptr) orelse return allocToI64(allocator, "error: null command");

    const out = execRemoteCommandSlice(allocator, hosts, cmd, true) orelse return 0;
    defer allocator.free(out);
    return allocToI64(allocator, out);
}

//==============================================================================
// JSON Field Extraction
//==============================================================================

/// Extract a string field from a JSON object.
/// Args: json_ptr (cstr), field_ptr (cstr)
/// Returns: i64 ptr to extracted value string.
export fn json_field(json_ptr: i64, field_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const json = ptrToSlice(json_ptr) orelse return allocToI64(allocator, "");
    const field = ptrToSlice(field_ptr) orelse return allocToI64(allocator, "");

    // Search for "field":"value" pattern
    const search = std.fmt.allocPrint(allocator, "\"{s}\":\"", .{field}) catch return 0;
    defer allocator.free(search);

    const start_idx = std.mem.indexOf(u8, json, search) orelse return allocToI64(allocator, "");
    const value_start = start_idx + search.len;

    // Find closing quote
    var i: usize = value_start;
    while (i < json.len) : (i += 1) {
        if (json[i] == '"' and (i == 0 or json[i - 1] != '\\')) {
            const value = json[value_start..i];
            const result = allocator.dupeZ(u8, value) catch return 0;
            return @intCast(@intFromPtr(result.ptr));
        }
    }
    return allocToI64(allocator, "");
}

//==============================================================================
// Bridge Functions
//==============================================================================

/// List all registered servers as JSON.
export fn bridge_list_servers(_: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    var json = std.ArrayListUnmanaged(u8){};
    json.appendSlice(allocator,"[") catch return 0;

    for (servers, 0..) |s, idx| {
        if (idx > 0) json.appendSlice(allocator,",") catch return 0;
        const entry = std.fmt.allocPrint(
            allocator,
            "{{\"id\":\"{s}\",\"name\":\"{s}\",\"container\":\"{s}\",\"port\":{d},\"config\":\"{s}\",\"format\":\"{s}\"}}",
            .{ s.id, s.name, s.container, s.port, s.config, s.format },
        ) catch return 0;
        defer allocator.free(entry);
        json.appendSlice(allocator,entry) catch return 0;
    }

    json.appendSlice(allocator,"]") catch return 0;
    const result = allocator.dupeZ(u8, json.items) catch return 0;
    json.deinit(allocator);
    return @intCast(@intFromPtr(result.ptr));
}

/// Resolve a server ID to its config file path.
export fn bridge_resolve_config_path(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.config);
        }
    }
    return allocToI64(allocator, "");
}

/// Resolve a server ID to its config format.
export fn bridge_resolve_config_format(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.format);
        }
    }
    return allocToI64(allocator, "none");
}

/// Resolve a server ID to its container name.
export fn bridge_resolve_container(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.container);
        }
    }
    return allocToI64(allocator, "");
}

/// Build a sed command for the given config format.
/// Args: format, key, value, config_path (all cstr ptrs)
/// Supports xml and ini; format and key must pass isSafeConfigIdentifier,
/// value must pass isSafeConfigValue (allowing spaces and empty strings while
/// escaping sed delimiters), and config_path must pass isSafeConfigPath.
/// Does not execute the command. Returns a caller-owned c_allocator C string
/// with the command or an error for invalid parameters/unsupported formats;
/// null inputs or allocation failures return 0.
export fn bridge_build_sed(fmt_ptr: i64, key_ptr: i64, val_ptr: i64, path_ptr: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const format = ptrToSlice(fmt_ptr) orelse return 0;
    const key = ptrToSlice(key_ptr) orelse return 0;
    const value = ptrToSlice(val_ptr) orelse return 0;
    const path = ptrToSlice(path_ptr) orelse return 0;

    if (!isSafeConfigIdentifier(format) or !isSafeConfigIdentifier(key) or !isSafeConfigValue(value) or !isSafeConfigPath(path)) {
        return allocToI64(allocator, "error: invalid sed parameters");
    }

    const escaped_value = escapeSedReplacement(allocator, value) catch return 0;
    defer allocator.free(escaped_value);

    const cmd = if (std.mem.eql(u8, format, "xml"))
        // XML: sed -i 's/Key="[^"]*"/Key="NewValue"/' file
        std.fmt.allocPrint(allocator, "sed -i 's/{s}=\"[^\"]*\"/{s}=\"{s}\"/' {s}", .{ key, key, escaped_value, path })
    else if (std.mem.eql(u8, format, "ini"))
        // INI: sed -i 's/^key *=.*/key = newvalue/' file
        std.fmt.allocPrint(allocator, "sed -i 's/^{s} *=.*/{s} = {s}/' {s}", .{ key, key, escaped_value, path })
    else
        return allocToI64(allocator, "error: unsupported config format");

    const result_str = cmd catch return 0;
    const result_z = allocator.dupeZ(u8, result_str) catch return 0;
    allocator.free(result_str);
    return @intCast(@intFromPtr(result_z.ptr));
}

/// Apply a config update (`sed_cmd`) on `host` and restart `container` only if
/// the config update succeeded.
/// Args: host, sed_cmd, container, key, value (all cstr ptrs)
/// Returns a JSON status object (`{"status":"ok",...}` or `{"status":"error","error":"..."}`).
export fn bridge_apply_config_update(host_ptr: i64, sed_cmd_ptr: i64, container_ptr: i64, key_ptr: i64, val_ptr: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const host = ptrToSlice(host_ptr) orelse return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"null host\"}");
    const sed_cmd = ptrToSlice(sed_cmd_ptr) orelse return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"null sed command\"}");
    const container = ptrToSlice(container_ptr) orelse return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"null container\"}");
    const key = ptrToSlice(key_ptr) orelse return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"null key\"}");
    const value = ptrToSlice(val_ptr) orelse return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"null value\"}");

    if (!isSafeConfigIdentifier(key) or !isSafeConfigValue(value)) {
        return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"invalid key or value\"}");
    }
    if (!isSafeConfigIdentifier(container) or container[0] == '-') {
        return allocToI64(allocator, "{\"status\":\"error\",\"error\":\"invalid container identifier\"}");
    }
    if (std.mem.startsWith(u8, sed_cmd, "error:")) {
        const msg = std.fmt.allocPrint(allocator, "{{\"status\":\"error\",\"error\":\"{s}\"}}", .{sed_cmd}) catch return 0;
        defer allocator.free(msg);
        return allocToI64(allocator, msg);
    }

    const sed_out = execRemoteCommandSlice(allocator, host, sed_cmd, true) orelse return 0;
    defer allocator.free(sed_out);
    if (std.mem.startsWith(u8, sed_out, "error:")) {
        const msg = std.fmt.allocPrint(allocator, "{{\"status\":\"error\",\"error\":\"{s}\"}}", .{sed_out}) catch return 0;
        defer allocator.free(msg);
        return allocToI64(allocator, msg);
    }

    const restart_cmd = std.fmt.allocPrint(allocator, "podman restart {s}", .{container}) catch return 0;
    defer allocator.free(restart_cmd);

    const restart_out = execRemoteCommandSlice(allocator, host, restart_cmd, true) orelse return 0;
    defer allocator.free(restart_out);
    if (std.mem.startsWith(u8, restart_out, "error:")) {
        const msg = std.fmt.allocPrint(allocator, "{{\"status\":\"error\",\"error\":\"{s}\"}}", .{restart_out}) catch return 0;
        defer allocator.free(msg);
        return allocToI64(allocator, msg);
    }

    const ok_json = std.fmt.allocPrint(allocator, "{{\"status\":\"ok\",\"key\":\"{s}\",\"value\":\"{s}\"}}", .{ key, value }) catch return 0;
    defer allocator.free(ok_json);
    return allocToI64(allocator, ok_json);
}

/// Build a podman action command.
/// Args: action (cstr), container (cstr)
/// Supports start, stop, restart, status, and logs (last 50 lines).
/// The container must pass isSafeConfigIdentifier and must not start with `-`.
/// Does not execute the command. Returns a caller-owned c_allocator C string
/// with the command or an error for invalid action/container; null inputs or
/// allocation failures return 0.
export fn bridge_build_action_cmd(action_ptr: i64, container_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const action = ptrToSlice(action_ptr) orelse return 0;
    const container = ptrToSlice(container_ptr) orelse return 0;
    if (!isSafeConfigIdentifier(container) or container[0] == '-') {
        return allocToI64(allocator, "error: invalid container identifier");
    }

    const cmd = if (std.mem.eql(u8, action, "start"))
        std.fmt.allocPrint(allocator, "podman start {s}", .{container})
    else if (std.mem.eql(u8, action, "stop"))
        std.fmt.allocPrint(allocator, "podman stop {s}", .{container})
    else if (std.mem.eql(u8, action, "restart"))
        std.fmt.allocPrint(allocator, "podman restart {s}", .{container})
    else if (std.mem.eql(u8, action, "status"))
        std.fmt.allocPrint(allocator, "podman ps -a -f name=^{s}$ --format '{{{{.Status}}}}'", .{container})
    else if (std.mem.eql(u8, action, "logs"))
        std.fmt.allocPrint(allocator, "podman logs --tail 50 {s}", .{container})
    else
        return allocToI64(allocator, "error: invalid action");

    const result_str = cmd catch return 0;
    const result_z = allocator.dupeZ(u8, result_str) catch return 0;
    allocator.free(result_str);
    return @intCast(@intFromPtr(result_z.ptr));
}

/// Parse a config file into JSON key-value pairs.
/// Detects XML attributes or INI lines.
export fn bridge_parse_config(fmt_ptr: i64, content_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const format = ptrToSlice(fmt_ptr) orelse return allocToI64(allocator, "[]");
    const content = ptrToSlice(content_ptr) orelse return allocToI64(allocator, "[]");

    if (std.mem.eql(u8, format, "xml")) {
        return parseXmlAttributes(allocator, content);
    } else if (std.mem.eql(u8, format, "ini")) {
        return parseIniLines(allocator, content);
    }
    return allocToI64(allocator, "[]");
}

/// Infer types for parsed key-value pairs.
/// Input: JSON array of {"key":"...","value":"..."} objects.
/// Output: same array with "type" field added.
export fn bridge_infer_types(pairs_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    // For now, pass through — type inference is done in the overlay step
    // where we have game-specific knowledge.
    return pairs_ptr;
}

/// Overlay game-specific schema metadata.
/// Adds labels, types, ranges, and enum options based on known game schemas.
export fn bridge_overlay_schema(server_id_ptr: i64, pairs_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return pairs_ptr;
    const pairs_json = ptrToSlice(pairs_ptr) orelse return pairs_ptr;

    // For Barotrauma, enrich with known field metadata
    if (std.mem.eql(u8, server_id, "barotrauma")) {
        return overlayBarotraumaSchema(allocator, pairs_json);
    }

    // For unknown games, auto-infer types from values
    return autoInferSchema(allocator, pairs_json);
}

//==============================================================================
// Config Parsers
//==============================================================================

/// Parse XML attributes: key="value" patterns.
/// Returns JSON: [{"key":"...","value":"..."}]
fn parseXmlAttributes(allocator: std.mem.Allocator, content: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator,"[") catch return 0;

    var first = true;
    var i: usize = 0;
    while (i < content.len) {
        // Find pattern: identifier="value"
        // Skip whitespace
        while (i < content.len and (content[i] == ' ' or content[i] == '\n' or content[i] == '\r' or content[i] == '\t')) : (i += 1) {}

        // Look for key="
        const key_start = i;
        while (i < content.len and content[i] != '=' and content[i] != ' ' and content[i] != '\n' and content[i] != '<' and content[i] != '>') : (i += 1) {}

        if (i >= content.len or content[i] != '=') {
            i += 1;
            continue;
        }

        const key = content[key_start..i];
        i += 1; // skip '='

        // Expect opening quote
        if (i >= content.len or content[i] != '"') {
            continue;
        }
        i += 1; // skip '"'

        const val_start = i;
        while (i < content.len and content[i] != '"') : (i += 1) {}

        if (i >= content.len) break;

        const value = content[val_start..i];
        i += 1; // skip closing '"'

        // Skip XML-internal attributes (xmlns, version, encoding, etc.)
        if (key.len == 0) continue;
        if (std.mem.startsWith(u8, key, "<?")) continue;
        if (std.mem.eql(u8, key, "version")) continue;
        if (std.mem.eql(u8, key, "encoding")) continue;

        if (!first) result.appendSlice(allocator,",") catch return 0;
        first = false;

        const entry = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"value\":\"{s}\"}}", .{ key, value }) catch return 0;
        defer allocator.free(entry);
        result.appendSlice(allocator,entry) catch return 0;
    }

    result.appendSlice(allocator,"]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

/// Parse INI lines: key = value patterns.
fn parseIniLines(allocator: std.mem.Allocator, content: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator,"[") catch return 0;

    var first = true;
    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_section: []const u8 = "General";

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        if (trimmed[0] == '#' or trimmed[0] == ';') continue;

        // Section header [SECTION]
        if (trimmed[0] == '[' and trimmed[trimmed.len - 1] == ']') {
            current_section = trimmed[1 .. trimmed.len - 1];
            continue;
        }

        // Key = Value
        if (std.mem.indexOf(u8, trimmed, "=")) |eq_idx| {
            const key = std.mem.trim(u8, trimmed[0..eq_idx], " \t");
            const value = std.mem.trim(u8, trimmed[eq_idx + 1 ..], " \t");

            if (!first) result.appendSlice(allocator,",") catch return 0;
            first = false;

            const entry = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"value\":\"{s}\",\"group\":\"{s}\"}}", .{ key, value, current_section }) catch return 0;
            defer allocator.free(entry);
            result.appendSlice(allocator,entry) catch return 0;
        }
    }

    result.appendSlice(allocator,"]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

//==============================================================================
// Game-Specific Schema Overlays
//==============================================================================

/// Known Barotrauma field metadata.
const BaroFieldMeta = struct {
    key: []const u8,
    label: []const u8,
    field_type: []const u8,
    group: []const u8,
    min: ?i32 = null,
    max: ?i32 = null,
    options: ?[]const []const u8 = null,
};

const baro_gamemode_options = [_][]const u8{ "mission", "sandbox", "multiplayercampaign", "pvp" };
const baro_respawn_options = [_][]const u8{ "MidRound", "BetweenRounds" };
const baro_playstyle_options = [_][]const u8{ "Serious", "Casual", "Roleplay", "Rampage", "SomethingDifferent" };
const baro_losmode_options = [_][]const u8{ "None", "Transparent", "Opaque" };
const baro_botspawn_options = [_][]const u8{ "Normal", "Fill" };

const baro_fields = [_]BaroFieldMeta{
    .{ .key = "ServerName", .label = "Server Name", .field_type = "string", .group = "Server" },
    .{ .key = "password", .label = "Password", .field_type = "string", .group = "Server" },
    .{ .key = "IsPublic", .label = "Public Server", .field_type = "bool", .group = "Server" },
    .{ .key = "MaxPlayers", .label = "Max Players", .field_type = "int", .group = "Server", .min = 1, .max = 16 },
    .{ .key = "TickRate", .label = "Tick Rate", .field_type = "int", .group = "Server", .min = 10, .max = 60 },
    .{ .key = "GameModeIdentifier", .label = "Game Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_gamemode_options },
    .{ .key = "SelectedSubmarine", .label = "Submarine", .field_type = "string", .group = "Gameplay" },
    .{ .key = "SelectedShuttle", .label = "Shuttle", .field_type = "string", .group = "Gameplay" },
    .{ .key = "SelectedLevelDifficulty", .label = "Difficulty", .field_type = "int", .group = "Gameplay", .min = 0, .max = 100 },
    .{ .key = "BotCount", .label = "Bot Count", .field_type = "int", .group = "Gameplay", .min = 0, .max = 16 },
    .{ .key = "MaxBotCount", .label = "Max Bot Count", .field_type = "int", .group = "Gameplay", .min = 0, .max = 16 },
    .{ .key = "BotSpawnMode", .label = "Bot Spawn Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_botspawn_options },
    .{ .key = "RespawnMode", .label = "Respawn Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_respawn_options },
    .{ .key = "MinRespawnRatio", .label = "Min Respawn Ratio", .field_type = "float", .group = "Gameplay" },
    .{ .key = "RespawnInterval", .label = "Respawn Interval (s)", .field_type = "int", .group = "Gameplay", .min = 0, .max = 600 },
    .{ .key = "AllowFriendlyFire", .label = "Friendly Fire", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowRewiring", .label = "Allow Rewiring", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowDisguises", .label = "Allow Disguises", .field_type = "bool", .group = "Rules" },
    .{ .key = "VoiceChatEnabled", .label = "Voice Chat", .field_type = "bool", .group = "Communication" },
    .{ .key = "PlayStyle", .label = "Play Style", .field_type = "enum", .group = "Server", .options = &baro_playstyle_options },
    .{ .key = "LosMode", .label = "Line of Sight", .field_type = "enum", .group = "Gameplay", .options = &baro_losmode_options },
    .{ .key = "StartWhenClientsReady", .label = "Start When Ready", .field_type = "bool", .group = "Lobby" },
    .{ .key = "StartWhenClientsReadyRatio", .label = "Ready Ratio", .field_type = "float", .group = "Lobby" },
    .{ .key = "AllowSpectating", .label = "Allow Spectating", .field_type = "bool", .group = "Rules" },
    .{ .key = "KarmaEnabled", .label = "Karma System", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowVoteKick", .label = "Vote Kick", .field_type = "bool", .group = "Rules" },
    .{ .key = "enableupnp", .label = "UPnP", .field_type = "bool", .group = "Network" },
    .{ .key = "MaxLagCompensation", .label = "Max Lag Compensation (ms)", .field_type = "int", .group = "Network", .min = 0, .max = 500 },
};

/// Enrich Barotrauma key-value pairs (`pairs_json`) with known field metadata.
/// Uses the values already parsed in `pairs_json` so no redundant second SSH
/// read is performed when `bridge_scan_config` supplies parsed pairs; falls
/// back to fetching `/opt/barotrauma-game/serversettings.xml` via `getVpsHost`
/// only when `pairs_json` is empty (`""` or `"[]"`).
/// Returns a caller-owned, null-terminated JSON string allocated with allocator,
/// encoded as an i64 pointer, or 0 if allocation of the response fails.
fn overlayBarotraumaSchema(allocator: std.mem.Allocator, pairs_json: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator, "[") catch return 0;

    const trimmed_pairs = std.mem.trim(u8, pairs_json, " \t\r\n");
    const has_caller_pairs = trimmed_pairs.len > 2 and !std.mem.eql(u8, trimmed_pairs, "[]");

    var remote_xml: ?[]u8 = null;
    defer if (remote_xml) |xml| allocator.free(xml);

    if (!has_caller_pairs) {
        const vps_host = getVpsHost();
        if (!isSafeHost(vps_host)) {
            result.deinit(allocator);
            return allocToI64(allocator, "[]");
        }
        remote_xml = execRemoteCommandSlice(
            allocator,
            vps_host,
            "cat /opt/barotrauma-game/serversettings.xml",
            true,
        );
        if (remote_xml == null or std.mem.startsWith(u8, remote_xml.?, "error:")) {
            result.deinit(allocator);
            return allocToI64(allocator, "[]");
        }
    }

    var first = true;
    for (baro_fields) |field| {
        const current_value = if (has_caller_pairs)
            (extractPairValueFromJson(allocator, trimmed_pairs, field.key) orelse "")
        else
            (extractXmlAttribute(allocator, remote_xml.?, field.key) orelse "");

        if (!first) result.appendSlice(allocator, ",") catch return 0;
        first = false;

        // Build JSON entry with metadata
        var entry = std.ArrayListUnmanaged(u8){};
        const base = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"label\":\"{s}\",\"type\":\"{s}\",\"group\":\"{s}\",\"value\":\"{s}\"", .{ field.key, field.label, field.field_type, field.group, current_value }) catch return 0;
        defer allocator.free(base);
        entry.appendSlice(allocator, base) catch return 0;

        if (field.min) |min| {
            const min_str = std.fmt.allocPrint(allocator, ",\"min\":{d}", .{min}) catch return 0;
            defer allocator.free(min_str);
            entry.appendSlice(allocator, min_str) catch return 0;
        }
        if (field.max) |max| {
            const max_str = std.fmt.allocPrint(allocator, ",\"max\":{d}", .{max}) catch return 0;
            defer allocator.free(max_str);
            entry.appendSlice(allocator, max_str) catch return 0;
        }
        if (field.options) |options| {
            entry.appendSlice(allocator, ",\"options\":[") catch return 0;
            for (options, 0..) |opt, oi| {
                if (oi > 0) entry.appendSlice(allocator, ",") catch return 0;
                const opt_str = std.fmt.allocPrint(allocator, "\"{s}\"", .{opt}) catch return 0;
                defer allocator.free(opt_str);
                entry.appendSlice(allocator, opt_str) catch return 0;
            }
            entry.appendSlice(allocator, "]") catch return 0;
        }

        entry.appendSlice(allocator, "}") catch return 0;
        result.appendSlice(allocator, entry.items) catch return 0;
        entry.deinit(allocator);
    }

    result.appendSlice(allocator, "]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

/// Infer a primitive schema type name from a raw config string value.
fn inferValueType(val: []const u8) []const u8 {
    if (std.ascii.eqlIgnoreCase(val, "true") or std.ascii.eqlIgnoreCase(val, "false")) {
        return "bool";
    }
    if (val.len > 0) {
        var digits: usize = 0;
        var dots: usize = 0;
        var valid_num = true;
        for (val, 0..) |ch, idx| {
            if (idx == 0 and (ch == '-' or ch == '+')) continue;
            if (ch >= '0' and ch <= '9') {
                digits += 1;
            } else if (ch == '.') {
                dots += 1;
            } else {
                valid_num = false;
                break;
            }
        }
        if (valid_num and digits > 0) {
            if (dots == 0) return "int";
            if (dots == 1) return "float";
        }
    }
    return "string";
}

/// Auto-infer schema from raw key-value pairs (for unknown games).
/// Adds `"type":"bool|int|float|string"` to each object in `pairs_json`.
fn autoInferSchema(allocator: std.mem.Allocator, pairs_json: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator, "[") catch return 0;

    var first = true;
    var pos: usize = 0;
    while (std.mem.indexOfPos(u8, pairs_json, pos, "{\"key\":\"")) |obj_start| {
        const key_start = obj_start + "{\"key\":\"".len;
        const key_end = std.mem.indexOfScalarPos(u8, pairs_json, key_start, '"') orelse break;
        const key = pairs_json[key_start..key_end];

        const obj_end = std.mem.indexOfScalarPos(u8, pairs_json, key_end, '}') orelse break;
        const obj_slice = pairs_json[obj_start .. obj_end + 1];
        pos = obj_end + 1;

        var value: []const u8 = "";
        if (std.mem.indexOf(u8, obj_slice, "\"value\":\"")) |v_idx| {
            const v_start = v_idx + "\"value\":\"".len;
            if (std.mem.indexOfScalarPos(u8, obj_slice, v_start, '"')) |v_end| {
                value = obj_slice[v_start..v_end];
            }
        }

        const inferred = inferValueType(value);
        if (!first) result.appendSlice(allocator, ",") catch return 0;
        first = false;

        const entry = std.fmt.allocPrint(
            allocator,
            "{{\"key\":\"{s}\",\"value\":\"{s}\",\"type\":\"{s}\"}}",
            .{ key, value, inferred },
        ) catch return 0;
        defer allocator.free(entry);
        result.appendSlice(allocator, entry) catch return 0;
    }

    result.appendSlice(allocator, "]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

//==============================================================================
// Helpers
//==============================================================================

/// Extract the `"value"` for a matching `"key"` entry from `pairs_json`
/// (`[{"key":"...","value":"..."},...]`).
fn extractPairValueFromJson(allocator: std.mem.Allocator, pairs_json: []const u8, key: []const u8) ?[]const u8 {
    const search = std.fmt.allocPrint(allocator, "\"key\":\"{s}\"", .{key}) catch return null;
    defer allocator.free(search);

    const key_idx = std.mem.indexOf(u8, pairs_json, search) orelse return null;
    const after_key = pairs_json[key_idx + search.len ..];
    const obj_end = std.mem.indexOfScalar(u8, after_key, '}') orelse after_key.len;
    const obj_rest = after_key[0..obj_end];

    const val_marker = "\"value\":\"";
    const val_idx = std.mem.indexOf(u8, obj_rest, val_marker) orelse return null;
    const val_start = val_idx + val_marker.len;
    const val_end = std.mem.indexOfScalarPos(u8, obj_rest, val_start, '"') orelse return null;
    return obj_rest[val_start..val_end];
}

/// Extract an XML attribute value by key from raw XML content.
fn extractXmlAttribute(allocator: std.mem.Allocator, xml: []const u8, key: []const u8) ?[]const u8 {
    const search = std.fmt.allocPrint(allocator, "{s}=\"", .{key}) catch return null;
    defer allocator.free(search);

    const start_idx = std.mem.indexOf(u8, xml, search) orelse return null;
    const value_start = start_idx + search.len;

    var i: usize = value_start;
    while (i < xml.len and xml[i] != '"') : (i += 1) {}
    if (i >= xml.len) return null;

    return xml[value_start..i];
}

/// Convert a i64 (Ephapax FFI convention) to a slice by treating it as a C string pointer.
fn ptrToSlice(val: i64) ?[]const u8 {
    if (val == 0) return null;
    const ptr: [*:0]const u8 = @ptrFromInt(@as(usize, @intCast(val)));
    return std.mem.span(ptr);
}

/// Allocate a null-terminated copy of a string and return as i64 pointer.
fn allocToI64(allocator: std.mem.Allocator, str: []const u8) i64 {
    const z = allocator.dupeZ(u8, str) catch return 0;
    return @intCast(@intFromPtr(z.ptr));
}

//==============================================================================
// Tests
//==============================================================================

fn cstrToI64(s: [*:0]const u8) i64 {
    return @intCast(@intFromPtr(s));
}

test "bridge_build_sed accepts spaces and empty values and escapes slashes" {
    const xml_cmd_ptr = bridge_build_sed(
        cstrToI64("xml"),
        cstrToI64("ServerName"),
        cstrToI64("My Submarine Server / EU"),
        cstrToI64("/opt/barotrauma-game/serversettings.xml"),
        0,
        0,
    );
    const xml_cmd = ptrToSlice(xml_cmd_ptr).?;
    defer std.heap.c_allocator.free(xml_cmd[0 .. xml_cmd.len + 1]);
    try std.testing.expectEqualStrings(
        "sed -i 's/ServerName=\"[^\"]*\"/ServerName=\"My Submarine Server \\/ EU\"/' /opt/barotrauma-game/serversettings.xml",
        xml_cmd,
    );

    const empty_cmd_ptr = bridge_build_sed(
        cstrToI64("xml"),
        cstrToI64("password"),
        cstrToI64(""),
        cstrToI64("/opt/barotrauma-game/serversettings.xml"),
        0,
        0,
    );
    const empty_cmd = ptrToSlice(empty_cmd_ptr).?;
    defer std.heap.c_allocator.free(empty_cmd[0 .. empty_cmd.len + 1]);
    try std.testing.expectEqualStrings(
        "sed -i 's/password=\"[^\"]*\"/password=\"\"/' /opt/barotrauma-game/serversettings.xml",
        empty_cmd,
    );

    const bad_cmd_ptr = bridge_build_sed(
        cstrToI64("xml"),
        cstrToI64("ServerName"),
        cstrToI64("bad'quote"),
        cstrToI64("/opt/barotrauma-game/serversettings.xml"),
        0,
        0,
    );
    const bad_cmd = ptrToSlice(bad_cmd_ptr).?;
    defer std.heap.c_allocator.free(bad_cmd[0 .. bad_cmd.len + 1]);
    try std.testing.expectEqualStrings("error: invalid sed parameters", bad_cmd);
}

test "overlayBarotraumaSchema enriches caller pairs_json without SSH" {
    const pairs = "[{\"key\":\"ServerName\",\"value\":\"Deep Europa\"},{\"key\":\"MaxPlayers\",\"value\":\"12\"}]";
    const out_ptr = bridge_overlay_schema(cstrToI64("barotrauma"), cstrToI64(pairs), 0, 0, 0, 0);
    const out_str = ptrToSlice(out_ptr).?;
    defer std.heap.c_allocator.free(out_str[0 .. out_str.len + 1]);

    try std.testing.expect(std.mem.indexOf(u8, out_str, "\"key\":\"ServerName\",\"label\":\"Server Name\",\"type\":\"string\",\"group\":\"Server\",\"value\":\"Deep Europa\"") != null);
    try std.testing.expect(std.mem.indexOf(u8, out_str, "\"key\":\"MaxPlayers\",\"label\":\"Max Players\",\"type\":\"int\",\"group\":\"Server\",\"value\":\"12\",\"min\":1,\"max\":16") != null);
}

test "autoInferSchema infers bool, int, float, and string types" {
    const pairs = "[{\"key\":\"pvp\",\"value\":\"True\"},{\"key\":\"max_players\",\"value\":\"16\"},{\"key\":\"ratio\",\"value\":\"0.75\"},{\"key\":\"cluster_name\",\"value\":\"World 1\"}]";
    const out_ptr = bridge_overlay_schema(cstrToI64("dst"), cstrToI64(pairs), 0, 0, 0, 0);
    const out_str = ptrToSlice(out_ptr).?;
    defer std.heap.c_allocator.free(out_str[0 .. out_str.len + 1]);

    try std.testing.expect(std.mem.indexOf(u8, out_str, "{\"key\":\"pvp\",\"value\":\"True\",\"type\":\"bool\"}") != null);
    try std.testing.expect(std.mem.indexOf(u8, out_str, "{\"key\":\"max_players\",\"value\":\"16\",\"type\":\"int\"}") != null);
    try std.testing.expect(std.mem.indexOf(u8, out_str, "{\"key\":\"ratio\",\"value\":\"0.75\",\"type\":\"float\"}") != null);
    try std.testing.expect(std.mem.indexOf(u8, out_str, "{\"key\":\"cluster_name\",\"value\":\"World 1\",\"type\":\"string\"}") != null);
}

test "pssh_exec and bridge_apply_config_update reject error commands and invalid hosts without spawning" {
    const err_out_ptr = pssh_exec(cstrToI64("localhost"), cstrToI64("error: invalid sed parameters"), 0, 0, 0, 0);
    const err_out = ptrToSlice(err_out_ptr).?;
    defer std.heap.c_allocator.free(err_out[0 .. err_out.len + 1]);
    try std.testing.expectEqualStrings("error: invalid sed parameters", err_out);

    const bad_host_ptr = pssh_exec(cstrToI64("-oProxyCommand=evil"), cstrToI64("cat /opt/barotrauma-game/serversettings.xml"), 0, 0, 0, 0);
    const bad_host = ptrToSlice(bad_host_ptr).?;
    defer std.heap.c_allocator.free(bad_host[0 .. bad_host.len + 1]);
    try std.testing.expectEqualStrings("error: invalid host", bad_host);

    const update_err_ptr = bridge_apply_config_update(
        cstrToI64("localhost"),
        cstrToI64("error: invalid sed parameters"),
        cstrToI64("barotrauma"),
        cstrToI64("ServerName"),
        cstrToI64("Europa"),
        0,
    );
    const update_err = ptrToSlice(update_err_ptr).?;
    defer std.heap.c_allocator.free(update_err[0 .. update_err.len + 1]);
    try std.testing.expect(std.mem.indexOf(u8, update_err, "\"status\":\"error\"") != null);
}

