// Gossamer Webview Shell — Zig Build Configuration
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

    // --- Shared library (.so / .dylib / .dll) ---
    const shared_lib = b.addSharedLibrary(.{
        .name = "gossamer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    linkPlatformLibs(shared_lib);
    b.installArtifact(shared_lib);

    // --- Static library (.a) ---
    const static_lib = b.addStaticLibrary(.{
        .name = "gossamer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    linkPlatformLibs(static_lib);
    b.installArtifact(static_lib);

    // --- Unit tests ---
    // Note: unit tests test FFI logic (result codes, null checks, etc.)
    // They do NOT link against GTK — platform tests are integration tests.
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run Gossamer unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // --- Integration tests (require GTK/WebKitGTK) ---
    const integration_tests = b.addTest(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });

    linkPlatformLibs(integration_tests);
    integration_tests.linkLibrary(shared_lib);

    const run_integration_tests = b.addRunArtifact(integration_tests);
    const integration_step = b.step("test-integration", "Run integration tests (requires display)");
    integration_step.dependOn(&run_integration_tests.step);

    // --- Documentation ---
    const docs_lib = b.addStaticLibrary(.{
        .name = "gossamer-docs",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const docs_step = b.step("docs", "Generate Gossamer API documentation");
    docs_step.dependOn(&b.addInstallDirectory(.{
        .source = docs_lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    }).step);
}

/// Link platform-specific system libraries required for webview support.
fn linkPlatformLibs(step: *std.Build.Step.Compile) void {
    step.linkLibC();

    const target_os = step.rootModuleTarget().os.tag;

    switch (target_os) {
        .linux => {
            // GTK 3 + WebKitGTK for Linux (Phase 1)
            step.linkSystemLibrary("gtk+-3.0");
            step.linkSystemLibrary("webkit2gtk-4.1");
            step.linkSystemLibrary("glib-2.0");
        },
        // Phase 2: macOS
        // .macos => {
        //     step.linkFramework("Cocoa");
        //     step.linkFramework("WebKit");
        // },
        // Phase 2: Windows
        // .windows => {
        //     step.linkSystemLibrary("WebView2Loader");
        //     step.linkSystemLibrary("ole32");
        //     step.linkSystemLibrary("comctl32");
        // },
        else => {},
    }
}
