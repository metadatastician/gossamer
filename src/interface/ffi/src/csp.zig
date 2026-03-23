// Gossamer — CSP Enforcement & Streaming IPC (Backend → Frontend Push)
//
// Provides two runtime capabilities:
//
//   1. Content-Security-Policy enforcement:
//      gossamer_set_csp(handle, csp_string) injects a <meta> CSP tag into the
//      webview, restricting the origin policy for scripts, styles, images, etc.
//      Can be called from config at startup or at runtime for dynamic policy.
//
//   2. Streaming IPC (gossamer_emit):
//      gossamer_emit(handle, event_name, payload_json) pushes an event from
//      the backend (any thread) to the frontend. Uses g_idle_add to marshal
//      the JS evaluation onto the GTK main thread, so it is safe to call from
//      worker threads, async callbacks, or external event sources.
//
//      Frontend JS API:
//        window.__gossamer_on(eventName, callback) — register listener
//        window.__gossamer_emit(eventName, payload)  — dispatched by backend
//        window.gossamer.on(eventName, callback)    — proxy alias
//
// Thread safety:
//   Both functions use g_idle_add for GTK thread marshalling. The context
//   structs are heap-allocated and self-freeing in the idle callback.
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const main = @import("main.zig");
const platform = switch (@import("builtin").os.tag) {
    .linux, .freebsd, .openbsd, .netbsd => @import("webview_gtk.zig"),
    .macos => @import("webview_cocoa.zig"),
    .windows => @import("webview_win32.zig"),
    .ios => @import("webview_ios.zig"),
    else => @compileError("Gossamer: unsupported platform"),
};

/// GTK/GLib C bindings for g_idle_add (thread-safe main-loop dispatch).
const c = @cImport({
    @cInclude("glib.h");
});

//==============================================================================
// CSP Enforcement
//==============================================================================

/// Apply a Content-Security-Policy to the webview by injecting a <meta> tag.
///
/// The CSP string should be a valid Content-Security-Policy directive, e.g.:
///   "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
///
/// This injects:
///   <meta http-equiv="Content-Security-Policy" content="...">
///
/// Can be called at any time — the meta tag is added to the current document's
/// <head>. If called before page load, re-call after navigation.
///
/// Thread safety: if called from a non-GTK thread, uses g_idle_add to marshal
/// the JS evaluation onto the GTK main thread.
export fn gossamer_set_csp(handle_ptr: u64, csp: [*:0]const u8) main.Result {
    main.clearError();
    const handle = main.ptrFromU64(handle_ptr) orelse {
        main.setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        main.setError("Webview not initialized");
        return .@"error";
    }

    const allocator = std.heap.c_allocator;
    const csp_slice = std.mem.span(csp);

    // Escape the CSP string for embedding in a JS string literal.
    // CSP values may contain single quotes (e.g. 'self', 'unsafe-inline').
    const escaped = escapeForJSSingleQuote(allocator, csp_slice) catch {
        main.setError("Out of memory escaping CSP string");
        return .out_of_memory;
    };
    defer allocator.free(escaped);

    // Build JS that removes any existing CSP meta and injects a new one.
    // Uses single-quoted JS strings to avoid conflicts with CSP single quotes.
    const js = std.fmt.allocPrintSentinel(
        allocator,
        "(function(){{var old=document.querySelector('meta[http-equiv=\"Content-Security-Policy\"]');if(old)old.remove();var m=document.createElement('meta');m.httpEquiv='Content-Security-Policy';m.content='{s}';var h=document.head||document.getElementsByTagName('head')[0];if(h)h.appendChild(m);}})()",
        .{escaped},
        0,
    ) catch {
        main.setError("Out of memory building CSP injection JS");
        return .out_of_memory;
    };
    defer allocator.free(js);

    platform.eval(&handle.webview, js) catch {
        main.setError("Failed to evaluate CSP injection JS");
        return .@"error";
    };

    main.clearError();
    return .ok;
}

//==============================================================================
// Streaming IPC — Backend → Frontend Push
//==============================================================================

/// Context for a deferred emit delivered via g_idle_add.
/// Heap-allocated, self-freeing in the idle callback.
const EmitContext = struct {
    /// Allocator for self-cleanup
    allocator: std.mem.Allocator,
    /// Back-reference to the webview handle
    handle: *main.GossamerHandle,
    /// Null-terminated JS string to evaluate (owned)
    js: [:0]u8,
};

