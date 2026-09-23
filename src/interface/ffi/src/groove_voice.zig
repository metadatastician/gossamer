// SPDX-License-Identifier: MPL-2.0
//! Scoped voice data validation. No posture parameter enters the frame codec.
const std = @import("std");
const bebop = @import("bebop_voice_signal.zig");

pub const Scope = struct {
    token: [4096]u8 = [_]u8{0} ** 4096,
    token_len: usize = 0,
    room: [128]u8 = [_]u8{0} ** 128,
    room_len: usize = 0,
    subject: [128]u8 = [_]u8{0} ** 128,
    subject_len: usize = 0,
    peer: [128]u8 = [_]u8{0} ** 128,
    peer_len: usize = 0,
    timer: std.time.Timer,

    pub fn init(token: []const u8, room: []const u8, subject: []const u8, peer: []const u8) !Scope {
        if (token.len == 0 or token.len > 4096 or !validId(room) or !validId(subject) or !validId(peer) or std.mem.eql(u8, subject, peer)) return error.InvalidScope;
        for (token) |c| if (!std.ascii.isAlphanumeric(c) and c != '-' and c != '_' and c != '.') return error.InvalidScope;
        var scope = Scope{ .timer = try std.time.Timer.start(), .token_len = token.len, .room_len = room.len, .subject_len = subject.len, .peer_len = peer.len };
        @memcpy(scope.token[0..token.len], token);
        @memcpy(scope.room[0..room.len], room);
        @memcpy(scope.subject[0..subject.len], subject);
        @memcpy(scope.peer[0..peer.len], peer);
        return scope;
    }

    pub fn accepts(self: *const Scope, bytes: []const u8, incoming: bool) bool {
        if (bytes.len == 0 or bytes.len > 16384) return false;
        const decoded = bebop.decode(bytes) catch return false;
        if (decoded.rest.len != 0) return false;
        const expected = if (incoming) self.peer[0..self.peer_len] else self.subject[0..self.subject_len];
        return switch (decoded.signal) {
            inline .offer, .answer, .ice_candidate => |msg| std.mem.eql(u8, msg.room_id, self.room[0..self.room_len]) and std.mem.eql(u8, msg.user_id, expected),
            else => false,
        };
    }
};

fn validId(id: []const u8) bool {
    if (id.len == 0 or id.len > 128) return false;
    for (id) |c| if (!std.ascii.isAlphanumeric(c) and c != '-' and c != '_' and c != '.') return false;
    return true;
}

test "scope rejects header injection and non-signaling frames" {
    try std.testing.expectError(error.InvalidScope, Scope.init("token\r\nInjected: x", "room", "alice", "bob"));
    var scope = try Scope.init("token", "room", "alice", "bob");
    try std.testing.expect(!scope.accepts(&.{ 9, 255 }, false));
    try std.testing.expect(!scope.accepts(&.{99}, true));
}
