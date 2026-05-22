// Gossamer Core Operations Benchmarks
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Ported 1:1 from tests/bench/gossamer_bench.ts. Zig has no built-in bench
// harness comparable to Deno.bench, so each bench is implemented as a
// `zig test` block that times its body under std.time.Timer and prints
// per-op latency / throughput. The assertion is just `true` so the test
// runner doesn't flag a failure; the value is in the printed numbers.
//
// Covered groups (mirrors the TS port):
//   ipc           — IPC message serialisation
//   capability    — capability lookup at 100 / 1000 / 10000 entries
//   path          — path normalisation
//   dialog        — dialog state machine transitions
//   result        — result code → name lookup
//   ipc-validate  — IPC command name validation
//
// Run via:
//   zig test src/interface/ffi/test/gossamer_bench.zig
// Add -OReleaseFast for realistic numbers.

const std = @import("std");
const testing = std.testing;

//==============================================================================
// Bench reporter (closure-free — Zig anonymous structs can't capture locals,
// so each test inlines its own timing loop and calls reportBench at the end)
//==============================================================================

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
// IPC message serialisation
//==============================================================================

const IPCMessage = struct {
    source: []const u8,
    command: []const u8,
    payload: []const u8, // pre-stringified JSON; mirrors `unknown` in TS
};

const SAMPLE_MESSAGES = [_]IPCMessage{
    .{ .source = "webview-0", .command = "open-file", .payload = "{\"path\":\"/tmp/file.txt\"}" },
    .{ .source = "panel-1", .command = "save", .payload = "{\"data\":\"content\",\"compress\":true}" },
    .{ .source = "cli", .command = "ping", .payload = "null" },
    .{ .source = "backend", .command = "list-dir", .payload = "{\"dir\":\"/home/user\",\"recursive\":false}" },
    .{ .source = "webview-2", .command = "eval-js", .payload = "{\"script\":\"document.title\",\"timeout\":5000}" },
};

fn serialiseMessage(allocator: std.mem.Allocator, msg: IPCMessage) ![]u8 {
    return try std.fmt.allocPrint(
        allocator,
        "{{\"source\":\"{s}\",\"command\":\"{s}\",\"payload\":{s}}}",
        .{ msg.source, msg.command, msg.payload },
    );
}

test "ipc/serialise: single small message" {
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        const out = try serialiseMessage(testing.allocator, SAMPLE_MESSAGES[0]);
        testing.allocator.free(out);
    }
    reportBench("ipc/serialise: single small message", iters, timer.read());
}

test "ipc/serialise: large payload (1KB)" {
    const iters: u64 = 10_000;
    var big_payload: [1024 + 2]u8 = undefined;
    big_payload[0] = '"';
    @memset(big_payload[1..1025], 'x');
    big_payload[1025] = '"';
    const msg = IPCMessage{ .source = "webview-0", .command = "send-data", .payload = &big_payload };
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        const out = try serialiseMessage(testing.allocator, msg);
        testing.allocator.free(out);
    }
    reportBench("ipc/serialise: large payload (1KB)", iters, timer.read());
}

test "ipc/serialise: batch of 100 messages" {
    const iters: u64 = 1_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            const out = try serialiseMessage(testing.allocator, SAMPLE_MESSAGES[i % SAMPLE_MESSAGES.len]);
            testing.allocator.free(out);
        }
    }
    reportBench("ipc/serialise: batch of 100 messages", iters, timer.read());
}

//==============================================================================
// Capability lookup
//==============================================================================

const BenchCapEntry = struct { kind: u32, revoked: bool };
const BenchCapMap = std.AutoHashMap(u64, BenchCapEntry);

fn buildCapMap(allocator: std.mem.Allocator, size: u64) !BenchCapMap {
    var map = BenchCapMap.init(allocator);
    var i: u64 = 0;
    while (i < size) : (i += 1) {
        try map.put(i + 1, .{ .kind = @intCast(i % 7), .revoked = false });
    }
    return map;
}

fn capCheck(map: *const BenchCapMap, token: u64) bool {
    if (map.get(token)) |e| return !e.revoked;
    return false;
}

test "capability/check: lookup in 100-entry registry" {
    var reg = try buildCapMap(testing.allocator, 100);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 50);
    reportBench("capability/check: lookup in 100-entry registry", iters, timer.read());
}

