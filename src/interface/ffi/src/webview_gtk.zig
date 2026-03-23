// Gossamer — WebKitGTK Platform Implementation (Linux)
//
// Provides the platform-specific webview operations for Linux using
// GTK 3 and WebKitGTK. This is the Phase 1 implementation.
//
// Dependencies (system packages):
//   Fedora: gtk3-devel webkit2gtk4.1-devel
//   Debian: libgtk-3-dev libwebkit2gtk-4.1-dev
//   Arch:   gtk3 webkit2gtk-4.1
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

// GTK and WebKitGTK C bindings
const c = @cImport({
    @cInclude("gtk/gtk.h");
    @cInclude("webkit2/webkit2.h");
});

/// Platform-specific webview state for GTK/WebKitGTK.
/// Stored inside GossamerHandle.webview.
pub const WebviewState = struct {
    /// GTK top-level window
    window: *c.GtkWidget,
    /// WebKitGTK web view widget
    webview: *c.GtkWidget,
    /// Whether GTK has been initialised (process-global)
    gtk_initialized: bool,
};

/// Error type for platform operations.
pub const PlatformError = error{
    GtkInitFailed,
    WindowCreateFailed,
    WebviewCreateFailed,
    OperationFailed,
};

/// Create a new GTK window containing a WebKitGTK webview.
///
/// Must be called from the main thread (GTK requirement).
pub fn create(
    title: [*:0]const u8,
    width: u32,
    height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
) PlatformError!WebviewState {
    // Initialise GTK (safe to call multiple times)
    if (c.gtk_init_check(null, null) == 0) {
        return PlatformError.GtkInitFailed;
    }

    // Create top-level window
    const window = c.gtk_window_new(c.GTK_WINDOW_TOPLEVEL) orelse {
        return PlatformError.WindowCreateFailed;
    };

    // Configure window properties
    c.gtk_window_set_title(@ptrCast(window), title);
    c.gtk_window_set_default_size(
        @ptrCast(window),
        @intCast(width),
        @intCast(height),
    );
    c.gtk_window_set_resizable(@ptrCast(window), @intFromBool(resizable));
    c.gtk_window_set_decorated(@ptrCast(window), @intFromBool(decorations));

    if (fullscreen) {
        c.gtk_window_fullscreen(@ptrCast(window));
    }

    // Create WebKitGTK web view
    const webview = c.webkit_web_view_new() orelse {
        c.gtk_widget_destroy(window);
        return PlatformError.WebviewCreateFailed;
    };

    // Add webview to window
    c.gtk_container_add(@ptrCast(window), webview);

    // Connect the "destroy" signal to quit the GTK main loop
    _ = c.g_signal_connect_data(
        @ptrCast(window),
        "destroy",
        @ptrCast(&onWindowDestroy),
        null,
        null,
        0,
    );

    // Show everything
    c.gtk_widget_show_all(window);

    return WebviewState{
        .window = window,
        .webview = webview,
        .gtk_initialized = true,
    };
}

/// Load HTML content into the webview.
pub fn loadHTML(state: *WebviewState, html: [*:0]const u8) PlatformError!void {
    c.webkit_web_view_load_html(
        @ptrCast(state.webview),
        html,
        null, // base URI
    );
}

/// Navigate to a URL.
pub fn navigate(state: *WebviewState, url: [*:0]const u8) PlatformError!void {
    c.webkit_web_view_load_uri(
        @ptrCast(state.webview),
        url,
    );
}

/// Evaluate JavaScript in the webview context.
pub fn eval(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    c.webkit_web_view_run_javascript(
        @ptrCast(state.webview),
        js,
        null, // cancellable
        null, // callback
        null, // user_data
    );
}

/// Set the window title.
pub fn setTitle(state: *WebviewState, title: [*:0]const u8) PlatformError!void {
    c.gtk_window_set_title(@ptrCast(state.window), title);
}

/// Resize the window.
pub fn resize(state: *WebviewState, width: u32, height: u32) PlatformError!void {
    c.gtk_window_resize(
        @ptrCast(state.window),
        @intCast(width),
        @intCast(height),
    );
}

/// Run the GTK main event loop. Blocks until the window is closed.
pub fn run(_: *WebviewState) void {
    c.gtk_main();
}

/// Destroy the webview and its window.
pub fn destroy(state: *WebviewState) void {
    if (state.gtk_initialized) {
        c.gtk_widget_destroy(state.window);
        state.gtk_initialized = false;
    }
}

// Signal handler: called when the GTK window is destroyed.
fn onWindowDestroy(_: ?*c.GtkWidget, _: ?*anyopaque) callconv(.c) void {
    c.gtk_main_quit();
}

//==============================================================================
// IPC Message Handler
//==============================================================================

/// Opaque reference to GossamerHandle from main.zig.
/// We store this as userdata in the signal handler.
const GossamerHandle = @import("main.zig").GossamerHandle;
const BindingEntry = @import("main.zig").BindingEntry;

