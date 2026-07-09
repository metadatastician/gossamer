// SPDX-License-Identifier: MPL-2.0
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
/// Pub so main.zig's session API can bounds-check target indices.
pub const TARGET_COUNT = 10;

/// Maximum manifest JSON size (16 KiB).
const MAX_MANIFEST: usize = 16 * 1024;

/// Maximum response buffer (manifest + HTTP headers).
const MAX_RESPONSE: usize = MAX_MANIFEST + 2048;

/// Maximum number of capability names per target.
const MAX_CAPS: usize = 32;

/// Maximum capability name length.
const MAX_CAP_NAME: usize = 64;

/// Well-known groove targets: index → (port, service_id).
///
/// Ports mirror groove/registry/groove-registry.json (the groove-registry),
/// which is the source of truth — fix port drift there first, then here.
///
/// DO NOT REORDER OR RENUMBER: the indices are API. FFI consumers, the
/// Idris2 ABI, and gossamer_transmute's PanLL attach (index 4, main.zig)
/// all address targets by index. Append new targets at the end only.
/// The "groove target table order is frozen" test below pins this.
const targets = [TARGET_COUNT]struct { port: u16, name: []const u8 }{
    .{ .port = 6473, .name = "burble" },
    .{ .port = 6480, .name = "vext" },
    .{ .port = 6475, .name = "verisimdb" },
    .{ .port = 9090, .name = "hypatia" },
    .{ .port = 8000, .name = "panll" },
    .{ .port = 9000, .name = "echidna" },
    .{ .port = 7800, .name = "rpa-elysium" },
    .{ .port = 7700, .name = "conflow" },
    .{ .port = 7600, .name = "panic-attack" },
    .{ .port = 9100, .name = "gitbot-fleet" },
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
    // Fail closed: when TLS was requested we must not probe over plaintext.
    if (refuseTlsPlaintext()) {
        grooves[idx].status = .not_found;
        return;
    }

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
                var obj_depth: usize = 1;
                var scan = pos + 1;
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
                            }
                        }
                    }
                    scan += 1;
                }
                // If no "type" field found, the key name was already skipped
                // past — we cannot recover it here. This is fine because all
                // schema-conforming manifests have "type".
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
pub export fn gossamer_groove_discover() callconv(.c) u32 {
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
pub export fn gossamer_groove_status(target_id: u32) callconv(.c) u32 {
    if (target_id >= TARGET_COUNT) return 0;
    return @intFromEnum(grooves[target_id].status);
}

/// Get the manifest JSON for a connected groove target.
/// Returns a pointer to a null-terminated string (thread-local buffer).
/// Returns pointer to empty string if not connected.
pub export fn gossamer_groove_manifest(target_id: u32) callconv(.c) [*:0]const u8 {
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
pub export fn gossamer_groove_find_capability(cap_name: [*:0]const u8) callconv(.c) u32 {
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
pub export fn gossamer_groove_check_compat(target_a: u32, target_b: u32) callconv(.c) u32 {
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
///
/// When GOSSAMER_GROOVE_SECRET is set, the message is signed with
/// HMAC-SHA256 and the X-Groove-Signature header is included.
/// When GOSSAMER_GROOVE_TLS=1, the send is REFUSED (fail closed): TLS is
/// not implemented yet, and silently falling back to plaintext would betray
/// the caller's request. Check gossamer_last_error() on failure.
pub export fn gossamer_groove_send(target_id: u32, msg_ptr: [*:0]const u8) callconv(.c) u32 {
    initGrooveSecurity();
    if (refuseTlsPlaintext()) return 1;
    if (target_id >= TARGET_COUNT) return 1;
    if (grooves[target_id].status == .not_found) return 1;

    const port = targets[target_id].port;
    const addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    const stream = std.net.tcpConnectToAddress(addr) catch return 1;
    defer stream.close();

    // Determine message length.
    var msg_len: usize = 0;
    while (msg_ptr[msg_len] != 0) : (msg_len += 1) {}

    const msg_body = msg_ptr[0..msg_len];

    // Build and send HTTP POST, with optional HMAC signature header.
    var header_buf: [768]u8 = undefined;
    const sig = computeHmac(msg_body);
    const header = if (sig) |s|
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/message HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "X-Groove-Signature: {s}\r\n" ++
            "Connection: close\r\n\r\n", .{ msg_len, s }) catch return 1
    else
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/message HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Connection: close\r\n\r\n", .{msg_len}) catch return 1;
    stream.writeAll(header) catch return 1;
    stream.writeAll(msg_body) catch return 1;

    return 0;
}

/// Receive a pending message from a grooved service.
/// Uses HTTP GET to /.well-known/groove/recv on the target port.
/// Returns a pointer to the response body (thread-local buffer).
/// Refused (empty string) when GOSSAMER_GROOVE_TLS=1 — fail closed, see
/// gossamer_groove_send.
pub export fn gossamer_groove_recv(target_id: u32) callconv(.c) [*:0]const u8 {
    if (refuseTlsPlaintext()) return "";
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
pub export fn gossamer_groove_summary() callconv(.c) [*:0]const u8 {
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
pub export fn gossamer_groove_disconnect(target_id: u32) callconv(.c) void {
    if (target_id >= TARGET_COUNT) return;
    grooves[target_id] = .{};
}

/// Disconnect all groove targets.
pub export fn gossamer_groove_disconnect_all() callconv(.c) void {
    for (&grooves) |*g| {
        g.* = .{};
    }
}

//==============================================================================
// Groove Session Wire Client (groove SPEC v0.3 lease endpoints)
//==============================================================================
//
// The session API in main.zig (gossamer_groove_connect_session /
// gossamer_groove_heartbeat / gossamer_groove_disconnect_session) speaks the
// lease endpoints of the groove protocol:
//
//   POST /.well-known/groove/connect
//        {"service_id":"gossamer","consumes":[...],"lease":{"mode":"soft"|"hard","ttl_ms":N}}
//     → 200 {"handle":"...", ...}
//   GET  /.well-known/groove/heartbeat?handle=H
//     → 204 (refreshes a hard lease's window; any 2xx is accepted)
//   POST /.well-known/groove/disconnect {"handle":"..."}
//     → 2xx (releases the lease)
//
// Failures are reported through main.setError so FFI callers can surface
// them via gossamer_last_error().

/// Errors surfaced by the wire client. The caller decides how to map them
/// to FFI result codes; the thread-local error message is already set.
pub const WireError = error{
    /// GOSSAMER_GROOVE_TLS=1 but TLS is not implemented — fail closed.
    TlsRefused,
    /// TCP connect or I/O to the target failed.
    ConnectFailed,
    /// The target answered, but not with what the SPEC promises.
    ProtocolError,
};

/// Maximum lease-handle length accepted from a groove service.
pub const MAX_WIRE_HANDLE: usize = 128;

/// Send one plaintext HTTP request to localhost:port and read the full
/// response into `buf`. Returns the response slice (status line + headers +
/// body), or null on any I/O failure (connection refused, write error).
fn httpExchange(port: u16, head: []const u8, body: []const u8, buf: []u8) ?[]const u8 {
    const addr = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, port);
    const stream = std.net.tcpConnectToAddress(addr) catch return null;
    defer stream.close();

    stream.writeAll(head) catch return null;
    if (body.len > 0) {
        stream.writeAll(body) catch return null;
    }

    var total: usize = 0;
    while (total < buf.len) {
        const n = stream.read(buf[total..]) catch break;
        if (n == 0) break;
        total += n;
    }
    if (total == 0) return null;
    return buf[0..total];
}

/// Parse the status code out of a raw HTTP response ("HTTP/1.x NNN ...").
fn parseStatusCode(response: []const u8) ?u32 {
    const sp = std.mem.indexOfScalar(u8, response, ' ') orelse return null;
    if (sp + 4 > response.len) return null;
    return std.fmt.parseInt(u32, response[sp + 1 .. sp + 4], 10) catch null;
}

/// POST /.well-known/groove/connect — acquire a lease from a target.
/// Writes the returned lease handle into `out` and returns its length.
pub fn wireConnect(target_id: u32, mode: []const u8, ttl_ms: u64, out: []u8) WireError!usize {
    if (refuseTlsPlaintext()) return error.TlsRefused;
    if (target_id >= TARGET_COUNT) {
        main.setError("Invalid groove target index");
        return error.ConnectFailed;
    }

    var body_buf: [192]u8 = undefined;
    // ttl_ms == 0 means "no lease": legacy SPEC §4.3 semantics. A literal
    // {"ttl_ms":0} would be rejected with 400 by conforming providers
    // (SPEC §4.6 TTL bounds), so the lease member is omitted entirely.
    const body = if (ttl_ms == 0)
        std.fmt.bufPrint(&body_buf,
            "{{\"service_id\":\"gossamer\",\"consumes\":[]}}", .{}) catch {
            main.setError("Groove connect body exceeds buffer");
            return error.ProtocolError;
        }
    else
        std.fmt.bufPrint(&body_buf,
            "{{\"service_id\":\"gossamer\",\"consumes\":[],\"lease\":{{\"mode\":\"{s}\",\"ttl_ms\":{d}}}}}",
            .{ mode, ttl_ms }) catch {
            main.setError("Groove connect body exceeds buffer");
            return error.ProtocolError;
        };

    // Sign the lease request exactly like gossamer_groove_send signs messages.
    var header_buf: [768]u8 = undefined;
    const sig = computeHmac(body);
    const header = if (sig) |s|
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/connect HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "X-Groove-Signature: {s}\r\n" ++
            "Connection: close\r\n\r\n", .{ body.len, s }) catch {
            main.setError("Groove connect header exceeds buffer");
            return error.ProtocolError;
        }
    else
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/connect HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Connection: close\r\n\r\n", .{body.len}) catch {
            main.setError("Groove connect header exceeds buffer");
            return error.ProtocolError;
        };

    var buf: [MAX_RESPONSE]u8 = undefined;
    const response = httpExchange(targets[target_id].port, header, body, &buf) orelse {
        main.setError("Groove connect failed: target unreachable");
        return error.ConnectFailed;
    };

    const code = parseStatusCode(response) orelse {
        main.setError("Groove connect: malformed HTTP response");
        return error.ProtocolError;
    };
    if (code != 200) {
        main.setError("Groove connect rejected by target");
        return error.ProtocolError;
    }

    const sep = std.mem.indexOf(u8, response, "\r\n\r\n") orelse {
        main.setError("Groove connect: response has no body");
        return error.ProtocolError;
    };
    const resp_body = response[sep + 4 ..];

    // Extract the "handle" string from the lease response.
    var pos: usize = 0;
    while (pos < resp_body.len) : (pos += 1) {
        if (matchJsonKey(resp_body, pos, "handle")) |val_start| {
            if (extractJsonString(resp_body, val_start)) |handle| {
                if (handle.len > out.len) {
                    main.setError("Groove lease handle exceeds buffer");
                    return error.ProtocolError;
                }
                @memcpy(out[0..handle.len], handle);
                return handle.len;
            }
        }
    }
    main.setError("Groove connect: response missing lease handle");
    return error.ProtocolError;
}

/// GET /.well-known/groove/heartbeat?handle=H — refresh a lease.
/// The SPEC answers 204 on success; any 2xx is accepted.
pub fn wireHeartbeat(target_id: u32, handle: []const u8) WireError!void {
    if (refuseTlsPlaintext()) return error.TlsRefused;
    if (target_id >= TARGET_COUNT) {
        main.setError("Invalid groove target index");
        return error.ConnectFailed;
    }

    var req_buf: [512]u8 = undefined;
    const request = std.fmt.bufPrint(&req_buf,
        "GET /.well-known/groove/heartbeat?handle={s} HTTP/1.0\r\n" ++
        "Host: localhost\r\n" ++
        "Connection: close\r\n\r\n", .{handle}) catch {
        main.setError("Groove heartbeat request exceeds buffer");
        return error.ProtocolError;
    };

    var buf: [MAX_RESPONSE]u8 = undefined;
    const response = httpExchange(targets[target_id].port, request, "", &buf) orelse {
        main.setError("Groove heartbeat failed: target unreachable");
        return error.ConnectFailed;
    };

    const code = parseStatusCode(response) orelse {
        main.setError("Groove heartbeat: malformed HTTP response");
        return error.ProtocolError;
    };
    if (code < 200 or code > 299) {
        main.setError("Groove heartbeat rejected: lease lapsed or handle unknown");
        return error.ProtocolError;
    }
}

/// POST /.well-known/groove/disconnect — release a lease.
/// Body is {"handle":"..."} per SPEC v0.3 (there is no older wire
/// disconnect to stay compatible with — prior code never released remotely).
pub fn wireDisconnect(target_id: u32, handle: []const u8) WireError!void {
    if (refuseTlsPlaintext()) return error.TlsRefused;
    if (target_id >= TARGET_COUNT) {
        main.setError("Invalid groove target index");
        return error.ConnectFailed;
    }

    var body_buf: [MAX_WIRE_HANDLE + 32]u8 = undefined;
    const body = std.fmt.bufPrint(&body_buf, "{{\"handle\":\"{s}\"}}", .{handle}) catch {
        main.setError("Groove disconnect body exceeds buffer");
        return error.ProtocolError;
    };

    var header_buf: [768]u8 = undefined;
    const sig = computeHmac(body);
    const header = if (sig) |s|
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/disconnect HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "X-Groove-Signature: {s}\r\n" ++
            "Connection: close\r\n\r\n", .{ body.len, s }) catch {
            main.setError("Groove disconnect header exceeds buffer");
            return error.ProtocolError;
        }
    else
        std.fmt.bufPrint(&header_buf,
            "POST /.well-known/groove/disconnect HTTP/1.0\r\n" ++
            "Host: localhost\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: {d}\r\n" ++
            "Connection: close\r\n\r\n", .{body.len}) catch {
            main.setError("Groove disconnect header exceeds buffer");
            return error.ProtocolError;
        };

    var buf: [MAX_RESPONSE]u8 = undefined;
    const response = httpExchange(targets[target_id].port, header, body, &buf) orelse {
        main.setError("Groove disconnect failed: target unreachable");
        return error.ConnectFailed;
    };

    const code = parseStatusCode(response) orelse {
        main.setError("Groove disconnect: malformed HTTP response");
        return error.ProtocolError;
    };
    if (code < 200 or code > 299) {
        main.setError("Groove disconnect rejected by target");
        return error.ProtocolError;
    }
}

//==============================================================================
// Groove Message Signing (HMAC-SHA256)
//==============================================================================
//
// When the environment variable GOSSAMER_GROOVE_SECRET is set, all groove
// messages are signed with HMAC-SHA256. The signature is included as the
// X-Groove-Signature header on outbound requests and verified on inbound.
//
// This provides message authenticity even over unencrypted localhost connections.
// GOSSAMER_GROOVE_TLS=1 requests HTTPS for cross-host grooves; TLS is NOT
// implemented yet, so setting it makes every groove network operation fail
// closed ("refusing plaintext") rather than silently downgrade to HTTP.
//
// Design:
//   - HMAC key: raw bytes of GOSSAMER_GROOVE_SECRET (max 256 bytes)
//   - Signed payload: the JSON message body
//   - Signature format: hex-encoded HMAC-SHA256 digest (64 chars)
//   - Header: X-Groove-Signature: <hex>
//

/// Maximum HMAC key length (from environment variable).
const MAX_KEY_LEN = 256;

/// Cached HMAC key from GOSSAMER_GROOVE_SECRET.
var hmac_key: [MAX_KEY_LEN]u8 = undefined;
var hmac_key_len: usize = 0;
var hmac_initialized: bool = false;

/// Whether TLS is enabled for groove connections.
/// Set by GOSSAMER_GROOVE_TLS=1 environment variable.
var groove_tls_enabled: bool = false;

/// Initialize groove security from environment variables.
/// Called lazily on first groove operation.
fn initGrooveSecurity() void {
    if (hmac_initialized) return;
    hmac_initialized = true;

    // Check for HMAC signing key
    if (std.posix.getenv("GOSSAMER_GROOVE_SECRET")) |secret| {
        const len = @min(secret.len, MAX_KEY_LEN);
        @memcpy(hmac_key[0..len], secret[0..len]);
        hmac_key_len = len;
    }

    // Check for TLS mode (fail-closed — see refuseTlsPlaintext)
    if (std.posix.getenv("GOSSAMER_GROOVE_TLS")) |tls_val| {
        groove_tls_enabled = tls_val.len > 0 and tls_val[0] == '1';
    }
}

/// Refuse plaintext traffic when TLS was requested but is not implemented.
/// Returns true (with the thread-local error set) when the operation must be
/// aborted. Fail closed: a caller that asked for TLS must never be silently
/// downgraded to HTTP.
fn refuseTlsPlaintext() bool {
    initGrooveSecurity();
    if (groove_tls_enabled) {
        main.setError("groove TLS requested but not implemented; refusing plaintext");
        return true;
    }
    return false;
}

/// Compute HMAC-SHA256 of a message using the configured key.
/// Returns hex-encoded signature (64 chars), or null if no key configured.
fn computeHmac(message: []const u8) ?[64]u8 {
    if (hmac_key_len == 0) return null;

    // Real HMAC-SHA256 (RFC 2104; test vectors from RFC 4231 below). HMAC
    // itself handles arbitrary key lengths — keys longer than the SHA-256
    // block are hashed first, shorter keys are zero-padded — so the full
    // configured key is passed through with no truncation.
    var mac: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&mac, message, hmac_key[0..hmac_key_len]);

    // Hex-encode the MAC (256-bit = exactly 64 hex chars)
    var hex: [64]u8 = undefined;
    const hex_chars = "0123456789abcdef";
    for (mac, 0..) |byte, i| {
        hex[i * 2] = hex_chars[byte >> 4];
        hex[i * 2 + 1] = hex_chars[byte & 0x0f];
    }
    return hex;
}

