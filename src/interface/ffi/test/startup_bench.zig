// Gossamer Startup Benchmarks
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Ported 1:1 from tests/bench/startup_bench.ts. Same harness shape as
// gossamer_bench.zig — each test inlines its timing loop and calls
// reportBench. Run with `-OReleaseFast` for realistic numbers.
//
// NOTE: the TS port's RESULT_MAP carries 15 codes (Ok..DeadlockDetected) —
// 3 more than Types.idr's 12. That's pre-existing drift in the TS file and
// is preserved here so the port is faithful; it's a benchmark-only static
// lookup, not an ABI assertion.
//
// Run via:
//   zig test src/interface/ffi/test/startup_bench.zig

const std = @import("std");
const testing = std.testing;

fn reportBench(name: []const u8, iterations: u64, elapsed_ns: u64) void {
    const per_op_ns: f64 = if (iterations == 0) 0 else @as(f64, @floatFromInt(elapsed_ns)) /
        @as(f64, @floatFromInt(iterations));
    const ops_per_s: f64 = if (elapsed_ns == 0) 0 else @as(f64, @floatFromInt(iterations)) *
        std.time.ns_per_s / @as(f64, @floatFromInt(elapsed_ns));
    std.debug.print(
        "BENCH {s:<60}  iters={d:>8}  {d:>8.1} ns/op  {d:>12.0} ops/s\n",
        .{ name, iterations, per_op_ns, ops_per_s },
    );
}

//==============================================================================
// WindowConfig creation
//==============================================================================

const WindowConfig = struct {
    label: []const u8,
    title: []const u8,
    width: u32,
    height: u32,
    min_width: ?u32,
    min_height: ?u32,
    max_width: ?u32,
    max_height: ?u32,
    resizable: bool,
    fullscreen: bool,
    decorations: bool,
    transparent: bool,
    center: bool,
    always_on_top: bool,
    visible: bool,
    url: []const u8,
};

const WINDOW_CONFIGS = [_]WindowConfig{
    .{
        .label = "main", .title = "My Gossamer App", .width = 1400, .height = 900,
        .min_width = 1000, .min_height = 600, .max_width = null, .max_height = null,
        .resizable = true, .fullscreen = false, .decorations = true, .transparent = false,
        .center = true, .always_on_top = false, .visible = true, .url = "/",
    },
    .{
        .label = "settings", .title = "Settings", .width = 800, .height = 600,
        .min_width = 600, .min_height = 400, .max_width = 1200, .max_height = 1000,
        .resizable = true, .fullscreen = false, .decorations = true, .transparent = false,
        .center = true, .always_on_top = false, .visible = false, .url = "/settings",
    },
};

test "startup/window-config: create single config" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        const config = WindowConfig{
            .label = "main", .title = "App", .width = 800, .height = 600,
            .min_width = 400, .min_height = 300, .max_width = null, .max_height = null,
            .resizable = true, .fullscreen = false, .decorations = true, .transparent = false,
            .center = true, .always_on_top = false, .visible = true, .url = "/",
        };
        std.mem.doNotOptimizeAway(config);
    }
    reportBench("startup/window-config: create single config", iters, timer.read());
}

test "startup/window-config: create 10 configs" {
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: u32 = 0;
        while (i < 10) : (i += 1) {
            const config = WindowConfig{
                .label = "window", .title = "Window N", .width = 1024 + i * 10,
                .height = 768 + i * 10, .min_width = 600, .min_height = 400,
                .max_width = null, .max_height = null, .resizable = true,
                .fullscreen = false, .decorations = true, .transparent = false,
                .center = true, .always_on_top = false, .visible = true, .url = "/window",
            };
            std.mem.doNotOptimizeAway(config);
        }
    }
    reportBench("startup/window-config: create 10 configs", iters, timer.read());
}

test "startup/window-config: clone config (struct copy)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        var clone = WINDOW_CONFIGS[0];
        std.mem.doNotOptimizeAway(&clone);
    }
    reportBench("startup/window-config: clone config (struct copy)", iters, timer.read());
}

//==============================================================================
// IPC channel creation + bind + dispatch
//==============================================================================

const IPCChannel = struct {
    id: u64,
    bound: bool,
    message_count: u64,
};

const IPCChannelManager = struct {
    channels: std.AutoHashMap(u64, IPCChannel),
    next_id: u64 = 1,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) IPCChannelManager {
        return .{
            .channels = std.AutoHashMap(u64, IPCChannel).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *IPCChannelManager) void {
        self.channels.deinit();
    }

    pub fn create(self: *IPCChannelManager) !u64 {
        const id = self.next_id;
        self.next_id += 1;
        try self.channels.put(id, .{ .id = id, .bound = false, .message_count = 0 });
        return id;
    }

    pub fn bind(self: *IPCChannelManager, id: u64) bool {
        if (self.channels.getPtr(id)) |ch| {
            ch.bound = true;
            return true;
        }
        return false;
    }

    pub fn dispatch(self: *IPCChannelManager, id: u64) bool {
        if (self.channels.getPtr(id)) |ch| {
            if (!ch.bound) return false;
            ch.message_count += 1;
            return true;
        }
        return false;
    }
};

test "startup/ipc: create single channel" {
    var mgr = IPCChannelManager.init(testing.allocator);
    defer mgr.deinit();
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = try mgr.create();
    reportBench("startup/ipc: create single channel", iters, timer.read());
}

test "startup/ipc: create + bind channel" {
    var mgr = IPCChannelManager.init(testing.allocator);
    defer mgr.deinit();
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        const id = try mgr.create();
        _ = mgr.bind(id);
    }
    reportBench("startup/ipc: create + bind channel", iters, timer.read());
}

