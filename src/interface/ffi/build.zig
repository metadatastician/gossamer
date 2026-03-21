// Gossamer Webview Shell — Zig Build Configuration (Zig 0.15+)
//
// Builds libgossamer as both shared (.so/.dylib/.dll) and static (.a) libraries.
// Links against platform-specific webview libraries at compile time.
//
// Usage:
//   zig build                         # Build for current platform
//   zig build test                    # Run unit tests
//   zig build -Doptimize=ReleaseSafe  # Optimised build with safety checks
//
// Dependencies (Linux — Phase 1):
//   Fedora: gtk3-devel webkit2gtk4.1-devel
//   Debian: libgtk-3-dev libwebkit2gtk-4.1-dev
//   Arch:   gtk3 webkit2gtk-4.1
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the root module (shared between shared/static/test)
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // Add system library dependencies to the module
    root_module.linkSystemLibrary("gtk+-3.0", .{});
    root_module.linkSystemLibrary("webkit2gtk-4.1", .{});
    root_module.linkSystemLibrary("glib-2.0", .{});

    // --- Shared library (.so / .dylib / .dll) ---
    const shared_lib = b.addLibrary(.{
        .name = "gossamer",
        .root_module = root_module,
        .linkage = .dynamic,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    b.installArtifact(shared_lib);

    // --- Static library (.a) ---
    const static_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    static_module.linkSystemLibrary("gtk+-3.0", .{});
    static_module.linkSystemLibrary("webkit2gtk-4.1", .{});
    static_module.linkSystemLibrary("glib-2.0", .{});

    const static_lib = b.addLibrary(.{
        .name = "gossamer",
        .root_module = static_module,
        .linkage = .static,
    });

    b.installArtifact(static_lib);

    // --- Unit tests ---
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run Gossamer unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