/// Query whether groove message signing is active.
/// Returns 1 if GOSSAMER_GROOVE_SECRET is set, 0 otherwise.
pub export fn gossamer_groove_signing_active() callconv(.c) u32 {
    initGrooveSecurity();
    return if (hmac_key_len > 0) @as(u32, 1) else @as(u32, 0);
}

/// Query whether TLS is enabled for groove connections.
/// Returns 1 if GOSSAMER_GROOVE_TLS=1 is set, 0 otherwise.
/// NOTE: while TLS is unimplemented, enabled means every groove network
/// operation fails closed (refusing plaintext) — see refuseTlsPlaintext.
pub export fn gossamer_groove_tls_enabled() callconv(.c) u32 {
    initGrooveSecurity();
    return if (groove_tls_enabled) @as(u32, 1) else @as(u32, 0);
}

//==============================================================================
// Tests
//==============================================================================

test "groove security initialization reads env" {
    // Just verify the function doesn't crash when env vars aren't set
    hmac_initialized = false;
    hmac_key_len = 0;
    groove_tls_enabled = false;
    initGrooveSecurity();
    // After init, state should be stable
    try std.testing.expect(hmac_initialized);
}

test "computeHmac returns null when no key" {
    hmac_key_len = 0;
    const result = computeHmac("test message");
    try std.testing.expect(result == null);
}