test "capability/check: lookup in 1000-entry registry" {
    var reg = try buildCapMap(testing.allocator, 1000);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 500);
    reportBench("capability/check: lookup in 1000-entry registry", iters, timer.read());
}

test "capability/check: lookup in 10000-entry registry" {
    var reg = try buildCapMap(testing.allocator, 10000);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 5000);
    reportBench("capability/check: lookup in 10000-entry registry", iters, timer.read());
}

test "capability/check: miss (token not in registry)" {
    var reg = try buildCapMap(testing.allocator, 10000);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 99999);
    reportBench("capability/check: miss (token not in registry)", iters, timer.read());
}

test "capability/check: first entry (best case)" {
    var reg = try buildCapMap(testing.allocator, 10000);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 1);
    reportBench("capability/check: first entry (best case)", iters, timer.read());
}

test "capability/check: last entry (worst case)" {
    var reg = try buildCapMap(testing.allocator, 10000);
    defer reg.deinit();
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = capCheck(&reg, 10000);
    reportBench("capability/check: last entry (worst case)", iters, timer.read());
}

//==============================================================================
// Path normalisation
//==============================================================================

fn normalisePath(allocator: std.mem.Allocator, p: []const u8) ?[]u8 {
    if (std.mem.indexOfScalar(u8, p, 0)) |_| return null;
    var out: std.ArrayList(u8) = .empty;
    var prev_slash = false;
    for (p) |c| {
        if (c == '/') {
            if (!prev_slash) out.append(allocator, '/') catch {
                out.deinit(allocator);
                return null;
            };
            prev_slash = true;
        } else {
            out.append(allocator, c) catch {
                out.deinit(allocator);
                return null;
            };
            prev_slash = false;
        }
    }
    if (out.items.len > 1 and out.items[out.items.len - 1] == '/') {
        _ = out.pop();
    }
    if (out.items.len == 0) {
        out.append(allocator, '/') catch {
            out.deinit(allocator);
            return null;
        };
    }
    return out.toOwnedSlice(allocator) catch null;
}

const SAMPLE_PATHS = [_][]const u8{
    "/home/user/docs",
    "/tmp//file.txt",
    "relative/path/to/file",
    "/var/lib/gossamer/data/",
    "/a/b/c/d/e/f/g/h",
    "./local/file",
};

test "path/normalise: single path" {
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        if (normalisePath(testing.allocator, "/home/user//docs/")) |out| testing.allocator.free(out);
    }
    reportBench("path/normalise: single path", iters, timer.read());
}

test "path/normalise: batch of 100 paths" {
    const iters: u64 = 1_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            if (normalisePath(testing.allocator, SAMPLE_PATHS[i % SAMPLE_PATHS.len])) |out|
                testing.allocator.free(out);
        }
    }
    reportBench("path/normalise: batch of 100 paths", iters, timer.read());
}

test "path/normalise: path with null byte (rejection)" {
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        if (normalisePath(testing.allocator, "/tmp/file\x00evil")) |out| testing.allocator.free(out);
    }
    reportBench("path/normalise: path with null byte (rejection)", iters, timer.read());
}

test "path/normalise: deeply nested path (10 levels)" {
    const iters: u64 = 100_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        if (normalisePath(testing.allocator, "/a/b/c/d/e/f/g/h/i/j/file.txt")) |out|
            testing.allocator.free(out);
    }
    reportBench("path/normalise: deeply nested path (10 levels)", iters, timer.read());
}

//==============================================================================
// Dialog state machine transitions
//==============================================================================

const DialogState = enum { idle, open, save, openDir, multi, cancelled, selected };

fn transitionDialog(from: DialogState, action: []const u8) DialogState {
    return switch (from) {
        .idle => blk: {
            if (std.mem.eql(u8, action, "show-open")) break :blk .open;
            if (std.mem.eql(u8, action, "show-save")) break :blk .save;
            if (std.mem.eql(u8, action, "show-dir")) break :blk .openDir;
            if (std.mem.eql(u8, action, "show-multi")) break :blk .multi;
            break :blk .idle;
        },
        .open, .save, .openDir, .multi => blk: {
            if (std.mem.eql(u8, action, "confirm")) break :blk .selected;
            if (std.mem.eql(u8, action, "cancel")) break :blk .cancelled;
            break :blk from;
        },
        .selected, .cancelled => blk: {
            if (std.mem.eql(u8, action, "reset")) break :blk .idle;
            break :blk from;
        },
    };
}

