// Gossamer — GTK File Dialog Implementation (Linux)
//
// Implements native file open/save/directory dialogs using GTK 3's
// GtkFileChooserDialog. Parses filter strings in the format:
//   "Name|ext1;ext2|Name2|ext3;ext4"
// e.g. "JSON files|*.json;*.yaml|All files|*"
//
// All returned paths are heap-allocated C strings via std.heap.c_allocator.
// The caller frees them via gossamer_dialog_free_path().
// Returns 0 (null) if the user cancels or an error occurs.
//
// INVARIANT: GTK-allocated strings (from gtk_file_chooser_get_filename etc.)
// are ALWAYS copied to c_allocator via dupeZ(), then the GTK original is freed
// with g_free(). This ensures gossamer_dialog_free_path() always frees from
// the same allocator that allocated. Do NOT return GTK-allocated pointers.
//
// Dependencies: GTK 3 (already linked by webview_gtk.zig)
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const main = @import("main.zig");

/// GTK C bindings for file chooser dialogs.
const c = @cImport({
    @cInclude("gtk/gtk.h");
});

/// Set the thread-local error from main.zig.
fn setError(msg: []const u8) void {
    main.setError(msg);
}

/// Clear the thread-local error from main.zig.
fn clearError() void {
    main.clearError();
}

/// Allocator used for all path strings returned to callers.
/// Uses libc malloc/free so callers can free with standard free().
const allocator = std.heap.c_allocator;

//==============================================================================
// File Filters
//==============================================================================

/// Maximum number of filter groups that can be parsed from a single filter
/// string. Each group is a (name, patterns) pair.
const MAX_FILTERS = 32;

/// Parse a filter string and add file filters to a GtkFileChooser.
///
/// Filter format: "Name|pattern1;pattern2|Name2|pattern3"
///   - Pairs of (name, patterns) separated by '|'
///   - Multiple patterns within a group separated by ';'
///   - Example: "JSON files|*.json;*.yaml|All files|*"
///
/// If the filter string is empty, no filters are added.
fn addFiltersToChooser(chooser: *c.GtkFileChooser, filters: [*:0]const u8) void {
    const filter_str = std.mem.span(filters);
    if (filter_str.len == 0) return;

    // Split on '|' — alternating name/pattern pairs
    var segment_iter = std.mem.splitScalar(u8, filter_str, '|');
    var filter_count: usize = 0;

    while (filter_count < MAX_FILTERS) {
        // Get the filter display name
        const name_segment = segment_iter.next() orelse break;
        if (name_segment.len == 0) continue;

        // Get the glob pattern(s)
        const pattern_segment = segment_iter.next() orelse break;
        if (pattern_segment.len == 0) continue;

        // Create a GTK file filter
        const file_filter = c.gtk_file_filter_new() orelse continue;

        // gtk_file_filter_set_name requires a null-terminated string.
        // The segment from splitScalar is not null-terminated, so duplicate it.
        const name_z = allocator.dupeZ(u8, name_segment) catch continue;
        defer allocator.free(name_z);
        c.gtk_file_filter_set_name(file_filter, name_z.ptr);

        // Split patterns by ';' and add each one
        var pattern_iter = std.mem.splitScalar(u8, pattern_segment, ';');
        while (pattern_iter.next()) |pattern| {
            if (pattern.len == 0) continue;
            // Null-terminate each pattern for GTK
            const pattern_z = allocator.dupeZ(u8, pattern) catch continue;
            defer allocator.free(pattern_z);
            c.gtk_file_filter_add_pattern(file_filter, pattern_z.ptr);
        }

        c.gtk_file_chooser_add_filter(chooser, file_filter);
        filter_count += 1;
    }
}

//==============================================================================
// GTK Initialisation Guard
//==============================================================================

/// Check whether GTK is initialised. If not, attempt initialisation.
/// Returns true if GTK is ready, false if initialisation failed.
fn ensureGtkInit() bool {
    return c.gtk_init_check(null, null) != 0;
}

//==============================================================================
// Core Dialog Runner
//==============================================================================

