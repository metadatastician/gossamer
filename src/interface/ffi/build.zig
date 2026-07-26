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
//   zig build -Dtarget=aarch64-linux-android   # Android (needs ANDROID_NDK_HOME)
//
// Platform dependencies:
//   Linux/BSD: gtk3-devel webkit2gtk4.1-devel (Fedora) or equivalent
//   macOS:     Cocoa.framework WebKit.framework (system)
//   Windows:   WebView2Loader.dll ole32.lib user32.lib
//   iOS:       UIKit.framework WebKit.framework (Xcode SDK)
//   Android:   Android NDK r26+ (set ANDROID_NDK_HOME; see `just android-build`)
//
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");

/// minSdk / min API level for the Android build.
/// Matches docs/architecture/android-components.adoc (minSdk 26).
const ANDROID_API = "26";

/// The NDK sysroot "lib triple" directory name for an Android CPU arch.
fn androidLibTriple(arch: std.Target.Cpu.Arch) []const u8 {
    return switch (arch) {
        .aarch64 => "aarch64-linux-android",
        .x86_64 => "x86_64-linux-android",
        .arm => "arm-linux-androideabi",
        .x86 => "i686-linux-android",
        .riscv64 => "riscv64-linux-android",
        else => "x86_64-linux-android",
    };
}

/// Point the linker at the Android NDK sysroot so `-llog` / `-landroid` resolve.
///
/// Zig supplies Bionic libc for `*-linux-android`, but the platform stubs the
/// shell needs (liblog, libandroid) live in the NDK sysroot, keyed by lib-triple
/// and API level:
///   <ndk>/toolchains/llvm/prebuilt/<host>/sysroot/usr/lib/<triple>/<api>/
/// Reads ANDROID_NDK_HOME, which `just android-build` and the NDK CI job set.
fn addAndroidNdk(b: *std.Build, module: *std.Build.Module, arch: std.Target.Cpu.Arch, ndk: []const u8) void {
    // Prebuilt toolchains ship under a host-tagged directory.
    const host = switch (builtin.os.tag) {
        .macos => "darwin-x86_64",
        else => "linux-x86_64",
    };
    const lib_dir = b.fmt(
        "{s}/toolchains/llvm/prebuilt/{s}/sysroot/usr/lib/{s}/{s}",
        .{ ndk, host, androidLibTriple(arch), ANDROID_API },
    );
    module.addLibraryPath(.{ .cwd_relative = lib_dir });
}

/// Link platform-specific system libraries to a module.
///
/// The Android ABI is consulted first because an Android target reports
/// `os == .linux` (it runs a Linux kernel) yet must NOT link GTK/WebKitGTK — its
/// WebView and component hosts are reached entirely over JNI. The only NDK
/// libraries the shell needs are liblog (diagnostics) and libandroid; Bionic
/// libc is supplied by Zig.
fn linkPlatformLibs(b: *std.Build, module: *std.Build.Module, target: std.Build.ResolvedTarget, ndk: ?[]const u8) void {
    const t = target.result;
    // `.android` is reported by aarch64/x86_64 targets; 32-bit ARM reports
    // `.androideabi`. Both must route to the JNI backend, never GTK/WebKitGTK.
    if (t.abi == .android or t.abi == .androideabi) {
        if (ndk) |ndk_path| {
            addAndroidNdk(b, module, t.cpu.arch, ndk_path);
        } else {
            std.debug.print(
                "gossamer: building an *-linux-android target but -Dndk was not given — " ++
                    "liblog/libandroid will not resolve. Pass -Dndk=$ANDROID_NDK_HOME " ++
                    "(NDK r26+); `just android-build` does this for you.\n",
                .{},
            );
        }
        module.linkSystemLibrary("log", .{});
        module.linkSystemLibrary("android", .{});
        return;
    }
    switch (t.os.tag) {
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

    // Path to the Android NDK (r26+), required only for `*-linux-android`
    // targets so the linker can find liblog/libandroid. `just android-build`
    // passes `-Dndk=$ANDROID_NDK_HOME`; ignored for every other target.
    const android_ndk = b.option([]const u8, "ndk", "Path to Android NDK r26+ (required for *-linux-android targets)");

    // Create the root module (shared between shared/static/test)
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    linkPlatformLibs(b, root_module, target, android_ndk);

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

    linkPlatformLibs(b, static_module, target, android_ndk);

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

    linkPlatformLibs(b, test_module, target, android_ndk);

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

    linkPlatformLibs(b, gossamer_module, target, android_ndk);

    const display_test_module = b.createModule(.{
        .root_source_file = b.path("test/display_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "gossamer", .module = gossamer_module },
        },
    });

    linkPlatformLibs(b, display_test_module, target, android_ndk);

    const display_tests = b.addTest(.{
        .root_module = display_test_module,
    });

    const run_display_tests = b.addRunArtifact(display_tests);
    const display_test_step = b.step("test-display", "Run Gossamer display integration tests (requires X11/Wayland/Xvfb)");
    display_test_step.dependOn(&run_display_tests.step);

    // --- FFI/ABI integration tests (headless; no display server) ---
    // test/integration_test.zig exercises the exported C API surface (result
    // codes, capability lifecycle, IPC, groove, filesystem, ssg, plugin) against
    // the Idris2 ABI. It imports the `gossamer` module (main.zig re-exports the
    // submodules) rather than ../src/*.zig, which Zig 0.15 forbids from a
    // test/-rooted module. GTK/WebKit dev libs are needed to compile main.zig,
    // but no display server is required to run.
    //   zig build test-integration
    const integration_test_module = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "gossamer", .module = gossamer_module },
        },
    });

    linkPlatformLibs(b, integration_test_module, target, android_ndk);

    const integration_tests = b.addTest(.{
        .root_module = integration_test_module,
    });

    const run_integration_tests = b.addRunArtifact(integration_tests);
    const integration_test_step = b.step("test-integration", "Run Gossamer FFI/ABI integration tests (headless)");
    integration_test_step.dependOn(&run_integration_tests.step);

    // --- Groove session-lease demo (manual; needs a LIVE groove service) ---
    // Connects a soft lease (short TTL) and lets it lapse, connects a hard
    // lease and heartbeats three windows, disconnects (showing the handle
    // once-guard), then prints the teardown audit summary. Rooted in test/
    // and importing the `gossamer` module for the same Zig 0.15 reason as
    // the integration tests above.
    //   zig build groove-demo -- <target-index>
    const groove_demo_module = b.createModule(.{
        .root_source_file = b.path("test/groove_demo.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "gossamer", .module = gossamer_module },
        },
    });

    linkPlatformLibs(b, groove_demo_module, target, android_ndk);

    const groove_demo = b.addExecutable(.{
        .name = "groove-demo",
        .root_module = groove_demo_module,
    });

    const run_groove_demo = b.addRunArtifact(groove_demo);
    if (b.args) |args| run_groove_demo.addArgs(args);
    const groove_demo_step = b.step("groove-demo", "Build and run the groove session-lease demo (needs a live groove service)");
    groove_demo_step.dependOn(&run_groove_demo.step);

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
    // ship. `linkPlatformLibs` wires the NDK sysroot (liblog/libandroid) when the
    // ABI is `.android`, reading ANDROID_NDK_HOME; the per-ABI loop and jniLibs
    // packaging live in the Justfile (`just android-build`).
    //   zig build -Dtarget=aarch64-linux-android      # arm64-v8a
    //   zig build -Dtarget=x86_64-linux-android       # x86_64 (emulator)
    //   zig build -Dtarget=arm-linux-androideabi      # armeabi-v7a
}
