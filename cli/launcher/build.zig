// Gossamer launcher — Build configuration
//
// Builds the `gossamer-launcher` binary: a thin Zig host that embeds
// wasmtime (via libwasmtime, dynamic linkage) and runs a precompiled
// cli.wasm produced by the Ephapax compiler.
//
// External system dependencies:
//   • wasmtime C API >= v44.0.1 — install from
//     https://github.com/bytecodealliance/wasmtime/releases as the
//     `wasmtime-vX.Y.Z-<arch>-c-api.tar.xz` bundle, extracting
//     include/ and lib/ into /usr/local. Verify with:
//       pkg-config --cflags --libs wasmtime
//     or:
//       test -f /usr/local/include/wasmtime.h && \
//       test -f /usr/local/lib/libwasmtime.so
//
// Phase 14a.5a (MVP) of the gossamer CLI port to typed-wasm Ephapax.
// At this stage the launcher only bridges the 5 baseline `env::*`
// imports (print_i32, print_string, argv_count, argv_arg_len,
// argv_arg_get). Phase 14a.5b adds the ~80 libgossamer imports;
// Phase 14a.5c wires the Ephapax compile step.
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // libwasmtime ships as a shared library at /usr/local/lib by default
    // when installed from the c-api release tarball. addIncludePath is
    // not strictly needed because /usr/local/include is on Zig's default
    // header search path on most systems, but include it explicitly so
    // non-default install prefixes still work.
    exe_module.addIncludePath(.{ .cwd_relative = "/usr/local/include" });
    exe_module.addLibraryPath(.{ .cwd_relative = "/usr/local/lib" });
    exe_module.linkSystemLibrary("wasmtime", .{});

    // libgossamer — built from ../../src/interface/ffi by `zig build` in
    // that directory. The bridges in src/bridges.zig declare the
    // libgossamer symbols as `extern fn` and trampoline guest calls into
    // them.
    exe_module.addLibraryPath(b.path("../../src/interface/ffi/zig-out/lib"));
    exe_module.addRPath(b.path("../../src/interface/ffi/zig-out/lib"));
    exe_module.linkSystemLibrary("gossamer", .{});

    const exe = b.addExecutable(.{
        .name = "gossamer-launcher",
        .root_module = exe_module,
    });

    b.installArtifact(exe);

    //--- Compile cli.wasm from ../src/Main.eph via the ephapax toolchain.
    //
    // The path to the ephapax binary defaults to `ephapax` on PATH but
    // can be overridden via the EPHAPAX env var for dev work where the
    // compiler lives in a sibling repo checkout (typical workflow:
    //   EPHAPAX=$HOME/dev/repos/ephapax/target/debug/ephapax zig build
    // ). Output lands at zig-out/share/gossamer/cli.wasm so the install
    // step picks it up under the standard prefix layout.
    const ephapax_bin = std.process.getEnvVarOwned(b.allocator, "EPHAPAX") catch
        b.allocator.dupe(u8, "ephapax") catch unreachable;
    const compile_wasm = b.addSystemCommand(&.{ ephapax_bin, "compile" });
    compile_wasm.addFileArg(b.path("../src/Main.eph"));
    compile_wasm.addArg("-o");
    const wasm_out = compile_wasm.addOutputFileArg("cli.wasm");
    const install_wasm = b.addInstallFileWithDir(wasm_out, .{ .custom = "share/gossamer" }, "cli.wasm");
    b.getInstallStep().dependOn(&install_wasm.step);

    // Run step — passes args through after `--`. With no args it falls
    // back to discovering cli.wasm via the launcher's search order:
    //   zig build run                 # runs the installed cli.wasm
    //   zig build run -- one two      # passes args to the discovered wasm
    //   zig build run -- /path.wasm   # explicit wasm path (override)
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    // Make the run step see the freshly-built cli.wasm by setting
    // GOSSAMER_WASM to the install location. The launcher's discovery
    // logic checks this env var first.
    run_cmd.setEnvironmentVariable("GOSSAMER_WASM", b.getInstallPath(.{ .custom = "share/gossamer" }, "cli.wasm"));
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run gossamer-launcher against the installed cli.wasm");
    run_step.dependOn(&run_cmd.step);
}
