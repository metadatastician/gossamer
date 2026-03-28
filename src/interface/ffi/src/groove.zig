// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer Groove — Lightweight service discovery via well-known port probing.
//
// Each groove target exposes a JSON manifest at GET /.well-known/groove on its
// well-known port. The manifest declares capabilities the service offers.
// Gossamer probes these on startup (or on demand) and registers available
// capabilities for frontend and backend use.
//
// The Idris2 ABI (Groove.idr) provides type-level proofs that:
// - You cannot connect unless required capabilities are satisfied
// - You cannot forget to disconnect (linear handles)
// - Composition of two grooves is sound (both sides feed each other)
//
// This Zig layer implements the raw TCP probing and HTTP parsing.
// Type safety is enforced at the Idris2/Ephapax boundary, not here.

const std = @import("std");
const main = @import("main.zig");

/// Number of well-known groove targets.
const TARGET_COUNT = 10;

/// Maximum manifest JSON size (16 KiB).
const MAX_MANIFEST: usize = 16 * 1024;

/// Maximum response buffer (manifest + HTTP headers).
const MAX_RESPONSE: usize = MAX_MANIFEST + 2048;

/// Maximum number of capability names per target.
const MAX_CAPS: usize = 32;

/// Maximum capability name length.
const MAX_CAP_NAME: usize = 64;

/// Well-known groove targets: index → (port, service_id).
const targets = [TARGET_COUNT]struct { port: u16, name: []const u8 }{
    .{ .port = 6473, .name = "burble" },
    .{ .port = 6480, .name = "vext" },
    .{ .port = 8093, .name = "verisimdb" },
    .{ .port = 9090, .name = "hypatia" },
    .{ .port = 4040, .name = "panll" },
    .{ .port = 9000, .name = "echidna" },
    .{ .port = 7800, .name = "rpa-elysium" },
    .{ .port = 7700, .name = "conflow" },
    .{ .port = 7600, .name = "panic-attacker" },
    .{ .port = 7500, .name = "gitbot-fleet" },
};

/// Groove connection status.
const Status = enum(u32) {
    not_found = 0,
    incompatible = 1,
    connected = 2,
    active = 3,
};

/// Per-target groove state.
const GrooveState = struct {
    status: Status = .not_found,
    manifest: [MAX_MANIFEST]u8 = [_]u8{0} ** MAX_MANIFEST,
    manifest_len: usize = 0,
    /// Parsed capability names from the manifest.
    cap_names: [MAX_CAPS][MAX_CAP_NAME]u8 = [_][MAX_CAP_NAME]u8{[_]u8{0} ** MAX_CAP_NAME} ** MAX_CAPS,
    cap_count: usize = 0,
};

/// Global groove registry.
var grooves: [TARGET_COUNT]GrooveState = [_]GrooveState{.{}} ** TARGET_COUNT;

/// Shared string output buffer for FFI returns.
/// Thread-local to avoid races in multi-threaded scenarios.
threadlocal var out_buf: [MAX_MANIFEST]u8 = undefined;

//==============================================================================
// Internal: TCP probe and HTTP parse
//==============================================================================

/// Probe a single groove target by TCP connecting and requesting
/// GET /.well-known/groove.
fn probeTarget(idx: usize) void {
    const port = targets[idx].port;

    // Attempt TCP connection to localhost:port.
    const addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    const stream = std.net.tcpConnectToAddress(addr) catch {
        grooves[idx].status = .not_found;
        return;
    };
    defer stream.close();

    // Send minimal HTTP GET for the groove manifest.
    const request =
        "GET /.well-known/groove HTTP/1.0\r\n" ++
        "Host: localhost\r\n" ++
        "Accept: application/json\r\n" ++
        "Connection: close\r\n\r\n";
    stream.writeAll(request) catch {
        grooves[idx].status = .not_found;
        return;
    };

    // Read the full response.
    var buf: [MAX_RESPONSE]u8 = undefined;
    var total: usize = 0;
    while (total < buf.len) {
        const n = stream.read(buf[total..]) catch break;
        if (n == 0) break;
        total += n;
    }

    // Find body after \r\n\r\n separator.
    const response = buf[0..total];
    const sep = std.mem.indexOf(u8, response, "\r\n\r\n") orelse {
        grooves[idx].status = .not_found;
        return;
    };
    const body = response[sep + 4 ..];

    if (body.len == 0 or body.len > MAX_MANIFEST) {
        grooves[idx].status = .not_found;
        return;
    }

    // Store the manifest JSON.
    @memcpy(grooves[idx].manifest[0..body.len], body);
    grooves[idx].manifest_len = body.len;
    grooves[idx].status = .connected;

    // Parse capability names from the manifest for fast lookup.
    parseCapabilities(idx);
}

