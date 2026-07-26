// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
// Gossamer launcher — libgossamer bridge layer
//
// Trampolines guest wasm calls into native libgossamer C ABI. Each
// `env::gossamer_<name>` host import:
//   1. Reads the wasm-side args from wasmtime_val_t[],
//   2. For strings: copies up to `buf_len` bytes from guest linear
//      memory into a host-allocated null-terminated dupe,
//   3. Calls the corresponding `extern fn gossamer_<name>(...)`,
//   4. For string-out: copies the C string back into a guest-provided
//      buffer, returning bytes written (or -1 on overflow),
//   5. Marshals the result back into wasmtime_val_t.
//
// Phase 14a.5b. Adds ~29 libgossamer bridges to the launcher MVP from
// 14a.5a. Eager-grants Shell + FileSystem + Network capabilities at
// startup and exposes them via env::cap_token(kind), which lets the
// guest pass capability tokens through to the FFI calls that require
// them without re-running gossamer_cap_grant per call.
//
// IPC bridge handlers (gossamer_channel_bind callbacks for
// window_minimize, group_create, transmute, etc. — 27 handlers in the
// native cli/src/main.zig today) DO NOT bridge through wasm. They live
// in libgossamer (or get registered by the launcher itself) and the
// wasm guest never sees them. A follow-up will move them out of
// cli/src/main.zig into libgossamer's channel_open path so the native
// CLI can deprecate cleanly.
//

const std = @import("std");
const launcher = @import("main.zig");

const c = @cImport({
    @cInclude("wasm.h");
    @cInclude("wasmtime.h");
});

//==============================================================================
// libgossamer extern declarations
//==============================================================================
//
// These match the C-ABI exports in src/interface/ffi/src/*.zig. The
// launcher links libgossamer (see build.zig) so the linker resolves
// these at load time.

extern fn gossamer_version() [*:0]const u8;
extern fn gossamer_build_info() [*:0]const u8;
extern fn gossamer_last_error() ?[*:0]const u8;
extern fn gossamer_create_ex(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    min_width: u32,
    min_height: u32,
    max_width: u32,
    max_height: u32,
    resizable: u8,
    decorations: u8,
    fullscreen: u8,
    visible: u8,
) ?*anyopaque;
extern fn gossamer_navigate(handle: u64, url: [*:0]const u8) c_int;
extern fn gossamer_load_html(handle: u64, html: [*:0]const u8) c_int;
extern fn gossamer_channel_open(handle: u64) u64;
extern fn gossamer_set_csp(handle: u64, csp: [*:0]const u8) c_int;
extern fn gossamer_set_title(handle: u64, title: [*:0]const u8) c_int;
extern fn gossamer_registry_add(handle: u64) u32;
extern fn gossamer_run(handle: u64) void;
extern fn gossamer_groove_discover() u32;
extern fn gossamer_groove_status(target_id: u32) u32;
extern fn gossamer_watcher_start(handle: u64, config_json: [*:0]const u8, frontend_dist: [*:0]const u8) ?*anyopaque;
extern fn gossamer_watcher_stop(opaque_handle: ?*anyopaque) void;
extern fn gossamer_shell_spawn(command: [*:0]const u8, cap_token: u64) ?*anyopaque;
extern fn gossamer_shell_kill(opaque_handle: ?*anyopaque, cap_token: u64) c_int;
extern fn gossamer_fs_read_text(path: [*:0]const u8, cap_token: u64) ?[*:0]u8;
extern fn gossamer_fs_write_text(path: [*:0]const u8, contents: [*:0]const u8, cap_token: u64) c_int;
extern fn gossamer_fs_exists(path: [*:0]const u8, cap_token: u64) u32;
extern fn gossamer_fs_mkdir_p(path: [*:0]const u8, cap_token: u64) c_int;
extern fn gossamer_fs_copy_file(src: [*:0]const u8, dst: [*:0]const u8, cap_token: u64) c_int;
extern fn gossamer_conf_load(path: [*:0]const u8, cap_token: u64) ?*anyopaque;
extern fn gossamer_conf_get_string(conf: ?*anyopaque, path: [*:0]const u8) ?[*:0]const u8;
extern fn gossamer_conf_get_int(conf: ?*anyopaque, path: [*:0]const u8, default_value: i64) i64;
extern fn gossamer_conf_get_bool(conf: ?*anyopaque, path: [*:0]const u8, default_value: c_int) c_int;
extern fn gossamer_conf_has(conf: ?*anyopaque, path: [*:0]const u8) c_int;
extern fn gossamer_conf_free(opaque_conf: ?*anyopaque) void;
extern fn gossamer_cap_grant(resource_kind: u32) u64;

