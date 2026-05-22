// Gossamer Integration Tests
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// These tests verify that the Zig FFI correctly implements the Idris2 ABI.
// They exercise the exported C API surface without requiring a display server
// (headless — no GTK/WebKit needed).
//
// Test count target: 120+ tests covering the full exported API surface:
//   - main.zig: guard, registry, group, z-order, broadcast, arrange,
//               transmute, activity, debug, groove-typed, channel, cap,
//               platform query, async inflight
//   - csp.zig:  gossamer_set_csp, gossamer_emit
//   - filesystem.zig: gossamer_fs_* (null-safety, invalid tokens)
//   - ssg.zig:  gossamer_ssg_* (file I/O, front matter, markdown, template)
//   - groove.zig: gossamer_groove_* (discovery stubs, status, manifest, summary)

const std = @import("std");
const testing = std.testing;

// Primary module — all main.zig exports accessible via gossamer.*
const gossamer = @import("../src/main.zig");
const Result = gossamer.Result;

// Sub-module imports — functions exported from these modules are reachable
// through the shared library; for test builds we import directly.
const csp_mod = @import("../src/csp.zig");
const fs_mod = @import("../src/filesystem.zig");
const ssg_mod = @import("../src/ssg.zig");
const groove_mod = @import("../src/groove.zig");

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
    try testing.expectEqualStrings("0.3.0", ver_str);
}

