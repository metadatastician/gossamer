// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — WebKitGTK Platform Implementation (Linux)
//
// Provides the platform-specific webview operations for Linux using
// GTK 3 and WebKitGTK. This is the Phase 1 implementation.
//
// Async IPC Architecture (2026-03-23):
//   When a JS __gossamer_invoke() arrives, the IPC handler runs on the GTK
//   main thread. For commands registered with gossamer_channel_bind_async(),
//   the callback is dispatched to a worker thread (std.Thread.spawn).
//   When the worker completes, g_idle_add() posts the response back to the
//   GTK main thread for JS evaluation. This prevents I/O-heavy callbacks
//   (HTTP, file reads, database queries) from blocking the UI event loop.
//
//   Synchronous commands (registered via gossamer_channel_bind) still run
//   inline on the main thread for zero-overhead fast paths.
//
// Dependencies (system packages):
//   Fedora: gtk3-devel webkit2gtk4.1-devel
//   Debian: libgtk-3-dev libwebkit2gtk-4.1-dev
//   Arch:   gtk3 webkit2gtk-4.1
//

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
    /// Horizontal paned container (webview left, groove dock right).
    /// Created on first dock; null until then.
    paned: ?*c.GtkWidget = null,
    /// Groove dock panel (right side of paned). WebKitGTK webview showing
    /// the docked service's UI. Null when no service is docked.
    dock_webview: ?*c.GtkWidget = null,
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
    min_width: u32,
    min_height: u32,
    max_width: u32,
    max_height: u32,
    resizable: bool,
    decorations: bool,
    fullscreen: bool,
    visible: bool,
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

    if (min_width != 0 or min_height != 0 or max_width != 0 or max_height != 0) {
        var geometry: c.GdkGeometry = std.mem.zeroes(c.GdkGeometry);
        var hints: u32 = 0;

        geometry.min_width = if (min_width != 0) @intCast(min_width) else 0;
        geometry.min_height = if (min_height != 0) @intCast(min_height) else 0;
        geometry.max_width = if (max_width != 0) @intCast(max_width) else std.math.maxInt(c_int);
        geometry.max_height = if (max_height != 0) @intCast(max_height) else std.math.maxInt(c_int);

        if (min_width != 0 or min_height != 0) {
            hints |= @as(u32, @intCast(c.GDK_HINT_MIN_SIZE));
        }
        if (max_width != 0 or max_height != 0) {
            hints |= @as(u32, @intCast(c.GDK_HINT_MAX_SIZE));
        }

        const hint_mask: c.GdkWindowHints = @bitCast(hints);
        c.gtk_window_set_geometry_hints(
            @ptrCast(window),
            null,
            &geometry,
            hint_mask,
        );
    }

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

    // Show everything unless the window should start hidden.
    if (visible) {
        c.gtk_widget_show_all(window);
    }

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

/// Show the webview window.
pub fn show(state: *WebviewState) PlatformError!void {
    c.gtk_widget_show_all(state.window);
}

/// Hide the webview window.
pub fn hide(state: *WebviewState) PlatformError!void {
    c.gtk_widget_hide(state.window);
}

/// Minimize the webview window.
pub fn minimize(state: *WebviewState) PlatformError!void {
    c.gtk_window_iconify(@ptrCast(state.window));
}

/// Maximize the webview window.
pub fn maximize(state: *WebviewState) PlatformError!void {
    c.gtk_window_maximize(@ptrCast(state.window));
}

/// Restore the webview window from minimized or maximized state.
pub fn restore(state: *WebviewState) PlatformError!void {
    c.gtk_window_deiconify(@ptrCast(state.window));
    c.gtk_window_unmaximize(@ptrCast(state.window));
    c.gtk_widget_show_all(state.window);
}

/// Raise the window to the front of the z-order.
pub fn raise(state: *WebviewState) PlatformError!void {
    const gdk_win = c.gtk_widget_get_window(state.window);
    if (gdk_win != null) {
        c.gdk_window_raise(gdk_win);
    }
    // Also present to ensure focus
    c.gtk_window_present(@ptrCast(state.window));
}

/// Lower the window to the back of the z-order.
pub fn lower(state: *WebviewState) PlatformError!void {
    const gdk_win = c.gtk_widget_get_window(state.window);
    if (gdk_win != null) {
        c.gdk_window_lower(gdk_win);
    }
}

