// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Groove session-lease demo — exercises the G-2/G-3 session API end to end
// against a LIVE groove service:
//
//   1. connect a SOFT lease with a short TTL, let it lapse, and show the
//      heartbeat reporting the lapse,
//   2. connect a HARD lease and heartbeat it across three TTL windows,
//   3. disconnect (consuming the handle — a second disconnect must fail
//      with already_consumed),
//   4. print the teardown audit summary.
//
// Usage:  zig build groove-demo -- <target-index>     (default 0 = burble)
//     or: just groove-demo 4                          (4 = panll)
//
// The demo needs the target service listening on its well-known groove port
// (see the target table in src/groove.zig, mirrored from
// groove/registry/groove-registry.json).

const std = @import("std");
const gossamer = @import("gossamer");

/// Fetch and unwrap the thread-local FFI error message.
fn lastError() [:0]const u8 {
    return std.mem.span(gossamer.gossamer_last_error() orelse "unknown error");
}

pub fn main() !void {
    var args = std.process.args();
    _ = args.next(); // argv[0]
    var target: u32 = 0;
    if (args.next()) |arg| {
        target = std.fmt.parseInt(u32, arg, 10) catch 0;
    }
    std.debug.print("groove demo: target index {d}\n", .{target});

    // 1. Soft lease with a short TTL — let it lapse.
    const soft_ttl: u32 = 2;
    const soft = gossamer.gossamer_groove_connect_session(target, 1, soft_ttl);
    if (soft == .invalid) {
        std.debug.print("soft connect failed: {s}\n", .{lastError()});
        return;
    }
    std.debug.print("soft lease acquired (ttl {d}s); letting it lapse...\n", .{soft_ttl});
    std.Thread.sleep(@as(u64, soft_ttl + 1) * std.time.ns_per_s);
    const lapsed = gossamer.gossamer_groove_heartbeat(soft);
    if (lapsed == .ok) {
        std.debug.print("heartbeat after lapse -> ok (target kept the lease alive)\n", .{});
    } else {
        std.debug.print("heartbeat after lapse -> {d} ({s})\n", .{ @intFromEnum(lapsed), lastError() });
    }
    _ = gossamer.gossamer_groove_disconnect_session(soft);

    // 2. Hard lease — heartbeat across three TTL windows.
    const hard_ttl: u32 = 3;
    const hard = gossamer.gossamer_groove_connect_session(target, 0, hard_ttl);
    if (hard == .invalid) {
        std.debug.print("hard connect failed: {s}\n", .{lastError()});
        return;
    }
    std.debug.print("hard lease acquired (ttl {d}s); heartbeating 3 windows...\n", .{hard_ttl});
    for (0..3) |window| {
        std.Thread.sleep(@as(u64, hard_ttl) * std.time.ns_per_s / 2);
        const hb = gossamer.gossamer_groove_heartbeat(hard);
        std.debug.print("heartbeat window {d} -> {d}\n", .{ window + 1, @intFromEnum(hb) });
    }

    // 3. Disconnect — consuming. The second call must fail (once-guard).
    const first = gossamer.gossamer_groove_disconnect_session(hard);
    const second = gossamer.gossamer_groove_disconnect_session(hard);
    std.debug.print("disconnect -> {d}; second disconnect (must fail) -> {d}\n", .{ @intFromEnum(first), @intFromEnum(second) });

    // 4. Audit summary of the ordered teardown descent.
    var buf: [4096]u8 = undefined;
    const n = gossamer.gossamer_groove_audit_summary(&buf, buf.len);
    std.debug.print("{s}", .{buf[0..n]});
}