/// Register the WebKitGTK script message handler for IPC dispatch.
///
/// Sets up a `gossamer_ipc` message handler on the WebKitUserContentManager.
/// When JavaScript calls `window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)`,
/// the handler parses the JSON `{id, name, payload}`, looks up the command name
/// in the parent handle's bindings map, invokes the callback, and sends the
/// result back to JavaScript via `window.__gossamer_callbacks[id].resolve(result)`.
pub fn registerIPCHandler(state: *WebviewState, handle: *GossamerHandle) PlatformError!void {
    // Get the user content manager from the webview
    const webview_wk: *c.WebKitWebView = @ptrCast(state.webview);
    const manager = c.webkit_web_view_get_user_content_manager(webview_wk);
    if (manager == null) {
        return PlatformError.OperationFailed;
    }

    // Register the script message handler name
    _ = c.webkit_user_content_manager_register_script_message_handler(
        manager,
        "gossamer_ipc",
    );

    // Connect the signal, passing the GossamerHandle as userdata
    _ = c.g_signal_connect_data(
        @ptrCast(manager),
        "script-message-received::gossamer_ipc",
        @ptrCast(&onIPCMessage),
        @ptrCast(handle),
        null,
        0,
    );
}

/// IPC message signal handler.
///
/// Called by WebKitGTK when JavaScript posts a message via
/// `window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)`.
///
/// The message is a JSON string: `{"id":"abc","name":"load_level","payload":"{...}"}`
/// We parse it, dispatch to the bound callback, and send the response back.
fn onIPCMessage(
    _: ?*anyopaque, // WebKitUserContentManager (unused)
    result: ?*c.WebKitJavascriptResult,
    user_data: ?*anyopaque,
) callconv(.c) void {
    const handle: *GossamerHandle = @ptrCast(@alignCast(user_data orelse return));
    const js_result = result orelse return;

    // Extract the message string from the JavaScript result
    const js_value = c.webkit_javascript_result_get_js_value(js_result);
    if (js_value == null) return;

    const msg_raw = c.jsc_value_to_string(js_value);
    if (msg_raw == null) return;
    defer c.g_free(msg_raw);

    const msg: [*:0]const u8 = @ptrCast(msg_raw);
    const msg_slice = std.mem.span(msg);

    // Minimal JSON parsing: extract id, name, payload fields.
    // Format: {"id":"...","name":"...","payload":"..."}
    const id = extractJsonField(msg_slice, "id") orelse {
        return; // Malformed message — no id to respond to
    };
    const name = extractJsonField(msg_slice, "name") orelse {
        sendIPCError(handle, id, "Missing 'name' field in IPC message");
        return;
    };
    const payload = extractJsonField(msg_slice, "payload") orelse "";

    // Look up the binding by name
    const entry: BindingEntry = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    // Allocate a null-terminated payload string for the C ABI callback
    const allocator = std.heap.c_allocator;
    const payload_z = allocator.dupeZ(u8, payload) catch {
        sendIPCError(handle, id, "Out of memory");
        return;
    };
    defer allocator.free(payload_z);

    // Invoke the callback with user data
    const response_ptr = entry.callback(payload_z, entry.user_data);
    const response = std.mem.span(response_ptr);

    // Send the response back to JavaScript
    sendIPCResponse(handle, id, response);
}

/// Send a success response back to the JavaScript IPC bridge.
fn sendIPCResponse(handle: *GossamerHandle, id: []const u8, response: []const u8) void {
    const allocator = std.heap.c_allocator;

    // Build JS: window.__gossamer_callbacks["id"].resolve(JSON.parse("response"));
    // We need to escape the response for embedding in a JS string
    const escaped = escapeForJS(allocator, response) catch return;
    defer allocator.free(escaped);

    const js = std.fmt.allocPrintSentinel(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].resolve(JSON.parse(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, escaped, id },
        0,
    ) catch return;
    defer allocator.free(js);

    eval(&handle.webview, js) catch {};
}

/// Send an error response back to the JavaScript IPC bridge.
fn sendIPCError(handle: *GossamerHandle, id: []const u8, msg: []const u8) void {
    const allocator = std.heap.c_allocator;
    const js = std.fmt.allocPrintSentinel(
        allocator,
        "if (window.__gossamer_callbacks[\"{s}\"]) {{ window.__gossamer_callbacks[\"{s}\"].reject(new Error(\"{s}\")); delete window.__gossamer_callbacks[\"{s}\"]; }}",
        .{ id, id, msg, id },
        0,
    ) catch return;
    defer allocator.free(js);

    eval(&handle.webview, js) catch {};
}

/// Extract a JSON string field value by key name.
/// Simple parser for `"key":"value"` patterns — does not handle nested objects
/// or escaped quotes in values. Sufficient for the IPC envelope format.
fn extractJsonField(json: []const u8, key: []const u8) ?[]const u8 {
    // Search for "key":"
    const allocator = std.heap.c_allocator;
    const search = std.fmt.allocPrint(allocator, "\"{s}\":\"", .{key}) catch return null;
    defer allocator.free(search);

    const start_idx = std.mem.indexOf(u8, json, search) orelse return null;
    const value_start = start_idx + search.len;

    // Find the closing quote (handle escaped quotes)
    var i: usize = value_start;
    while (i < json.len) : (i += 1) {
        if (json[i] == '"' and (i == 0 or json[i - 1] != '\\')) {
            return json[value_start..i];
        }
    }
    return null;
}

/// Escape a string for embedding inside a JavaScript double-quoted string.
fn escapeForJS(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var result = std.ArrayListUnmanaged(u8){};
    errdefer result.deinit(allocator);

    for (input) |ch| {
        switch (ch) {
            '"' => try result.appendSlice(allocator, "\\\""),
            '\\' => try result.appendSlice(allocator, "\\\\"),
            '\n' => try result.appendSlice(allocator, "\\n"),
            '\r' => try result.appendSlice(allocator, "\\r"),
            '\t' => try result.appendSlice(allocator, "\\t"),
            else => try result.append(allocator, ch),
        }
    }

    return result.toOwnedSlice(allocator);
}
