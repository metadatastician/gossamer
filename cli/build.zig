// Gossamer CLI — Build Configuration
//
// Builds the `gossamer` CLI binary that links against libgossamer.
//
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const os = target.query.os_tag orelse builtin.os.tag;

    const exe_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // Link against libgossamer (built from ../src/interface/ffi/)
    exe_module.addLibraryPath(b.path("../src/interface/ffi/zig-out/lib"));
    exe_module.addRPath(b.path("../src/interface/ffi/zig-out/lib"));
    exe_module.linkSystemLibrary("gossamer", .{});

    // Platform-specific libraries (same as libgossamer itself needs)
    switch (os) {
        .linux, .freebsd, .openbsd, .netbsd => {
            exe_module.linkSystemLibrary("gtk+-3.0", .{});
            exe_module.linkSystemLibrary("webkit2gtk-4.1", .{});
            exe_module.linkSystemLibrary("glib-2.0", .{});
        },
        .macos => {
            exe_module.linkFramework("Cocoa", .{});
            exe_module.linkFramework("WebKit", .{});
        },
        .windows => {
            exe_module.linkSystemLibrary("ole32", .{});
            exe_module.linkSystemLibrary("user32", .{});
        },
        else => {},
    }

    const exe = b.addExecutable(.{
        .name = "gossamer",
        .root_module = exe_module,
    });

    b.installArtifact(exe);

    // Run step: `zig build run -- <args>`
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the Gossamer CLI");
    run_step.dependOn(&run_cmd.step);
}
