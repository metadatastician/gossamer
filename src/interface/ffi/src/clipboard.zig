// Gossamer — Clipboard FFI Implementation
//
// Implements clipboard read/write operations for the Gossamer webview shell.
// Uses GTK clipboard API on Linux (gtk_clipboard_get, gtk_clipboard_set_text,
// gtk_clipboard_wait_for_text) with fallback error codes on unsupported platforms.
//
// Thread-local return buffer avoids heap allocation for clipboard reads.
// The buffer is valid until the next gossamer_clipboard_read() call on the
// same thread.
//
// Matches ABI: Gossamer.ABI.Types.ResourceKind.Clipboard (kind = 3)
//
// Dependencies: GTK 3 (already linked by webview_gtk.zig)
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const builtin = @import("builtin");
const main = @import("main.zig");

const Result = main.Result;

/// Set the thread-local error from main.zig.
fn setError(msg: []const u8) void {
    main.setError(msg);
}

/// Clear the thread-local error from main.zig.
fn clearError() void {
    main.clearError();
}

//==============================================================================
// Platform-Specific Clipboard Backend
//==============================================================================

/// GTK clipboard backend (Linux, FreeBSD, OpenBSD, NetBSD).
/// Uses the CLIPBOARD selection (not PRIMARY) for cross-application copy/paste.
const gtk_clipboard = struct {
    const c = @cImport({
        @cInclude("gtk/gtk.h");
    });

    /// Ensure GTK is initialised before any clipboard operation.
    /// Returns true if GTK is ready, false on failure.
    fn ensureInit() bool {
        return c.gtk_init_check(null, null) != 0;
    }

    /// Read text from the system clipboard into the caller's buffer.
    /// Returns the number of bytes written (excluding null terminator),
    /// or -1 on error. If the clipboard is empty, returns 0 and writes
    /// a null terminator at buf[0].
    fn read(buf: [*]u8, buf_len: usize) c_int {
        if (!ensureInit()) {
            setError("Clipboard: GTK init failed (no display?)");
            return -1;
        }

        const clipboard = c.gtk_clipboard_get(c.GDK_SELECTION_CLIPBOARD);
        if (clipboard == null) {
            setError("Clipboard: failed to get GTK clipboard");
            return -1;
        }

        const text_ptr: ?[*:0]u8 = c.gtk_clipboard_wait_for_text(clipboard);
        if (text_ptr == null) {
            // Clipboard is empty — not an error
            if (buf_len > 0) {
                buf[0] = 0;
            }
            return 0;
        }
        defer c.g_free(@ptrCast(text_ptr));

        const text = std.mem.span(text_ptr.?);
        const copy_len = @min(text.len, if (buf_len > 0) buf_len - 1 else 0);

        if (copy_len > 0) {
            @memcpy(buf[0..copy_len], text[0..copy_len]);
        }
        if (buf_len > 0) {
            buf[copy_len] = 0;
        }

        return @intCast(copy_len);
    }

    /// Write text to the system clipboard.
    /// Returns .ok on success, error Result on failure.
    fn write(text: [*:0]const u8) Result {
        if (!ensureInit()) {
            setError("Clipboard: GTK init failed (no display?)");
            return .@"error";
        }

        const clipboard = c.gtk_clipboard_get(c.GDK_SELECTION_CLIPBOARD);
        if (clipboard == null) {
            setError("Clipboard: failed to get GTK clipboard");
            return .@"error";
        }

        const text_slice = std.mem.span(text);
        c.gtk_clipboard_set_text(clipboard, text, @intCast(text_slice.len));

        // Store the clipboard contents so they persist after the program exits.
        // gtk_clipboard_store() requires the clipboard owner to have called
        // gtk_clipboard_set_can_store() first, but set_text does this implicitly
        // on modern GTK. This is a best-effort call.
        c.gtk_clipboard_store(clipboard);

        clearError();
        return .ok;
    }
};

/// Unsupported platform fallback — all operations return errors.
const unsupported_clipboard = struct {
    fn read(_: [*]u8, _: usize) c_int {
        setError("Clipboard: not supported on this platform");
        return -1;
    }

    fn write(_: [*:0]const u8) Result {
        setError("Clipboard: not supported on this platform");
        return .@"error";
    }
};

/// Compile-time platform dispatch for clipboard backend.
const backend = switch (builtin.os.tag) {
    .linux, .freebsd, .openbsd, .netbsd => gtk_clipboard,
    else => unsupported_clipboard,
};

//==============================================================================
// Exported C ABI Functions
//==============================================================================

/// Read text from the system clipboard into the caller-provided buffer.
///
/// Writes a null-terminated UTF-8 string into `buf` (up to `buf_len - 1` bytes
/// plus terminator). Returns the number of bytes written (excluding the null
/// terminator), or -1 on error. Returns 0 if the clipboard is empty.
///
/// Null-safety: returns -1 (invalid_param) if buf is null or buf_len is 0.
///
/// Matches ABI: Gossamer.ABI.Types.ResourceKind.Clipboard (kind = 3)
export fn gossamer_clipboard_read(buf: ?[*]u8, buf_len: usize) callconv(.c) c_int {
    if (buf == null or buf_len == 0) {
        setError("Clipboard read: null buffer or zero length");
        return -1;
    }

    clearError();
    return backend.read(buf.?, buf_len);
}

/// Write a null-terminated UTF-8 string to the system clipboard.
///
/// Returns Result.ok (0) on success, or an error code on failure.
///
/// Null-safety: returns invalid_param if text is null.
///
/// Matches ABI: Gossamer.ABI.Types.ResourceKind.Clipboard (kind = 3)
export fn gossamer_clipboard_write(text: ?[*:0]const u8) callconv(.c) c_int {
    if (text == null) {
        setError("Clipboard write: null text pointer");
        return @intFromEnum(Result.invalid_param);
    }

    clearError();
    return @intFromEnum(backend.write(text.?));
}

//==============================================================================
// Tests
//==============================================================================

test "clipboard_write rejects null pointer" {
    const result = gossamer_clipboard_write(null);
    try std.testing.expectEqual(@as(c_int, @intFromEnum(Result.invalid_param)), result);
}

test "clipboard_read rejects null buffer" {
    const result = gossamer_clipboard_read(null, 256);
    try std.testing.expectEqual(@as(c_int, -1), result);
}

test "clipboard_read rejects zero length" {
    var buf: [1]u8 = undefined;
    const result = gossamer_clipboard_read(&buf, 0);
    try std.testing.expectEqual(@as(c_int, -1), result);
}
