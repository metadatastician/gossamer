// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
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

/// macOS Cocoa clipboard backend.
/// Uses NSPasteboard for copy/paste operations.
const cocoa_clipboard = struct {
    const c = @cImport({
        @cInclude("objc/runtime.h");
        @cInclude("objc/message.h");
    });

    /// Get the general pasteboard (NSPasteboardNameGeneral).
    fn getPasteboard() ?*anyopaque {
        const cls = c.objc_getClass("NSPasteboard") orelse return null;
        const sel = c.sel_registerName("generalPasteboard") orelse return null;
        const func: *const fn (?*anyopaque, c.SEL) callconv(.c) ?*anyopaque = @ptrCast(&c.objc_msgSend);
        return func(@ptrCast(cls), sel);
    }

    /// Create an NSString from a C string.
    fn nsString(str: [*:0]const u8) ?*anyopaque {
        const cls = c.objc_getClass("NSString") orelse return null;
        const sel = c.sel_registerName("stringWithUTF8String:") orelse return null;
        const func: *const fn (?*anyopaque, c.SEL, [*:0]const u8) callconv(.c) ?*anyopaque = @ptrCast(&c.objc_msgSend);
        return func(@ptrCast(cls), sel, str);
    }

    /// Get UTF8 string from NSString.
    fn nsStringToUTF8(str: ?*anyopaque) ?[*:0]const u8 {
        if (str == null) return null;
        const sel = c.sel_registerName("UTF8String") orelse return null;
        const func: *const fn (?*anyopaque, c.SEL) callconv(.c) [*:0]const u8 = @ptrCast(&c.objc_msgSend);
        return func(str, sel);
    }

    /// Read text from the system clipboard.
    fn read(buf: [*]u8, buf_len: usize) c_int {
        const pasteboard = getPasteboard();
        if (pasteboard == null) {
            setError("Clipboard: failed to get NSPasteboard");
            return -1;
        }

        const sel = c.sel_registerName("stringForType:") orelse {
            setError("Clipboard: failed to get stringForType: selector");
            return -1;
        };

        // Get NSString from pasteboard for NSPasteboardTypeString
        const type_str = nsString("NSPasteboardTypeString") orelse {
            setError("Clipboard: failed to create type string");
            return -1;
        };

        const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(&c.objc_msgSend);
        const str: ?*anyopaque = func(pasteboard, sel, type_str);

        if (str == null) {
            // Clipboard is empty
            if (buf_len > 0) {
                buf[0] = 0;
            }
            return 0;
        }

        const utf8_ptr = nsStringToUTF8(str);
        if (utf8_ptr == null) {
            setError("Clipboard: failed to convert NSString to UTF8");
            return -1;
        }

        const text = std.mem.span(utf8_ptr.?);
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
    fn write(text: [*:0]const u8) Result {
        const pasteboard = getPasteboard();
        if (pasteboard == null) {
            setError("Clipboard: failed to get NSPasteboard");
            return .@"error";
        }

        // Clear existing contents
        const clear_sel = c.sel_registerName("clearContents") orelse {
            setError("Clipboard: failed to get clearContents selector");
            return .@"error";
        };
        const clear_func: *const fn (?*anyopaque, c.SEL) callconv(.c) void = @ptrCast(&c.objc_msgSend);
        clear_func(pasteboard, clear_sel);

        // Create NSString from text
        const str = nsString(text) orelse {
            setError("Clipboard: failed to create NSString");
            return .@"error";
        };

        // Create array of items (single item with string)
        const array_cls = c.objc_getClass("NSArray") orelse {
            setError("Clipboard: failed to get NSArray class");
            return .@"error";
        };
        const array_sel = c.sel_registerName("arrayWithObject:") orelse {
            setError("Clipboard: failed to get arrayWithObject: selector");
            return .@"error";
        };
        const func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) ?*anyopaque = @ptrCast(&c.objc_msgSend);
        const items = func(@ptrCast(array_cls), array_sel, str);

        if (items == null) {
            setError("Clipboard: failed to create items array");
            return .@"error";
        }

        // Write to pasteboard
        const write_sel = c.sel_registerName("writeObjects:") orelse {
            setError("Clipboard: failed to get writeObjects: selector");
            return .@"error";
        };
        const write_func: *const fn (?*anyopaque, c.SEL, ?*anyopaque) callconv(.c) void = @ptrCast(&c.objc_msgSend);
        write_func(pasteboard, write_sel, items);

        clearError();
        return .ok;
    }
};