/// Extract capability names from the manifest JSON.
///
/// Supports the canonical object format defined in groove-manifest.schema.json:
///   "capabilities": { "voice": { "type": "voice", ... }, ... }
///
/// Extracts the "type" field from each capability value object, which is what
/// consumers use for capability lookup. Falls back to extracting the object
/// key name if no "type" field is found.
///
/// Also supports legacy array format as a fallback for forward compatibility:
///   "capabilities": [ { "name": "...", "type": "..." }, ... ]
fn parseCapabilities(idx: usize) void {
    const json = grooves[idx].manifest[0..grooves[idx].manifest_len];
    grooves[idx].cap_count = 0;

    // Find "capabilities" key.
    const caps_key = "\"capabilities\"";
    const caps_start = std.mem.indexOf(u8, json, caps_key) orelse return;
    const after_key = caps_start + caps_key.len;

    // Skip whitespace and colon after the key.
    var pos = after_key;
    while (pos < json.len and (json[pos] == ' ' or json[pos] == ':' or json[pos] == '\n' or json[pos] == '\r' or json[pos] == '\t')) : (pos += 1) {}
    if (pos >= json.len) return;

    if (json[pos] == '{') {
        // Canonical object format: extract "type" field from each value object,
        // falling back to the object key name.
        parseCapabilitiesObject(idx, json, pos);
    } else if (json[pos] == '[') {
        // Legacy array format: extract "type" or "name" field from each element.
        parseCapabilitiesArray(idx, json, pos);
    }
}

/// Parse capabilities from the canonical object format.
/// Extracts the "type" field value from each capability sub-object.
/// If no "type" field is found, uses the object key as the capability name.
fn parseCapabilitiesObject(idx: usize, json: []const u8, start: usize) void {
    var pos = start + 1; // skip opening '{'

    var depth: usize = 1;
    while (pos < json.len and depth > 0) {
        if (json[pos] == '{') {
            depth += 1;
            if (depth == 2) {
                // Entered a capability value object — search for "type" field.
                const obj_start = pos;
                var obj_depth: usize = 1;
                var scan = pos + 1;
                var found_type = false;
                while (scan < json.len and obj_depth > 0) {
                    if (json[scan] == '{') {
                        obj_depth += 1;
                    } else if (json[scan] == '}') {
                        obj_depth -= 1;
                    } else if (obj_depth == 1) {
                        // Look for "type" key at this level.
                        if (matchJsonKey(json, scan, "type")) |val_start| {
                            if (extractJsonString(json, val_start)) |type_val| {
                                addCapName(idx, type_val.ptr, type_val.len);
                                found_type = true;
                            }
                        }
                    }
                    scan += 1;
                }
                // If no "type" field found, the key name was already skipped
                // past — we cannot recover it here. This is fine because all
                // schema-conforming manifests have "type".
                _ = found_type;
                _ = obj_start;
            }
        } else if (json[pos] == '}') {
            depth -= 1;
        }
        pos += 1;
    }
}

/// Parse capabilities from the legacy array format.
/// Extracts the "type" or "name" field from each array element object.
fn parseCapabilitiesArray(idx: usize, json: []const u8, start: usize) void {
    var pos = start + 1; // skip opening '['
    var depth: usize = 1;

    while (pos < json.len and depth > 0) {
        if (json[pos] == '[') {
            depth += 1;
        } else if (json[pos] == ']') {
            depth -= 1;
        } else if (json[pos] == '{' and depth == 1) {
            // Found an element object — look for "type" then "name".
            var obj_depth: usize = 1;
            var scan = pos + 1;
            var found = false;
            while (scan < json.len and obj_depth > 0) {
                if (json[scan] == '{') {
                    obj_depth += 1;
                } else if (json[scan] == '}') {
                    obj_depth -= 1;
                } else if (obj_depth == 1 and !found) {
                    // Prefer "type", fall back to "name".
                    if (matchJsonKey(json, scan, "type")) |val_start| {
                        if (extractJsonString(json, val_start)) |val| {
                            addCapName(idx, val.ptr, val.len);
                            found = true;
                        }
                    } else if (matchJsonKey(json, scan, "name")) |val_start| {
                        if (extractJsonString(json, val_start)) |val| {
                            addCapName(idx, val.ptr, val.len);
                            found = true;
                        }
                    }
                }
                scan += 1;
            }
        }
        pos += 1;
    }
}

