// Gossamer Integration Tests
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// These tests verify that the Zig FFI correctly implements the Idris2 ABI.
// They exercise the exported C API surface without requiring a display server
// (headless — no GTK/WebKit needed).

const std = @import("std");
const testing = std.testing;

// Import the Gossamer FFI via the main module
const gossamer = @import("../src/main.zig");
const Result = gossamer.Result;

//==============================================================================
// Result Code Alignment Tests
//==============================================================================

test "result codes match Idris2 ABI (Types.idr resultToInt)" {
    // Each value must match Types.idr exactly — any mismatch breaks the ABI
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(Result.ok));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(Result.@"error"));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(Result.invalid_param));
    try testing.expectEqual(@as(c_int, 3), @intFromEnum(Result.out_of_memory));
    try testing.expectEqual(@as(c_int, 4), @intFromEnum(Result.null_pointer));
    try testing.expectEqual(@as(c_int, 5), @intFromEnum(Result.already_consumed));
    try testing.expectEqual(@as(c_int, 6), @intFromEnum(Result.resource_leaked));
    try testing.expectEqual(@as(c_int, 7), @intFromEnum(Result.double_free));
    try testing.expectEqual(@as(c_int, 8), @intFromEnum(Result.webview_unavailable));
    try testing.expectEqual(@as(c_int, 9), @intFromEnum(Result.ipc_protocol_error));
    try testing.expectEqual(@as(c_int, 10), @intFromEnum(Result.capability_denied));
}

test "result enum has exactly 11 variants" {
    // Ensures no accidental additions/removals without updating Types.idr
    const fields = @typeInfo(Result).@"enum".fields;
    try testing.expectEqual(@as(usize, 11), fields.len);
}

//==============================================================================
// Version & Build Info Tests
//==============================================================================

test "version string is semantic version format" {
    const ver = gossamer.gossamer_version();
    const ver_str = std.mem.span(ver);

    // Must be "X.Y.Z" format
    try testing.expectEqualStrings("0.1.0", ver_str);
}

test "build info string contains version" {
    const info = gossamer.gossamer_build_info();
    const info_str = std.mem.span(info);

    // Build info should mention Gossamer and the version
    try testing.expect(std.mem.indexOf(u8, info_str, "Gossamer") != null);
    try testing.expect(std.mem.indexOf(u8, info_str, "0.1.0") != null);
}

//==============================================================================
// Null Handle Safety Tests
//==============================================================================

test "load_html with null handle returns null_pointer" {
    const result = gossamer.gossamer_load_html(0, "");
    try testing.expectEqual(Result.null_pointer, result);
}

test "navigate with null handle returns null_pointer" {
    const result = gossamer.gossamer_navigate(0, "");
    try testing.expectEqual(Result.null_pointer, result);
}

test "eval with null handle returns null_pointer" {
    const result = gossamer.gossamer_eval(0, "");
    try testing.expectEqual(Result.null_pointer, result);
}

test "set_title with null handle returns null_pointer" {
    const result = gossamer.gossamer_set_title(0, "");
    try testing.expectEqual(Result.null_pointer, result);
}

test "resize with null handle returns null_pointer" {
    const result = gossamer.gossamer_resize(0, 800, 600);
    try testing.expectEqual(Result.null_pointer, result);
}

test "run with null handle is safe (no-op)" {
    // gossamer_run(0) must not crash — just return
    gossamer.gossamer_run(0);
}

test "destroy with null handle is safe (no-op)" {
    // gossamer_destroy(0) must not crash — just return
    gossamer.gossamer_destroy(0);
}

//==============================================================================
// IPC Channel Tests (Null Safety)
//==============================================================================

test "channel_open with null handle returns 0" {
    const channel = gossamer.gossamer_channel_open(0);
    try testing.expectEqual(@as(u64, 0), channel);
}

test "channel_bind with null channel returns null_pointer" {
    const result = gossamer.gossamer_channel_bind(0, "test", null, null);
    try testing.expectEqual(Result.null_pointer, result);
}

