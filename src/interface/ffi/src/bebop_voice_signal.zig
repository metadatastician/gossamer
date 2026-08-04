// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Bebop VoiceSignal decoder (spline ADR-0005 criterion (b)).
//
// Decodes burble's voice-signalling plane: the VoiceSignal union defined in
// burble `server/priv/schemas/voice_signal.bop` and produced by burble's OWN
// generator (`mix bebop.generate`). Interop is validated against burble's
// ACTUAL bytes (vendored fixtures, see test/bebop_fixtures/) — burble's
// generator, not the Bebop spec, is what is deployed.
//
// Wire format (as burble emits it):
//   - strings:  u32-LE length prefix + UTF-8 bytes (returned zero-copy)
//   - bool:     one byte, 0 or 1 — anything else is malformed
//   - u16/u32:  little-endian; f32: IEEE 754 LE
//   - enums:    one byte (uint8-backed)
//   - union:    1-byte discriminator tag, then the variant payload
//
// STRICT by construction, matching burble's post-2026-08-04 decoders: a frame
// that declares more bytes than it carries, a garbage bool byte, an unknown
// enum value, or an unknown tag is an error — never a defaulted value.
//
// Pure Zig, std-only, no allocation: decoded strings are slices into the
// input buffer and live exactly as long as it does.

const std = @import("std");

pub const DecodeError = error{
    Truncated,
    LengthOverflow,
    InvalidBool,
    UnknownEnum,
    UnknownTag,
};

// --- Enums (values pinned by voice_signal.bop) ------------------------------

pub const AudioCodec = enum(u8) {
    opus = 1,
    lyra = 2,

    fn from(byte: u8) DecodeError!AudioCodec {
        return switch (byte) {
            1 => .opus,
            2 => .lyra,
            else => DecodeError.UnknownEnum,
        };
    }
};

pub const MuteState = enum(u8) {
    unmuted = 0,
    self_muted = 1,
    server_muted = 2,

    fn from(byte: u8) DecodeError!MuteState {
        return switch (byte) {
            0 => .unmuted,
            1 => .self_muted,
            2 => .server_muted,
            else => DecodeError.UnknownEnum,
        };
    }
};

pub const DeafenState = enum(u8) {
    undeafened = 0,
    self_deafened = 1,
    server_deafened = 2,

    fn from(byte: u8) DecodeError!DeafenState {
        return switch (byte) {
            0 => .undeafened,
            1 => .self_deafened,
            2 => .server_deafened,
            else => DecodeError.UnknownEnum,
        };
    }
};

/// Value-aligned with room_event.bop's LeaveReason (burble ruling A3).
pub const LeaveReason = enum(u8) {
    voluntary = 0,
    kicked = 1,
    banned = 2,
    timeout = 3,
    server_shutdown = 4,

    fn from(byte: u8) DecodeError!LeaveReason {
        return switch (byte) {
            0 => .voluntary,
            1 => .kicked,
            2 => .banned,
            3 => .timeout,
            4 => .server_shutdown,
            else => DecodeError.UnknownEnum,
        };
    }
};

// --- Structs ----------------------------------------------------------------

pub const Vec3 = struct { x: f32, y: f32, z: f32 };

pub const SdpPayload = struct {
    sdp: []const u8,
    media_type: []const u8,
};

pub const IceCandidatePayload = struct {
    candidate: []const u8,
    sdp_m_line_index: u16,
    sdp_mid: []const u8,
    username_fragment: []const u8,
};

// --- Messages ---------------------------------------------------------------

pub const Join = struct {
    room_id: []const u8,
    user_id: []const u8,
    display_name: []const u8,
    codec: AudioCodec,
    self_muted: bool,
    position: Vec3,
};

pub const Leave = struct {
    room_id: []const u8,
    user_id: []const u8,
    reason: LeaveReason,
};

pub const Mute = struct {
    room_id: []const u8,
    user_id: []const u8,
    state: MuteState,
};

pub const Unmute = struct {
    room_id: []const u8,
    user_id: []const u8,
};

pub const Deafen = struct {
    room_id: []const u8,
    user_id: []const u8,
    state: DeafenState,
};

pub const SpeakingStart = struct {
    room_id: []const u8,
    user_id: []const u8,
    audio_level: f32,
};

pub const SpeakingStop = struct {
    room_id: []const u8,
    user_id: []const u8,
};

pub const PositionUpdate = struct {
    room_id: []const u8,
    user_id: []const u8,
    position: Vec3,
    orientation: f32,
};