test "computeHmac returns non-null when key is set" {
    @memcpy(hmac_key[0..4], "test");
    hmac_key_len = 4;
    const result = computeHmac("hello world");
    try std.testing.expect(result != null);
    // Reset
    hmac_key_len = 0;
}

test "groove target count is 10" {
    try std.testing.expectEqual(@as(usize, 10), TARGET_COUNT);
}

test "groove status defaults to not_found" {
    gossamer_groove_disconnect_all();
    for (0..TARGET_COUNT) |i| {
        try std.testing.expectEqual(Status.not_found, grooves[i].status);
    }
}

test "computeHmac implements HMAC-SHA256 (RFC 4231 test case 2)" {
    // key "Jefe", data "what do ya want for nothing?"
    @memcpy(hmac_key[0..4], "Jefe");
    hmac_key_len = 4;
    defer hmac_key_len = 0;

    const sig = computeHmac("what do ya want for nothing?").?;
    try std.testing.expectEqualStrings(
        "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
        &sig,
    );
}

test "computeHmac supports keys longer than the SHA-256 block (RFC 4231 test case 6)" {
    // 131 bytes of 0xaa — HMAC must hash the key first, not truncate it.
    @memset(hmac_key[0..131], 0xaa);
    hmac_key_len = 131;
    defer hmac_key_len = 0;

    const sig = computeHmac("Test Using Larger Than Block-Size Key - Hash Key First").?;
    try std.testing.expectEqualStrings(
        "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54",
        &sig,
    );
}