test "channel_close with null channel is safe (no-op)" {
    gossamer.gossamer_channel_close(0);
}

//==============================================================================
// Capability Lifecycle Tests
//==============================================================================

test "cap_grant returns non-zero token for valid resource kinds" {
    // Test all 6 valid resource kinds (0..5 per Types.idr ResourceKind)
    var tokens: [6]u64 = undefined;
    for (0..6) |i| {
        tokens[i] = gossamer.gossamer_cap_grant(@intCast(i));
        try testing.expect(tokens[i] != 0);
    }
    // Clean up
    for (tokens) |t| gossamer.gossamer_cap_revoke(t);
}

test "cap_grant rejects invalid resource kind" {
    // Resource kinds > 5 are invalid (Types.idr has 6 constructors: 0-5)
    try testing.expectEqual(@as(u64, 0), gossamer.gossamer_cap_grant(6));
    try testing.expectEqual(@as(u64, 0), gossamer.gossamer_cap_grant(255));
}

test "cap_check succeeds for active token" {
    const token = gossamer.gossamer_cap_grant(0); // FileSystem
    try testing.expect(token != 0);

    const result = gossamer.gossamer_cap_check(token);
    try testing.expectEqual(Result.ok, result);

    gossamer.gossamer_cap_revoke(token);
}

test "cap_check fails for zero token" {
    try testing.expectEqual(Result.capability_denied, gossamer.gossamer_cap_check(0));
}

test "cap_check fails after revocation" {
    const token = gossamer.gossamer_cap_grant(1); // Network
    gossamer.gossamer_cap_revoke(token);

    // Token should be denied after revocation
    try testing.expectEqual(Result.capability_denied, gossamer.gossamer_cap_check(token));
}

test "cap_resource_kind returns correct kind" {
    const token = gossamer.gossamer_cap_grant(3); // Clipboard
    try testing.expectEqual(@as(u32, 3), gossamer.gossamer_cap_resource_kind(token));
    gossamer.gossamer_cap_revoke(token);
}

test "cap_resource_kind returns 0xFFFFFFFF for invalid token" {
    try testing.expectEqual(@as(u32, 0xFFFFFFFF), gossamer.gossamer_cap_resource_kind(0));
}

test "cap_revoke with zero token is safe (no-op)" {
    gossamer.gossamer_cap_revoke(0);
}

//==============================================================================
// Error Message Tests
//==============================================================================

test "last_error set after null handle operation" {
    _ = gossamer.gossamer_load_html(0, "");
    const err = gossamer.gossamer_last_error();
    try testing.expect(err != null);

    if (err) |e| {
        const err_str = std.mem.span(e);
        try testing.expect(err_str.len > 0);
    }
}

test "last_error contains meaningful message" {
    _ = gossamer.gossamer_load_html(0, "");
    const err = gossamer.gossamer_last_error();
    try testing.expect(err != null);

    if (err) |e| {
        const err_str = std.mem.span(e);
        // Should mention "null" or "handle" — not a generic message
        const has_context = std.mem.indexOf(u8, err_str, "ull") != null or
            std.mem.indexOf(u8, err_str, "andle") != null;
        try testing.expect(has_context);
    }
}

//==============================================================================
// System Integration Stub Tests (Phase 2)
//==============================================================================

test "tray_create returns 0 (not yet implemented)" {
    const tray = gossamer.gossamer_tray_create("Test");
    try testing.expectEqual(@as(u64, 0), tray);
}

test "notify returns error (not yet implemented)" {
    const result = gossamer.gossamer_notify("Title", "Body");
    try testing.expectEqual(Result.@"error", result);
}

test "dialog_open returns 0 (not yet implemented)" {
    const dialog = gossamer.gossamer_dialog_open("Open", "*");
    try testing.expectEqual(@as(u64, 0), dialog);
}

test "dialog_save returns 0 (not yet implemented)" {
    const dialog = gossamer.gossamer_dialog_save("Save", "*");
    try testing.expectEqual(@as(u64, 0), dialog);
}
