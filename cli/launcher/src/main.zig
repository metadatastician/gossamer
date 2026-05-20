// Gossamer launcher — MVP host runtime for Ephapax-compiled cli.wasm
//
// Loads a .wasm module compiled by the ephapax toolchain and runs its
// `main` export inside an embedded wasmtime instance. Provides the 5
// baseline host imports any ephapax program may rely on:
//
//   • env::print_i32(n: i32) -> ()
//   • env::print_string(ptr: i32, len: i32) -> ()
//   • env::argv_count() -> i32
//   • env::argv_arg_len(idx: i32) -> i32
//   • env::argv_arg_get(idx: i32, buf_ptr: i32, buf_len: i32) -> i32
//
// argv accessors read the launcher's own argv (with argv[0] dropped so
// the wasm sees only user-provided arguments — matches POSIX shell
// behaviour for nested invocations).
//
// Phase 14a.5a of the gossamer CLI port to typed-wasm Ephapax. Bridges
// for the ~80 `gossamer_*` libgossamer imports land in 14a.5b; build
// integration (compile cli.wasm via ephapax, install alongside this
// binary, search for it at runtime) lands in 14a.5c.
//
// Usage (during development, manual wasm path):
//   gossamer-launcher /path/to/cli.wasm [user-args...]
//
// Eventually (post-14a.5c):
//   gossamer dev    # launcher discovers /usr/share/gossamer/cli.wasm
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const bridges = @import("bridges.zig");

pub const c = @cImport({
    @cInclude("wasm.h");
    @cInclude("wasmtime.h");
});

/// Userdata threaded through every host-import callback. Holds the
/// launcher's argv (already trimmed to drop argv[0]) and a pointer to
/// the wasm linear memory so callbacks can read/write guest buffers.
///
/// `cap_tokens` holds the launcher's eager-granted capability tokens,
/// indexed by ResourceKind (0=FileSystem, 1=Network, 2=Shell, 3=Clipboard,
/// 4=Notification, 5=Tray). Set during init via bridges.grantCaps and
/// read by the guest through env::cap_token(kind).
pub const HostEnv = struct {
    /// argv visible to the wasm guest. argv[0] of the launcher is
    /// dropped so the guest sees only its own arguments.
    argv: []const []const u8,
    /// Set after instantiation so the print_string / argv_arg_get
    /// callbacks can resolve guest pointer arguments into host slices.
    memory: ?*c.wasmtime_memory_t = null,
    /// Store context — needed to query the memory's data pointer at
    /// callback time (wasmtime expects this on every memory access).
    context: ?*c.wasmtime_context_t = null,
    /// Eager-granted capability tokens, one slot per ResourceKind. 0
    /// means no token was granted for that kind.
    cap_tokens: [6]u64 = .{ 0, 0, 0, 0, 0, 0 },
};

pub const ImportSpec = struct {
    name: []const u8,
    params: []const c.wasm_valkind_t,
    results: []const c.wasm_valkind_t,
    callback: *const fn (
        ?*anyopaque,
        ?*c.wasmtime_caller_t,
        [*c]const c.wasmtime_val_t,
        usize,
        [*c]c.wasmtime_val_t,
        usize,
    ) callconv(.c) ?*c.wasm_trap_t,
};

/// Pretty-print a wasmtime_error_t to stderr and return the same
/// non-zero exit code each time so error handling stays terse.
fn reportError(label: []const u8, err: ?*c.wasmtime_error_t) u8 {
    if (err == null) return 0;
    var msg: c.wasm_byte_vec_t = undefined;
    c.wasmtime_error_message(err, &msg);
    std.debug.print("gossamer-launcher: {s}: {s}\n", .{ label, msg.data[0..msg.size] });
    c.wasm_byte_vec_delete(&msg);
    c.wasmtime_error_delete(err);
    return 1;
}

/// Same shape for a trap.
fn reportTrap(label: []const u8, trap: ?*c.wasm_trap_t) u8 {
    if (trap == null) return 0;
    var msg: c.wasm_byte_vec_t = undefined;
    c.wasm_trap_message(trap, &msg);
    std.debug.print("gossamer-launcher: {s}: trap: {s}\n", .{ label, msg.data[0..msg.size] });
    c.wasm_byte_vec_delete(&msg);
    c.wasm_trap_delete(trap);
    return 1;
}

