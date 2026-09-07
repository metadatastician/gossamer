// SPDX-License-Identifier: MPL-2.0
//! One bounded, window-owned signaling worker. No GTK pointer, callback or
//! JavaScript credential crosses into this thread. Window destruction joins it.
const std = @import("std");
const main = @import("main.zig");
const groove = @import("groove.zig");
const Scope = @import("groove_voice.zig").Scope;
const Atomic = std.atomic.Value;
const allocator = std.heap.c_allocator;

pub const Status = enum(c_int) { connecting = 1, active = 2, ended = 3, failed = 4, stopping = 5, stopped = 6 };
fn receiveFailureStatus(mode: c_int, result: i32) Status {
    return if (mode == 1 and result == -2) .ended else .failed;
}
pub var live_workers: Atomic(u32) = .init(0);
const Frame = struct { data: [16384]u8 = [_]u8{0} ** 16384, len: usize = 0 };

const Queue = struct {
    frames: [4]Frame = [_]Frame{.{}} ** 4,
    count: usize = 0,

    fn push(self: *Queue, bytes: []const u8) bool {
        if (self.count == self.frames.len or bytes.len == 0 or bytes.len > 16384) return false;
        const frame = &self.frames[self.count];
        @memcpy(frame.data[0..bytes.len], bytes);
        frame.len = bytes.len;
        self.count += 1;
        return true;
    }

    fn pop(self: *Queue, out: *Frame) bool {
        if (self.count == 0) return false;
        out.* = self.frames[0];
        self.count -= 1;
        std.mem.copyForwards(Frame, self.frames[0..self.count], self.frames[1 .. self.count + 1]);
        std.crypto.secureZero(u8, std.mem.asBytes(&self.frames[self.count]));
        return true;
    }
};

