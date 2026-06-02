// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — IPC envelope parsing (platform-agnostic)
//
// The injected JavaScript bridge in main.zig double-encodes each call: the
// user payload is stringified, embedded as a string field inside the outer
// message, and the whole message is stringified again. So the wire message
// for `invoke("greet", { from: "page" })` is, verbatim:
//
//   {"id":"...","name":"greet","payload":"{\"from\":\"page\"}","binary":0}
//
// The `payload` field is therefore a JSON *string* whose interior quotes are
// escaped. A real JSON parser unescapes it, yielding the genuine inner JSON
// (`{"from":"page"}`) that the bound handler and the language bindings expect.
// Every platform backend shares this format, so the parse lives here once
// rather than being re-derived (and mis-derived) in each backend.

const std = @import("std");

//## The IPC envelope as sent by the injected bridge.
// `id` is mandatory: an envelope without one cannot be answered, so a missing
// id is a parse error and the message is dropped. `name`, `payload`, and
// `binary` default, so a structurally valid envelope still decodes when a
// field is absent; the backend decides how to treat an empty name. `binary`
// is a JSON number on the wire (0 or 1), not a string.
pub const Envelope = struct {
    id: []const u8,
    name: []const u8 = "",
    payload: []const u8 = "",
    binary: i64 = 0,
};

//## Parse one IPC envelope with a real JSON parser.
// The returned value owns its decoded strings (in an internal arena); they
// live until `deinit()`. The caller must duplicate anything that has to
// outlive the parse before calling `deinit()`. `ignore_unknown_fields` keeps
// the parser forward-compatible with new envelope fields.
pub fn parseEnvelope(
    allocator: std.mem.Allocator,
    msg: []const u8,
) !std.json.Parsed(Envelope) {
    return std.json.parseFromSlice(
        Envelope,
        allocator,
        msg,
        .{ .ignore_unknown_fields = true },
    );
}

test "parseEnvelope unescapes the doubly-encoded payload, including an escaped quote" {
    const msg =
        \\{"id":"x","name":"greet","payload":"{\"a\":1,\"s\":\"hi\\\"there\"}","binary":0}
    ;
    var parsed = try parseEnvelope(std.testing.allocator, msg);
    defer parsed.deinit();
    try std.testing.expectEqualStrings("x", parsed.value.id);
    try std.testing.expectEqualStrings("greet", parsed.value.name);
    // The genuine inner JSON a downstream parser (e.g. serde_json) must accept.
    try std.testing.expectEqualStrings(
        \\{"a":1,"s":"hi\"there"}
    , parsed.value.payload);
    try std.testing.expectEqual(@as(i64, 0), parsed.value.binary);
}

test "parseEnvelope yields genuine inner JSON for a simple payload" {
    const msg =
        \\{"id":"abc","name":"greet","payload":"{\"from\":\"page\"}","binary":0}
    ;
    var parsed = try parseEnvelope(std.testing.allocator, msg);
    defer parsed.deinit();
    try std.testing.expectEqualStrings(
        \\{"from":"page"}
    , parsed.value.payload);
}

test "parseEnvelope reads the numeric binary flag" {
    const msg =
        \\{"id":"abc","name":"send","payload":"AAEC","binary":1}
    ;
    var parsed = try parseEnvelope(std.testing.allocator, msg);
    defer parsed.deinit();
    try std.testing.expect(parsed.value.binary != 0);
    try std.testing.expectEqualStrings("AAEC", parsed.value.payload);
}

test "parseEnvelope requires an id" {
    const msg =
        \\{"name":"greet","payload":"{}","binary":0}
    ;
    // No default for id, so a missing id is a parse error and the caller drops it.
    try std.testing.expectError(error.MissingField, parseEnvelope(std.testing.allocator, msg));
}