pub const Offer = struct {
    room_id: []const u8,
    user_id: []const u8,
    sdp: SdpPayload,
};

pub const Answer = struct {
    room_id: []const u8,
    user_id: []const u8,
    sdp: SdpPayload,
};

pub const IceCandidate = struct {
    room_id: []const u8,
    user_id: []const u8,
    candidate: IceCandidatePayload,
};

/// Variant set mirrors the union declaration in voice_signal.bop; the WIRE
/// tag values (1..11) are handled explicitly in decode() — the Zig tag enum
/// is internal and carries no wire meaning.
pub const VoiceSignal = union(enum) {
    join: Join,
    leave: Leave,
    mute: Mute,
    unmute: Unmute,
    deafen: Deafen,
    speaking_start: SpeakingStart,
    speaking_stop: SpeakingStop,
    position_update: PositionUpdate,
    offer: Offer,
    answer: Answer,
    ice_candidate: IceCandidate,
};

pub const Decoded = struct {
    signal: VoiceSignal,
    /// Bytes remaining after the frame — burble's decoders return the tail
    /// the same way; callers that require exact-length frames assert
    /// `rest.len == 0`.
    rest: []const u8,
};

// --- Reader -----------------------------------------------------------------

const Reader = struct {
    buf: []const u8,
    pos: usize = 0,

    fn remaining(self: *const Reader) usize {
        return self.buf.len - self.pos;
    }

    fn take(self: *Reader, n: usize) DecodeError![]const u8 {
        if (self.remaining() < n) return DecodeError.Truncated;
        const s = self.buf[self.pos .. self.pos + n];
        self.pos += n;
        return s;
    }

    fn u8v(self: *Reader) DecodeError!u8 {
        const s = try self.take(1);
        return s[0];
    }

    fn u16le(self: *Reader) DecodeError!u16 {
        const s = try self.take(2);
        return std.mem.readInt(u16, s[0..2], .little);
    }

    fn u32le(self: *Reader) DecodeError!u32 {
        const s = try self.take(4);
        return std.mem.readInt(u32, s[0..4], .little);
    }

    fn f32le(self: *Reader) DecodeError!f32 {
        const s = try self.take(4);
        return @bitCast(std.mem.readInt(u32, s[0..4], .little));
    }

    fn boolv(self: *Reader) DecodeError!bool {
        return switch (try self.u8v()) {
            0 => false,
            1 => true,
            else => DecodeError.InvalidBool,
        };
    }

    /// u32-LE length-prefixed string, zero-copy. The declared length is
    /// bounds-checked against the bytes actually present (the class of hole
    /// burble's CI caught on 2026-07-28: 0xFFFFFFFF declared, 3 carried).
    fn string(self: *Reader) DecodeError![]const u8 {
        const len = try self.u32le();
        if (len > self.remaining()) return DecodeError.LengthOverflow;
        return self.take(len);
    }

    fn vec3(self: *Reader) DecodeError!Vec3 {
        return .{ .x = try self.f32le(), .y = try self.f32le(), .z = try self.f32le() };
    }

    fn sdpPayload(self: *Reader) DecodeError!SdpPayload {
        return .{ .sdp = try self.string(), .media_type = try self.string() };
    }

    fn iceCandidatePayload(self: *Reader) DecodeError!IceCandidatePayload {
        return .{
            .candidate = try self.string(),
            .sdp_m_line_index = try self.u16le(),
            .sdp_mid = try self.string(),
            .username_fragment = try self.string(),
        };
    }
};

// --- Top-level decode -------------------------------------------------------

pub fn decode(bytes: []const u8) DecodeError!Decoded {
    var r = Reader{ .buf = bytes };
    const tag = try r.u8v();

    const signal: VoiceSignal = switch (tag) {
        1 => .{ .join = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .display_name = try r.string(),
            .codec = try AudioCodec.from(try r.u8v()),
            .self_muted = try r.boolv(),
            .position = try r.vec3(),
        } },
        2 => .{ .leave = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .reason = try LeaveReason.from(try r.u8v()),
        } },
        3 => .{ .mute = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .state = try MuteState.from(try r.u8v()),
        } },
        4 => .{ .unmute = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
        } },
        5 => .{ .deafen = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .state = try DeafenState.from(try r.u8v()),
        } },
        6 => .{ .speaking_start = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .audio_level = try r.f32le(),
        } },
        7 => .{ .speaking_stop = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
        } },
        8 => .{ .position_update = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .position = try r.vec3(),
            .orientation = try r.f32le(),
        } },
        9 => .{ .offer = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .sdp = try r.sdpPayload(),
        } },
        10 => .{ .answer = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .sdp = try r.sdpPayload(),
        } },
        11 => .{ .ice_candidate = .{
            .room_id = try r.string(),
            .user_id = try r.string(),
            .candidate = try r.iceCandidatePayload(),
        } },
        else => return DecodeError.UnknownTag,
    };

    return .{ .signal = signal, .rest = r.buf[r.pos..] };
}

