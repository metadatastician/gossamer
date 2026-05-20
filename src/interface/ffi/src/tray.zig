// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — System Tray Implementation (Linux/KDE)
//
// Implements the system tray using GTK StatusIcon + GLib/GIO for notifications.
// Uses GTK's built-in status icon which integrates with KDE's SNI protocol
// via XEmbed fallback on Wayland through xdg-desktop-portal.
//
// For KDE Plasma (Fedora Kinoite), this works because:
// - GTK StatusIcon → XEmbed → KDE's legacy tray support
// - GNotification → xdg-desktop-portal → KDE notification daemon
//
// Dependencies: GTK 3 (already linked by webview_gtk.zig)
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const main = @import("main.zig");

const c = @cImport({
    @cInclude("gtk/gtk.h");
});

//==============================================================================
// Tray State
//==============================================================================

/// Maximum number of menu items in the tray context menu.
const MAX_MENU_ITEMS = 64;

/// Tray handle — wraps a GtkStatusIcon + context menu.
pub const TrayHandle = struct {
    /// GTK status icon
    status_icon: *c.GtkStatusIcon,
    /// Right-click context menu
    menu: *c.GtkWidget,
    /// Attached main window, if any.
    window: ?*main.GossamerHandle,
    /// Allocator
    allocator: std.mem.Allocator,
    /// Callback for menu item activation (item_id -> void)
    menu_callback: ?*const fn (u32) callconv(.c) void,
    /// Number of menu items added
    menu_item_count: u32,
    /// Whether the tray is visible
    visible: bool,
};

/// Global tray handle (only one tray per application).
var global_tray: ?*TrayHandle = null;

//==============================================================================
// Tray Lifecycle
//==============================================================================

/// Create a system tray icon.
///
/// Args: tooltip (cstr)
/// Returns: pointer to TrayHandle (as u64), or 0 on failure.
///
/// The tray icon shows a tooltip on hover and a context menu on right-click.
/// Menu items are added via gossamer_tray_add_item.
///
/// Matches: Gossamer.ABI.Foreign.prim__trayCreate
export fn gossamer_tray_create(tooltip: [*:0]const u8) u64 {
    const allocator = std.heap.c_allocator;

    // Ensure GTK is initialised
    if (c.gtk_init_check(null, null) == 0) {
        return 0;
    }

    // Create status icon
    const status_icon = c.gtk_status_icon_new_from_icon_name("preferences-system-network") orelse {
        return 0;
    };

    c.gtk_status_icon_set_tooltip_text(status_icon, tooltip);
    c.gtk_status_icon_set_visible(status_icon, 1);

    // Create context menu
    const menu = c.gtk_menu_new() orelse {
        c.g_object_unref(@ptrCast(status_icon));
        return 0;
    };

    // Allocate tray handle
    const handle = allocator.create(TrayHandle) catch {
        return 0;
    };

    handle.* = .{
        .status_icon = status_icon,
        .menu = menu,
        .window = null,
        .allocator = allocator,
        .menu_callback = null,
        .menu_item_count = 0,
        .visible = true,
    };

    // Connect right-click signal to show menu
    _ = c.g_signal_connect_data(
        @ptrCast(status_icon),
        "popup-menu",
        @ptrCast(&onTrayPopup),
        @ptrCast(handle),
        null,
        0,
    );

    // Connect left-click signal
    _ = c.g_signal_connect_data(
        @ptrCast(status_icon),
        "activate",
        @ptrCast(&onTrayActivate),
        @ptrCast(handle),
        null,
        0,
    );

    global_tray = handle;
    return @intCast(@intFromPtr(handle));
}

/// Destroy the system tray icon. CONSUMES the handle.
export fn gossamer_tray_destroy(handle_ptr: u64) void {
    const handle = trayFromU64(handle_ptr) orelse return;

    c.gtk_status_icon_set_visible(handle.status_icon, 0);
    c.g_object_unref(@ptrCast(handle.status_icon));
    c.gtk_widget_destroy(handle.menu);

    handle.window = null;
    handle.visible = false;
    if (global_tray == handle) global_tray = null;
    handle.allocator.destroy(handle);
}

//==============================================================================
// Menu Management
//==============================================================================

/// Add an item to the tray context menu.
///
/// Args: handle (u64), label (cstr), item_id (u32)
/// Returns: 0 on success, non-zero on failure.
///
/// When the item is clicked, the menu_callback is invoked with item_id.
export fn gossamer_tray_add_item(handle_ptr: u64, label: [*:0]const u8, item_id: u32) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;

    if (handle.menu_item_count >= MAX_MENU_ITEMS) return 2;

    const menu_item = c.gtk_menu_item_new_with_label(label) orelse return 3;

    // Pack the item_id into the signal userdata
    _ = c.g_signal_connect_data(
        @ptrCast(menu_item),
        "activate",
        @ptrCast(&onMenuItemActivate),
        @ptrFromInt(@as(usize, item_id)),
        null,
        0,
    );

    c.gtk_menu_shell_append(@ptrCast(handle.menu), menu_item);
    c.gtk_widget_show(menu_item);
    handle.menu_item_count += 1;

    return 0;
}