/// Run a file chooser dialog and return the selected path.
///
/// Creates a GtkFileChooserDialog with the given action (OPEN/SAVE/SELECT_FOLDER),
/// adds filters, runs the dialog modally, and returns the selected filename as
/// a heap-allocated null-terminated C string.
///
/// Returns 0 if the user cancels or an error occurs.
/// The caller is responsible for freeing the returned string via
/// gossamer_dialog_free_path() or libc free().
fn runFileChooserDialog(
    title: [*:0]const u8,
    filters: [*:0]const u8,
    action: c_uint,
    accept_label: [*:0]const u8,
) u64 {
    if (!ensureGtkInit()) {
        setError("GTK not initialised — cannot show file dialog");
        return 0;
    }

    // Create the file chooser dialog.
    // gtk_file_chooser_dialog_new is variadic; we pass button label/response
    // pairs terminated by a NULL sentinel.
    const dialog = c.gtk_file_chooser_dialog_new(
        title,
        null, // parent window (transient-for) — null for standalone
        @intCast(action),
        @as([*:0]const u8, "_Cancel"),
        @as(c_int, c.GTK_RESPONSE_CANCEL),
        accept_label,
        @as(c_int, c.GTK_RESPONSE_ACCEPT),
        @as(?*anyopaque, null), // variadic sentinel
    ) orelse {
        setError("Failed to create file chooser dialog");
        return 0;
    };

    // Configure the chooser
    const chooser: *c.GtkFileChooser = @ptrCast(dialog);
    addFiltersToChooser(chooser, filters);

    // For save dialogs, prompt before overwriting existing files
    if (action == c.GTK_FILE_CHOOSER_ACTION_SAVE) {
        c.gtk_file_chooser_set_do_overwrite_confirmation(chooser, 1);
    }

    // Run the dialog modally — blocks until the user responds
    const response = c.gtk_dialog_run(@ptrCast(dialog));

    var result: u64 = 0;

    if (response == c.GTK_RESPONSE_ACCEPT) {
        // gtk_file_chooser_get_filename returns a g_malloc'd string
        const filename: ?[*:0]u8 = c.gtk_file_chooser_get_filename(chooser);
        if (filename) |gtk_path| {
            // Copy to a libc-allocated string for consistent free() semantics
            const path_slice = std.mem.span(gtk_path);
            const path_copy = allocator.dupeZ(u8, path_slice) catch {
                c.g_free(gtk_path);
                c.gtk_widget_destroy(dialog);
                setError("Out of memory copying file path");
                return 0;
            };
            // Free the GTK-allocated original
            c.g_free(gtk_path);
            result = @intCast(@intFromPtr(path_copy.ptr));
            clearError();
        }
    }

    // Destroy the dialog widget
    c.gtk_widget_destroy(dialog);

    // Drain pending GTK events so the dialog window fully closes
    while (c.gtk_events_pending() != 0) {
        _ = c.gtk_main_iteration();
    }

    return result;
}

//==============================================================================
// Exported FFI Functions
//==============================================================================

/// Show a file open dialog (single file selection).
///
/// Args:
///   title   — Dialog window title (null-terminated C string)
///   filters — Filter specification: "Name|ext1;ext2|Name2|ext3"
///
/// Returns:
///   Pointer to null-terminated file path string (caller frees via
///   gossamer_dialog_free_path), or 0 if the user cancelled.
///
/// Matches: Gossamer.ABI.Foreign.prim__dialogOpen
export fn gossamer_dialog_open(title: [*:0]const u8, filters: [*:0]const u8) u64 {
    clearError();
    return runFileChooserDialog(
        title,
        filters,
        c.GTK_FILE_CHOOSER_ACTION_OPEN,
        "_Open",
    );
}

/// Show a file save dialog.
///
/// Args:
///   title   — Dialog window title (null-terminated C string)
///   filters — Filter specification: "Name|ext1;ext2|Name2|ext3"
///
/// Returns:
///   Pointer to null-terminated file path string (caller frees via
///   gossamer_dialog_free_path), or 0 if the user cancelled.
///
/// Matches: Gossamer.ABI.Foreign.prim__dialogSave
export fn gossamer_dialog_save(title: [*:0]const u8, filters: [*:0]const u8) u64 {
    clearError();
    return runFileChooserDialog(
        title,
        filters,
        c.GTK_FILE_CHOOSER_ACTION_SAVE,
        "_Save",
    );
}