// --- Tests ------------------------------------------------------------------
//
// Two layers:
//   1. Hand-built frames that pin the wire layout independently (mirrors of
//      burble's own byte-layout tests).
//   2. Vendored fixture frames produced by burble's ACTUAL generator — the
//      interop proof (criterion (b) validates against deployed bytes, not
//      the Bebop spec).

const testing = std.testing;

/// Fixed-buffer frame builder — no allocator, no std container API drift.
const FrameBuilder = struct {
    buf: [512]u8 = undefined,
    len: usize = 0,

    fn append(self: *FrameBuilder, byte: u8) void {
        self.buf[self.len] = byte;
        self.len += 1;
    }

    fn appendSlice(self: *FrameBuilder, s: []const u8) void {
        @memcpy(self.buf[self.len..][0..s.len], s);
        self.len += s.len;
    }

    fn appendString(self: *FrameBuilder, s: []const u8) void {
        var lenb: [4]u8 = undefined;
        std.mem.writeInt(u32, &lenb, @intCast(s.len), .little);
        self.appendSlice(&lenb);
        self.appendSlice(s);
    }

    fn appendF32(self: *FrameBuilder, v: f32) void {
        var b: [4]u8 = undefined;
        std.mem.writeInt(u32, &b, @bitCast(v), .little);
        self.appendSlice(&b);
    }

    fn items(self: *const FrameBuilder) []const u8 {
        return self.buf[0..self.len];
    }
};

test "leave frame: pinned layout decodes (1-byte enum reason, ruling A3)" {
    // tag=2, "r", "u", reason=kicked(1) — byte-identical to burble's pinned
    // wire-layout test in wire_roundtrip_test.exs.
    const frame = [_]u8{ 2, 1, 0, 0, 0, 'r', 1, 0, 0, 0, 'u', 1 };
    const d = try decode(&frame);
    try testing.expectEqualStrings("r", d.signal.leave.room_id);
    try testing.expectEqualStrings("u", d.signal.leave.user_id);
    try testing.expectEqual(LeaveReason.kicked, d.signal.leave.reason);
    try testing.expectEqual(@as(usize, 0), d.rest.len);
}

test "offer frame: nested SdpPayload round-trips zero-copy" {
    var frame = FrameBuilder{};
    frame.append(9); // Offer tag
    frame.appendString("room-1");
    frame.appendString("user-1");
    frame.appendString("v=0\r\n");
    frame.appendString("audio");

    const d = try decode(frame.items());
    try testing.expectEqualStrings("room-1", d.signal.offer.room_id);
    try testing.expectEqualStrings("v=0\r\n", d.signal.offer.sdp.sdp);
    try testing.expectEqualStrings("audio", d.signal.offer.sdp.media_type);
}

test "EVERY strict prefix of a valid frame is rejected" {
    var frame = FrameBuilder{};
    frame.append(1); // Join tag
    frame.appendString("room-abc123");
    frame.appendString("user-42");
    frame.appendString("Ada");
    frame.append(1); // codec = opus
    frame.append(0); // self_muted = false
    frame.appendF32(1.5);
    frame.appendF32(-2.25);
    frame.appendF32(0.0);

    // The full frame decodes.
    const full = try decode(frame.items());
    try testing.expectEqual(AudioCodec.opus, full.signal.join.codec);
    try testing.expectEqual(@as(usize, 0), full.rest.len);

    // No strict prefix may decode — which DecodeError depends on where the
    // cut lands (mid-prefix vs mid-body), so require an error, any error.
    var len: usize = 0;
    while (len < frame.len) : (len += 1) {
        const res = decode(frame.items()[0..len]);
        try testing.expect(std.meta.isError(res));
    }
}

test "declared string length beyond the buffer is LengthOverflow, not empty" {
    const frame = [_]u8{ 1, 0xFF, 0xFF, 0xFF, 0xFF, 'a', 'b', 'c' };
    try testing.expectError(DecodeError.LengthOverflow, decode(&frame));
}

