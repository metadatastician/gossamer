// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Standalone SSG build runner.
//
// Calls gossamer_ssg_build_site directly from the Zig SSG module.
// This is a thin CLI wrapper so that `just build-site` can invoke the
// full SSG pipeline without requiring the Ephapax compiler.
//
// Usage:
//   zig run scripts/ssg-build-runner.zig -- <content_dir> <template_file> <out_dir>

const std = @import("std");
const ssg = @import("../src/interface/ffi/src/ssg.zig");

pub fn main() !void {
    var args = std.process.args();

    // Skip argv[0] (program name).
    _ = args.skip();

    const content_dir = args.next() orelse {
        std.debug.print("Usage: ssg-build-runner <content_dir> <template_file> <out_dir>\n", .{});
        std.process.exit(1);
    };
    const template_file = args.next() orelse {
        std.debug.print("Usage: ssg-build-runner <content_dir> <template_file> <out_dir>\n", .{});
        std.process.exit(1);
    };
    const out_dir = args.next() orelse {
        std.debug.print("Usage: ssg-build-runner <content_dir> <template_file> <out_dir>\n", .{});
        std.process.exit(1);
    };

    std.debug.print("SSG Build: {s} + {s} -> {s}\n", .{ content_dir, template_file, out_dir });

    const result = ssg.gossamer_ssg_build_site(content_dir, template_file, out_dir);

    if (result != 0) {
        std.debug.print("SSG build failed (error code: {d})\n", .{result});
        std.process.exit(1);
    }

    std.debug.print("SSG build succeeded.\n", .{});
}
