// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Theme System Implementation
//
// Provides theme management (light/dark/custom) via CSS injection into webviews.
// Themes are applied by injecting CSS into the document head via JavaScript.
//
// Thread-safe: uses the platform's main-thread marshaling (g_idle_add on GTK).
//

const std = @import("std");
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

// ===========================================================================
// Theme Definitions
// ===========================================================================

/// Built-in theme CSS strings.
const ThemeCSS = struct {
    pub const light: [*:0]const u8 =
        \\:root {
        \\    --bg-primary: #ffffff;
        \\    --bg-secondary: #f5f5f5;
        \\    --bg-tertiary: #e8e8e8;
        \\    --text-primary: #1a1a2e;
        \\    --text-secondary: #4a4a6e;
        \\    --text-tertiary: #8a8aae;
        \\    --border: #d1d1e0;
        \\    --accent: #0066cc;
        \\    --accent-hover: #0052a3;
        \\    --success: #008000;
        \\    --warning: #cc8800;
        \\    --error: #cc0000;
        \\    --code-bg: #f0f0f0;
        \\    --code-border: #cccccc;
        \\}
        \\body {
        \\    background-color: var(--bg-primary);
        \\    color: var(--text-primary);
        \\}
    ;

    pub const dark: [*:0]const u8 =
        \\:root {
        \\    --bg-primary: #1a1a2e;
        \\    --bg-secondary: #16213e;
        \\    --bg-tertiary: #0f3460;
        \\    --text-primary: #e8e8e8;
        \\    --text-secondary: #b8b8c8;
        \\    --text-tertiary: #888898;
        \\    --border: #3a3a5e;
        \\    --accent: #4dabf7;
        \\    --accent-hover: #339af0;
        \\    --success: #50c878;
        \\    --warning: #ffa600;
        \\    --error: #ff6b81;
        \\    --code-bg: #0f3460;
        \\    --code-border: #3a3a5e;
        \\}
        \\body {
        \\    background-color: var(--bg-primary);
        \\    color: var(--text-primary);
        \\}
    ;

    pub const high_contrast: [*:0]const u8 =
        \\:root {
        \\    --bg-primary: #000000;
        \\    --bg-secondary: #000000;
        \\    --bg-tertiary: #000000;
        \\    --text-primary: #ffffff;
        \\    --text-secondary: #ffffff;
        \\    --text-tertiary: #cccccc;
        \\    --border: #ffffff;
        \\    --accent: #ffff00;
        \\    --accent-hover: #cccc00;
        \\    --success: #00ff00;
        \\    --warning: #ffcc00;
        \\    --error: #ff0000;
        \\    --code-bg: #000000;
        \\    --code-border: #ffffff;
        \\}
        \\body {
        \\    background-color: var(--bg-primary);
        \\    color: var(--text-primary);
        \\}
    ;
};

/// Predefined theme identifiers.
/// Explicitly c_int-tagged: this enum crosses the C ABI (gossamer_theme_apply
/// parameter), and a tagless enum is not permitted in an `export fn` signature.
pub const ThemeKind = enum(c_int) { light, dark, high_contrast, custom };

/// Map theme kind to CSS string.
fn themeCSS(kind: ThemeKind, custom_css: ?[*:0]const u8) [*:0]const u8 {
    return switch (kind) {
        .light => ThemeCSS.light,
        .dark => ThemeCSS.dark,
        .high_contrast => ThemeCSS.high_contrast,
        .custom => custom_css orelse ThemeCSS.light,
    };
}

// ===========================================================================
// Theme Application
// ===========================================================================