/// Helper: build a wasm_functype_t from arrays of param/result kinds.
/// Ownership of the returned functype transfers to the caller — it
/// must eventually be passed to wasm_functype_delete (or to a function
/// like wasmtime_linker_define_func which takes ownership).
fn funcType(params: []const c.wasm_valkind_t, results: []const c.wasm_valkind_t) ?*c.wasm_functype_t {
    var ps: c.wasm_valtype_vec_t = undefined;
    var rs: c.wasm_valtype_vec_t = undefined;
    c.wasm_valtype_vec_new_uninitialized(&ps, params.len);
    for (params, 0..) |k, i| {
        ps.data[i] = c.wasm_valtype_new(k);
    }
    c.wasm_valtype_vec_new_uninitialized(&rs, results.len);
    for (results, 0..) |k, i| {
        rs.data[i] = c.wasm_valtype_new(k);
    }
    return c.wasm_functype_new(&ps, &rs);
}

/// Resolve a guest linear-memory range into a host slice. Bounds-checks
/// against the current memory size; returns null on overflow / OOB.
pub fn guestSlice(env: *HostEnv, ptr: i32, len: i32) ?[]u8 {
    if (ptr < 0 or len < 0) return null;
    const mem = env.memory orelse return null;
    const ctx = env.context orelse return null;
    const base = c.wasmtime_memory_data(ctx, mem);
    const size = c.wasmtime_memory_data_size(ctx, mem);
    const start: usize = @intCast(ptr);
    const length: usize = @intCast(len);
    if (start > size or length > size - start) return null;
    return base[start .. start + length];
}

//==============================================================================
// Host import callbacks — signature matches wasmtime_func_callback_t
//==============================================================================

fn hostPrintI32(
    env_raw: ?*anyopaque,
    _: ?*c.wasmtime_caller_t,
    args: [*c]const c.wasmtime_val_t,
    nargs: usize,
    _: [*c]c.wasmtime_val_t,
    _: usize,
) callconv(.c) ?*c.wasm_trap_t {
    _ = env_raw;
    if (nargs < 1) return null;
    const n: i32 = args[0].of.i32;
    std.debug.print("{d}\n", .{n});
    return null;
}

fn hostPrintString(
    env_raw: ?*anyopaque,
    _: ?*c.wasmtime_caller_t,
    args: [*c]const c.wasmtime_val_t,
    nargs: usize,
    _: [*c]c.wasmtime_val_t,
    _: usize,
) callconv(.c) ?*c.wasm_trap_t {
    const env: *HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    if (nargs < 2) return null;
    const ptr: i32 = args[0].of.i32;
    const len: i32 = args[1].of.i32;
    const slice = guestSlice(env, ptr, len) orelse return null;
    std.debug.print("{s}", .{slice});
    return null;
}

fn hostArgvCount(
    env_raw: ?*anyopaque,
    _: ?*c.wasmtime_caller_t,
    _: [*c]const c.wasmtime_val_t,
    _: usize,
    results: [*c]c.wasmtime_val_t,
    nresults: usize,
) callconv(.c) ?*c.wasm_trap_t {
    const env: *HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    if (nresults < 1) return null;
    results[0].kind = c.WASMTIME_I32;
    results[0].of.i32 = @intCast(env.argv.len);
    return null;
}

fn hostArgvArgLen(
    env_raw: ?*anyopaque,
    _: ?*c.wasmtime_caller_t,
    args: [*c]const c.wasmtime_val_t,
    nargs: usize,
    results: [*c]c.wasmtime_val_t,
    nresults: usize,
) callconv(.c) ?*c.wasm_trap_t {
    const env: *HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    if (nargs < 1 or nresults < 1) return null;
    const idx: i32 = args[0].of.i32;
    results[0].kind = c.WASMTIME_I32;
    if (idx < 0 or idx >= env.argv.len) {
        results[0].of.i32 = -1;
    } else {
        results[0].of.i32 = @intCast(env.argv[@intCast(idx)].len);
    }
    return null;
}

fn hostArgvArgGet(
    env_raw: ?*anyopaque,
    _: ?*c.wasmtime_caller_t,
    args: [*c]const c.wasmtime_val_t,
    nargs: usize,
    results: [*c]c.wasmtime_val_t,
    nresults: usize,
) callconv(.c) ?*c.wasm_trap_t {
    const env: *HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    if (nargs < 3 or nresults < 1) return null;
    const idx: i32 = args[0].of.i32;
    const buf_ptr: i32 = args[1].of.i32;
    const buf_len: i32 = args[2].of.i32;
    results[0].kind = c.WASMTIME_I32;
    if (idx < 0 or idx >= env.argv.len) {
        results[0].of.i32 = -1;
        return null;
    }
    const arg = env.argv[@intCast(idx)];
    if (buf_len < arg.len) {
        results[0].of.i32 = -1;
        return null;
    }
    const slice = guestSlice(env, buf_ptr, @intCast(arg.len)) orelse {
        results[0].of.i32 = -1;
        return null;
    };
    @memcpy(slice, arg);
    results[0].of.i32 = @intCast(arg.len);
    return null;
}