/// Windows Win32 clipboard backend.
/// Uses the Win32 clipboard API (OpenClipboard, GetClipboardData, SetClipboardData).
const win32_clipboard = struct {
    const c = @cImport({
        @cInclude("windows.h");
    });

    /// Read text from the system clipboard.
    fn read(buf: [*]u8, buf_len: usize) c_int {
        if (c.OpenClipboard(null) == 0) {
            setError("Clipboard: OpenClipboard failed");
            return -1;
        }
        defer _ = c.CloseClipboard();

        const h_data = c.GetClipboardData(c.CF_UNICODETEXT);
        if (h_data == null) {
            // Clipboard is empty or doesn't contain text
            if (buf_len > 0) {
                buf[0] = 0;
            }
            return 0;
        }

        const locked = c.GlobalLock(h_data);
        if (locked == null) {
            setError("Clipboard: GlobalLock failed");
            return -1;
        }
        defer _ = c.GlobalUnlock(h_data);
        const text_ptr: [*]const u16 = @ptrCast(@alignCast(locked));

        // Convert UTF-16 to UTF-8
        // Find null terminator
        var len: usize = 0;
        while (text_ptr[len] != 0 and len < 1000000) : (len += 1) {}

        // Allocate temporary buffer for UTF-8 conversion
        var utf8_buf: [1024]u8 = undefined;
        const utf8_len = std.unicode.utf16LeToUtf8(utf8_buf[0..], text_ptr[0..len]) catch {
            setError("Clipboard: UTF-16 to UTF-8 conversion failed");
            return -1;
        };

        const copy_len = @min(utf8_len, if (buf_len > 0) buf_len - 1 else 0);

        if (copy_len > 0) {
            @memcpy(buf[0..copy_len], utf8_buf[0..copy_len]);
        }
        if (buf_len > 0) {
            buf[copy_len] = 0;
        }

        return @intCast(copy_len);
    }

    /// Write text to the system clipboard.
    fn write(text: [*:0]const u8) Result {
        const text_slice = std.mem.span(text);

        // Allocate global memory for clipboard data
        // UTF-16 buffer (worst case 2 bytes per UTF-8 byte + null terminator)
        const utf16_cap = text_slice.len + 1;
        const h_mem = c.GlobalAlloc(c.GMEM_MOVEABLE, utf16_cap * 2);
        if (h_mem == null) {
            setError("Clipboard: GlobalAlloc failed");
            return .@"error";
        }

        const locked = c.GlobalLock(h_mem);
        if (locked == null) {
            _ = c.GlobalFree(h_mem);
            setError("Clipboard: GlobalLock failed");
            return .@"error";
        }
        const utf16_ptr: [*]u16 = @ptrCast(@alignCast(locked));

        // Convert UTF-8 to UTF-16
        const utf16_len = std.unicode.utf8ToUtf16Le(utf16_ptr[0..utf16_cap], text_slice) catch {
            _ = c.GlobalUnlock(h_mem);
            _ = c.GlobalFree(h_mem);
            setError("Clipboard: UTF-8 to UTF-16 conversion failed");
            return .@"error";
        };

        // Add null terminator
        utf16_ptr[utf16_len] = 0;

        // Unlock before setting clipboard data
        _ = c.GlobalUnlock(h_mem);

        if (c.OpenClipboard(null) == 0) {
            _ = c.GlobalFree(h_mem);
            setError("Clipboard: OpenClipboard failed");
            return .@"error";
        }
        defer _ = c.CloseClipboard();

        // Empty clipboard first
        if (c.EmptyClipboard() == 0) {
            _ = c.GlobalFree(h_mem);
            setError("Clipboard: EmptyClipboard failed");
            return .@"error";
        }

        const h_data = c.SetClipboardData(c.CF_UNICODETEXT, h_mem);
        if (h_data == null) {
            _ = c.GlobalFree(h_mem);
            setError("Clipboard: SetClipboardData failed");
            return .@"error";
        }

        // SetClipboardData takes ownership of h_mem - do not free it
        // The clipboard now owns the memory and will free it when cleared

        clearError();
        return .ok;
    }
};