/// Apply a theme to a webview by injecting CSS into the document head.
/// Uses JavaScript to create a style element and append it to the head.
///
/// The injection is thread-safe: it uses the platform's main-thread mechanism
/// (g_idle_add on GTK, dispatch_async on Cocoa, etc.) to ensure the JS runs
/// on the correct thread.
///
/// Parameters:
///   handle_ptr - The GossamerHandle pointer (as u64)
///   kind - The predefined theme kind
///   custom_css - Optional custom CSS string (used when kind == .custom)
///
/// Returns:
///   Result.ok on success, error code on failure
pub export fn gossamer_theme_apply(handle_ptr: u64, kind: ThemeKind, custom_css: ?[*:0]const u8) Result {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Theme apply: null handle");
        return .null_pointer;
    }

    const css = themeCSS(kind, custom_css);

    // Escape the CSS for JavaScript string literal
    // Replace backslashes, single quotes, double quotes, and newlines
    var escaped: [4096]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;

    while (css[i] != 0 and j < escaped.len - 10) : (i += 1) {
        switch (css[i]) {
            '\\' => {
                escaped[j] = '\\';
                j += 1;
                escaped[j] = '\\';
                j += 1;
            },
            '"' => {
                escaped[j] = '\\';
                j += 1;
                escaped[j] = '"';
                j += 1;
            },
            '\'' => {
                escaped[j] = '\\';
                j += 1;
                escaped[j] = '\'';
                j += 1;
            },
            '\n' => {
                escaped[j] = '\\';
                j += 1;
                escaped[j] = 'n';
                j += 1;
            },
            '\r' => {
                escaped[j] = '\\';
                j += 1;
                escaped[j] = 'r';
                j += 1;
            },
            else => {
                escaped[j] = css[i];
                j += 1;
            },
        }
    }
    escaped[j] = 0;

    // Build the JavaScript to inject CSS
    var js: [5120]u8 = undefined;
    const js_prefix = "(function() { var style = document.createElement('style'); style.id = 'gossamer-theme'; var existing = document.getElementById('gossamer-theme'); if (existing) { existing.remove(); } style.textContent = '";
    const js_suffix = "'; document.head.appendChild(style); })();";

    // Copy prefix
    var k: usize = 0;
    var m: usize = 0;
    while (js_prefix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = js_prefix[m];
        k += 1;
    }

    // Copy escaped CSS
    m = 0;
    while (escaped[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = escaped[m];
        k += 1;
    }

    // Copy suffix
    m = 0;
    while (js_suffix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = js_suffix[m];
        k += 1;
    }
    js[k] = 0;

    // Evaluate the JavaScript
    const result = main.gossamer_eval(handle_ptr, js[0..k :0].ptr);
    if (result != .ok) {
        // Error already set by eval
        return result;
    }

    clearError();
    return .ok;
}

/// Set the theme to light mode.
pub export fn gossamer_theme_light(handle_ptr: u64) Result {
    return gossamer_theme_apply(handle_ptr, .light, null);
}

/// Set the theme to dark mode.
pub export fn gossamer_theme_dark(handle_ptr: u64) Result {
    return gossamer_theme_apply(handle_ptr, .dark, null);
}

/// Set the theme to high contrast mode.
pub export fn gossamer_theme_high_contrast(handle_ptr: u64) Result {
    return gossamer_theme_apply(handle_ptr, .high_contrast, null);
}

/// Set a custom theme via raw CSS string.
pub export fn gossamer_theme_custom(handle_ptr: u64, css: [*:0]const u8) Result {
    return gossamer_theme_apply(handle_ptr, .custom, css);
}

// ===========================================================================
// System Theme Detection (Platform-Specific)
// ===========================================================================

/// Detect the system's preferred color scheme.
/// Returns 1 for dark mode, 0 for light mode, -1 on error/unavailable.
pub export fn gossamer_theme_system_detect() c_int {
    // Platform detection
    const builtin = @import("builtin");

    return if (builtin.abi == .android)
        -1 // Not available on Android
    else switch (builtin.os.tag) {
        .linux => detectLinuxTheme(),
        .macos => detectMacosTheme(),
        .windows => detectWindowsTheme(),
        else => -1,
    };
}

/// Linux theme detection (read the GTK prefer-dark-theme setting).
/// GtkSettings is a GObject, so the property is read with g_object_get —
/// not g_settings_get_value, which takes a GSettings (different type).
fn detectLinuxTheme() c_int {
    const c = @cImport({
        @cInclude("gtk/gtk.h");
    });

    if (c.gtk_init_check(null, null) != 0) {
        const settings = c.gtk_settings_get_default();
        if (settings != null) {
            var prefer_dark: c.gboolean = 0;
            c.g_object_get(settings, "gtk-application-prefer-dark-theme", &prefer_dark, @as(?*anyopaque, null));
            return if (prefer_dark != 0) 1 else 0;
        }
    }

    return -1;
}

/// macOS theme detection (read AppleInterfaceStyle).
/// Placeholder: needs a CFPreferences query; reported unavailable until then.
fn detectMacosTheme() c_int {
    return -1;
}

/// Windows theme detection (read AppsUseLightTheme from the registry).
/// Placeholder: needs registry access; reported unavailable until then.
fn detectWindowsTheme() c_int {
    return -1;
}