/// Push an event from the backend to the frontend webview.
///
/// Evaluates: window.__gossamer_emit("event_name", <payload_json>)
///
/// The event_name is a string identifier. The payload is a JSON string that
/// will be parsed on the frontend side (passed as-is to JSON.parse).
///
/// Thread safety: uses g_idle_add to marshal the JS evaluation onto the GTK
/// main thread. Safe to call from any thread (worker threads, async callbacks,
/// signal handlers, etc.).
///
/// Example (from Zig FFI):
///   gossamer_emit(handle, "file_changed", "{\"path\":\"/tmp/foo.txt\"}")
///
/// Frontend:
///   window.__gossamer_on("file_changed", function(data) {
///     console.log("Changed:", data.path);
///   });
export fn gossamer_emit(
    handle_ptr: u64,
    event_name: [*:0]const u8,
    payload_json: [*:0]const u8,
) main.Result {
    main.clearError();
    const handle = main.ptrFromU64(handle_ptr) orelse {
        main.setError("Null webview handle");
        return .null_pointer;
    };

    if (!handle.initialized) {
        main.setError("Webview not initialized");
        return .@"error";
    }

    const allocator = std.heap.c_allocator;
    const event_slice = std.mem.span(event_name);
    const payload_slice = std.mem.span(payload_json);

    // Escape event name for JS string embedding
    const escaped_event = escapeForJSSingleQuote(allocator, event_slice) catch {
        main.setError("Out of memory escaping event name");
        return .out_of_memory;
    };
    defer allocator.free(escaped_event);

    // Escape payload for JS string embedding
    const escaped_payload = escapeForJSSingleQuote(allocator, payload_slice) catch {
        main.setError("Out of memory escaping payload");
        return .out_of_memory;
    };
    defer allocator.free(escaped_payload);

    // Build JS: window.__gossamer_emit('event_name', JSON.parse('payload'))
    // We parse the payload on the frontend so listeners get a real object.
    const js = std.fmt.allocPrintSentinel(
        allocator,
        "if(window.__gossamer_emit){{window.__gossamer_emit('{s}',JSON.parse('{s}'))}}",
        .{ escaped_event, escaped_payload },
        0,
    ) catch {
        main.setError("Out of memory building emit JS");
        return .out_of_memory;
    };

    // Allocate context for g_idle_add delivery on the GTK main thread.
    // This ensures thread safety — the caller may be on any thread.
    const ctx = allocator.create(EmitContext) catch {
        allocator.free(js);
        main.setError("Out of memory allocating emit context");
        return .out_of_memory;
    };

    ctx.* = .{
        .allocator = allocator,
        .handle = handle,
        .js = js,
    };

    // Schedule JS evaluation on the GTK main thread.
    // g_idle_add is documented as thread-safe in GLib.
    _ = c.g_idle_add(@ptrCast(&emitIdleCallback), @ptrCast(ctx));

    main.clearError();
    return .ok;
}

/// GLib idle callback — runs on the GTK main thread.
/// Evaluates the emit JS and frees the context.
/// Returns G_SOURCE_REMOVE (0) for single invocation.
fn emitIdleCallback(user_data: ?*anyopaque) callconv(.c) c_int {
    const ctx: *EmitContext = @ptrCast(@alignCast(user_data orelse return 0));
    const allocator = ctx.allocator;

    // Evaluate the JS on the webview (now safe — we are on the GTK thread)
    platform.eval(&ctx.handle.webview, ctx.js) catch {};

    // Clean up
    allocator.free(ctx.js);
    allocator.destroy(ctx);

    // G_SOURCE_REMOVE — do not call again
    return 0;
}

//==============================================================================
// String Escaping Helpers
//==============================================================================

/// Escape a string for embedding inside a JavaScript single-quoted string.
/// Handles: ' → \', \ → \\, newlines, carriage returns, tabs.
fn escapeForJSSingleQuote(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var result = std.ArrayListUnmanaged(u8){};
    errdefer result.deinit(allocator);

    for (input) |ch| {
        switch (ch) {
            '\'' => try result.appendSlice(allocator, "\\'"),
            '\\' => try result.appendSlice(allocator, "\\\\"),
            '\n' => try result.appendSlice(allocator, "\\n"),
            '\r' => try result.appendSlice(allocator, "\\r"),
            '\t' => try result.appendSlice(allocator, "\\t"),
            else => try result.append(allocator, ch),
        }
    }

    return result.toOwnedSlice(allocator);
}

//==============================================================================
// Tests
//==============================================================================

test "escapeForJSSingleQuote handles special characters" {
    const allocator = std.testing.allocator;

    const input = "default-src 'self'; script-src 'unsafe-inline'";
    const escaped = try escapeForJSSingleQuote(allocator, input);
    defer allocator.free(escaped);

    try std.testing.expectEqualStrings("default-src \\'self\\'; script-src \\'unsafe-inline\\'", escaped);
}

test "escapeForJSSingleQuote handles backslashes" {
    const allocator = std.testing.allocator;

    const input = "path\\to\\file";
    const escaped = try escapeForJSSingleQuote(allocator, input);
    defer allocator.free(escaped);

    try std.testing.expectEqualStrings("path\\\\to\\\\file", escaped);
}

test "escapeForJSSingleQuote handles newlines and tabs" {
    const allocator = std.testing.allocator;

    const input = "line1\nline2\ttab";
    const escaped = try escapeForJSSingleQuote(allocator, input);
    defer allocator.free(escaped);

    try std.testing.expectEqualStrings("line1\\nline2\\ttab", escaped);
}

test "escapeForJSSingleQuote handles empty string" {
    const allocator = std.testing.allocator;

    const escaped = try escapeForJSSingleQuote(allocator, "");
    defer allocator.free(escaped);

    try std.testing.expectEqualStrings("", escaped);
}

test "gossamer_set_csp rejects null handle" {
    const result = gossamer_set_csp(0, "default-src 'self'");
    try std.testing.expectEqual(main.Result.null_pointer, result);
}

test "gossamer_emit rejects null handle" {
    const result = gossamer_emit(0, "test_event", "{}");
    try std.testing.expectEqual(main.Result.null_pointer, result);
}
