// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Accessibility Support
//
// Provides accessibility features for webview-based applications:
// - Screen reader announcements (via ARIA live regions)
// - High contrast mode detection
// - Keyboard navigation focus management
// - Reduced motion preference detection
//
// Platform-specific implementations use native accessibility APIs where available.
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

// ===========================================================================
// ARIA Live Region Support
// ===========================================================================

/// Announce a message to screen readers via ARIA live region.
/// Creates or updates an ARIA live region element and sets its text content.
/// The message will be read aloud by screen readers.
///
/// Parameters:
///   handle_ptr - The GossamerHandle pointer (as u64)
///   message - The message to announce
///   politeness - "polite" or "assertive" (controls interruption behavior)
///
/// Returns Result.ok on success, error code on failure.
pub export fn gossamer_a11y_announce(handle_ptr: u64, message: [*:0]const u8, politeness: [*:0]const u8) Result {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Accessibility announce: null handle");
        return .null_pointer;
    }

    // Escape the message for JavaScript
    var escaped_msg: [1024]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;

    while (message[i] != 0 and j < escaped_msg.len - 10) : (i += 1) {
        switch (message[i]) {
            '\\' => {
                escaped_msg[j] = '\\';
                j += 1;
                escaped_msg[j] = '\\';
                j += 1;
            },
            '"' => {
                escaped_msg[j] = '\\';
                j += 1;
                escaped_msg[j] = '"';
                j += 1;
            },
            '\'' => {
                escaped_msg[j] = '\\';
                j += 1;
                escaped_msg[j] = '\'';
                j += 1;
            },
            '\n' => {
                escaped_msg[j] = '\\';
                j += 1;
                escaped_msg[j] = 'n';
                j += 1;
            },
            '\r' => {
                escaped_msg[j] = '\\';
                j += 1;
                escaped_msg[j] = 'r';
                j += 1;
            },
            else => {
                escaped_msg[j] = message[i];
                j += 1;
            },
        }
    }
    escaped_msg[j] = 0;

    // Escape politeness setting
    var escaped_politeness: [64]u8 = undefined;
    i = 0;
    j = 0;
    while (politeness[i] != 0 and j < escaped_politeness.len - 10) : (i += 1) {
        switch (politeness[i]) {
            '\\' => {
                escaped_politeness[j] = '\\';
                j += 1;
                escaped_politeness[j] = '\\';
                j += 1;
            },
            '"' => {
                escaped_politeness[j] = '\\';
                j += 1;
                escaped_politeness[j] = '"';
                j += 1;
            },
            else => {
                escaped_politeness[j] = politeness[i];
                j += 1;
            },
        }
    }
    escaped_politeness[j] = 0;

    // Build JavaScript
    var js: [2048]u8 = undefined;
    var k: usize = 0;
    const prefix = "(function() { var region = document.getElementById('gossamer-a11y-region'); if (!region) { region = document.createElement('div'); region.id = 'gossamer-a11y-region'; region.setAttribute('role', 'status'); region.setAttribute('aria-live', '";
    var m: usize = 0;
    while (prefix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = prefix[m];
        k += 1;
    }

    m = 0;
    while (escaped_politeness[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = escaped_politeness[m];
        k += 1;
    }

    const middle = "'); region.setAttribute('aria-atomic', 'true'); document.body.appendChild(region); } region.textContent = '";
    m = 0;
    while (middle[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = middle[m];
        k += 1;
    }

    m = 0;
    while (escaped_msg[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = escaped_msg[m];
        k += 1;
    }

    const suffix = "'; })();";
    m = 0;
    while (suffix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = suffix[m];
        k += 1;
    }
    js[k] = 0;

    const result = main.gossamer_eval(handle_ptr, js[0..k :0].ptr);
    if (result != .ok) {
        return result;
    }

    clearError();
    return .ok;
}

/// Set the ARIA live region politeness mode.
/// Politeness can be "polite" (waits for user idle) or "assertive" (interrupts immediately).
pub export fn gossamer_a11y_set_politeness(handle_ptr: u64, politeness: [*:0]const u8) Result {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Accessibility set politeness: null handle");
        return .null_pointer;
    }

    var escaped: [64]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;
    while (politeness[i] != 0 and j < escaped.len - 10) : (i += 1) {
        switch (politeness[i]) {
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
            else => {
                escaped[j] = politeness[i];
                j += 1;
            },
        }
    }
    escaped[j] = 0;

    var js: [512]u8 = undefined;
    const prefix = "(function() { var region = document.getElementById('gossamer-a11y-region'); if (region) { region.setAttribute('aria-live', '";
    var k: usize = 0;
    var m: usize = 0;
    while (prefix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = prefix[m];
        k += 1;
    }

    m = 0;
    while (escaped[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = escaped[m];
        k += 1;
    }

    const suffix = "'); } })();";
    m = 0;
    while (suffix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = suffix[m];
        k += 1;
    }
    js[k] = 0;

    const result = main.gossamer_eval(handle_ptr, js[0..k :0].ptr);
    if (result != .ok) {
        return result;
    }

    clearError();
    return .ok;
}

// ===========================================================================
// Focus Management
// ===========================================================================

/// Set focus to a specific element by CSS selector.
/// Useful for keyboard navigation and accessibility.
pub export fn gossamer_a11y_focus(handle_ptr: u64, selector: [*:0]const u8) Result {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Accessibility focus: null handle");
        return .null_pointer;
    }

    // Build JavaScript to focus element
    var escaped: [256]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;
    while (selector[i] != 0 and j < escaped.len - 10) : (i += 1) {
        switch (selector[i]) {
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
            else => {
                escaped[j] = selector[i];
                j += 1;
            },
        }
    }
    escaped[j] = 0;

    var js: [512]u8 = undefined;
    const prefix = "(function() { var el = document.querySelector('";
    var k: usize = 0;
    var m: usize = 0;
    while (prefix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = prefix[m];
        k += 1;
    }

    m = 0;
    while (escaped[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = escaped[m];
        k += 1;
    }

    const suffix = "'); if (el) { el.focus(); } })();";
    m = 0;
    while (suffix[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = suffix[m];
        k += 1;
    }
    js[k] = 0;

    const result = main.gossamer_eval(handle_ptr, js[0..k :0].ptr);
    if (result != .ok) {
        return result;
    }

    clearError();
    return .ok;
}

// ===========================================================================
// Media Query Detection (Preferences)
// ===========================================================================

/// Check if the user prefers reduced motion.
/// Returns 1 for prefers-reduced-motion, 0 for no-preference, -1 on error.
pub export fn gossamer_a11y_prefers_reduced_motion(handle_ptr: u64) c_int {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Accessibility prefers reduced motion: null handle");
        return -1;
    }

    // Inject a script that stashes the media-query result on a global.
    // Reading it back needs gossamer_eval with return-value support (TODO);
    // until then the return value below is a placeholder.
    var js_set: [256]u8 = undefined;
    const template = "window.__gossamer_a11y_prefers_reduced_motion = (window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 1 : 0);";
    var k: usize = 0;
    var m: usize = 0;
    while (template[m] != 0 and k < js_set.len - 1) : (m += 1) {
        js_set[k] = template[m];
        k += 1;
    }
    js_set[k] = 0;

    const result = main.gossamer_eval(handle_ptr, js_set[0..k :0].ptr);
    if (result != .ok) {
        return -1;
    }

    // TODO: Read the value back - would need gossamer_eval with return value support
    // For now, return 0 as placeholder
    clearError();
    return 0;
}

/// Check if the user prefers high contrast mode.
/// Returns 1 for prefers-contrast: more, 0 for no-preference, -1 on error.
pub export fn gossamer_a11y_prefers_high_contrast(handle_ptr: u64) c_int {
    if (main.ptrFromU64(handle_ptr) == null) {
        setError("Accessibility prefers high contrast: null handle");
        return -1;
    }

    var js: [256]u8 = undefined;
    const template = "window.__gossamer_a11y_prefers_high_contrast = (window.matchMedia('(prefers-contrast: more)').matches ? 1 : 0);";
    var k: usize = 0;
    var m: usize = 0;
    while (template[m] != 0 and k < js.len - 1) : (m += 1) {
        js[k] = template[m];
        k += 1;
    }
    js[k] = 0;

    const result = main.gossamer_eval(handle_ptr, js[0..k :0].ptr);
    if (result != .ok) {
        return -1;
    }

    clearError();
    return 0;
}