test "garbage bool byte and unknown enum/tag are rejected" {
    // Join with codec byte 9 -> UnknownEnum.
    var bad_codec = FrameBuilder{};
    bad_codec.append(1);
    bad_codec.appendString("r");
    bad_codec.appendString("u");
    bad_codec.appendString("n");
    bad_codec.append(9);
    try testing.expectError(DecodeError.UnknownEnum, decode(bad_codec.items()));

    // Join with self_muted byte 7 -> InvalidBool.
    var bad_bool = FrameBuilder{};
    bad_bool.append(1);
    bad_bool.appendString("r");
    bad_bool.appendString("u");
    bad_bool.appendString("n");
    bad_bool.append(1); // opus
    bad_bool.append(7); // garbage bool
    try testing.expectError(DecodeError.InvalidBool, decode(bad_bool.items()));

    // Unknown union tag.
    try testing.expectError(DecodeError.UnknownTag, decode(&[_]u8{ 99, 1, 2, 3 }));
    try testing.expectError(DecodeError.Truncated, decode(&[_]u8{}));
}

test "INTEROP: every vendored frame from burble's actual generator decodes" {
    // testdata/voice_signal_frames.hex is produced by burble's own codecs
    // (provenance in its header) — this is the criterion-(b) proof that
    // gossamer parses the deployed plane, not a spec-shaped imitation of it.
    const fixtures = @embedFile("testdata/voice_signal_frames.hex");

    var frames_seen: usize = 0;
    var lines = std.mem.splitScalar(u8, fixtures, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        var parts = std.mem.splitScalar(u8, line, ' ');
        const name = parts.next().?;
        const hex = parts.next().?;

        var buf: [512]u8 = undefined;
        const bytes = try std.fmt.hexToBytes(buf[0 .. hex.len / 2], hex);

        const d = try decode(bytes);
        try testing.expectEqual(@as(usize, 0), d.rest.len);
        try testing.expectEqualStrings(name, @tagName(d.signal));

        // Every fixture uses the same identifiers — a cheap cross-variant
        // content check that would catch field-order drift.
        switch (d.signal) {
            inline else => |msg| {
                try testing.expectEqualStrings("room-fixture", msg.room_id);
                try testing.expectEqualStrings("user-1", msg.user_id);
            },
        }

        frames_seen += 1;
    }

    // All 11 union variants must be exercised — a silently shrunk fixture
    // file may not masquerade as coverage.
    try testing.expectEqual(@as(usize, 11), frames_seen);
}

test "INTEROP: fixture spot-checks pin cross-plane semantics" {
    const fixtures = @embedFile("testdata/voice_signal_frames.hex");

    var lines = std.mem.splitScalar(u8, fixtures, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        var parts = std.mem.splitScalar(u8, line, ' ');
        const name = parts.next().?;
        const hex = parts.next().?;
        var buf: [512]u8 = undefined;
        const bytes = try std.fmt.hexToBytes(buf[0 .. hex.len / 2], hex);
        const d = try decode(bytes);

        if (std.mem.eql(u8, name, "leave")) {
            // The A3 enum interop: burble encoded :kicked, we must see kicked.
            try testing.expectEqual(LeaveReason.kicked, d.signal.leave.reason);
        } else if (std.mem.eql(u8, name, "offer")) {
            try testing.expectEqualStrings("v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\n", d.signal.offer.sdp.sdp);
            try testing.expectEqualStrings("audio", d.signal.offer.sdp.media_type);
        } else if (std.mem.eql(u8, name, "ice_candidate")) {
            try testing.expectEqual(@as(u16, 0), d.signal.ice_candidate.candidate.sdp_m_line_index);
            try testing.expectEqualStrings("abcd", d.signal.ice_candidate.candidate.username_fragment);
        } else if (std.mem.eql(u8, name, "join")) {
            try testing.expectEqual(AudioCodec.opus, d.signal.join.codec);
            try testing.expect(!d.signal.join.self_muted);
            try testing.expectApproxEqAbs(@as(f32, 1.0), d.signal.join.position.x, 0.0001);
        }
    }
}

test "trailing bytes are surfaced as rest, matching burble's contract" {
    const frame = [_]u8{ 2, 1, 0, 0, 0, 'r', 1, 0, 0, 0, 'u', 0, 0xAA, 0xBB };
    const d = try decode(&frame);
    try testing.expectEqual(LeaveReason.voluntary, d.signal.leave.reason);
    try testing.expectEqualSlices(u8, &[_]u8{ 0xAA, 0xBB }, d.rest);
}

