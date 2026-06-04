// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// Gossamer Webview Shell — Zig Build Configuration (Zig 0.15+)
//
// Builds libgossamer as both shared (.so/.dylib/.dll) and static (.a) libraries.
// Links against platform-specific webview libraries at compile time.
//
// Usage:
//   zig build                         # Build for current platform
//   zig build test                    # Run unit tests (headless)
//   zig build test-display            # Run display integration tests (needs X11/Xvfb)
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

const std = @import("std");

/// Link platform-specific system libraries to a module.
fn linkPlatformLibs(module: *std.Build.Module, os: std.Target.Os.Tag) void {
    switch (os) {
        .linux, .freebsd, .openbsd, .netbsd => {
            // GTK 3 + WebKitGTK 4.1 (same across Linux and BSD)
            module.linkSystemLibrary("gtk+-3.0", .{});
            module.linkSystemLibrary("webkit2gtk-4.1", .{});
            module.linkSystemLibrary("glib-2.0", .{});
            // libdl for plugin system (dlopen/dlsym/dlclose)
            module.linkSystemLibrary("dl", .{});
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
        .version = .{ .major = 0, .minor = 3, .patch = 0 },
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

    // --- Display integration tests (require X11/Wayland/Xvfb) ---
    // These tests exercise real GTK/WebKitGTK webview creation, HTML loading,
    // navigation, IPC channel setup, and capability lifecycle.
    //
    // Run via: zig build test-display (with a display server)
    //     or: xvfb-run -a zig build test-display (headless CI)
    //     or: ./scripts/test-with-display.sh (auto-detect)
    // Create a module for the main gossamer source so display tests can import it
    const gossamer_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    linkPlatformLibs(gossamer_module, os);

    const display_test_module = b.createModule(.{
        .root_source_file = b.path("test/display_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "gossamer", .module = gossamer_module },
        },
    });

    linkPlatformLibs(display_test_module, os);

    const display_tests = b.addTest(.{
        .root_module = display_test_module,
    });

    const run_display_tests = b.addRunArtifact(display_tests);
    const display_test_step = b.step("test-display", "Run Gossamer display integration tests (requires X11/Wayland/Xvfb)");
    display_test_step.dependOn(&run_display_tests.step);
}

const builtin = @import("builtin");