/// Move the window to absolute screen coordinates.
pub fn moveTo(state: *WebviewState, x: i32, y: i32) PlatformError!void {
    c.gtk_window_move(@ptrCast(state.window), x, y);
}

/// Request that the GTK window close.
pub fn requestClose(state: *WebviewState) PlatformError!void {
    if (state.gtk_initialized) {
        c.gtk_widget_destroy(state.window);
        state.gtk_initialized = false;
    }
}

/// Run the GTK main event loop. Blocks until the window is closed.
pub fn run(_: *WebviewState) void {
    c.gtk_main();
}

/// Query the screen/monitor dimensions for the window's current display.
/// Returns [width, height]. Falls back to 1920x1080 if detection fails.
pub fn getScreenSize(state: *WebviewState) [2]u32 {
    const gdk_win = c.gtk_widget_get_window(state.window);
    if (gdk_win != null) {
        const display = c.gdk_window_get_display(gdk_win);
        if (display != null) {
            const monitor = c.gdk_display_get_monitor_at_window(display, gdk_win);
            if (monitor != null) {
                var geom: c.GdkRectangle = undefined;
                c.gdk_monitor_get_workarea(monitor, &geom);
                if (geom.width > 0 and geom.height > 0) {
                    return .{ @intCast(geom.width), @intCast(geom.height) };
                }
            }
        }
    }
    return .{ 1920, 1080 };
}

/// Dock a groove service panel on the right side of the window.
/// Creates a GtkPaned (horizontal split) on first call, reparenting the
/// webview into the left pane and creating a new WebKitGTK webview in
/// the right pane that loads the groove service's UI URL.
///
/// side: 0=right, 1=left (right is default)
pub fn dock(state: *WebviewState, url: [*:0]const u8, dock_width: u32) PlatformError!void {
    if (state.dock_webview != null) {
        // Already docked — just navigate the dock webview to the new URL
        const dock_wk: *c.WebKitWebView = @ptrCast(state.dock_webview.?);
        c.webkit_web_view_load_uri(dock_wk, url);
        return;
    }

    // Create the dock webview
    const dock_wv = c.webkit_web_view_new() orelse return PlatformError.WebviewCreateFailed;

    if (state.paned == null) {
        // First dock: reparent the main webview into a GtkPaned.
        // 1. Remove webview from window
        c.gtk_container_remove(@ptrCast(state.window), state.webview);
        // 2. Create horizontal paned
        const paned = c.gtk_paned_new(c.GTK_ORIENTATION_HORIZONTAL) orelse return PlatformError.OperationFailed;
        // 3. Add main webview to left pane
        c.gtk_paned_pack1(@ptrCast(paned), state.webview, 1, 0);
        // 4. Add dock webview to right pane
        c.gtk_paned_pack2(@ptrCast(paned), dock_wv, 0, 0);
        // 5. Set the divider position (main webview gets most of the space)
        const alloc_w = blk: {
            var alloc: c.GtkAllocation = undefined;
            c.gtk_widget_get_allocation(state.window, &alloc);
            break :blk if (alloc.width > 0) @as(c_int, alloc.width) else 800;
        };
        const pos: c_int = alloc_w - @as(c_int, @intCast(@min(dock_width, @as(u32, @intCast(alloc_w)))));
        c.gtk_paned_set_position(@ptrCast(paned), pos);
        // 6. Add paned to window
        c.gtk_container_add(@ptrCast(state.window), paned);
        c.gtk_widget_show_all(paned);
        state.paned = paned;
    } else {
        // Paned already exists (from a previous dock) — just add the new dock webview
        c.gtk_paned_pack2(@ptrCast(state.paned.?), dock_wv, 0, 0);
        c.gtk_widget_show_all(dock_wv);
    }

    // Load the groove service URL into the dock panel
    const dock_wk: *c.WebKitWebView = @ptrCast(dock_wv);
    c.webkit_web_view_load_uri(dock_wk, url);
    state.dock_webview = dock_wv;
}

/// Remove the docked groove panel, restoring the webview to full width.
pub fn undock(state: *WebviewState) void {
    if (state.dock_webview) |dock_wv| {
        c.gtk_widget_destroy(dock_wv);
        state.dock_webview = null;
    }

    if (state.paned) |paned| {
        // Reparent the main webview back to the window directly
        c.gtk_container_remove(@ptrCast(paned), state.webview);
        c.gtk_container_remove(@ptrCast(state.window), paned);
        c.gtk_container_add(@ptrCast(state.window), state.webview);
        c.gtk_widget_show_all(state.webview);
        state.paned = null;
    }
}