//==============================================================================
// Linker setup — bind every env::* import to its host callback
//==============================================================================

fn defineImports(
    linker: *c.wasmtime_linker_t,
    env: *HostEnv,
    imports: []const ImportSpec,
) ?*c.wasmtime_error_t {
    for (imports) |spec| {
        const ft = funcType(spec.params, spec.results) orelse return null;
        const err = c.wasmtime_linker_define_func(
            linker,
            "env",
            "env".len,
            spec.name.ptr,
            spec.name.len,
            ft,
            spec.callback,
            env,
            null,
        );
        c.wasm_functype_delete(ft);
        if (err != null) return err;
    }
    return null;
}

//==============================================================================
// Entry point
//==============================================================================

/// Discover cli.wasm via the standard install-prefix search.
///
/// Priority:
///   1. $GOSSAMER_WASM env var (explicit override).
///   2. <exe_dir>/../share/gossamer/cli.wasm  (install-prefix-relative).
///   3. /usr/local/share/gossamer/cli.wasm
///   4. /usr/share/gossamer/cli.wasm
///
/// Caller owns the returned slice. Returns null if no candidate exists.
fn findCliWasm(allocator: std.mem.Allocator) ?[]u8 {
    if (std.process.getEnvVarOwned(allocator, "GOSSAMER_WASM")) |env_path| {
        std.fs.cwd().access(env_path, .{}) catch {
            allocator.free(env_path);
            return null;
        };
        return env_path;
    } else |_| {}

    // Resolve <exe_dir>/../share/gossamer/cli.wasm
    if (std.fs.selfExeDirPathAlloc(allocator)) |exe_dir| {
        defer allocator.free(exe_dir);
        const candidate = std.fs.path.join(allocator, &.{ exe_dir, "..", "share", "gossamer", "cli.wasm" }) catch null;
        if (candidate) |p| {
            if (std.fs.cwd().access(p, .{})) |_| return p else |_| allocator.free(p);
        }
    } else |_| {}

    for ([_][]const u8{
        "/usr/local/share/gossamer/cli.wasm",
        "/usr/share/gossamer/cli.wasm",
    }) |p| {
        if (std.fs.cwd().access(p, .{})) |_| return allocator.dupe(u8, p) catch null else |_| {}
    }
    return null;
}

pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const all_args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, all_args);

    // Resolve the cli.wasm path. An argv-supplied .wasm overrides
    // discovery (development workflow: smoke-test arbitrary modules).
    // Otherwise, fall back to GOSSAMER_WASM / install-prefix / system
    // share paths in that order.
    var owned_wasm_path: ?[]u8 = null;
    defer if (owned_wasm_path) |p| allocator.free(p);

    const explicit_wasm: ?[]const u8 = if (all_args.len >= 2 and std.mem.endsWith(u8, all_args[1], ".wasm")) all_args[1] else null;
    const wasm_path: []const u8 = blk: {
        if (explicit_wasm) |p| break :blk p;
        if (findCliWasm(allocator)) |p| {
            owned_wasm_path = p;
            break :blk p;
        }
        std.debug.print(
            \\gossamer-launcher: no cli.wasm found.
            \\
            \\Searched:
            \\  $GOSSAMER_WASM           (unset / unreadable)
            \\  <exe_dir>/../share/gossamer/cli.wasm
            \\  /usr/local/share/gossamer/cli.wasm
            \\  /usr/share/gossamer/cli.wasm
            \\
            \\Install via `zig build install` or pass a .wasm path
            \\explicitly: gossamer-launcher /path/to/cli.wasm [args...]
            \\
            \\
        , .{});
        return 1;
    };

    // argv visible to the guest: drop argv[0] (the launcher path) and,
    // if argv[1] was an explicit wasm path, also drop that. What
    // remains is the user's real intent.
    const skip_count: usize = if (explicit_wasm != null) 2 else 1;
    var guest_argv: std.ArrayListUnmanaged([]const u8) = .empty;
    defer guest_argv.deinit(allocator);
    for (all_args[skip_count..]) |a| {
        try guest_argv.append(allocator, a);
    }

    // Load the wasm bytes.
    const wasm_bytes = std.fs.cwd().readFileAlloc(allocator, wasm_path, 64 * 1024 * 1024) catch {
        std.debug.print("gossamer-launcher: cannot read {s}\n", .{wasm_path});
        return 1;
    };
    defer allocator.free(wasm_bytes);

    // Engine + store.
    const engine = c.wasm_engine_new() orelse {
        std.debug.print("gossamer-launcher: wasm_engine_new failed\n", .{});
        return 1;
    };
    defer c.wasm_engine_delete(engine);

    var host_env = HostEnv{ .argv = guest_argv.items };

    const store = c.wasmtime_store_new(engine, &host_env, null) orelse {
        std.debug.print("gossamer-launcher: wasmtime_store_new failed\n", .{});
        return 1;
    };
    defer c.wasmtime_store_delete(store);

    const ctx = c.wasmtime_store_context(store) orelse {
        std.debug.print("gossamer-launcher: wasmtime_store_context failed\n", .{});
        return 1;
    };
    host_env.context = ctx;

    // Linker + the 5 baseline imports.
    const linker = c.wasmtime_linker_new(engine) orelse {
        std.debug.print("gossamer-launcher: wasmtime_linker_new failed\n", .{});
        return 1;
    };
    defer c.wasmtime_linker_delete(linker);

    const i32_kind: c.wasm_valkind_t = c.WASM_I32;

    const imports = [_]ImportSpec{
        .{ .name = "print_i32", .params = &.{i32_kind}, .results = &.{}, .callback = &hostPrintI32 },
        .{ .name = "print_string", .params = &.{ i32_kind, i32_kind }, .results = &.{}, .callback = &hostPrintString },
        .{ .name = "argv_count", .params = &.{}, .results = &.{i32_kind}, .callback = &hostArgvCount },
        .{ .name = "argv_arg_len", .params = &.{i32_kind}, .results = &.{i32_kind}, .callback = &hostArgvArgLen },
        .{ .name = "argv_arg_get", .params = &.{ i32_kind, i32_kind, i32_kind }, .results = &.{i32_kind}, .callback = &hostArgvArgGet },
    };

    if (reportError("defineImports", defineImports(linker, &host_env, &imports)) != 0) return 1;

    // Phase 14a.5b — libgossamer bridges. Eager-grant baseline caps
    // (FileSystem / Network / Shell) before registering bridges so the
    // guest can pass cap tokens through fs / shell / conf calls via
    // env::cap_token(kind).
    bridges.grantCaps(&host_env);
    if (reportError("defineImports (bridges)", defineImports(linker, &host_env, &bridges.Imports)) != 0) return 1;

    // Compile + instantiate the module.
    var module: ?*c.wasmtime_module_t = null;
    if (reportError(
        "wasmtime_module_new",
        c.wasmtime_module_new(engine, wasm_bytes.ptr, wasm_bytes.len, &module),
    ) != 0) return 1;
    defer c.wasmtime_module_delete(module);

    var instance: c.wasmtime_instance_t = undefined;
    var trap: ?*c.wasm_trap_t = null;
    if (reportError(
        "wasmtime_linker_instantiate",
        c.wasmtime_linker_instantiate(linker, ctx, module, &instance, &trap),
    ) != 0) return 1;
    if (reportTrap("instantiate", trap) != 0) return 1;

    // Capture the guest's linear memory (export name "memory" by convention).
    var memory_export: c.wasmtime_extern_t = undefined;
    if (c.wasmtime_instance_export_get(ctx, &instance, "memory", "memory".len, &memory_export)) {
        if (memory_export.kind == c.WASMTIME_EXTERN_MEMORY) {
            host_env.memory = &memory_export.of.memory;
        }
    }
    // Lack of memory export is fine when the guest never calls print_string
    // or argv_arg_get; those callbacks return null traps if no memory.

    // Look up and invoke `main`. Returns are ignored — the launcher's
    // exit code is 0 on clean return, 1 on trap / error.
    var main_export: c.wasmtime_extern_t = undefined;
    if (!c.wasmtime_instance_export_get(ctx, &instance, "main", "main".len, &main_export)) {
        std.debug.print("gossamer-launcher: module has no `main` export\n", .{});
        return 1;
    }
    if (main_export.kind != c.WASMTIME_EXTERN_FUNC) {
        std.debug.print("gossamer-launcher: `main` export is not a function\n", .{});
        return 1;
    }

    var results_buf: [4]c.wasmtime_val_t = undefined;
    if (reportError(
        "wasmtime_func_call",
        c.wasmtime_func_call(ctx, &main_export.of.func, null, 0, &results_buf, results_buf.len, &trap),
    ) != 0) return 1;
    if (reportTrap("main", trap) != 0) return 1;

    return 0;
}