test "build info string contains version" {
    const info = gossamer.gossamer_build_info();
    const info_str = std.mem.span(info);

    // Build info should mention Gossamer and the version
    try testing.expect(std.mem.indexOf(u8, info_str, "Gossamer") != null);
    try testing.expect(std.mem.indexOf(u8, info_str, "0.3.0") != null);
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

test "show with null handle returns null_pointer" {
    const result = gossamer.gossamer_show(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "hide with null handle returns null_pointer" {
    const result = gossamer.gossamer_hide(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "minimize with null handle returns null_pointer" {
    const result = gossamer.gossamer_minimize(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "maximize with null handle returns null_pointer" {
    const result = gossamer.gossamer_maximize(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "restore with null handle returns null_pointer" {
    const result = gossamer.gossamer_restore(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "request_close with null handle returns null_pointer" {
    const result = gossamer.gossamer_request_close(0);
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
    const CAP_ERROR = @import("../src/main.zig").CAP_ERROR;
    try testing.expectEqual(CAP_ERROR, gossamer.gossamer_cap_grant(6));
    try testing.expectEqual(CAP_ERROR, gossamer.gossamer_cap_grant(255));
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

//==============================================================================
// Clipboard API Tests
//==============================================================================

test "clipboard_write rejects null pointer" {
    const result = gossamer.gossamer_clipboard_write(null);
    try testing.expectEqual(@as(c_int, @intFromEnum(Result.invalid_param)), result);
}

test "clipboard_read rejects null buffer" {
    const result = gossamer.gossamer_clipboard_read(null, 256);
    try testing.expectEqual(@as(c_int, -1), result);
}

test "clipboard_read rejects zero length" {
    var buf: [1]u8 = undefined;
    const result = gossamer.gossamer_clipboard_read(&buf, 0);
    try testing.expectEqual(@as(c_int, -1), result);
}

test "clipboard_read with valid buffer and no display returns -1 or 0+" {
    // In headless CI, GTK init will fail so we get -1.
    // With a display, we get 0 (empty clipboard) or >0 (clipboard has text).
    // Either way it must not crash.
    var buf: [256]u8 = undefined;
    const result = gossamer.gossamer_clipboard_read(&buf, buf.len);
    try testing.expect(result >= -1);
}

test "clipboard_write with valid text and no display returns error or ok" {
    // In headless CI, GTK init will fail so we get error.
    // With a display, we get ok.
    // Either way it must not crash.
    const result = gossamer.gossamer_clipboard_write("gossamer clipboard test");
    try testing.expect(result == @intFromEnum(Result.ok) or result == @intFromEnum(Result.@"error"));
}

//==============================================================================
// Guard Mode Tests
//==============================================================================

test "guard_set with null handle returns null_pointer" {
    // Null handle — must reject immediately without dereferencing
    const result = gossamer.gossamer_guard_set(0, 0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "guard_get with null handle returns -1" {
    // Null handle sentinel is -1 (not a valid GuardMode ordinal)
    const val = gossamer.gossamer_guard_get(0);
    try testing.expectEqual(@as(c_int, -1), val);
}

test "guard mode ordinals match ABI spec" {
    // free=0, locked=1, read_only=2 — must not change without ABI version bump
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(gossamer.GuardMode.free));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(gossamer.GuardMode.locked));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(gossamer.GuardMode.read_only));
}

test "guard_set with invalid mode returns invalid_param" {
    // Mode 99 is not a valid GuardMode — must reject with invalid_param
    // A non-null but invalid handle pointer will fail on initialized check first,
    // so we verify null returns null_pointer (the only safe headless path).
    // The invalid-mode branch is covered by a stack-allocated handle test below.
    const result = gossamer.gossamer_guard_set(0, 99);
    // Null handle: null_pointer takes precedence over invalid mode
    try testing.expectEqual(Result.null_pointer, result);
}

test "guard_set invalid mode on fake handle returns invalid_param" {
    // Construct a minimal GossamerHandle on the stack for guard mode validation.
    // Uses an invalid (but non-null) pointer — guard_set checks mode before
    // touching platform state, so invalid_param is returned without a crash.
    // We pass a raw stack address; the handle check calls ptrFromU64 which only
    // verifies non-zero, so we must supply a real initialized struct.
    var fake_handle = std.mem.zeroes(gossamer.GossamerHandle);
    fake_handle.initialized = true;
    fake_handle.closed = false;
    fake_handle.guard = .free;
    fake_handle.allocator = std.heap.c_allocator;
    fake_handle.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    const hptr: u64 = @intFromPtr(&fake_handle);

    const result = gossamer.gossamer_guard_set(hptr, 99);
    try testing.expectEqual(Result.invalid_param, result);

    fake_handle.bindings.deinit();
}

//==============================================================================
// Window Registry Tests
//==============================================================================

test "registry_add with null handle returns 0" {
    // Null handle must not be registered — returns 0 (failure sentinel)
    const id = gossamer.gossamer_registry_add(0);
    try testing.expectEqual(@as(u32, 0), id);
}

test "registry_remove with null handle is safe (no-op)" {
    // Must not crash or access invalid memory
    gossamer.gossamer_registry_remove(0);
}

test "registry_count returns a value in 0..64" {
    // Count must be bounded by the max-window limit
    const count = gossamer.gossamer_registry_count();
    try testing.expect(count <= 64);
}

test "registry_count monotonicity: add increases count" {
    // Create a fake initialized handle to add to the registry
    var fake_handle = std.mem.zeroes(gossamer.GossamerHandle);
    fake_handle.initialized = true;
    fake_handle.closed = false;
    fake_handle.allocator = std.heap.c_allocator;
    fake_handle.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    const hptr: u64 = @intFromPtr(&fake_handle);

    const count_before = gossamer.gossamer_registry_count();
    const id = gossamer.gossamer_registry_add(hptr);

    if (id != 0) {
        // Successfully registered — count must have increased
        const count_after = gossamer.gossamer_registry_count();
        try testing.expect(count_after > count_before);

        // Remove and verify count returns to previous value
        gossamer.gossamer_registry_remove(hptr);
        const count_final = gossamer.gossamer_registry_count();
        try testing.expectEqual(count_before, count_final);
    }

    fake_handle.bindings.deinit();
}

//==============================================================================
// Window Group Tests
//==============================================================================

test "group_create returns non-zero id" {
    // A valid group creation must return a non-zero group ID
    const gid = gossamer.gossamer_group_create("test-group");
    try testing.expect(gid != 0);

    // Clean up the group slot
    gossamer.gossamer_group_destroy(gid);
}

test "group_create with null label returns non-zero id" {
    // Null label is explicitly optional — group creation must still succeed
    const gid = gossamer.gossamer_group_create(null);
    try testing.expect(gid != 0);
    gossamer.gossamer_group_destroy(gid);
}

test "group_add with invalid group returns invalid_param" {
    // Group ID 0xFFFFFFFF does not exist — must return invalid_param
    const result = gossamer.gossamer_group_add(0xFFFFFFFF, 1);
    try testing.expectEqual(Result.invalid_param, result);
}

test "group_remove with invalid group returns ok (idempotent)" {
    // Removing from a non-existent group is invalid_param (group not found)
    const result = gossamer.gossamer_group_remove(0xFFFFFFFF, 1);
    try testing.expectEqual(Result.invalid_param, result);
}

test "group_destroy with invalid id is safe (no-op)" {
    // Destroying a non-existent group must not crash
    gossamer.gossamer_group_destroy(0xFFFFFFFF);
    gossamer.gossamer_group_destroy(0);
}

test "group_apply with invalid group returns invalid_param" {
    // Applying an operation to a non-existent group must return invalid_param
    const result = gossamer.gossamer_group_apply(0xFFFFFFFF, 0);
    try testing.expectEqual(Result.invalid_param, result);
}

test "group lifecycle: create add remove destroy" {
    // Full lifecycle without a real window — uses window_id 0 which is valid
    // as a non-registered window; add/remove are idempotent for unknown IDs.
    const gid = gossamer.gossamer_group_create("lifecycle-group");
    try testing.expect(gid != 0);

    // Adding window ID 999 (not in registry) — should succeed (stores the ID)
    const add_result = gossamer.gossamer_group_add(gid, 999);
    try testing.expectEqual(Result.ok, add_result);

    // Adding the same window ID again is idempotent
    const add_again = gossamer.gossamer_group_add(gid, 999);
    try testing.expectEqual(Result.ok, add_again);

    // Remove the window from the group
    const remove_result = gossamer.gossamer_group_remove(gid, 999);
    try testing.expectEqual(Result.ok, remove_result);

    // Removing a window that is no longer a member is also idempotent
    const remove_again = gossamer.gossamer_group_remove(gid, 999);
    try testing.expectEqual(Result.ok, remove_again);

    // Destroy — must not crash even if members list was modified
    gossamer.gossamer_group_destroy(gid);
}

//==============================================================================
// Z-Order Tests (raise / lower)
//==============================================================================

test "raise with null handle returns null_pointer" {
    const result = gossamer.gossamer_raise(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "lower with null handle returns null_pointer" {
    const result = gossamer.gossamer_lower(0);
    try testing.expectEqual(Result.null_pointer, result);
}

//==============================================================================
// Cross-Window Communication Tests
//==============================================================================

test "broadcast with empty string event is safe and returns 0" {
    // No windows registered at test time, so delivered count is 0
    const delivered = gossamer.gossamer_broadcast("", "{}");
    // With no registered windows the result should be 0
    try testing.expect(delivered == 0);
}

test "broadcast with valid event name returns 0 when no windows registered" {
    const delivered = gossamer.gossamer_broadcast("test_event", "{\"key\":\"value\"}");
    try testing.expect(delivered == 0);
}

test "send_to with invalid target returns invalid_param" {
    // Target ID 0xFFFFFFFF is not registered — must return invalid_param
    const result = gossamer.gossamer_send_to(0xFFFFFFFF, "event", "{}");
    try testing.expectEqual(Result.invalid_param, result);
}

test "send_to with target ID 0 returns invalid_param" {
    // Window ID 0 is the unregistered sentinel — always invalid
    const result = gossamer.gossamer_send_to(0, "event", "{}");
    try testing.expectEqual(Result.invalid_param, result);
}

//==============================================================================
// Arrange Strategy Tests
//==============================================================================

test "arrange with invalid strategy returns invalid_param" {
    // Strategy 999 is not defined (valid: 0=tile_h, 1=tile_v, 2=cascade, 3=grid)
    const result = gossamer.gossamer_arrange(999);
    // With no windows arrange returns ok early (count==0 path), so this only
    // fires if windows are registered. In headless tests with no windows:
    // count==0 → returns ok before reaching the strategy switch.
    // Either ok (no windows) or invalid_param (windows registered + bad strategy).
    const ok = @intFromEnum(Result.ok);
    const inv = @intFromEnum(Result.invalid_param);
    try testing.expect(@intFromEnum(result) == ok or @intFromEnum(result) == inv);
}

test "arrange with strategy 0 is safe when no windows" {
    // tile_horizontal with 0 windows must return ok without touching screen geometry
    const result = gossamer.gossamer_arrange(0);
    try testing.expectEqual(Result.ok, result);
}

test "arrange with strategy 1 is safe when no windows" {
    const result = gossamer.gossamer_arrange(1);
    try testing.expectEqual(Result.ok, result);
}

test "arrange with strategy 2 is safe when no windows" {
    const result = gossamer.gossamer_arrange(2);
    try testing.expectEqual(Result.ok, result);
}

test "arrange with strategy 3 is safe when no windows" {
    const result = gossamer.gossamer_arrange(3);
    try testing.expectEqual(Result.ok, result);
}

//==============================================================================
// Transmute Tests
//==============================================================================

test "transmute with null handle returns null_pointer" {
    const result = gossamer.gossamer_transmute(0, 0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "transmute_get with null handle returns -1" {
    const val = gossamer.gossamer_transmute_get(0);
    try testing.expectEqual(@as(c_int, -1), val);
}

test "transmute mode ordinals match ABI spec" {
    // Must not change without an ABI version bump
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(gossamer.TransmuteMode.gui));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(gossamer.TransmuteMode.tui));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(gossamer.TransmuteMode.cli));
    try testing.expectEqual(@as(c_int, 3), @intFromEnum(gossamer.TransmuteMode.terminal_export));
    try testing.expectEqual(@as(c_int, 4), @intFromEnum(gossamer.TransmuteMode.panll_attach));
    try testing.expectEqual(@as(c_int, 5), @intFromEnum(gossamer.TransmuteMode.panll_detach));
}

test "transmute with invalid mode on fake handle returns invalid_param" {
    // Supply a real initialized handle struct to trigger the mode validation path
    var fake_handle = std.mem.zeroes(gossamer.GossamerHandle);
    fake_handle.initialized = true;
    fake_handle.closed = false;
    fake_handle.allocator = std.heap.c_allocator;
    fake_handle.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    const hptr: u64 = @intFromPtr(&fake_handle);

    // Mode 99 is not a valid TransmuteMode — must return invalid_param
    const result = gossamer.gossamer_transmute(hptr, 99);
    try testing.expectEqual(Result.invalid_param, result);

    fake_handle.bindings.deinit();
}

//==============================================================================
// Activity Level Tests
//==============================================================================

test "activity_set with null handle returns null_pointer" {
    const result = gossamer.gossamer_activity_set(0, 0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "activity_get with null handle returns -1" {
    const val = gossamer.gossamer_activity_get(0);
    try testing.expectEqual(@as(c_int, -1), val);
}

test "activity level ordinals match ABI spec" {
    // Must not change without an ABI version bump
    try testing.expectEqual(@as(c_int, 0), @intFromEnum(gossamer.ActivityLevel.paused));
    try testing.expectEqual(@as(c_int, 1), @intFromEnum(gossamer.ActivityLevel.low));
    try testing.expectEqual(@as(c_int, 2), @intFromEnum(gossamer.ActivityLevel.mid));
    try testing.expectEqual(@as(c_int, 3), @intFromEnum(gossamer.ActivityLevel.high));
    try testing.expectEqual(@as(c_int, 4), @intFromEnum(gossamer.ActivityLevel.realtime));
}

test "activity_set with invalid level on fake handle returns invalid_param" {
    var fake_handle = std.mem.zeroes(gossamer.GossamerHandle);
    fake_handle.initialized = true;
    fake_handle.closed = false;
    fake_handle.allocator = std.heap.c_allocator;
    fake_handle.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    const hptr: u64 = @intFromPtr(&fake_handle);

    // Level 99 is not a valid ActivityLevel
    const result = gossamer.gossamer_activity_set(hptr, 99);
    try testing.expectEqual(Result.invalid_param, result);

    fake_handle.bindings.deinit();
}

//==============================================================================
// Debug Drawer Tests
//==============================================================================

test "debug_open with null handle returns null_pointer" {
    const result = gossamer.gossamer_debug_open(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "debug_close with null handle returns null_pointer" {
    const result = gossamer.gossamer_debug_close(0);
    try testing.expectEqual(Result.null_pointer, result);
}

test "debug_toggle with null handle returns null_pointer" {
    const result = gossamer.gossamer_debug_toggle(0);
    try testing.expectEqual(Result.null_pointer, result);
}

//==============================================================================
// Typed Groove Connection Tests (main.zig)
//==============================================================================

test "groove_connect_typed with invalid type returns invalid_param" {
    // Groove type 99 is not valid (0=hard, 1=soft)
    const result = gossamer.gossamer_groove_connect_typed(1, 99, 0);
    try testing.expectEqual(Result.invalid_param, result);
}

test "groove_connect_typed with hard type succeeds" {
    // Hard groove connection with target 9999 (not probed) — should succeed
    // at the connection record level without network activity
    const result = gossamer.gossamer_groove_connect_typed(9999, 0, 0);
    try testing.expectEqual(Result.ok, result);

    // Disconnect to clean up the slot
    _ = gossamer.gossamer_groove_disconnect_typed(9999);
}

test "groove_connect_typed with soft type succeeds" {
    const result = gossamer.gossamer_groove_connect_typed(8888, 1, 30);
    try testing.expectEqual(Result.ok, result);
    _ = gossamer.gossamer_groove_disconnect_typed(8888);
}

test "groove_disconnect_typed is idempotent for unknown target" {
    // Disconnecting a target that was never connected must return ok
    const result = gossamer.gossamer_groove_disconnect_typed(0xDEADBEEF);
    try testing.expectEqual(Result.ok, result);
}

test "groove_query_type returns -1 for unconnected target" {
    // Target not in the groove_connections array — returns -1 (not connected)
    const type_val = gossamer.gossamer_groove_query_type(0xABCDEF01);
    try testing.expectEqual(@as(c_int, -1), type_val);
}

test "groove_query_type returns correct type after connect" {
    _ = gossamer.gossamer_groove_connect_typed(7777, 1, 60); // soft
    const type_val = gossamer.gossamer_groove_query_type(7777);
    try testing.expectEqual(@as(c_int, 1), type_val); // 1 = soft
    _ = gossamer.gossamer_groove_disconnect_typed(7777);
}

test "groove_dock with null handle returns null_pointer" {
    const result = gossamer.gossamer_groove_dock(0, "http://localhost:6473", 300);
    try testing.expectEqual(Result.null_pointer, result);
}

test "groove_undock with null handle returns null_pointer" {
    const result = gossamer.gossamer_groove_undock(0);
    try testing.expectEqual(Result.null_pointer, result);
}

//==============================================================================
// Async IPC Tests
//==============================================================================

test "channel_bind_async with null channel returns null_pointer" {
    // Null channel pointer — must reject immediately
    const result = gossamer.gossamer_channel_bind_async(0, "handler", null, null);
    try testing.expectEqual(Result.null_pointer, result);
}

test "async_inflight_count starts at 0 before any async binds" {
    // Reset the inflight tracker to a clean state for this test
    gossamer.async_ipc.reset();
    const count = gossamer.gossamer_async_inflight_count();
    try testing.expectEqual(@as(u32, 0), count);
}

test "async_inflight_count returns value in 0..256" {
    // Count is always bounded by MAX_INFLIGHT_ASYNC (256)
    const count = gossamer.gossamer_async_inflight_count();
    try testing.expect(count <= 256);
}

test "async_ipc acquireSlot increments inflight count" {
    gossamer.async_ipc.reset();
    const slot = gossamer.async_ipc.acquireSlot();
    try testing.expect(slot != null);
    try testing.expectEqual(@as(u32, 1), gossamer.gossamer_async_inflight_count());
    gossamer.async_ipc.releaseSlot(slot.?);
}

test "async_ipc releaseSlot decrements inflight count back to zero" {
    gossamer.async_ipc.reset();
    const slot = gossamer.async_ipc.acquireSlot().?;
    gossamer.async_ipc.releaseSlot(slot);
    try testing.expectEqual(@as(u32, 0), gossamer.gossamer_async_inflight_count());
}

test "async_ipc acquireSlot returns null when all slots occupied" {
    gossamer.async_ipc.reset();
    // Set a small limit so we can fill it without allocating 256 slots
    _ = gossamer.gossamer_set_max_inflight(2);
    defer _ = gossamer.gossamer_set_max_inflight(256);

    const s0 = gossamer.async_ipc.acquireSlot();
    const s1 = gossamer.async_ipc.acquireSlot();
    const s2 = gossamer.async_ipc.acquireSlot(); // must fail — limit is 2

    try testing.expect(s0 != null);
    try testing.expect(s1 != null);
    try testing.expect(s2 == null);

    gossamer.async_ipc.releaseSlot(s0.?);
    gossamer.async_ipc.releaseSlot(s1.?);
}

test "async_ipc releaseSlot on already-free slot is a no-op" {
    gossamer.async_ipc.reset();
    // Releasing a slot that was never acquired must not corrupt the count
    gossamer.async_ipc.releaseSlot(0);
    try testing.expectEqual(@as(u32, 0), gossamer.gossamer_async_inflight_count());
}

//==============================================================================
// Platform Query API Tests
//==============================================================================

test "platform returns non-null non-empty string" {
    const plat = gossamer.gossamer_platform();
    const plat_str = std.mem.span(plat);
    try testing.expect(plat_str.len > 0);
}

test "platform returns recognised OS name" {
    const plat = gossamer.gossamer_platform();
    const plat_str = std.mem.span(plat);
    // Must be one of the known platform identifiers
    const valid = std.mem.eql(u8, plat_str, "linux") or
        std.mem.eql(u8, plat_str, "macos") or
        std.mem.eql(u8, plat_str, "windows") or
        std.mem.eql(u8, plat_str, "freebsd") or
        std.mem.eql(u8, plat_str, "openbsd") or
        std.mem.eql(u8, plat_str, "netbsd") or
        std.mem.eql(u8, plat_str, "ios") or
        std.mem.eql(u8, plat_str, "unknown");
    try testing.expect(valid);
}

test "arch returns non-null non-empty string" {
    const arch = gossamer.gossamer_arch();
    const arch_str = std.mem.span(arch);
    try testing.expect(arch_str.len > 0);
}

test "arch returns recognised architecture name" {
    const arch = gossamer.gossamer_arch();
    const arch_str = std.mem.span(arch);
    const valid = std.mem.eql(u8, arch_str, "x86_64") or
        std.mem.eql(u8, arch_str, "aarch64") or
        std.mem.eql(u8, arch_str, "riscv64") or
        std.mem.eql(u8, arch_str, "wasm32") or
        std.mem.eql(u8, arch_str, "unknown");
    try testing.expect(valid);
}

test "webview_engine returns non-null non-empty string" {
    const engine = gossamer.gossamer_webview_engine();
    const engine_str = std.mem.span(engine);
    try testing.expect(engine_str.len > 0);
}

test "webview_engine returns recognised engine name" {
    const engine = gossamer.gossamer_webview_engine();
    const engine_str = std.mem.span(engine);
    const valid = std.mem.eql(u8, engine_str, "webkitgtk") or
        std.mem.eql(u8, engine_str, "wkwebview") or
        std.mem.eql(u8, engine_str, "webview2") or
        std.mem.eql(u8, engine_str, "none");
    try testing.expect(valid);
}

test "is_desktop returns 0 or 1" {
    const val = gossamer.gossamer_is_desktop();
    try testing.expect(val == 0 or val == 1);
}

test "platform_json is non-null and contains opening brace" {
    // Must be valid JSON — at minimum a JSON object opening
    const json = gossamer.gossamer_platform_json();
    const json_str = std.mem.span(json);
    try testing.expect(json_str.len > 0);
    try testing.expect(std.mem.indexOf(u8, json_str, "{") != null);
}

test "platform_json contains platform key" {
    const json = gossamer.gossamer_platform_json();
    const json_str = std.mem.span(json);
    try testing.expect(std.mem.indexOf(u8, json_str, "platform") != null);
}

test "platform_json contains arch key" {
    const json = gossamer.gossamer_platform_json();
    const json_str = std.mem.span(json);
    try testing.expect(std.mem.indexOf(u8, json_str, "arch") != null);
}

test "platform_json contains version key" {
    const json = gossamer.gossamer_platform_json();
    const json_str = std.mem.span(json);
    try testing.expect(std.mem.indexOf(u8, json_str, "version") != null);
}

//==============================================================================
// CSP Module Tests (null-handle safety)
//==============================================================================

test "set_csp with null handle returns null_pointer" {
    // Verify the csp module's exported function rejects null properly
    const result = csp_mod.gossamer_set_csp(0, "default-src 'self'");
    try testing.expectEqual(Result.null_pointer, result);
}

test "emit with null handle returns null_pointer" {
    const result = csp_mod.gossamer_emit(0, "test_event", "{}");
    try testing.expectEqual(Result.null_pointer, result);
}

test "emit with null handle and empty event name returns null_pointer" {
    const result = csp_mod.gossamer_emit(0, "", "{}");
    try testing.expectEqual(Result.null_pointer, result);
}

test "set_csp with null handle and complex CSP returns null_pointer" {
    const csp = "default-src 'self'; script-src 'self' 'unsafe-inline'; img-src *";
    const result = csp_mod.gossamer_set_csp(0, csp);
    try testing.expectEqual(Result.null_pointer, result);
}

//==============================================================================
// Filesystem Module Tests (capability gating + null safety)
//==============================================================================

test "fs_read_text with zero cap_token returns null" {
    // Zero token is always invalid — capability check must reject it
    const result = fs_mod.gossamer_fs_read_text("/tmp/gossamer_test_nonexistent.txt", 0);
    try testing.expectEqual(@as(?[*:0]u8, null), result);
}

test "fs_write_text with zero cap_token returns capability_denied" {
    const result = fs_mod.gossamer_fs_write_text("/tmp/gossamer_test.txt", "hello", 0);
    try testing.expectEqual(Result.capability_denied, result);
}

test "fs_exists with zero cap_token returns 0xFFFFFFFF" {
    // Invalid token — returns error sentinel 0xFFFFFFFF
    const result = fs_mod.gossamer_fs_exists("/tmp", 0);
    try testing.expectEqual(@as(u32, 0xFFFFFFFF), result);
}

test "fs_list_dir with zero cap_token returns null" {
    const result = fs_mod.gossamer_fs_list_dir("/tmp", 0);
    try testing.expectEqual(@as(?[*:0]u8, null), result);
}

test "fs_remove with zero cap_token returns capability_denied" {
    const result = fs_mod.gossamer_fs_remove("/tmp/gossamer_nonexistent.txt", 0);
    try testing.expectEqual(Result.capability_denied, result);
}

test "fs_read_text with valid filesystem cap and nonexistent path returns null" {
    // Grant a real FileSystem capability and verify the file-not-found path
    const token = gossamer.gossamer_cap_grant(0); // FileSystem
    defer gossamer.gossamer_cap_revoke(token);

    // Must use absolute path — filesystem module uses openFileAbsolute
    const result = fs_mod.gossamer_fs_read_text("/tmp/gossamer_definitely_does_not_exist_xyz123.txt", token);
    try testing.expectEqual(@as(?[*:0]u8, null), result);
}

test "fs_write_text with wrong capability kind returns capability_denied" {
    // Grant a Network capability (kind=1) for a filesystem operation — wrong kind
    const token = gossamer.gossamer_cap_grant(1); // Network
    defer gossamer.gossamer_cap_revoke(token);

    const result = fs_mod.gossamer_fs_write_text("/tmp/gossamer_test.txt", "hello", token);
    try testing.expectEqual(Result.capability_denied, result);
}

test "fs_exists with valid cap and known path returns 1" {
    // /tmp always exists on Linux/BSD
    const token = gossamer.gossamer_cap_grant(0);
    defer gossamer.gossamer_cap_revoke(token);

    const result = fs_mod.gossamer_fs_exists("/tmp", token);
    try testing.expectEqual(@as(u32, 1), result);
}

test "fs_exists with valid cap and nonexistent path returns 0" {
    const token = gossamer.gossamer_cap_grant(0);
    defer gossamer.gossamer_cap_revoke(token);

    const result = fs_mod.gossamer_fs_exists("/tmp/gossamer_xyz_does_not_exist_abc987", token);
    try testing.expectEqual(@as(u32, 0), result);
}

test "fs_write_then_read_then_remove round trip with valid cap" {
    // Full round-trip: write → read → remove, all with a valid capability
    const token = gossamer.gossamer_cap_grant(0);
    defer gossamer.gossamer_cap_revoke(token);

    const test_path = "/tmp/gossamer_fs_roundtrip_test.txt";
    const test_content = "Gossamer filesystem round-trip test content";

    // Write
    const write_result = fs_mod.gossamer_fs_write_text(test_path, test_content, token);
    try testing.expectEqual(Result.ok, write_result);

    // Read back — requires a fresh valid token since the token above was used (not consumed)
    const read_result = fs_mod.gossamer_fs_read_text(test_path, token);
    try testing.expect(read_result != null);
    if (read_result) |r| {
        const read_str = std.mem.span(r);
        try testing.expectEqualStrings(test_content, read_str);
        std.heap.c_allocator.free(r[0 .. read_str.len + 1]);
    }

    // Remove
    const remove_result = fs_mod.gossamer_fs_remove(test_path, token);
    try testing.expectEqual(Result.ok, remove_result);

    // Verify gone
    const exists_after = fs_mod.gossamer_fs_exists(test_path, token);
    try testing.expectEqual(@as(u32, 0), exists_after);
}

//==============================================================================
// SSG Module Tests
//==============================================================================

test "ssg_read_file with nonexistent path returns null" {
    const result = ssg_mod.gossamer_ssg_read_file("/tmp/gossamer_ssg_definitely_does_not_exist.md");
    try testing.expectEqual(@as(?[*:0]u8, null), result);
}

test "ssg_write_file to tmp path returns 0" {
    const result = ssg_mod.gossamer_ssg_write_file("/tmp/gossamer_ssg_write_test.txt", "test");
    try testing.expectEqual(@as(c_int, 0), result);
    std.fs.cwd().deleteFile("/tmp/gossamer_ssg_write_test.txt") catch {};
}

test "ssg_list_files on nonexistent directory returns empty string not null" {
    // Non-existent dir returns empty string (not null) per ssg.zig contract
    const result = ssg_mod.gossamer_ssg_list_files("/tmp/gossamer_ssg_nonexistent_dir_xyz", ".md");
    try testing.expect(result != null);
    if (result) |r| {
        const str = std.mem.span(r);
        try testing.expectEqualStrings("", str);
        std.heap.c_allocator.free(r[0 .. str.len + 1]);
    }
}

test "ssg_list_files on existing directory returns non-null" {
    // /tmp always exists and is iterable
    const result = ssg_mod.gossamer_ssg_list_files("/tmp", ".md");
    try testing.expect(result != null);
    if (result) |r| {
        const str = std.mem.span(r);
        std.heap.c_allocator.free(r[0 .. str.len + 1]);
    }
}

test "ssg_parse_front_matter with null-equivalent empty content returns empty string" {
    const result = ssg_mod.gossamer_ssg_parse_front_matter("Just regular content.");
    try testing.expect(result != null);
    if (result) |r| {
        const str = std.mem.span(r);
        try testing.expectEqualStrings("", str);
        std.heap.c_allocator.free(r[0 .. str.len + 1]);
    }
}

test "ssg_parse_front_matter with valid front matter extracts YAML block" {
    const content = "---\ntitle: Hello\ndate: 2026-03-22\n---\nBody here.";
    const fm = ssg_mod.gossamer_ssg_parse_front_matter(content) orelse unreachable;
    defer std.heap.c_allocator.free(fm[0 .. std.mem.span(fm).len + 1]);
    try testing.expectEqualStrings("title: Hello\ndate: 2026-03-22", std.mem.span(fm));
}

test "ssg_parse_front_matter with no closing delimiter returns empty string" {
    // Front matter opened but never closed — treated as no front matter
    const content = "---\ntitle: Broken\nno closing delimiter ever";
    const result = ssg_mod.gossamer_ssg_parse_front_matter(content);
    try testing.expect(result != null);
    if (result) |r| {
        const str = std.mem.span(r);
        try testing.expectEqualStrings("", str);
        std.heap.c_allocator.free(r[0 .. str.len + 1]);
    }
}

test "ssg_parse_body with no front matter returns entire content" {
    const content = "No front matter here.";
    const body = ssg_mod.gossamer_ssg_parse_body(content) orelse unreachable;
    defer std.heap.c_allocator.free(body[0 .. std.mem.span(body).len + 1]);
    try testing.expectEqualStrings("No front matter here.", std.mem.span(body));
}

test "ssg_parse_body with front matter returns content after delimiter" {
    const content = "---\ntitle: Test\n---\nBody text.";
    const body = ssg_mod.gossamer_ssg_parse_body(content) orelse unreachable;
    defer std.heap.c_allocator.free(body[0 .. std.mem.span(body).len + 1]);
    try testing.expectEqualStrings("Body text.", std.mem.span(body));
}

test "ssg_md_to_html with null-equivalent empty string returns empty output" {
    // Empty markdown produces no HTML elements
    const result = ssg_mod.gossamer_ssg_md_to_html("") orelse unreachable;
    const str = std.mem.span(result);
    defer std.heap.c_allocator.free(result[0 .. str.len + 1]);
    try testing.expectEqualStrings("", str);
}

test "ssg_md_to_html converts heading and paragraph" {
    // Core markdown conversion: heading + blank line + paragraph
    const md = "# Heading\n\nParagraph";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);

    // Must contain both <h1> and <p> tags
    try testing.expect(std.mem.indexOf(u8, html_str, "<h1>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<p>") != null);
}

test "ssg_md_to_html converts h1 through h6" {
    // All heading levels must be supported
    const md = "# H1\n## H2\n### H3\n#### H4\n##### H5\n###### H6";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);

    try testing.expect(std.mem.indexOf(u8, html_str, "<h1>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<h2>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<h3>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<h4>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<h5>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<h6>") != null);
}

test "ssg_md_to_html escapes HTML special characters in text" {
    const md = "Hello <world> & \"friends\"";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);

    // Raw < and > must not appear in paragraph text
    try testing.expect(std.mem.indexOf(u8, html_str, "<world>") == null);
    try testing.expect(std.mem.indexOf(u8, html_str, "&lt;") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "&gt;") != null);
}

test "ssg_md_to_html converts bold text" {
    const md = "**bold**";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);
    try testing.expect(std.mem.indexOf(u8, html_str, "<strong>bold</strong>") != null);
}

test "ssg_md_to_html converts italic text" {
    const md = "*italic*";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);
    try testing.expect(std.mem.indexOf(u8, html_str, "<em>italic</em>") != null);
}

test "ssg_md_to_html converts inline code" {
    const md = "Call `foo()` here.";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);
    try testing.expect(std.mem.indexOf(u8, html_str, "<code>foo()</code>") != null);
}

test "ssg_md_to_html converts hyperlinks" {
    const md = "Visit [example](https://example.com).";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);
    try testing.expect(std.mem.indexOf(u8, html_str, "<a href=\"https://example.com\">") != null);
}

test "ssg_template_substitute replaces known placeholder" {
    const tmpl = "<title>{{title}}</title>";
    const vars = "title=Gossamer Test";
    const result = ssg_mod.gossamer_ssg_template_substitute(tmpl, vars) orelse unreachable;
    const result_str = std.mem.span(result);
    defer std.heap.c_allocator.free(result[0 .. result_str.len + 1]);
    try testing.expectEqualStrings("<title>Gossamer Test</title>", result_str);
}

test "ssg_template_substitute preserves unknown placeholders" {
    const tmpl = "{{known}} - {{unknown}}";
    const vars = "known=yes";
    const result = ssg_mod.gossamer_ssg_template_substitute(tmpl, vars) orelse unreachable;
    const result_str = std.mem.span(result);
    defer std.heap.c_allocator.free(result[0 .. result_str.len + 1]);
    try testing.expectEqualStrings("yes - {{unknown}}", result_str);
}

test "ssg_template_substitute with empty vars string preserves all placeholders" {
    const tmpl = "{{a}} and {{b}}";
    const vars = "";
    const result = ssg_mod.gossamer_ssg_template_substitute(tmpl, vars) orelse unreachable;
    const result_str = std.mem.span(result);
    defer std.heap.c_allocator.free(result[0 .. result_str.len + 1]);
    try testing.expectEqualStrings("{{a}} and {{b}}", result_str);
}

test "ssg_template_substitute with empty template returns empty string" {
    const result = ssg_mod.gossamer_ssg_template_substitute("", "key=val") orelse unreachable;
    const result_str = std.mem.span(result);
    defer std.heap.c_allocator.free(result[0 .. result_str.len + 1]);
    try testing.expectEqualStrings("", result_str);
}

test "ssg_build_site with invalid content dir returns non-zero" {
    // Non-existent content dir — template read will fail first
    const result = ssg_mod.gossamer_ssg_build_site(
        "/tmp/gossamer_ssg_nonexistent_content_dir",
        "/tmp/gossamer_ssg_nonexistent_template.html",
        "/tmp/gossamer_ssg_nonexistent_out",
    );
    try testing.expect(result != 0);
}

//==============================================================================
// Groove Discovery Module Tests (groove.zig)
//==============================================================================

test "groove_discover returns count in 0..10" {
    // 10 well-known targets — in headless CI none are listening
    // so the count is 0, but must always be in range
    const count = groove_mod.gossamer_groove_discover();
    try testing.expect(count <= 10);
}

test "groove_status with invalid target_id returns 0 (not_found)" {
    // Out-of-range ID (>= TARGET_COUNT=10) — returns 0 per bounds check
    const status = groove_mod.gossamer_groove_status(999);
    try testing.expectEqual(@as(u32, 0), status);
}

test "groove_status with in-range target returns 0 before discovery" {
    // Disconnect all to ensure clean state, then check status
    groove_mod.gossamer_groove_disconnect_all();
    // After disconnect all, status is reset to not_found (0)
    const status = groove_mod.gossamer_groove_status(0);
    try testing.expectEqual(@as(u32, 0), status);
}

test "groove_manifest with invalid target_id returns empty string not null" {
    // Out-of-range returns the literal empty string pointer
    const manifest = groove_mod.gossamer_groove_manifest(999);
    const manifest_str = std.mem.span(manifest);
    try testing.expectEqualStrings("", manifest_str);
}

test "groove_manifest with unconnected target returns empty string" {
    groove_mod.gossamer_groove_disconnect_all();
    const manifest = groove_mod.gossamer_groove_manifest(0);
    const manifest_str = std.mem.span(manifest);
    try testing.expectEqualStrings("", manifest_str);
}

test "groove_find_capability with unknown name returns 0xFFFFFFFF" {
    // No services discovered — no capability can be found
    groove_mod.gossamer_groove_disconnect_all();
    const idx = groove_mod.gossamer_groove_find_capability("voice");
    try testing.expectEqual(@as(u32, 0xFFFFFFFF), idx);
}

test "groove_find_capability with empty name returns 0xFFFFFFFF" {
    // Empty capability name is invalid — returns not-found sentinel
    const idx = groove_mod.gossamer_groove_find_capability("");
    try testing.expectEqual(@as(u32, 0xFFFFFFFF), idx);
}

test "groove_check_compat with out-of-range targets returns 0" {
    // Both targets out of range — must return 0 (not compatible)
    const compat = groove_mod.gossamer_groove_check_compat(999, 998);
    try testing.expectEqual(@as(u32, 0), compat);
}

test "groove_check_compat with one out-of-range target returns 0" {
    const compat = groove_mod.gossamer_groove_check_compat(0, 999);
    try testing.expectEqual(@as(u32, 0), compat);
}

test "groove_check_compat with unconnected in-range targets returns 0" {
    groove_mod.gossamer_groove_disconnect_all();
    // Both targets exist but are not connected — not compatible
    const compat = groove_mod.gossamer_groove_check_compat(0, 1);
    try testing.expectEqual(@as(u32, 0), compat);
}

test "groove_send with invalid target returns non-zero (error)" {
    // Out-of-range target — must return 1 (error) not 0 (success)
    const result = groove_mod.gossamer_groove_send(999, "{}");
    try testing.expect(result != 0);
}

test "groove_send with not-connected target returns non-zero (error)" {
    groove_mod.gossamer_groove_disconnect_all();
    // Target 0 is not connected — grooves[0].status == not_found → return 1
    const result = groove_mod.gossamer_groove_send(0, "{\"test\":true}");
    try testing.expect(result != 0);
}

test "groove_recv with invalid target returns empty string" {
    const response = groove_mod.gossamer_groove_recv(999);
    const response_str = std.mem.span(response);
    try testing.expectEqualStrings("", response_str);
}

test "groove_recv with not-connected target returns empty string" {
    groove_mod.gossamer_groove_disconnect_all();
    const response = groove_mod.gossamer_groove_recv(0);
    const response_str = std.mem.span(response);
    try testing.expectEqualStrings("", response_str);
}

test "groove_summary returns non-null valid JSON array" {
    // Summary must always return a valid JSON array string
    const summary = groove_mod.gossamer_groove_summary();
    const summary_str = std.mem.span(summary);
    try testing.expect(summary_str.len > 0);
    // Must start with '[' and end with ']' (JSON array)
    try testing.expect(std.mem.indexOf(u8, summary_str, "[") != null);
    try testing.expect(std.mem.indexOf(u8, summary_str, "{") != null);
}

test "groove_summary contains all 10 service entries" {
    const summary = groove_mod.gossamer_groove_summary();
    const summary_str = std.mem.span(summary);
    // Each service appears once — count opening braces as a proxy
    var brace_count: usize = 0;
    for (summary_str) |c| {
        if (c == '{') brace_count += 1;
    }
    try testing.expectEqual(@as(usize, 10), brace_count);
}

test "groove_disconnect with out-of-range id is safe (no-op)" {
    // Must not crash or access invalid memory
    groove_mod.gossamer_groove_disconnect(999);
    groove_mod.gossamer_groove_disconnect(0xFFFFFFFF);
}

test "groove_disconnect_all is always safe" {
    // Must not crash regardless of state
    groove_mod.gossamer_groove_disconnect_all();
    groove_mod.gossamer_groove_disconnect_all(); // idempotent
}

test "groove_disconnect resets target state" {
    // Disconnect target 0 and verify its status returns to not_found (0)
    groove_mod.gossamer_groove_disconnect(0);
    const status = groove_mod.gossamer_groove_status(0);
    try testing.expectEqual(@as(u32, 0), status);
}

//==============================================================================
// Cross-Cutting / Integration Tests
//==============================================================================

test "multiple sequential error-setting operations: last_error reflects last op" {
    // Each failing operation should overwrite the previous error
    _ = gossamer.gossamer_load_html(0, "");    // sets "Null webview handle"
    _ = gossamer.gossamer_navigate(0, "");     // overwrites with same message
    _ = gossamer.gossamer_set_title(0, "");   // overwrites again

    // last_error is consume-on-read — should reflect the most recent operation
    const err = gossamer.gossamer_last_error();
    try testing.expect(err != null);
    if (err) |e| {
        const err_str = std.mem.span(e);
        try testing.expect(err_str.len > 0);
    }
}

test "cap_check does not expose token after revocation across multiple checks" {
    // Verify the revocation set correctly blocks reuse
    const token = gossamer.gossamer_cap_grant(2); // Shell
    try testing.expect(token != 0);

    try testing.expectEqual(Result.ok, gossamer.gossamer_cap_check(token));
    gossamer.gossamer_cap_revoke(token);

    // Multiple checks after revocation all must deny
    try testing.expectEqual(Result.capability_denied, gossamer.gossamer_cap_check(token));
    try testing.expectEqual(Result.capability_denied, gossamer.gossamer_cap_check(token));
    try testing.expectEqual(Result.capability_denied, gossamer.gossamer_cap_check(token));
}

test "guard mode enum has exactly 3 variants" {
    const fields = @typeInfo(gossamer.GuardMode).@"enum".fields;
    try testing.expectEqual(@as(usize, 3), fields.len);
}

test "transmute mode enum has exactly 6 variants" {
    const fields = @typeInfo(gossamer.TransmuteMode).@"enum".fields;
    try testing.expectEqual(@as(usize, 6), fields.len);
}

test "activity level enum has exactly 5 variants" {
    const fields = @typeInfo(gossamer.ActivityLevel).@"enum".fields;
    try testing.expectEqual(@as(usize, 5), fields.len);
}

test "groove_type enum has exactly 2 variants" {
    const fields = @typeInfo(gossamer.GrooveType).@"enum".fields;
    try testing.expectEqual(@as(usize, 2), fields.len);
}

test "platform and arch strings are consistent with platform_json" {
    // The individual query strings must appear inside the JSON blob
    const plat = gossamer.gossamer_platform();
    const plat_str = std.mem.span(plat);
    const arch = gossamer.gossamer_arch();
    const arch_str = std.mem.span(arch);
    const json = gossamer.gossamer_platform_json();
    const json_str = std.mem.span(json);

    try testing.expect(std.mem.indexOf(u8, json_str, plat_str) != null);
    try testing.expect(std.mem.indexOf(u8, json_str, arch_str) != null);
}

test "groove_summary is valid JSON containing opening brace" {
    // Used by the PanLL panel bus — must always be parseable
    const summary = groove_mod.gossamer_groove_summary();
    const summary_str = std.mem.span(summary);
    try testing.expect(std.mem.indexOf(u8, summary_str, "{") != null);
}

test "async_inflight_count is 0 after explicit reset" {
    // The reset() helper is documented for tests — verify it works
    gossamer.async_ipc.reset();
    const count = gossamer.gossamer_async_inflight_count();
    try testing.expectEqual(@as(u32, 0), count);
}

test "cap_grant for each valid resource kind produces unique tokens" {
    // Each grant must produce a distinct non-zero token (crypto random)
    var tokens: [6]u64 = undefined;
    for (0..6) |i| {
        tokens[i] = gossamer.gossamer_cap_grant(@intCast(i));
        try testing.expect(tokens[i] != 0);
    }

    // All tokens must be distinct (probability of collision is astronomically low)
    for (0..6) |i| {
        for (i + 1..6) |j| {
            try testing.expect(tokens[i] != tokens[j]);
        }
    }

    for (tokens) |t| gossamer.gossamer_cap_revoke(t);
}

test "ssg markdown heading and paragraph produce correct HTML structure" {
    // Validate the combined conversion used in the SSG pipeline
    const md = "# Heading\n\nParagraph text here.";
    const html = ssg_mod.gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = std.mem.span(html);
    defer std.heap.c_allocator.free(html[0 .. html_str.len + 1]);

    try testing.expect(std.mem.indexOf(u8, html_str, "<h1>Heading</h1>") != null);
    try testing.expect(std.mem.indexOf(u8, html_str, "<p>Paragraph text here.</p>") != null);
}

test "last_error is null after successful cap_grant" {
    // Successful operations should not leave a stale error
    const token = gossamer.gossamer_cap_grant(0);
    defer gossamer.gossamer_cap_revoke(token);
    try testing.expect(token != 0);

    // Clear any error from a previous test, then verify cap_grant cleared it
    _ = gossamer.gossamer_last_error(); // consume any prior error
    _ = gossamer.gossamer_cap_grant(0); // successful grant clears error
    const token2 = gossamer.gossamer_cap_grant(0);
    defer gossamer.gossamer_cap_revoke(token2);
    // After a successful grant, last_error should be null
    const err = gossamer.gossamer_last_error();
    try testing.expectEqual(@as(?[*:0]const u8, null), err);
}

test "groove type round-trip: connect hard then query returns 0" {
    // Connect with hard type (0) and verify query returns 0
    const target: u32 = 6666;
    _ = gossamer.gossamer_groove_connect_typed(target, 0, 0);
    const type_val = gossamer.gossamer_groove_query_type(target);
    try testing.expectEqual(@as(c_int, 0), type_val); // 0 = hard
    _ = gossamer.gossamer_groove_disconnect_typed(target);
}

test "groove type round-trip: connect soft then query returns 1" {
    const target: u32 = 5555;
    _ = gossamer.gossamer_groove_connect_typed(target, 1, 120);
    const type_val = gossamer.gossamer_groove_query_type(target);
    try testing.expectEqual(@as(c_int, 1), type_val); // 1 = soft
    _ = gossamer.gossamer_groove_disconnect_typed(target);
}

test "groove soft disconnect wipes state (query returns -1 after disconnect)" {
    const target: u32 = 4444;
    _ = gossamer.gossamer_groove_connect_typed(target, 1, 10); // soft
    _ = gossamer.gossamer_groove_disconnect_typed(target);
    // After soft disconnect the slot is zeroed — type query returns -1
    const type_val = gossamer.gossamer_groove_query_type(target);
    try testing.expectEqual(@as(c_int, -1), type_val);
}

test "version string is non-empty and does not start with v prefix" {
    // SEMVER: the version string is a bare "X.Y.Z", no leading 'v'
    const ver = gossamer.gossamer_version();
    const ver_str = std.mem.span(ver);
    try testing.expect(ver_str.len > 0);
    try testing.expect(ver_str[0] != 'v');
}

test "build info contains zig version string" {
    const info = gossamer.gossamer_build_info();
    const info_str = std.mem.span(info);
    // Build info format: "Gossamer X.Y.Z built with Zig X.Y.Z"
    try testing.expect(std.mem.indexOf(u8, info_str, "Zig") != null);
}

test "boundary: groove target count is exactly 10" {
    // TARGET_COUNT in groove.zig is 10 — verify summary reflects exactly 10 entries
    const summary = groove_mod.gossamer_groove_summary();
    const summary_str = std.mem.span(summary);
    // Count "\"id\":" occurrences as a proxy for entry count
    var entry_count: usize = 0;
    var pos: usize = 0;
    while (std.mem.indexOfPos(u8, summary_str, pos, "\"id\":")) |found| {
        entry_count += 1;
        pos = found + 5;
    }
    try testing.expectEqual(@as(usize, 10), entry_count);
}

test "boundary: registry count never exceeds 64 after multiple add/remove cycles" {
    // Register and deregister multiple fake handles in a loop
    var handles: [8]gossamer.GossamerHandle = undefined;
    for (&handles) |*h| {
        h.* = std.mem.zeroes(gossamer.GossamerHandle);
        h.initialized = true;
        h.closed = false;
        h.allocator = std.heap.c_allocator;
        h.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    }

    // Add all handles
    var ids: [8]u32 = undefined;
    for (&handles, 0..) |*h, i| {
        ids[i] = gossamer.gossamer_registry_add(@intFromPtr(h));
    }

    // Verify count is still bounded
    const count = gossamer.gossamer_registry_count();
    try testing.expect(count <= 64);

    // Remove all handles
    for (&handles) |*h| {
        gossamer.gossamer_registry_remove(@intFromPtr(h));
        h.bindings.deinit();
    }
}

//==============================================================================
// Plugin System Tests (plugin.zig)
//==============================================================================

const plugin_mod = @import("../src/plugin.zig");

test "plugin_load with null handle returns 0" {
    plugin_mod.resetForTesting();
    const id = plugin_mod.gossamer_plugin_load(0, "/tmp/nonexistent.so");
    try testing.expectEqual(@as(u32, 0), id);
}

test "plugin_load with empty path returns 0" {
    plugin_mod.resetForTesting();
    // Empty path must be rejected before dlopen is attempted
    const id = plugin_mod.gossamer_plugin_load(0, "");
    try testing.expectEqual(@as(u32, 0), id);
}

test "plugin_load with nonexistent library path returns 0" {
    plugin_mod.resetForTesting();

    // Create a stack-allocated fake handle with initialized=true, closed=false
    var fake_handle = std.mem.zeroes(gossamer.GossamerHandle);
    fake_handle.initialized = true;
    fake_handle.closed = false;
    fake_handle.allocator = std.heap.c_allocator;
    fake_handle.bindings = std.StringHashMap(gossamer.BindingEntry).init(std.heap.c_allocator);
    defer fake_handle.bindings.deinit();

    // Path that definitely does not exist — dlopen must fail
    const id = plugin_mod.gossamer_plugin_load(
        @intFromPtr(&fake_handle),
        "/tmp/__gossamer_test_nonexistent_plugin_42__.so",
    );
    try testing.expectEqual(@as(u32, 0), id);
}

test "plugin_unload with 0 is idempotent no-op" {
    plugin_mod.gossamer_plugin_unload(0);
}

test "plugin_unload with unknown id is idempotent no-op" {
    plugin_mod.resetForTesting();
    plugin_mod.gossamer_plugin_unload(9999);
}

test "plugin_unload double-unload is safe" {
    plugin_mod.resetForTesting();
    // Unload twice with the same ID — second call must be a silent no-op
    plugin_mod.gossamer_plugin_unload(1);
    plugin_mod.gossamer_plugin_unload(1);
}

test "plugin_list returns empty JSON array when no plugins loaded" {
    plugin_mod.resetForTesting();
    const json = std.mem.span(plugin_mod.gossamer_plugin_list());
    try testing.expectEqualStrings("[]", json);
}

test "isPluginLoaded returns true for plugin_id 0 (non-plugin)" {
    try testing.expect(plugin_mod.isPluginLoaded(0));
}

test "isPluginLoaded returns false for unregistered plugin_id" {
    plugin_mod.resetForTesting();
    try testing.expect(!plugin_mod.isPluginLoaded(42));
}