/// Register a JavaScript snippet as a persistent user script.
/// Unlike eval(), this survives page navigation and load_html() calls.
/// The script is injected at document-end on every page load.
pub fn addUserScript(state: *WebviewState, js: [*:0]const u8) PlatformError!void {
    const webview_wk: *c.WebKitWebView = @ptrCast(state.webview);
    const manager = c.webkit_web_view_get_user_content_manager(webview_wk);
    if (manager == null) return PlatformError.OperationFailed;

    const script = c.webkit_user_script_new(
        js,
        c.WEBKIT_USER_CONTENT_INJECT_ALL_FRAMES,
        c.WEBKIT_USER_SCRIPT_INJECT_AT_DOCUMENT_END,
        null, // allow_list (all URIs)
        null, // block_list (none)
    ) orelse return PlatformError.OperationFailed;

    c.webkit_user_content_manager_add_script(manager, script);
    c.webkit_user_script_unref(script);
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
    if (c.gtk_main_level() > 0) {
        c.gtk_main_quit();
    }
}

/// "delete-event" signal handler — intercepts the window manager X button.
///
/// When the guard mode is `locked` or `read_only`, this returns TRUE (1)
/// which tells GTK to suppress the close entirely. The window stays open.
///
/// When guard mode is `free`, returns FALSE (0) to allow normal close.
///
/// Also emits a JS event so the frontend can show visual feedback
/// (e.g. flash the guard indicator, play a sound, show a toast).
fn onDeleteEvent(_: ?*c.GtkWidget, _: ?*anyopaque, user_data: ?*anyopaque) callconv(.c) c_int {
    const handle: *GossamerHandle = @ptrCast(@alignCast(user_data orelse return 0));

    if (handle.guard == .free) {
        return 0; // Allow close
    }

    // Guard is active — block the close and notify JS
    const main = @import("main.zig");
    main.setError("Window close blocked by guard (mode: locked or read_only)");

    const notify_js = switch (handle.guard) {
        .locked =>
            \\(function(){
            \\  window.__gossamer_emit&&window.__gossamer_emit('guard_blocked',{action:'close',mode:'locked'});
            \\  var el=document.getElementById('guard-indicator');
            \\  if(el){el.style.animation='none';el.offsetHeight;el.style.animation='flash 0.3s ease 3';}
            \\})();
        ,
        .read_only =>
            \\(function(){
            \\  window.__gossamer_emit&&window.__gossamer_emit('guard_blocked',{action:'close',mode:'read_only'});
            \\  var el=document.getElementById('guard-indicator');
            \\  if(el){el.style.animation='none';el.offsetHeight;el.style.animation='flash 0.3s ease 3';}
            \\})();
        ,
        .free => unreachable,
    };

    const webview_wk: *c.WebKitWebView = @ptrCast(handle.webview.webview);
    c.webkit_web_view_run_javascript(webview_wk, notify_js, null, null, null);

    return 1; // Block close
}

//==============================================================================
// IPC Message Handler — Async-Capable Dispatch
//==============================================================================

/// Opaque reference to GossamerHandle from main.zig.
/// We store this as userdata in the signal handler.
const GossamerHandle = @import("main.zig").GossamerHandle;
const BindingEntry = @import("main.zig").BindingEntry;
const async_ipc = @import("main.zig").async_ipc;

/// Register the WebKitGTK script message handler for IPC dispatch.
///
/// Sets up a `gossamer_ipc` message handler on the WebKitUserContentManager.
/// When JavaScript calls `window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)`,
/// the handler parses the JSON `{id, name, payload}`, looks up the command name
/// in the parent handle's bindings map, and either:
///   - (sync)  invokes the callback inline and sends the response immediately
///   - (async) spawns a worker thread, invokes the callback off the GTK thread,
///             then posts the response back via g_idle_add for JS evaluation
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

    // Install the delete-event guard handler on the GTK window.
    // This intercepts the window manager's X button click. When the guard
    // mode is locked or read_only, the handler returns TRUE to block close.
    // The GossamerHandle pointer is passed as userdata.
    _ = c.g_signal_connect_data(
        @ptrCast(state.window),
        "delete-event",
        @ptrCast(&onDeleteEvent),
        @ptrCast(handle),
        null,
        0,
    );
}