//==============================================================================
// Marshalling helpers
//==============================================================================

/// Read a (ptr, len) pair from guest memory, allocate a null-terminated
/// host-side copy, return the slice. Caller frees with c_allocator.
fn dupeZGuestString(env: *launcher.HostEnv, ptr: i32, len: i32) ?[:0]u8 {
    const slice = launcher.guestSlice(env, ptr, len) orelse return null;
    return std.heap.c_allocator.dupeZ(u8, slice) catch null;
}

/// Copy a host C string back into guest memory at (buf_ptr, buf_len).
/// Returns bytes written (excluding NUL — the guest tracks length
/// explicitly), or -1 if the string didn't fit. Null input returns 0.
fn writeCStringToGuest(env: *launcher.HostEnv, src: ?[*:0]const u8, buf_ptr: i32, buf_len: i32) i32 {
    const s = src orelse return 0;
    const slice = std.mem.span(s);
    if (slice.len > std.math.maxInt(i32)) return -1;
    const dst = launcher.guestSlice(env, buf_ptr, @intCast(slice.len)) orelse return -1;
    if (slice.len > buf_len) return -1;
    @memcpy(dst, slice);
    return @intCast(slice.len);
}

/// Resolve an Ephapax String handle (single i32) to a host byte slice.
/// String layout in linear memory (from ephapax-wasm gen_string_new):
///   handle      = i32 pointer to an 8-byte header
///   header[0..4]= data pointer (i32)
///   header[4..8]= length        (i32, little-endian)
/// The data itself lives elsewhere in linear memory; this returns a
/// borrowed slice over it that remains valid until the guest mutates
/// or frees the string.
fn ephStringSlice(env: *launcher.HostEnv, handle: i32) ?[]u8 {
    const header = launcher.guestSlice(env, handle, 8) orelse return null;
    const data_ptr = std.mem.readInt(i32, header[0..4], .little);
    const data_len = std.mem.readInt(i32, header[4..8], .little);
    return launcher.guestSlice(env, data_ptr, data_len);
}

inline fn argI32(args: [*c]const c.wasmtime_val_t, idx: usize) i32 {
    return args[idx].of.i32;
}
inline fn argI64(args: [*c]const c.wasmtime_val_t, idx: usize) i64 {
    return args[idx].of.i64;
}
inline fn argU64(args: [*c]const c.wasmtime_val_t, idx: usize) u64 {
    return @bitCast(args[idx].of.i64);
}
inline fn argU32(args: [*c]const c.wasmtime_val_t, idx: usize) u32 {
    return @bitCast(args[idx].of.i32);
}
inline fn argU8(args: [*c]const c.wasmtime_val_t, idx: usize) u8 {
    return @intCast(args[idx].of.i32 & 0xFF);
}
inline fn retI32(results: [*c]c.wasmtime_val_t, value: i32) void {
    results[0].kind = c.WASMTIME_I32;
    results[0].of.i32 = value;
}
inline fn retI64(results: [*c]c.wasmtime_val_t, value: i64) void {
    results[0].kind = c.WASMTIME_I64;
    results[0].of.i64 = value;
}

//==============================================================================
// String-out bridges (size-first / get-into-buffer pattern)
//==============================================================================

/// env::gossamer_version_to(buf_ptr, buf_len) -> i32
/// Writes the version string into the guest buffer, returns bytes written.
fn bVersionTo(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    retI32(results, writeCStringToGuest(env, gossamer_version(), argI32(args, 0), argI32(args, 1)));
    return null;
}

/// env::gossamer_build_info_to(buf_ptr, buf_len) -> i32
fn bBuildInfoTo(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    retI32(results, writeCStringToGuest(env, gossamer_build_info(), argI32(args, 0), argI32(args, 1)));
    return null;
}

/// env::gossamer_last_error_to(buf_ptr, buf_len) -> i32
fn bLastErrorTo(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    retI32(results, writeCStringToGuest(env, gossamer_last_error(), argI32(args, 0), argI32(args, 1)));
    return null;
}