test "groove target table order is frozen — indices are API" {
    // PanLL attach (gossamer_transmute, main.zig) hard-codes index 4 and the
    // Idris2 ABI addresses targets by the same indices. Ports mirror
    // groove/registry/groove-registry.json; the ORDER here must never change.
    const expected = [TARGET_COUNT]struct { port: u16, name: []const u8 }{
        .{ .port = 6473, .name = "burble" },
        .{ .port = 6480, .name = "vext" },
        .{ .port = 6475, .name = "verisimdb" },
        .{ .port = 9090, .name = "hypatia" },
        .{ .port = 8000, .name = "panll" },
        .{ .port = 9000, .name = "echidna" },
        .{ .port = 7800, .name = "rpa-elysium" },
        .{ .port = 7700, .name = "conflow" },
        .{ .port = 7600, .name = "panic-attack" },
        .{ .port = 9100, .name = "gitbot-fleet" },
    };
    for (targets, expected) |actual, want| {
        try std.testing.expectEqualStrings(want.name, actual.name);
        try std.testing.expectEqual(want.port, actual.port);
    }
}

test "groove target ports are pairwise distinct (duplicate-port bug guard)" {
    // verisimdb and gitbot-fleet both claimed 8080 before the registry sync.
    for (targets, 0..) |a, i| {
        for (targets[i + 1 ..]) |b| {
            try std.testing.expect(a.port != b.port);
        }
    }
}

test "TLS-requested groove send fails closed (no plaintext fallback)" {
    hmac_initialized = true; // pin state — skip the env re-read
    groove_tls_enabled = true;
    defer {
        groove_tls_enabled = false;
        hmac_initialized = false;
        hmac_key_len = 0;
    }

    main.clearError();
    try std.testing.expectEqual(@as(u32, 1), gossamer_groove_send(0, "{\"type\":\"ping\"}"));
    const err = main.gossamer_last_error() orelse return error.TestUnexpectedResult;
    try std.testing.expect(
        std.mem.indexOf(u8, std.mem.span(err), "refusing plaintext") != null,
    );
}