pub const Host = struct {
    scope: Scope,
    mode: c_int,
    ttl: u32,
    origin: std.time.Instant,
    valid_until: Atomic(u64) = .init(0),
    thread: ?std.Thread = null,
    stop: Atomic(bool) = .init(false),
    status: Atomic(c_int) = .init(@intFromEnum(Status.connecting)),
    sent: Atomic(u64) = .init(0),
    mutex: std.Thread.Mutex = .{},
    outbound: Queue = .{},
    inbound: Queue = .{},

    pub fn start(scope: Scope, mode: c_int, ttl: u32) !*Host {
        if (mode < 0 or mode > 1 or ttl == 0 or ttl > 3600) return error.InvalidScope;
        const origin = try std.time.Instant.now();
        if (live_workers.fetchAdd(1, .acq_rel) >= 32) {
            _ = live_workers.fetchSub(1, .acq_rel);
            return error.Capacity;
        }
        errdefer _ = live_workers.fetchSub(1, .acq_rel);
        const host = try allocator.create(Host);
        errdefer allocator.destroy(host);
        host.* = .{ .scope = scope, .mode = mode, .ttl = ttl, .origin = origin };
        errdefer std.crypto.secureZero(u8, std.mem.asBytes(host));
        host.thread = try std.Thread.spawn(.{}, run, .{host});
        return host;
    }

    pub fn enqueue(self: *Host, bytes: []const u8) bool {
        if (!self.isActive()) return false;
        if (!self.scope.accepts(bytes, false)) return false;
        self.mutex.lock();
        defer self.mutex.unlock();
        if (!self.isActive()) return false;
        return self.outbound.push(bytes);
    }

    pub fn receive(self: *Host, out: []u8) i32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.stop.load(.acquire)) return 0;
        if (!self.isActive()) return -1;
        if (self.inbound.count == 0) return 0;
        if (out.len < self.inbound.frames[0].len) return -1;
        var frame: Frame = .{};
        defer std.crypto.secureZero(u8, std.mem.asBytes(&frame));
        _ = self.inbound.pop(&frame);
        @memcpy(out[0..frame.len], frame.data[0..frame.len]);
        return @intCast(frame.len);
    }

    fn elapsed(self: *const Host) ?u64 {
        const now = std.time.Instant.now() catch return null;
        return now.since(self.origin);
    }

    fn nextDeadline(self: *const Host) ?u64 {
        const windows: u64 = if (self.mode == 0) 3 else 1;
        return std.math.add(u64, self.elapsed() orelse return null, @as(u64, self.ttl) * windows * std.time.ns_per_s) catch null;
    }

    fn leaseFresh(self: *const Host) bool {
        const now = self.elapsed() orelse return false;
        return now < self.valid_until.load(.acquire);
    }

    fn isActive(self: *const Host) bool {
        return !self.stop.load(.acquire) and
            self.status.load(.acquire) == @intFromEnum(Status.active) and self.leaseFresh();
    }

    pub fn requestStop(self: *Host) void {
        self.stop.store(true, .release);
    }

    pub fn shutdown(self: *Host) void {
        self.requestStop();
        if (self.thread) |thread| thread.join();
        std.crypto.secureZero(u8, std.mem.asBytes(self));
        allocator.destroy(self);
    }

    fn run(self: *Host) void {
        defer _ = live_workers.fetchSub(1, .acq_rel);
        defer {
            std.crypto.secureZero(u8, &self.scope.token);
            self.scope.token_len = 0;
        }
        groove.wire_cancel = &self.stop;
        defer groove.wire_cancel = null;
        var handle: main.GrooveHandle = .invalid;
        defer {
            // Cancellation never suppresses the one bounded best-effort remote
            // release. Missing transport still leaves a finite provider lease.
            groove.wire_cancel = null;
            groove.wire_budget_ms = 500;
            if (handle != .invalid) _ = main.gossamer_groove_disconnect_session(handle);
            groove.wire_budget_ms = 5000;
            self.mutex.lock();
            std.crypto.secureZero(u8, std.mem.asBytes(&self.outbound));
            std.crypto.secureZero(u8, std.mem.asBytes(&self.inbound));
            self.mutex.unlock();
            if (self.stop.load(.acquire)) self.status.store(@intFromEnum(Status.stopped), .release);
        }
        // Mint before connect/renewal I/O, never after the response. This UI
        // horizon is conservative relative to the session/provider deadlines.
        const initial_deadline = self.nextDeadline() orelse {
            self.status.store(@intFromEnum(Status.failed), .release);
            return;
        };
        handle = main.gossamer_groove_voice_connect(0, self.mode, self.ttl, &self.scope.token, self.scope.token_len, &self.scope.room, self.scope.room_len, &self.scope.subject, self.scope.subject_len, &self.scope.peer, self.scope.peer_len);
        // The session table owns its credential copy. Keep only the non-secret
        // bound IDs here for UI-side enqueue validation.
        std.crypto.secureZero(u8, &self.scope.token);
        self.scope.token_len = 0;
        if (handle == .invalid) {
            self.status.store(@intFromEnum(Status.failed), .release);
            return;
        }
        self.valid_until.store(initial_deadline, .release);
        self.status.store(@intFromEnum(Status.active), .release);
        var maintenance = std.time.Timer.start() catch {
            self.status.store(@intFromEnum(Status.failed), .release);
            return;
        };
        var polling = std.time.Timer.start() catch {
            self.status.store(@intFromEnum(Status.failed), .release);
            return;
        };
        var frame: Frame = .{};
        defer std.crypto.secureZero(u8, std.mem.asBytes(&frame));
        while (!self.stop.load(.acquire)) {
            const observed_time = self.elapsed() orelse {
                self.status.store(@intFromEnum(Status.failed), .release);
                return;
            };
            if (observed_time >= self.valid_until.load(.acquire)) {
                self.status.store(@intFromEnum(receiveFailureStatus(self.mode, -2)), .release);
                return;
            }
            if (self.mode == 0 and maintenance.read() >= @as(u64, self.ttl) * std.time.ns_per_s / 2) {
                const renewed_deadline = self.nextDeadline() orelse {
                    self.status.store(@intFromEnum(Status.failed), .release);
                    return;
                };
                if (main.gossamer_groove_heartbeat(handle) != .ok) {
                    self.status.store(@intFromEnum(Status.failed), .release);
                    return;
                }
                self.valid_until.store(renewed_deadline, .release);
                maintenance.reset();
            }
            self.mutex.lock();
            const has_frame = self.outbound.pop(&frame);
            self.mutex.unlock();
            if (has_frame) {
                if (main.gossamer_groove_voice_send(handle, &frame.data, frame.len) != .ok) {
                    self.status.store(@intFromEnum(Status.failed), .release);
                    return;
                }
                _ = self.sent.fetchAdd(1, .acq_rel);
                std.crypto.secureZero(u8, std.mem.asBytes(&frame));
            }
            if (polling.read() >= 100 * std.time.ns_per_ms) {
                const length = main.receiveVoiceForHost(handle, &frame.data, frame.data.len);
                if (length < 0) {
                    self.status.store(@intFromEnum(receiveFailureStatus(self.mode, length)), .release);
                    return;
                }
                if (length > 0) {
                    self.mutex.lock();
                    const queued = self.inbound.push(frame.data[0..@intCast(length)]);
                    self.mutex.unlock();
                    std.crypto.secureZero(u8, std.mem.asBytes(&frame));
                    if (!queued) {
                        self.status.store(@intFromEnum(Status.failed), .release);
                        return;
                    }
                }
                polling.reset();
            }
            std.Thread.sleep(20 * std.time.ns_per_ms);
        }
    }
};