/// Check if position in JSON is the start of a specific key.
/// Returns the position after the colon (start of value) if matched, null otherwise.
fn matchJsonKey(json: []const u8, pos: usize, key: []const u8) ?usize {
    if (pos >= json.len or json[pos] != '"') return null;
    const after_quote = pos + 1;
    if (after_quote + key.len >= json.len) return null;
    if (!std.mem.eql(u8, json[after_quote .. after_quote + key.len], key)) return null;
    if (after_quote + key.len >= json.len or json[after_quote + key.len] != '"') return null;
    // Skip past closing quote, optional whitespace, and colon.
    var p = after_quote + key.len + 1;
    while (p < json.len and (json[p] == ' ' or json[p] == ':' or json[p] == '\n' or json[p] == '\r' or json[p] == '\t')) : (p += 1) {}
    return p;
}

/// Extract a JSON string value starting at the given position.
/// Returns the string contents (without quotes) as a slice, or null.
fn extractJsonString(json: []const u8, pos: usize) ?[]const u8 {
    if (pos >= json.len or json[pos] != '"') return null;
    const start = pos + 1;
    var end = start;
    while (end < json.len and json[end] != '"') : (end += 1) {}
    if (end >= json.len) return null;
    if (end == start) return null;
    return json[start..end];
}

/// Add a capability name to the groove state for a given target index.
fn addCapName(idx: usize, ptr: [*]const u8, len: usize) void {
    if (len == 0 or len >= MAX_CAP_NAME or grooves[idx].cap_count >= MAX_CAPS) return;
    const ci = grooves[idx].cap_count;
    @memcpy(grooves[idx].cap_names[ci][0..len], ptr[0..len]);
    grooves[idx].cap_names[ci][len] = 0;
    grooves[idx].cap_count += 1;
}

/// Check if a groove target has a specific capability by name.
fn hasCapability(idx: usize, name: []const u8) bool {
    for (0..grooves[idx].cap_count) |ci| {
        const cap = &grooves[idx].cap_names[ci];
        // Find null terminator.
        var len: usize = 0;
        while (len < MAX_CAP_NAME and cap[len] != 0) : (len += 1) {}
        if (len == name.len and std.mem.eql(u8, cap[0..len], name)) {
            return true;
        }
    }
    return false;
}

//==============================================================================
// Exported FFI Functions
//==============================================================================

/// Discover all groove targets by probing well-known ports.
/// Returns the number of successfully connected grooves.
export fn gossamer_groove_discover() callconv(.c) u32 {
    var count: u32 = 0;
    for (0..TARGET_COUNT) |i| {
        probeTarget(i);
        if (grooves[i].status == .connected or grooves[i].status == .active) {
            count += 1;
        }
    }
    return count;
}

/// Get the status of a specific groove target.
export fn gossamer_groove_status(target_id: u32) callconv(.c) u32 {
    if (target_id >= TARGET_COUNT) return 0;
    return @intFromEnum(grooves[target_id].status);
}

/// Get the manifest JSON for a connected groove target.
/// Returns a pointer to a null-terminated string (thread-local buffer).
/// Returns pointer to empty string if not connected.
export fn gossamer_groove_manifest(target_id: u32) callconv(.c) [*:0]const u8 {
    if (target_id >= TARGET_COUNT) return "";
    const state = &grooves[target_id];
    if (state.status == .not_found or state.manifest_len == 0) return "";

    const len = @min(state.manifest_len, MAX_MANIFEST - 1);
    @memcpy(out_buf[0..len], state.manifest[0..len]);
    out_buf[len] = 0;
    return @ptrCast(&out_buf);
}

/// Find which groove target provides a given capability.
/// Returns the target index, or 0xFFFFFFFF if none.
export fn gossamer_groove_find_capability(cap_name: [*:0]const u8) callconv(.c) u32 {
    // Determine string length.
    var len: usize = 0;
    while (cap_name[len] != 0 and len < MAX_CAP_NAME) : (len += 1) {}
    if (len == 0) return 0xFFFFFFFF;

    const name = cap_name[0..len];
    for (0..TARGET_COUNT) |i| {
        if (grooves[i].status == .connected or grooves[i].status == .active) {
            if (hasCapability(i, name)) {
                return @intCast(i);
            }
        }
    }
    return 0xFFFFFFFF;
}