/// Context passed to a worker thread for async IPC dispatch.
/// Heap-allocated, owned by the worker thread. Freed after the
/// g_idle_add callback delivers the response to the GTK main thread.
const AsyncIPCContext = struct {
    /// Owning allocator (for self-cleanup)
    allocator: std.mem.Allocator,
    /// Back-reference to the webview handle (for JS eval on main thread)
    handle: *GossamerHandle,
    /// Call ID from JavaScript (heap-duped, owned)
    id: []u8,
    /// Null-terminated payload string (heap-duped, owned)
    payload_z: [:0]u8,
    /// The callback to invoke
    callback: @import("main.zig").BindingCallback,
    /// User data to pass to the callback
    user_data: ?*anyopaque,
    /// Inflight slot index for cleanup after completion
    inflight_slot: usize,
    /// Response from the callback (set by worker, read by idle callback)
    response: ?[]const u8 = null,
    /// Error message if something went wrong (set by worker)
    err_msg: ?[]const u8 = null,
};

/// IPC message signal handler.
///
/// Called by WebKitGTK when JavaScript posts a message via
/// `window.webkit.messageHandlers.gossamer_ipc.postMessage(msg)`.
///
/// The message is a JSON string: `{"id":"abc","name":"load_level","payload":"{...}"}`
/// We parse it, dispatch to the bound callback (sync or async), and send
/// the response back.
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
    const payload_raw = extractJsonField(msg_slice, "payload") orelse "";
    const binary_flag = extractJsonField(msg_slice, "binary") orelse "0";
    const is_binary = binary_flag.len > 0 and binary_flag[0] == '1';

    const allocator = std.heap.c_allocator;

    // If binary flag is set, payload is base64-encoded.
    // Decode it before passing to the handler.
    var decoded_buf: ?[]u8 = null;
    defer if (decoded_buf) |buf| allocator.free(buf);

    const payload = blk: {
        if (is_binary and payload_raw.len > 0) {
            const decoded = std.base64.standard.Decoder.calcSizeForSlice(payload_raw) catch {
                sendIPCError(handle, id, "Invalid base64 in binary IPC payload");
                return;
            };
            const buf = allocator.alloc(u8, decoded) catch {
                sendIPCError(handle, id, "Out of memory decoding binary payload");
                return;
            };
            std.base64.standard.Decoder.decode(buf, payload_raw) catch {
                allocator.free(buf);
                sendIPCError(handle, id, "Base64 decode error in binary payload");
                return;
            };
            decoded_buf = buf;
            break :blk buf;
        }
        break :blk payload_raw;
    };

    // Look up the binding by name
    const entry: BindingEntry = handle.bindings.get(name) orelse {
        sendIPCError(handle, id, "No handler bound for command");
        return;
    };

    // Plugin liveness check — if the binding was registered by a plugin
    // that has since been unloaded, return a clean error instead of
    // calling into freed code (use-after-free prevention).
    const plugin_mod = @import("plugin.zig");
    if (!plugin_mod.isPluginLoaded(entry.plugin_id)) {
        sendIPCError(handle, id, "Plugin unloaded — handler no longer available");
        return;
    }

    // ─── Async dispatch path ───
    // If the binding is marked async, spawn a worker thread so the
    // GTK event loop is not blocked by I/O-heavy callbacks.
    if (entry.run_async) {
        // Try to acquire an inflight slot (bounded at MAX_INFLIGHT_ASYNC)
        const slot = async_ipc.acquireSlot() orelse {
            sendIPCError(handle, id, "Too many inflight async IPC calls (max 256)");
            return;
        };

        // Heap-allocate context for the worker thread
        const ctx = allocator.create(AsyncIPCContext) catch {
            async_ipc.releaseSlot(slot);
            sendIPCError(handle, id, "Out of memory allocating async context");
            return;
        };

        // Duplicate id and payload — the original slices reference GLib memory
        // that will be freed when this signal handler returns.
        const id_duped = allocator.dupe(u8, id) catch {
            allocator.destroy(ctx);
            async_ipc.releaseSlot(slot);
            sendIPCError(handle, id, "Out of memory");
            return;
        };
        const payload_duped = allocator.dupeZ(u8, payload) catch {
            allocator.free(id_duped);
            allocator.destroy(ctx);
            async_ipc.releaseSlot(slot);
            sendIPCError(handle, id, "Out of memory");
            return;
        };

        ctx.* = .{
            .allocator = allocator,
            .handle = handle,
            .id = id_duped,
            .payload_z = payload_duped,
            .callback = entry.callback,
            .user_data = entry.user_data,
            .inflight_slot = slot,
        };

        // Spawn worker thread — the callback runs off the GTK main thread.
        // detach() so the OS reclaims the thread stack when the worker exits;
        // we never join (response arrives via g_idle_add instead).
        const t = std.Thread.spawn(.{}, asyncWorkerFn, .{ctx}) catch {
            allocator.free(payload_duped);
            allocator.free(id_duped);
            allocator.destroy(ctx);
            async_ipc.releaseSlot(slot);
            sendIPCError(handle, id, "Failed to spawn worker thread");
            return;
        };
        t.detach();

        // The worker thread owns ctx from here. Response will arrive via
        // g_idle_add when the callback completes.
        return;
    }

    // ─── Synchronous dispatch path (original behaviour) ───
    // Fast commands run inline on the GTK main thread.
    const payload_z = allocator.dupeZ(u8, payload) catch {
        sendIPCError(handle, id, "Out of memory");
        return;
    };
    defer allocator.free(payload_z);

    // Invoke the callback with user data.
    // Guard against null returns: std.mem.span on a null sentinel pointer is UB.
    const response_ptr = entry.callback(payload_z, entry.user_data);
    if (@intFromPtr(response_ptr) == 0) {
        sendIPCError(handle, id, "Sync callback returned null");
        return;
    }
    const response = std.mem.span(response_ptr);

    // Send the response back to JavaScript
    sendIPCResponse(handle, id, response);
}