test "worker queues are bounded, ordered, and clear consumed storage" {
    var queue: Queue = .{};
    for (0..4) |_| try std.testing.expect(queue.push("control"));
    try std.testing.expect(!queue.push("overflow"));
    var frame: Frame = .{};
    try std.testing.expect(queue.pop(&frame));
    try std.testing.expectEqualStrings("control", frame.data[0..frame.len]);
    for (queue.frames[3].data) |byte| try std.testing.expectEqual(@as(u8, 0), byte);
    try std.testing.expect(queue.push("replacement"));
}

test "only local soft expiry is ended; transport failure is never clean expiry" {
    try std.testing.expectEqual(Status.ended, receiveFailureStatus(1, -2));
    try std.testing.expectEqual(Status.failed, receiveFailureStatus(1, -1));
    try std.testing.expectEqual(Status.failed, receiveFailureStatus(0, -2));
    try std.testing.expectEqual(Status.failed, receiveFailureStatus(0, -1));
}

test "UI queue rejects expired or failed authority without waiting for worker polling" {
    var host: Host = .{
        .scope = try Scope.init("fixture-not-a-credential", "room", "alice", "bob"),
        .mode = 1,
        .ttl = 1,
        .origin = try std.time.Instant.now(),
    };
    defer std.crypto.secureZero(u8, std.mem.asBytes(&host));
    host.status.store(@intFromEnum(Status.active), .release);
    host.valid_until.store(std.time.ns_per_s, .release);
    try std.testing.expect(host.isActive());
    try std.testing.expect(host.inbound.push("control"));
    var out: [32]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 7), host.receive(&out));
    try std.testing.expectEqualStrings("control", out[0..7]);
    try std.testing.expect(host.inbound.push("expired"));
    host.valid_until.store(0, .release);
    try std.testing.expect(!host.isActive());
    try std.testing.expectEqual(@as(i32, -1), host.receive(&out));
    try std.testing.expectEqualStrings("control", out[0..7]);
    host.valid_until.store(std.time.ns_per_s, .release);
    host.status.store(@intFromEnum(Status.failed), .release);
    try std.testing.expect(!host.isActive());
    try std.testing.expectEqual(@as(i32, -1), host.receive(&out));
}