//==============================================================================
// Webview lifecycle bridges
//==============================================================================

/// env::gossamer_create_ex(title_ptr, title_len, width, height,
///   min_w, min_h, max_w, max_h, resizable, decorations, fullscreen, visible) -> i64
/// Returns the @bitCast u64 of the opaque handle (0 on failure).
fn bCreateEx(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const title_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI64(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(title_z);

    const handle_ptr = gossamer_create_ex(
        title_z.ptr,
        argU32(args, 2),
        argU32(args, 3),
        argU32(args, 4),
        argU32(args, 5),
        argU32(args, 6),
        argU32(args, 7),
        argU8(args, 8),
        argU8(args, 9),
        argU8(args, 10),
        argU8(args, 11),
    );
    const as_u64: u64 = if (handle_ptr) |p| @intFromPtr(p) else 0;
    retI64(results, @bitCast(as_u64));
    return null;
}

/// env::gossamer_navigate(handle, url_ptr, url_len) -> i32
fn bNavigate(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const url_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(url_z);
    retI32(results, gossamer_navigate(argU64(args, 0), url_z.ptr));
    return null;
}

/// env::gossamer_load_html(handle, html_ptr, html_len) -> i32
fn bLoadHtml(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const html_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(html_z);
    retI32(results, gossamer_load_html(argU64(args, 0), html_z.ptr));
    return null;
}

/// env::gossamer_channel_open(handle) -> i64  (channel id; 0 on error)
fn bChannelOpen(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    retI64(results, @bitCast(gossamer_channel_open(argU64(args, 0))));
    return null;
}

/// env::gossamer_set_csp(handle, csp_ptr, csp_len) -> i32
fn bSetCsp(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const csp_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(csp_z);
    retI32(results, gossamer_set_csp(argU64(args, 0), csp_z.ptr));
    return null;
}

/// env::gossamer_set_title(handle, title_ptr, title_len) -> i32
fn bSetTitle(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const title_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(title_z);
    retI32(results, gossamer_set_title(argU64(args, 0), title_z.ptr));
    return null;
}

/// env::gossamer_registry_add(handle) -> i32
fn bRegistryAdd(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    retI32(results, @bitCast(gossamer_registry_add(argU64(args, 0))));
    return null;
}

/// env::gossamer_run(handle) -> ()
fn bRun(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, _: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    gossamer_run(argU64(args, 0));
    return null;
}

//==============================================================================
// Groove discovery
//==============================================================================

/// env::gossamer_groove_discover() -> i32
fn bGrooveDiscover(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, _: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    retI32(results, @bitCast(gossamer_groove_discover()));
    return null;
}

/// env::gossamer_groove_status(target_id) -> i32
fn bGrooveStatus(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    retI32(results, @bitCast(gossamer_groove_status(argU32(args, 0))));
    return null;
}

//==============================================================================
// Watcher (hot-reload)
//==============================================================================

/// env::gossamer_watcher_start(handle, json_ptr, json_len, fdist_ptr, fdist_len) -> i64
fn bWatcherStart(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const json_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI64(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(json_z);
    const fdist_z = dupeZGuestString(env, argI32(args, 3), argI32(args, 4)) orelse {
        retI64(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(fdist_z);
    const handle_ptr = gossamer_watcher_start(argU64(args, 0), json_z.ptr, fdist_z.ptr);
    const as_u64: u64 = if (handle_ptr) |p| @intFromPtr(p) else 0;
    retI64(results, @bitCast(as_u64));
    return null;
}

/// env::gossamer_watcher_stop(opaque_handle) -> ()
fn bWatcherStop(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, _: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const ptr: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    gossamer_watcher_stop(ptr);
    return null;
}

//==============================================================================
// Shell (background process management)
//==============================================================================

/// env::gossamer_shell_spawn(cmd_ptr, cmd_len, cap_token) -> i64  (opaque*)
fn bShellSpawn(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const cmd_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI64(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(cmd_z);
    const handle_ptr = gossamer_shell_spawn(cmd_z.ptr, argU64(args, 2));
    const as_u64: u64 = if (handle_ptr) |p| @intFromPtr(p) else 0;
    retI64(results, @bitCast(as_u64));
    return null;
}

/// env::gossamer_shell_kill(opaque, cap_token) -> i32
fn bShellKill(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const ptr: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    retI32(results, gossamer_shell_kill(ptr, argU64(args, 1)));
    return null;
}

//==============================================================================
// Filesystem
//==============================================================================

/// env::gossamer_fs_read_text(path_ptr, path_len, cap_token, buf_ptr, buf_len) -> i32
/// Reads the file via libgossamer, copies up to buf_len bytes into the
/// guest buffer, returns bytes written or -1.
fn bFsReadText(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const path_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    const buf_ptr = argI32(args, 3);
    const buf_len = argI32(args, 4);
    const result_ptr = gossamer_fs_read_text(path_z.ptr, argU64(args, 2));
    defer if (result_ptr) |p| std.heap.c_allocator.free(std.mem.span(p));
    retI32(results, writeCStringToGuest(env, result_ptr, buf_ptr, buf_len));
    return null;
}

/// env::gossamer_fs_write_text(path_ptr, path_len, contents_ptr, contents_len, cap_token) -> i32
fn bFsWriteText(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const path_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    const contents_z = dupeZGuestString(env, argI32(args, 2), argI32(args, 3)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(contents_z);
    retI32(results, gossamer_fs_write_text(path_z.ptr, contents_z.ptr, argU64(args, 4)));
    return null;
}

/// env::gossamer_fs_exists(path_ptr, path_len, cap_token) -> i32
fn bFsExists(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const path_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    retI32(results, @bitCast(gossamer_fs_exists(path_z.ptr, argU64(args, 2))));
    return null;
}

/// env::gossamer_fs_mkdir_p(path_ptr, path_len, cap_token) -> i32
fn bFsMkdirP(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const path_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    retI32(results, gossamer_fs_mkdir_p(path_z.ptr, argU64(args, 2)));
    return null;
}

/// env::gossamer_fs_copy_file(src_ptr, src_len, dst_ptr, dst_len, cap_token) -> i32
fn bFsCopyFile(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const src_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(src_z);
    const dst_z = dupeZGuestString(env, argI32(args, 2), argI32(args, 3)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(dst_z);
    retI32(results, gossamer_fs_copy_file(src_z.ptr, dst_z.ptr, argU64(args, 4)));
    return null;
}

//==============================================================================
// Conf (JSON config loader)
//==============================================================================

/// env::gossamer_conf_load(path_ptr, path_len, cap_token) -> i64  (opaque*)
fn bConfLoad(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const path_z = dupeZGuestString(env, argI32(args, 0), argI32(args, 1)) orelse {
        retI64(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    const handle_ptr = gossamer_conf_load(path_z.ptr, argU64(args, 2));
    const as_u64: u64 = if (handle_ptr) |p| @intFromPtr(p) else 0;
    retI64(results, @bitCast(as_u64));
    return null;
}

/// env::gossamer_conf_get_string(conf, path_ptr, path_len, buf_ptr, buf_len) -> i32
fn bConfGetString(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const conf: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    const path_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, -1);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    const result_ptr = gossamer_conf_get_string(conf, path_z.ptr);
    retI32(results, writeCStringToGuest(env, result_ptr, argI32(args, 3), argI32(args, 4)));
    return null;
}

/// env::gossamer_conf_get_int(conf, path_ptr, path_len, default) -> i64
fn bConfGetInt(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const conf: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    const path_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI64(results, argI64(args, 3));
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    retI64(results, gossamer_conf_get_int(conf, path_z.ptr, argI64(args, 3)));
    return null;
}

/// env::gossamer_conf_get_bool(conf, path_ptr, path_len, default) -> i32
fn bConfGetBool(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const conf: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    const path_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, argI32(args, 3));
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    retI32(results, gossamer_conf_get_bool(conf, path_z.ptr, argI32(args, 3)));
    return null;
}

/// env::gossamer_conf_has(conf, path_ptr, path_len) -> i32
fn bConfHas(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const conf: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    const path_z = dupeZGuestString(env, argI32(args, 1), argI32(args, 2)) orelse {
        retI32(results, 0);
        return null;
    };
    defer std.heap.c_allocator.free(path_z);
    retI32(results, gossamer_conf_has(conf, path_z.ptr));
    return null;
}

/// env::gossamer_conf_free(conf) -> ()
fn bConfFree(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, _: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const conf: ?*anyopaque = blk: {
        const raw = argU64(args, 0);
        break :blk if (raw == 0) null else @ptrFromInt(raw);
    };
    gossamer_conf_free(conf);
    return null;
}

//==============================================================================
// Capability tokens (eager-granted at startup; guest reads them via cap_token)
//==============================================================================

/// env::cap_token(kind: i32) -> i64
/// Returns the eager-granted token for `kind`, or 0 if no token was
/// granted. Lets the guest pass cap tokens through to fs / shell / etc.
/// without having to call gossamer_cap_grant itself.
fn bCapToken(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const kind = argI32(args, 0);
    const token: u64 = if (kind >= 0 and kind < env.cap_tokens.len)
        env.cap_tokens[@intCast(kind)]
    else
        0;
    retI64(results, @bitCast(token));
    return null;
}

//==============================================================================
// Ephapax-String-aware helpers (resolve guest String handle via memory)
//==============================================================================

/// env::say_string(string_handle: i32) -> ()
/// Print an Ephapax String to stderr. The argument is a single i32 —
/// the Ephapax String handle — which we walk through guest memory to
/// reach the actual bytes. Mirrors the baseline env::print_string but
/// takes the high-level String type so .eph code can call it with a
/// literal: `say_string("hello")`.
fn bSayString(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, _: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const slice = ephStringSlice(env, argI32(args, 0)) orelse return null;
    std.debug.print("{s}", .{slice});
    return null;
}

/// env::argv_eq_string(idx: i32, literal: String) -> i32
/// Returns 1 if argv[idx] equals the literal byte-for-byte, 0 otherwise.
/// Unblocks subcommand-name dispatch from .eph: rather than match by
/// argv_count, the guest can now do
///   if argv_eq_string(1, "dev") == 1 then runDev(...) else ...
fn bArgvEqString(env_raw: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    const env: *launcher.HostEnv = @alignCast(@ptrCast(env_raw orelse return null));
    const idx = argI32(args, 0);
    if (idx < 0 or idx >= env.argv.len) {
        retI32(results, 0);
        return null;
    }
    const literal = ephStringSlice(env, argI32(args, 1)) orelse {
        retI32(results, 0);
        return null;
    };
    const arg = env.argv[@intCast(idx)];
    retI32(results, if (std.mem.eql(u8, arg, literal)) 1 else 0);
    return null;
}

/// env::i64_is_zero(n: i64) -> i32
/// Returns 1 if n == 0, 0 otherwise. Works around v2-grammar Ephapax's
/// lack of i64 literals (`some_i64 == 0` won't typecheck because the
/// literal 0 is always i32). Lets the guest check cap_token results,
/// opaque-handle nullability, etc.
fn bI64IsZero(_: ?*anyopaque, _: ?*c.wasmtime_caller_t, args: [*c]const c.wasmtime_val_t, _: usize, results: [*c]c.wasmtime_val_t, _: usize) callconv(.c) ?*c.wasm_trap_t {
    retI32(results, if (argI64(args, 0) == 0) 1 else 0);
    return null;
}

//==============================================================================
// Imports table — registered into the wasmtime linker by main.zig
//==============================================================================

const I32 = c.WASM_I32;
const I64 = c.WASM_I64;

pub const Imports = [_]launcher.ImportSpec{
    // String-out (size-first / write-into-buffer pattern)
    .{ .name = "gossamer_version_to", .params = &.{ I32, I32 }, .results = &.{I32}, .callback = &bVersionTo },
    .{ .name = "gossamer_build_info_to", .params = &.{ I32, I32 }, .results = &.{I32}, .callback = &bBuildInfoTo },
    .{ .name = "gossamer_last_error_to", .params = &.{ I32, I32 }, .results = &.{I32}, .callback = &bLastErrorTo },

    // Webview lifecycle
    .{ .name = "gossamer_create_ex", .params = &.{ I32, I32, I32, I32, I32, I32, I32, I32, I32, I32, I32, I32 }, .results = &.{I64}, .callback = &bCreateEx },
    .{ .name = "gossamer_navigate", .params = &.{ I64, I32, I32 }, .results = &.{I32}, .callback = &bNavigate },
    .{ .name = "gossamer_load_html", .params = &.{ I64, I32, I32 }, .results = &.{I32}, .callback = &bLoadHtml },
    .{ .name = "gossamer_channel_open", .params = &.{I64}, .results = &.{I64}, .callback = &bChannelOpen },
    .{ .name = "gossamer_set_csp", .params = &.{ I64, I32, I32 }, .results = &.{I32}, .callback = &bSetCsp },
    .{ .name = "gossamer_set_title", .params = &.{ I64, I32, I32 }, .results = &.{I32}, .callback = &bSetTitle },
    .{ .name = "gossamer_registry_add", .params = &.{I64}, .results = &.{I32}, .callback = &bRegistryAdd },
    .{ .name = "gossamer_run", .params = &.{I64}, .results = &.{}, .callback = &bRun },

    // Groove
    .{ .name = "gossamer_groove_discover", .params = &.{}, .results = &.{I32}, .callback = &bGrooveDiscover },
    .{ .name = "gossamer_groove_status", .params = &.{I32}, .results = &.{I32}, .callback = &bGrooveStatus },

    // Watcher
    .{ .name = "gossamer_watcher_start", .params = &.{ I64, I32, I32, I32, I32 }, .results = &.{I64}, .callback = &bWatcherStart },
    .{ .name = "gossamer_watcher_stop", .params = &.{I64}, .results = &.{}, .callback = &bWatcherStop },

    // Shell
    .{ .name = "gossamer_shell_spawn", .params = &.{ I32, I32, I64 }, .results = &.{I64}, .callback = &bShellSpawn },
    .{ .name = "gossamer_shell_kill", .params = &.{ I64, I64 }, .results = &.{I32}, .callback = &bShellKill },

    // Filesystem
    .{ .name = "gossamer_fs_read_text", .params = &.{ I32, I32, I64, I32, I32 }, .results = &.{I32}, .callback = &bFsReadText },
    .{ .name = "gossamer_fs_write_text", .params = &.{ I32, I32, I32, I32, I64 }, .results = &.{I32}, .callback = &bFsWriteText },
    .{ .name = "gossamer_fs_exists", .params = &.{ I32, I32, I64 }, .results = &.{I32}, .callback = &bFsExists },
    .{ .name = "gossamer_fs_mkdir_p", .params = &.{ I32, I32, I64 }, .results = &.{I32}, .callback = &bFsMkdirP },
    .{ .name = "gossamer_fs_copy_file", .params = &.{ I32, I32, I32, I32, I64 }, .results = &.{I32}, .callback = &bFsCopyFile },

    // Conf
    .{ .name = "gossamer_conf_load", .params = &.{ I32, I32, I64 }, .results = &.{I64}, .callback = &bConfLoad },
    .{ .name = "gossamer_conf_get_string", .params = &.{ I64, I32, I32, I32, I32 }, .results = &.{I32}, .callback = &bConfGetString },
    .{ .name = "gossamer_conf_get_int", .params = &.{ I64, I32, I32, I64 }, .results = &.{I64}, .callback = &bConfGetInt },
    .{ .name = "gossamer_conf_get_bool", .params = &.{ I64, I32, I32, I32 }, .results = &.{I32}, .callback = &bConfGetBool },
    .{ .name = "gossamer_conf_has", .params = &.{ I64, I32, I32 }, .results = &.{I32}, .callback = &bConfHas },
    .{ .name = "gossamer_conf_free", .params = &.{I64}, .results = &.{}, .callback = &bConfFree },

    // Capability tokens
    .{ .name = "cap_token", .params = &.{I32}, .results = &.{I64}, .callback = &bCapToken },

    // Ephapax-String-aware helpers
    .{ .name = "say_string", .params = &.{I32}, .results = &.{}, .callback = &bSayString },
    .{ .name = "argv_eq_string", .params = &.{ I32, I32 }, .results = &.{I32}, .callback = &bArgvEqString },
    .{ .name = "i64_is_zero", .params = &.{I64}, .results = &.{I32}, .callback = &bI64IsZero },
};

/// Eager-grant the baseline capability tokens at launcher startup. The
/// guest sees them via env::cap_token(kind). Mirrors the kind taxonomy
/// in src/interface/abi/Types.idr ResourceKind (0=FileSystem, 1=Network,
/// 2=Shell). Notification + Tray + Clipboard are deferred until the
/// guest demonstrates a need; conservative default.
pub fn grantCaps(env: *launcher.HostEnv) void {
    env.cap_tokens[0] = gossamer_cap_grant(0); // FileSystem
    env.cap_tokens[1] = gossamer_cap_grant(1); // Network
    env.cap_tokens[2] = gossamer_cap_grant(2); // Shell
}