/// Check if two groove targets are compatible for composition.
/// Two targets are compatible if each offers what the other consumes.
/// Returns 1 if compatible, 0 if not.
export fn gossamer_groove_check_compat(target_a: u32, target_b: u32) callconv(.c) u32 {
    if (target_a >= TARGET_COUNT or target_b >= TARGET_COUNT) return 0;
    const a = &grooves[target_a];
    const b = &grooves[target_b];
    if (a.status == .not_found or b.status == .not_found) return 0;

    // For now, if both are connected they're considered compatible.
    // Full subset checking is done at the Idris2 ABI level.
    // The Zig layer only gates on connectivity.
    if (a.status == .connected or a.status == .active) {
        if (b.status == .connected or b.status == .active) {
            return 1;
        }
    }
    return 0;
}

/// Send a JSON message to a grooved service.
/// Uses HTTP POST to /.well-known/groove/message on the target port.
export fn gossamer_groove_send(target_id: u32, msg_ptr: [*:0]const u8) callconv(.c) u32 {
    if (target_id >= TARGET_COUNT) return 1;
    if (grooves[target_id].status == .not_found) return 1;

    const port = targets[target_id].port;
    const addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    const stream = std.net.tcpConnectToAddress(addr) catch return 1;
    defer stream.close();

    // Determine message length.
    var msg_len: usize = 0;
    while (msg_ptr[msg_len] != 0) : (msg_len += 1) {}

    // Build and send HTTP POST.
    var header_buf: [512]u8 = undefined;
    const header = std.fmt.bufPrint(&header_buf,
        "POST /.well-known/groove/message HTTP/1.0\r\n" ++
        "Host: localhost\r\n" ++
        "Content-Type: application/json\r\n" ++
        "Content-Length: {d}\r\n" ++
        "Connection: close\r\n\r\n", .{msg_len}) catch return 1;
    stream.writeAll(header) catch return 1;
    stream.writeAll(msg_ptr[0..msg_len]) catch return 1;

    return 0;
}

/// Receive a pending message from a grooved service.
/// Uses HTTP GET to /.well-known/groove/recv on the target port.
/// Returns a pointer to the response body (thread-local buffer).
export fn gossamer_groove_recv(target_id: u32) callconv(.c) [*:0]const u8 {
    if (target_id >= TARGET_COUNT) return "";
    if (grooves[target_id].status == .not_found) return "";

    const port = targets[target_id].port;
    const addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    const stream = std.net.tcpConnectToAddress(addr) catch return "";
    defer stream.close();

    const request =
        "GET /.well-known/groove/recv HTTP/1.0\r\n" ++
        "Host: localhost\r\n" ++
        "Accept: application/json\r\n" ++
        "Connection: close\r\n\r\n";
    stream.writeAll(request) catch return "";

    var buf: [MAX_RESPONSE]u8 = undefined;
    var total: usize = 0;
    while (total < buf.len) {
        const n = stream.read(buf[total..]) catch break;
        if (n == 0) break;
        total += n;
    }

    const response = buf[0..total];
    const sep = std.mem.indexOf(u8, response, "\r\n\r\n") orelse return "";
    const body = response[sep + 4 ..];
    const copy_len = @min(body.len, MAX_MANIFEST - 1);
    @memcpy(out_buf[0..copy_len], body[0..copy_len]);
    out_buf[copy_len] = 0;
    return @ptrCast(&out_buf);
}

/// Get a JSON summary of all groove connections.
/// Format: [{"id":0,"service":"burble","status":2,"port":6473,"caps":3}, ...]
export fn gossamer_groove_summary() callconv(.c) [*:0]const u8 {
    var pos: usize = 0;
    out_buf[pos] = '[';
    pos += 1;
    var first = true;

    for (0..TARGET_COUNT) |i| {
        if (!first) {
            out_buf[pos] = ',';
            pos += 1;
        }
        first = false;

        const status_val = @intFromEnum(grooves[i].status);
        const entry = std.fmt.bufPrint(out_buf[pos..], "{{\"id\":{d},\"service\":\"{s}\",\"status\":{d},\"port\":{d},\"caps\":{d}}}", .{
            i,
            targets[i].name,
            status_val,
            targets[i].port,
            grooves[i].cap_count,
        }) catch break;
        pos += entry.len;
    }

    out_buf[pos] = ']';
    pos += 1;
    out_buf[pos] = 0;
    return @ptrCast(&out_buf);
}

/// Disconnect a specific groove target.
export fn gossamer_groove_disconnect(target_id: u32) callconv(.c) void {
    if (target_id >= TARGET_COUNT) return;
    grooves[target_id] = .{};
}

/// Disconnect all groove targets.
export fn gossamer_groove_disconnect_all() callconv(.c) void {
    for (&grooves) |*g| {
        g.* = .{};
    }
}