/// Compile-time platform dispatch for clipboard backend.
///
/// Android reports `os.tag == .linux` (it runs a Linux kernel) but ships no
/// GTK, so it is routed to the unsupported-platform stub BEFORE the os-tag
/// switch — exactly as main.zig guards the webview backend with
/// `abi == .android`. The comptime `if` means the platform-specific structs (and
/// their `@cImport` directives) are never referenced, hence never analysed, on
/// non-matching targets.
const backend = if (builtin.abi == .android)
    unsupported_clipboard
else switch (builtin.os.tag) {
    .linux, .freebsd, .openbsd, .netbsd => gtk_clipboard,
    .macos => cocoa_clipboard,
    .windows => win32_clipboard,
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
pub export fn gossamer_clipboard_read(buf: ?[*]u8, buf_len: usize) callconv(.c) c_int {
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
pub export fn gossamer_clipboard_write(text: ?[*:0]const u8) callconv(.c) c_int {
    if (text == null) {
        setError("Clipboard write: null text pointer");
        return @intFromEnum(Result.invalid_param);
    }

    clearError();
    return @intFromEnum(backend.write(text.?));
}

//==============================================================================
// Capability-Gated Clipboard Functions
//==============================================================================

/// Read text from the system clipboard into a newly-allocated buffer.
/// The caller must free the returned pointer with gossamer_free().
///
/// Validates the capability token is active and of type Clipboard (kind=3).
///
/// Returns null on error (check gossamer_last_error).
/// Returns empty string ("") if clipboard is empty.
pub export fn gossamer_clipboard_read_text(cap_token: u64) ?[*:0]u8 {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("Clipboard capability denied — call gossamer_cap_grant(3) first");
        return null;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 3) {
        main.setError("Wrong capability kind — expected Clipboard (3)");
        return null;
    }

    // Read with a temporary buffer
    var tmp_buf: [4096]u8 = undefined;
    const len = backend.read(&tmp_buf, tmp_buf.len);

    if (len < 0) {
        // Error already set by backend
        return null;
    }

    // Allocate result buffer
    const allocator = std.heap.c_allocator;
    const result_len: usize = @intCast(len);
    const result = allocator.allocSentinel(u8, result_len, 0) catch {
        main.setError("Failed to allocate clipboard result");
        return null;
    };

    if (result_len > 0) {
        @memcpy(result[0..result_len], tmp_buf[0..result_len]);
    }

    main.clearError();
    return result.ptr;
}

/// Write text to the system clipboard.
///
/// Validates the capability token is active and of type Clipboard (kind=3).
///
/// Returns Result (0=ok, error code on failure).
pub export fn gossamer_clipboard_write_text(text: [*:0]const u8, cap_token: u64) main.Result {
    // Validate capability
    if (main.gossamer_cap_check(cap_token) != .ok) {
        main.setError("Clipboard capability denied — call gossamer_cap_grant(3) first");
        return .capability_denied;
    }
    if (main.gossamer_cap_resource_kind(cap_token) != 3) {
        main.setError("Wrong capability kind — expected Clipboard (3)");
        return .capability_denied;
    }

    clearError();
    return backend.write(text);
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
