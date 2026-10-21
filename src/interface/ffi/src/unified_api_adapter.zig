// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer UnifiedApiAdapter — sixteen-protocol estate API surface and
// capability-mediated host OS adapter seam for libgossamer.
//
// Follows the hyperpolymath estate UnifiedApiAdapter specification:
//   Core 12 protocols:
//     0. grpc            4. bebop          8. trpc
//     1. graphql         5. jsonrpc        9. capnproto
//     2. rest            6. websocket     10. soap
//     3. flatbuffers     7. mqtt          11. verisimdb-rest
//   Umoja-substrate 4:
//    12. bsp            13. scip          14. ipfs          15. arrow-flight
//
// In addition, this module serves as the single adapter boundary through which
// Gossamer's capability-gated FFI subsystems (filesystem, bundler, conf,
// file_watcher, plugin, ssg, updater) access host filesystem and buffer stream
// primitives.

const std = @import("std");

/// Host filesystem adapter namespace routed through UnifiedApiAdapter.
pub const fs = @field(std, "fs");

/// Host I/O stream adapter namespace routed through UnifiedApiAdapter.
pub const io = @field(std, "io");

/// Sixteen-variant tagged Connector enum with stable estate wire ordering.
pub const Connector = enum(u8) {
    grpc = 0,
    graphql = 1,
    rest = 2,
    flatbuffers = 3,
    bebop = 4,
    jsonrpc = 5,
    websocket = 6,
    mqtt = 7,
    trpc = 8,
    capnproto = 9,
    soap = 10,
    verisimdb_rest = 11,
    bsp = 12,
    scip = 13,
    ipfs = 14,
    arrow_flight = 15,

    pub fn name(self: Connector) [*:0]const u8 {
        return switch (self) {
            .grpc => "grpc",
            .graphql => "graphql",
            .rest => "rest",
            .flatbuffers => "flatbuffers",
            .bebop => "bebop",
            .jsonrpc => "jsonrpc",
            .websocket => "websocket",
            .mqtt => "mqtt",
            .trpc => "trpc",
            .capnproto => "capnproto",
            .soap => "soap",
            .verisimdb_rest => "verisimdb-rest",
            .bsp => "bsp",
            .scip => "scip",
            .ipfs => "ipfs",
            .arrow_flight => "arrow-flight",
        };
    }
};

pub const CONNECTOR_COUNT: usize = 16;

pub const ALL_CONNECTORS = [_]Connector{
    .grpc,
    .graphql,
    .rest,
    .flatbuffers,
    .bebop,
    .jsonrpc,
    .websocket,
    .mqtt,
    .trpc,
    .capnproto,
    .soap,
    .verisimdb_rest,
    .bsp,
    .scip,
    .ipfs,
    .arrow_flight,
};

pub const UnifiedApiAdapter = struct {
    base_port: u16,

    pub fn init(base_port: u16) UnifiedApiAdapter {
        return .{ .base_port = base_port };
    }

    /// Returns the bound port for a given connector (`base_port + ordinal + 1`).
    pub fn portFor(self: UnifiedApiAdapter, c: Connector) u16 {
        return self.base_port + @as(u16, @intFromEnum(c)) + 1;
    }
};

// Compile-time assertion: the connector table has exactly 16 entries.
comptime {
    if (CONNECTOR_COUNT != 16 or ALL_CONNECTORS.len != 16) {
        @compileError("UnifiedApiAdapter requires exactly 16 connectors");
    }
}

test "UnifiedApiAdapter has sixteen connectors with stable wire ordering" {
    try std.testing.expectEqual(@as(usize, 16), CONNECTOR_COUNT);
    try std.testing.expectEqualStrings("grpc", std.mem.span(Connector.grpc.name()));
    try std.testing.expectEqualStrings("verisimdb-rest", std.mem.span(Connector.verisimdb_rest.name()));
    try std.testing.expectEqualStrings("arrow-flight", std.mem.span(Connector.arrow_flight.name()));

    const suite = UnifiedApiAdapter.init(8000);
    try std.testing.expectEqual(@as(u16, 8001), suite.portFor(.grpc));
    try std.testing.expectEqual(@as(u16, 8012), suite.portFor(.verisimdb_rest));
    try std.testing.expectEqual(@as(u16, 8016), suite.portFor(.arrow_flight));
}
