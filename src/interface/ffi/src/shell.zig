// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Shell FFI Implementation
//
// Provides shell command execution gated by capability tokens. Each
// operation validates the caller holds a Shell capability (kind=2)
// before invoking the host shell.
//
// Two-operation surface:
//   • gossamer_shell_spawn  — start a process in the background, return
//     an opaque child handle. Stdin/stdout/stderr inherit from the
//     caller. Used by `gossamer dev` to launch the user's frontend dev
//     server (e.g. `deno task dev`) and keep it running alongside the
//     webview.
//   • gossamer_shell_kill   — send SIGTERM (or platform equivalent) to
//     a previously-spawned child, then wait for it. Idempotent on null.
//
// These functions are called from the IPC bridge or directly from
// Ephapax via the FFI shim in src/core/ShellExec.eph. Synchronous
// `gossamer_shell_execute` (run-to-completion, capture stdout) is a
// separate concern tracked elsewhere.
//

const std = @import("std");
const main = @import("main.zig");

/// Heap-allocated wrapper around std.process.Child so the C ABI can
/// hand back a single opaque pointer. Freed inside gossamer_shell_kill
/// after waiting on the child.
const SpawnedChild = struct {
    child: std.process.Child,
};

/// Spawn a shell command in the background. Stdin/stdout/stderr inherit
/// from the caller. The command is executed via `/bin/sh -c` on POSIX
/// hosts and via `cmd /c` on Windows so shell metacharacters resolve as
/// the user expects.
///
/// Validates the capability token is active and of type Shell (kind=2).
///
/// Returns an opaque handle suitable for gossamer_shell_kill, or null
/// on failure (check gossamer_last_error for details).
export fn gossamer_shell_spawn(
    command: [*:0]const u8,
    cap_token: u64,
) ?*anyopaque {
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("Shell capability denied — call gossamer_cap_grant(2) first");
        return null;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 2) {
        main.setError("Wrong capability kind — expected Shell (2)");
        return null;
    }

    const cmd_slice = std.mem.span(command);

    const allocator = std.heap.c_allocator;
    const wrapper = allocator.create(SpawnedChild) catch {
        main.setError("Failed to allocate child wrapper");
        return null;
    };

    const argv = switch (@import("builtin").os.tag) {
        .windows => &[_][]const u8{ "cmd", "/c", cmd_slice },
        else => &[_][]const u8{ "/bin/sh", "-c", cmd_slice },
    };

    wrapper.child = std.process.Child.init(argv, allocator);
    wrapper.child.stdin_behavior = .Inherit;
    wrapper.child.stdout_behavior = .Inherit;
    wrapper.child.stderr_behavior = .Inherit;

    wrapper.child.spawn() catch {
        allocator.destroy(wrapper);
        main.setError("Failed to spawn shell process");
        return null;
    };

    main.clearError();
    return @ptrCast(wrapper);
}

/// Terminate a previously-spawned child and wait for it. Sends SIGTERM
/// on POSIX hosts; on Windows the std.process.Child.kill() implementation
/// uses TerminateProcess. Blocks until the child exits. Idempotent on
/// null (no-op). Frees the wrapper after waiting; the opaque handle is
/// invalid after this call returns.
///
/// Validates the capability token is active and of type Shell (kind=2).
/// Returns Result (0=ok, 1=error, 10=capability_denied).
export fn gossamer_shell_kill(
    opaque_handle: ?*anyopaque,
    cap_token: u64,
) main.Result {
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("Shell capability denied");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 2) {
        main.setError("Wrong capability kind — expected Shell (2)");
        return .capability_denied;
    }

    const p = opaque_handle orelse {
        main.clearError();
        return .ok;
    };

    const allocator = std.heap.c_allocator;
    const wrapper: *SpawnedChild = @alignCast(@ptrCast(p));

    _ = wrapper.child.kill() catch {
        // Process may have already exited — fall through to free.
    };

    allocator.destroy(wrapper);
    main.clearError();
    return .ok;
}