/// Add a separator to the tray context menu.
export fn gossamer_tray_add_separator(handle_ptr: u64) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;

    const sep = c.gtk_separator_menu_item_new() orelse return 2;
    c.gtk_menu_shell_append(@ptrCast(handle.menu), sep);
    c.gtk_widget_show(sep);

    return 0;
}

/// Set the callback function for menu item activation.
///
/// The callback receives the item_id (u32) of the activated menu item.
export fn gossamer_tray_set_callback(handle_ptr: u64, callback: ?*const fn (u32) callconv(.c) void) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    handle.menu_callback = callback;
    return 0;
}

/// Set the tray icon by icon name (from icon theme).
///
/// Standard names: "dialog-information", "dialog-warning", "dialog-error",
/// "network-server", "network-offline", "preferences-system-network"
export fn gossamer_tray_set_icon(handle_ptr: u64, icon_name: [*:0]const u8) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    c.gtk_status_icon_set_from_icon_name(handle.status_icon, icon_name);
    return 0;
}

/// Set the tray icon from a file path.
export fn gossamer_tray_set_icon_from_file(handle_ptr: u64, path: [*:0]const u8) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    c.gtk_status_icon_set_from_file(handle.status_icon, path);
    return 0;
}

/// Update the tray tooltip text.
export fn gossamer_tray_set_tooltip(handle_ptr: u64, tooltip: [*:0]const u8) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    c.gtk_status_icon_set_tooltip_text(handle.status_icon, tooltip);
    return 0;
}

/// Show or hide the tray icon.
export fn gossamer_tray_set_visible(handle_ptr: u64, visible: u32) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    c.gtk_status_icon_set_visible(handle.status_icon, @intCast(visible));
    handle.visible = visible != 0;
    return 0;
}

/// Attach a main window handle to the tray so left-click can toggle it.
/// Passing 0 detaches the current window.
export fn gossamer_tray_set_window(handle_ptr: u64, window_ptr: u64) u32 {
    const handle = trayFromU64(handle_ptr) orelse return 1;
    if (window_ptr == 0) {
        handle.window = null;
        return 0;
    }

    const window = main.ptrFromU64(window_ptr) orelse return 2;
    if (!window.initialized or window.closed) return 2;
    handle.window = window;
    return 0;
}

/// Clear any attached main window from the singleton tray.
/// Used when the main window is being destroyed.
export fn gossamer_tray_clear_window() void {
    if (global_tray) |tray| {
        tray.window = null;
    }
}

//==============================================================================
// Notifications
//==============================================================================

/// Show a desktop notification.
///
/// Uses GTK's GNotification which routes through xdg-desktop-portal
/// to the KDE notification daemon on Fedora Kinoite/Wayland.
///
/// Args: title (cstr), body (cstr)
/// Returns: Result (0=ok, 1=error)
export fn gossamer_notify(title: [*:0]const u8, body: [*:0]const u8) u32 {
    // Use notify-send as a simple, reliable approach that works on all
    // Linux desktops including KDE Plasma on Wayland via Fedora Atomic.
    // This avoids linking libnotify and works with the notification portal.
    const allocator = std.heap.c_allocator;

    const title_slice = std.mem.span(title);
    const body_slice = std.mem.span(body);

    const argv = [_][]const u8{
        "notify-send",
        "--app-name=PanLL",
        "--icon=preferences-system-network",
        title_slice,
        body_slice,
    };

    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    }) catch return 1;
    allocator.free(result.stdout);
    allocator.free(result.stderr);

    return 0;
}

//==============================================================================
// Signal Handlers
//==============================================================================

/// Right-click handler: show the context menu.
fn onTrayPopup(
    status_icon: ?*c.GtkStatusIcon,
    button: c.guint,
    activate_time: c.guint32,
    user_data: ?*anyopaque,
) callconv(.c) void {
    const handle: *TrayHandle = @ptrCast(@alignCast(user_data orelse return));

    c.gtk_menu_popup(
        @ptrCast(handle.menu),
        null, // parent_menu_shell
        null, // parent_menu_item
        @ptrCast(&c.gtk_status_icon_position_menu), // position func
        @ptrCast(status_icon), // position func data
        button,
        activate_time,
    );
}

/// Left-click handler: toggle main window visibility.
fn onTrayActivate(
    _: ?*c.GtkStatusIcon,
    _: ?*anyopaque,
) callconv(.c) void {
    if (global_tray) |tray| {
        if (tray.window) |window| {
            if (window.initialized and !window.closed) {
                const handle_ptr = @intFromPtr(window);
                if (window.visible) {
                    _ = main.gossamer_hide(handle_ptr);
                } else {
                    _ = main.gossamer_restore(handle_ptr);
                }
                return;
            }
        }

        if (tray.menu_callback) |cb| {
            cb(0); // item_id 0 = "Open PanLL"
        }
    }
}

/// Menu item activation handler.
fn onMenuItemActivate(
    _: ?*c.GtkWidget,
    user_data: ?*anyopaque,
) callconv(.c) void {
    const item_id: u32 = @intCast(@intFromPtr(user_data));

    if (global_tray) |tray| {
        if (tray.menu_callback) |cb| {
            cb(item_id);
        }
    }
}

//==============================================================================
// Helpers
//==============================================================================

fn trayFromU64(val: u64) ?*TrayHandle {
    if (val == 0) return null;
    return @ptrFromInt(@as(usize, @intCast(val)));
}