/// Show a directory picker dialog.
///
/// Args:
///   title — Dialog window title (null-terminated C string)
///
/// Returns:
///   Pointer to null-terminated directory path string (caller frees via
///   gossamer_dialog_free_path), or 0 if the user cancelled.
///
/// Matches: Gossamer.ABI.Foreign.prim__dialogOpenDirectory
export fn gossamer_dialog_open_directory(title: [*:0]const u8) u64 {
    clearError();
    return runFileChooserDialog(
        title,
        "", // No file filters for directory selection
        c.GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
        "_Select",
    );
}

/// Show a file open dialog with multiple file selection.
///
/// Args:
///   title   — Dialog window title (null-terminated C string)
///   filters — Filter specification: "Name|ext1;ext2|Name2|ext3"
///
/// Returns:
///   Pointer to null-terminated string containing selected file paths
///   separated by newlines ('\n'). Caller frees via gossamer_dialog_free_path.
///   Returns 0 if the user cancelled or an error occurred.
///
/// Matches: Gossamer.ABI.Foreign.prim__dialogOpenMultiple
export fn gossamer_dialog_open_multiple(title: [*:0]const u8, filters: [*:0]const u8) u64 {
    clearError();
    if (!ensureGtkInit()) {
        setError("GTK not initialised — cannot show file dialog");
        return 0;
    }

    const dialog = c.gtk_file_chooser_dialog_new(
        title,
        null,
        @intCast(c.GTK_FILE_CHOOSER_ACTION_OPEN),
        @as([*:0]const u8, "_Cancel"),
        @as(c_int, c.GTK_RESPONSE_CANCEL),
        @as([*:0]const u8, "_Open"),
        @as(c_int, c.GTK_RESPONSE_ACCEPT),
        @as(?*anyopaque, null),
    ) orelse {
        setError("Failed to create file chooser dialog");
        return 0;
    };

    const chooser: *c.GtkFileChooser = @ptrCast(dialog);

    // Enable multiple file selection
    c.gtk_file_chooser_set_select_multiple(chooser, 1);

    // Add file filters
    addFiltersToChooser(chooser, filters);

    // Run the dialog modally
    const response = c.gtk_dialog_run(@ptrCast(dialog));

    var result: u64 = 0;

    if (response == c.GTK_RESPONSE_ACCEPT) {
        // Collect all selected filenames into a newline-separated string
        var paths = std.ArrayListUnmanaged(u8){};
        defer paths.deinit(allocator);

        const file_list: ?*c.GSList = c.gtk_file_chooser_get_filenames(chooser);
        var current = file_list;

        var first = true;
        while (current) |node| {
            const filename: ?[*:0]u8 = @ptrCast(@alignCast(node.data));
            if (filename) |f| {
                if (!first) {
                    paths.append(allocator, '\n') catch break;
                }
                const path_slice = std.mem.span(f);
                paths.appendSlice(allocator, path_slice) catch break;
                first = false;
                // Free the individual filename (g_malloc'd by GTK)
                c.g_free(f);
            }
            current = node.next;
        }

        // Free the GSList container (nodes only — data already freed above)
        if (file_list) |list| {
            c.g_slist_free(list);
        }

        if (paths.items.len > 0) {
            // Null-terminate and return
            const result_str = allocator.dupeZ(u8, paths.items) catch {
                c.gtk_widget_destroy(dialog);
                setError("Out of memory building path list");
                return 0;
            };
            result = @intCast(@intFromPtr(result_str.ptr));
            clearError();
        }
    }

    // Destroy the dialog widget
    c.gtk_widget_destroy(dialog);

    // Drain pending GTK events
    while (c.gtk_events_pending() != 0) {
        _ = c.gtk_main_iteration();
    }

    return result;
}

/// Free a path string returned by any gossamer_dialog_* function.
///
/// Convenience function so callers do not need to know the allocator
/// implementation. Safe to call with 0 (null).
///
/// Matches: Gossamer.ABI.Foreign.prim__dialogFreePath
export fn gossamer_dialog_free_path(path_ptr: u64) void {
    if (path_ptr == 0) return;
    const raw: [*]u8 = @ptrFromInt(@as(usize, @intCast(path_ptr)));
    // Find the null terminator to determine the length for free()
    var len: usize = 0;
    while (raw[len] != 0) : (len += 1) {}
    // Free the libc-allocated buffer (allocated via c_allocator / dupeZ)
    allocator.free(raw[0 .. len + 1]); // +1 to include the sentinel byte
}
