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
// Cross-compilation examples:
//   zig build -Dtarget=x86_64-macos     # macOS (Intel)
//   zig build -Dtarget=aarch64-macos    # macOS (Apple Silicon)
//   zig build -Dtarget=x86_64-windows   # Windows
//   zig build -Dtarget=riscv64-linux    # Linux RISC-V
//   zig build -Dtarget=aarch64-linux    # Linux ARM64
//
// Platform dependencies:
//   Linux/BSD: gtk3-devel webkit2gtk4.1-devel (Fedora) or equivalent
//   macOS:     Cocoa.framework WebKit.framework (system)
//   Windows:   WebView2Loader.dll ole32.lib user32.lib
//   iOS:       UIKit.framework WebKit.framework (Xcode SDK)
//   Android:   Android NDK (separate build target)
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

/// Link platform-specific system libraries to a module.
fn linkPlatformLibs(module: *std.Build.Module, os: std.Target.Os.Tag) void {
    switch (os) {
        .linux, .freebsd, .openbsd, .netbsd => {
            // GTK 3 + WebKitGTK 4.1 (same across Linux and BSD)
            module.linkSystemLibrary("gtk+-3.0", .{});
            module.linkSystemLibrary("webkit2gtk-4.1", .{});
            module.linkSystemLibrary("glib-2.0", .{});
        },
        .macos => {
            // Cocoa + WebKit frameworks
            module.linkFramework("Cocoa", .{});
            module.linkFramework("WebKit", .{});
        },
        .windows => {
            // Win32 + COM
            module.linkSystemLibrary("ole32", .{});
            module.linkSystemLibrary("user32", .{});
            module.linkSystemLibrary("kernel32", .{});
            // WebView2Loader.dll loaded at runtime via LoadLibrary
        },
        .ios => {
            // UIKit + WebKit frameworks
            module.linkFramework("UIKit", .{});
            module.linkFramework("WebKit", .{});
        },
        else => {},
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const os = target.query.os_tag orelse builtin.os.tag;

    // Create the root module (shared between shared/static/test)
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    linkPlatformLibs(root_module, os);

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

    linkPlatformLibs(static_module, os);

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
        .link_libc = true,
    });

    linkPlatformLibs(test_module, os);

    const unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run Gossamer unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

const builtin = @import("builtin");