test "dialog/transition: single state transition" {
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = transitionDialog(.idle, "show-open");
    reportBench("dialog/transition: single state transition", iters, timer.read());
}

test "dialog/transition: full open->select->reset cycle" {
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) {
        var s: DialogState = .idle;
        s = transitionDialog(s, "show-open");
        s = transitionDialog(s, "confirm");
        _ = transitionDialog(s, "reset");
    }
    reportBench("dialog/transition: full open->select->reset cycle", iters, timer.read());
}

test "dialog/transition: 1000 transitions" {
    const actions = [_][]const u8{ "show-open", "confirm", "reset", "show-save", "cancel", "reset" };
    const iters: u64 = 1_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var s: DialogState = .idle;
        var i: usize = 0;
        while (i < 1000) : (i += 1) s = transitionDialog(s, actions[i % actions.len]);
    }
    reportBench("dialog/transition: 1000 transitions", iters, timer.read());
}

//==============================================================================
// Result code round-trip
//==============================================================================

fn resultToName(code: u32) ?[]const u8 {
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
        else => null,
    };
}

test "result/lookup: single code lookup" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = resultToName(10);
    reportBench("result/lookup: single code lookup", iters, timer.read());
}

test "result/lookup: all 12 codes" {
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: u32 = 0;
        while (i <= 11) : (i += 1) _ = resultToName(i);
    }
    reportBench("result/lookup: all 12 codes", iters, timer.read());
}

test "result/lookup: 1000 random code lookups" {
    const iters: u64 = 10_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: u32 = 0;
        while (i < 1000) : (i += 1) _ = resultToName(i % 12);
    }
    reportBench("result/lookup: 1000 random code lookups", iters, timer.read());
}

//==============================================================================
// IPC command validation throughput
//==============================================================================

fn isValidIPCCommand(name: []const u8) bool {
    if (name.len == 0 or name.len > 255) return false;
    for (name) |c| {
        const ok = (c >= 'a' and c <= 'z') or
            (c >= 'A' and c <= 'Z') or
            (c >= '0' and c <= '9') or
            c == '_' or c == '-';
        if (!ok) return false;
    }
    return true;
}

const VALID_COMMANDS = [_][]const u8{
    "open-file", "save", "ping", "list-dir", "close-window",
    "navigate", "eval-js", "set-title", "show-dialog", "request-cap",
};

test "ipc/validate: single valid command name" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = isValidIPCCommand("open-file");
    reportBench("ipc/validate: single valid command name", iters, timer.read());
}

test "ipc/validate: single invalid command name" {
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = isValidIPCCommand("cmd;evil");
    reportBench("ipc/validate: single invalid command name", iters, timer.read());
}

test "ipc/validate: 1000 valid commands" {
    const iters: u64 = 10_000;
    var timer = try std.time.Timer.start();
    var k: u64 = 0;
    while (k < iters) : (k += 1) {
        var i: usize = 0;
        while (i < 1000) : (i += 1) _ = isValidIPCCommand(VALID_COMMANDS[i % VALID_COMMANDS.len]);
    }
    reportBench("ipc/validate: 1000 valid commands", iters, timer.read());
}

test "ipc/validate: max-length valid name (255 chars)" {
    var max_name: [255]u8 = undefined;
    @memset(&max_name, 'a');
    const iters: u64 = 1_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = isValidIPCCommand(&max_name);
    reportBench("ipc/validate: max-length valid name (255 chars)", iters, timer.read());
}

test "ipc/validate: over-length name (256 chars) rejection" {
    var over_name: [256]u8 = undefined;
    @memset(&over_name, 'a');
    const iters: u64 = 10_000_000;
    var timer = try std.time.Timer.start();
    var i: u64 = 0;
    while (i < iters) : (i += 1) _ = isValidIPCCommand(&over_name);
    reportBench("ipc/validate: over-length name (256 chars) rejection", iters, timer.read());
}