test "startup/ipc: create + bind + dispatch round-trip" {
    var mgr = IPCChannelManager.init(testing.allocator);
    defer mgr.deinit();
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        const id = try mgr.create();
        _ = mgr.bind(id);
        _ = mgr.dispatch(id);
    }
    reportBench("startup/ipc: create + bind + dispatch round-trip", iters, timer.read());
}

test "startup/ipc: dispatch 100 times on bound channel" {
    var mgr = IPCChannelManager.init(testing.allocator);
    defer mgr.deinit();
    const id = try mgr.create();
    _ = mgr.bind(id);
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var j: usize = 0;
        while (j < 100) : (j += 1) _ = mgr.dispatch(id);
    }
    reportBench("startup/ipc: dispatch 100 times on bound channel", iters, timer.read());
}

test "startup/ipc: dispatch on 100 different channels (scatter)" {
    var mgr = IPCChannelManager.init(testing.allocator);
    defer mgr.deinit();
    var pre: [100]u64 = undefined;
    var p: usize = 0;
    while (p < 100) : (p += 1) {
        pre[p] = try mgr.create();
        _ = mgr.bind(pre[p]);
    }
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var j: usize = 0;
        while (j < 100) : (j += 1) _ = mgr.dispatch(pre[j]);
    }
    reportBench("startup/ipc: dispatch on 100 different channels (scatter)", iters, timer.read());
}

//==============================================================================
// Result code lookup (15 codes — preserves TS port's superset)
//==============================================================================

fn startupResultToName(code: u32) ?[]const u8 {
    return switch (code) {
        0 => "Ok",
        1 => "Error",
        2 => "InvalidParam",
        3 => "OutOfMemory",
        4 => "NullPointer",
        5 => "AlreadyConsumed",
        6 => "ResourceLeaked",
        7 => "DoubleFree",
        8 => "WebviewUnavailable",
        9 => "IPCProtocolError",
        10 => "CapabilityDenied",
        11 => "GuardLocked",
        12 => "TimeoutExpired",
        13 => "ThreadPanic",
        14 => "DeadlockDetected",
        else => null,
    };
}

test "startup/result: single code lookup (Ok)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(startupResultToName(0));
    reportBench("startup/result: single code lookup (Ok)", iters, timer.read());
}

test "startup/result: single code lookup (middle value)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(startupResultToName(7));
    reportBench("startup/result: single code lookup (middle value)", iters, timer.read());
}

test "startup/result: single code lookup (high value)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(startupResultToName(14));
    reportBench("startup/result: single code lookup (high value)", iters, timer.read());
}

test "startup/result: all 15 code lookups" {
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: u32 = 0;
        while (i <= 14) : (i += 1) std.mem.doNotOptimizeAway(startupResultToName(i));
    }
    reportBench("startup/result: all 15 code lookups", iters, timer.read());
}

test "startup/result: 1000 lookups (cycling through 15 codes)" {
    const iters: u64 = 10_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: u32 = 0;
        while (i < 1000) : (i += 1) std.mem.doNotOptimizeAway(startupResultToName(i % 15));
    }
    reportBench("startup/result: 1000 lookups (cycling through 15 codes)", iters, timer.read());
}

//==============================================================================
// Capability set subset checking
//==============================================================================

const Capability = enum { filesystem, network, shell, clipboard, notification, tray };

fn checkSubset(requested: []const Capability, allowed: []const Capability) bool {
    outer: for (requested) |r| {
        for (allowed) |a| {
            if (r == a) continue :outer;
        }
        return false;
    }
    return true;
}

const CAPS_ALL = [_]Capability{ .filesystem, .network, .shell, .clipboard, .notification, .tray };
const CAPS_COMMON = [_]Capability{ .filesystem, .network, .clipboard };
const CAPS_RESTRICTED = [_]Capability{.clipboard};

test "startup/capability: check single cap subset (1 vs 6)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(checkSubset(&.{.filesystem}, &CAPS_ALL));
    reportBench("startup/capability: check single cap subset (1 vs 6)", iters, timer.read());
}

test "startup/capability: check 3-cap subset (3 vs 6)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(checkSubset(&CAPS_COMMON, &CAPS_ALL));
    reportBench("startup/capability: check 3-cap subset (3 vs 6)", iters, timer.read());
}

test "startup/capability: check 6-cap subset (6 vs 6, full match)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(checkSubset(&CAPS_ALL, &CAPS_ALL));
    reportBench("startup/capability: check 6-cap subset (6 vs 6, full match)", iters, timer.read());
}

test "startup/capability: check denied subset (1 vs 3, fails)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1)
        std.mem.doNotOptimizeAway(checkSubset(&.{.shell}, &CAPS_RESTRICTED));
    reportBench("startup/capability: check denied subset (1 vs 3, fails)", iters, timer.read());
}

test "startup/capability: check 100 random subsets (6-cap allowed)" {
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            const len = (i % CAPS_ALL.len) + 1;
            std.mem.doNotOptimizeAway(checkSubset(CAPS_ALL[0..len], &CAPS_ALL));
        }
    }
    reportBench("startup/capability: check 100 random subsets (6-cap allowed)", iters, timer.read());
}

test "startup/capability: check empty vs full (security check fast-path)" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    const empty = [_]Capability{};
    while (i < iters) : (i += 1) std.mem.doNotOptimizeAway(checkSubset(&empty, &CAPS_ALL));
    reportBench("startup/capability: check empty vs full (security check fast-path)", iters, timer.read());
}
