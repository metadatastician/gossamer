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
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

/// Link platform-specific system libraries to a module.
///
/// `abi` is consulted first because an Android target reports `os == .linux`
/// (it runs a Linux kernel) yet must NOT link GTK/WebKitGTK — its WebView and
/// component hosts are reached entirely over JNI. The only NDK libraries the
/// shell needs are liblog (diagnostics) and libandroid; libc is linked by the
/// module itself.
fn linkPlatformLibs(module: *std.Build.Module, os: std.Target.Os.Tag, abi: std.Target.Abi) void {
    if (abi == .android) {
        module.linkSystemLibrary("log", .{});
        module.linkSystemLibrary("android", .{});
        return;
    }
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
    const abi = target.result.abi;

    // Create the root module (shared between shared/static/test)
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    linkPlatformLibs(root_module, os, abi);

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

    linkPlatformLibs(static_module, os, abi);

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

    linkPlatformLibs(test_module, os, abi);

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

    linkPlatformLibs(gossamer_module, os, abi);

    const display_test_module = b.createModule(.{
        .root_source_file = b.path("test/display_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "gossamer", .module = gossamer_module },
        },
    });

    linkPlatformLibs(display_test_module, os, abi);

    const display_tests = b.addTest(.{
        .root_module = display_test_module,
    });

    const run_display_tests = b.addRunArtifact(display_tests);
    const display_test_step = b.step("test-display", "Run Gossamer display integration tests (requires X11/Wayland/Xvfb)");
    display_test_step.dependOn(&run_display_tests.step);

    // --- Android component host logic tests (host-runnable; pure Zig, no NDK) ---
    // The JNI binding and the Service/Receiver/Widget hosts are pure Zig, so
    // their registry/dispatch/JSON/directive logic runs on the host via
    // `zig build test-android`. This is a SEPARATE step (not folded into the
    // default `test`): the estate `test` gate runs under `2>/dev/null`, which
    // hides Zig compile errors, so a dedicated workflow (.github/workflows/
    // android.yml) runs this step with visible output instead.
    // Rooted in src/ (not test/) because Zig 0.15 forbids importing files
    // outside a module's root directory — a test/ root cannot @import("../src/
    // jni.zig"). The aggregator pulls in the android sources from the same dir.
    const android_test_module = b.createModule(.{
        .root_source_file = b.path("src/android_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    // Deliberately NO linkPlatformLibs: these modules pull in neither GTK nor
    // the NDK; keeping them library-free is what makes the tests host-runnable.

    const android_tests = b.addTest(.{
        .root_module = android_test_module,
    });

    const run_android_tests = b.addRunArtifact(android_tests);
    const android_test_step = b.step("test-android", "Run Android component host logic tests (host-runnable, no NDK)");
    android_test_step.dependOn(&run_android_tests.step);

    // --- Android cross-compilation (requires the Android NDK) ---
    // Produces libgossamer.so for each ABI neurophone (and other downstreams)
    // ship. This is a thin wrapper over the standard target options; the
    // per-ABI loop and jniLibs packaging live in the Justfile (`just
    // android-build`). Selected purely so `zig build -Dtarget=<abi>-linux-android`
    // routes through the JNI WebView backend and the component hosts.
    //   zig build -Dtarget=aarch64-linux-android      # arm64-v8a
    //   zig build -Dtarget=x86_64-linux-android       # x86_64 (emulator)
    //   zig build -Dtarget=arm-linux-androideabi      # armeabi-v7a
}

const builtin = @import("builtin");
