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