/// Worker function that runs on a spawned thread for async IPC dispatch.
/// Invokes the registered callback, then schedules response delivery
/// on the GTK main thread via g_idle_add.
fn asyncWorkerFn(ctx: *AsyncIPCContext) void {
    // Invoke the callback — this can block (I/O, HTTP, DB queries, etc.)
    // without affecting the GTK event loop.
    const response_ptr = ctx.callback(ctx.payload_z, ctx.user_data);

    // Guard against null returns from C callbacks.
    // std.mem.span on a null sentinel pointer is UB; leave ctx.response as
    // null and let asyncIdleCallback send the error instead.
    if (@intFromPtr(response_ptr) != 0) {
        ctx.response = std.mem.span(response_ptr);
    }

    // Schedule response delivery on the GTK main thread.
    // g_idle_add is thread-safe and will call asyncIdleCallback
    // during the next idle iteration of the GLib main loop.
    _ = c.g_idle_add(@ptrCast(&asyncIdleCallback), @ptrCast(ctx));
}

/// GLib idle callback — runs on the GTK main thread.
/// Delivers the async IPC response to JavaScript and cleans up.
///
/// Returns G_SOURCE_REMOVE (0) so GLib removes the idle source after
/// a single invocation.
fn asyncIdleCallback(user_data: ?*anyopaque) callconv(.c) c_int {
    const ctx: *AsyncIPCContext = @ptrCast(@alignCast(user_data orelse return 0));
    const allocator = ctx.allocator;

    // Deliver the response or error to JavaScript
    if (ctx.err_msg) |err_msg| {
        sendIPCError(ctx.handle, ctx.id, err_msg);
    } else if (ctx.response) |response| {
        sendIPCResponse(ctx.handle, ctx.id, response);
    } else {
        sendIPCError(ctx.handle, ctx.id, "Async callback returned null");
    }

    // Release the inflight slot
    async_ipc.releaseSlot(ctx.inflight_slot);

    // Clean up heap-allocated context
    allocator.free(ctx.payload_z);
    allocator.free(ctx.id);
    allocator.destroy(ctx);

    // G_SOURCE_REMOVE — do not call again
    return 0;
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
/// Handles all control characters (0x00-0x1F) via \uXXXX escapes to ensure
/// binary payloads don't corrupt the JS string.
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
            0x00...0x08, 0x0B, 0x0C, 0x0E...0x1F => {
                // Escape other control characters as \u00XX
                var escape_buf: [6]u8 = undefined;
                _ = std.fmt.bufPrint(&escape_buf, "\\u{X:0>4}", .{ch}) catch unreachable;
                try result.appendSlice(allocator, &escape_buf);
            },
            else => try result.append(allocator, ch),
        }
    }

    return result.toOwnedSlice(allocator);
}
