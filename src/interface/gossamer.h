// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer Webview Shell — C Header
//
// C-compatible declarations for the libgossamer shared library FFI.
// This header provides the C function signatures that match the Zig
// `pub export fn` declarations in src/interface/ffi/src/main.zig and
// associated modules.
//
// Usage:
//   #include "gossamer.h"
//   
//   // Create and run a webview
//   uint64_t handle = gossamer_create("Title", 800, 600, 1, 1, 0);
//   gossamer_load_html(handle, "<html>...</html>");
//   gossamer_run(handle);
//   gossamer_destroy(handle);

#ifndef GOSSAMER_H
#define GOSSAMER_H

#include <stdint.h>
#include <stdbool.h>

// Opaque handle types
typedef uint64_t GossamerHandle;
typedef uint64_t ChannelHandle;

// Result codes (must match Gossamer.ABI.Types.Result)
typedef enum {
    GOSSAMER_OK = 0,
    GOSSAMER_ERROR = 1,
    GOSSAMER_INVALID_PARAM = 2,
    GOSSAMER_OUT_OF_MEMORY = 3,
    GOSSAMER_NULL_POINTER = 4,
    GOSSAMER_ALREADY_CONSUMED = 5,
    GOSSAMER_RESOURCE_LEAKED = 6,
    GOSSAMER_DOUBLE_FREE = 7,
    GOSSAMER_WEBVIEW_UNAVAILABLE = 8,
    GOSSAMER_IPC_PROTOCOL_ERROR = 9,
    GOSSAMER_CAPABILITY_DENIED = 10,
    GOSSAMER_GUARD_LOCKED = 11,
} GossamerResult;

// Guard mode
typedef enum {
    GOSSAMER_GUARD_FREE = 0,
    GOSSAMER_GUARD_LOCKED = 1,
    GOSSAMER_GUARD_READ_ONLY = 2,
} GossamerGuardMode;

// Transmute mode
typedef enum {
    GOSSAMER_TRANSMUTE_NONE = 0,
    GOSSAMER_TRANSMUTE_VERTICAL = 1,
    GOSSAMER_TRANSMUTE_HORIZONTAL = 2,
    GOSSAMER_TRANSMUTE_TABS = 3,
} GossamerTransmuteMode;

// Activity level
typedef enum {
    GOSSAMER_ACTIVITY_IDLE = 0,
    GOSSAMER_ACTIVITY_NORMAL = 1,
    GOSSAMER_ACTIVITY_BUSY = 2,
} GossamerActivityLevel;

#ifdef __cplusplus
extern "C" {
#endif

// ===========================================================================
// Version Information
// ===========================================================================

const char* gossamer_build_info(void);
const char* gossamer_version(void);

// ===========================================================================
// Error Handling
// ===========================================================================

/// Get the last error message set on this thread.
/// Returns NULL if no error, otherwise a null-terminated UTF-8 string.
/// The pointer is valid only until the next Gossamer call on this thread.
const char* gossamer_last_error(void);

// ===========================================================================
// Webview Lifecycle
// ===========================================================================

/// Create a new webview window (legacy 6-argument form).
/// 
/// Parameters:
///   title        - Window title (UTF-8 null-terminated)
///   width        - Initial width in pixels
///   height       - Initial height in pixels
///   resizable    - 1 if window can be resized, 0 otherwise
///   decorations  - 1 if window has native chrome, 0 otherwise
///   fullscreen   - 1 for fullscreen mode, 0 otherwise
/// 
/// Returns a GossamerHandle (as uint64_t), or 0 on failure.
/// Must be called from the main thread.
GossamerHandle gossamer_create(
    const char* title,
    uint32_t width,
    uint32_t height,
    uint8_t resizable,
    uint8_t decorations,
    uint8_t fullscreen
);

/// Create a new webview window with extended configuration.
/// 
/// Parameters:
///   title        - Window title (UTF-8 null-terminated)
///   width        - Initial width in pixels
///   height       - Initial height in pixels
///   min_width    - Minimum width (0 = unset)
///   min_height   - Minimum height (0 = unset)
///   max_width    - Maximum width (0 = unset)
///   max_height   - Maximum height (0 = unset)
///   resizable    - 1 if window can be resized, 0 otherwise
///   decorations  - 1 if window has native chrome, 0 otherwise
///   fullscreen   - 1 for fullscreen mode, 0 otherwise
///   visible      - 1 to show immediately, 0 to start hidden
/// 
/// Returns a GossamerHandle (as uint64_t), or 0 on failure.
/// Must be called from the main thread.
GossamerHandle gossamer_create_ex(
    const char* title,
    uint32_t width,
    uint32_t height,
    uint32_t min_width,
    uint32_t min_height,
    uint32_t max_width,
    uint32_t max_height,
    uint8_t resizable,
    uint8_t decorations,
    uint8_t fullscreen,
    uint8_t visible
);

/// Destroy a webview and release all associated resources.
/// After this call, the handle is invalid and must not be used.
void gossamer_destroy(GossamerHandle handle);

/// Run the webview event loop.
/// This blocks until the window is closed.
/// After this returns, the handle is automatically cleaned up.
void gossamer_run(GossamerHandle handle);

// ===========================================================================
// Content Loading
// ===========================================================================

/// Load HTML content into the webview.
/// The HTML string must be null-terminated.
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_load_html(GossamerHandle handle, const char* html);

/// Navigate the webview to a URL.
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_navigate(GossamerHandle handle, const char* url);

/// Evaluate JavaScript in the webview context.
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_eval(GossamerHandle handle, const char* js);

// ===========================================================================
// Window Control
// ===========================================================================

/// Set the window title.
GossamerResult gossamer_set_title(GossamerHandle handle, const char* title);

/// Resize the window to the specified dimensions.
GossamerResult gossamer_resize(GossamerHandle handle, uint32_t width, uint32_t height);

/// Show the window.
GossamerResult gossamer_show(GossamerHandle handle);

/// Hide the window.
GossamerResult gossamer_hide(GossamerHandle handle);

/// Minimize the window.
GossamerResult gossamer_minimize(GossamerHandle handle);

/// Maximize the window.
GossamerResult gossamer_maximize(GossamerHandle handle);

/// Restore the window from minimized/maximized state.
GossamerResult gossamer_restore(GossamerHandle handle);

/// Request the window to close (user-initiated close).
GossamerResult gossamer_request_close(GossamerHandle handle);

/// Set the guard mode for the window.
GossamerResult gossamer_guard_set(GossamerHandle handle, GossamerGuardMode mode);

/// Get the current guard mode for the window.
GossamerGuardMode gossamer_guard_get(GossamerHandle handle);

// ===========================================================================
// IPC Channels
// ===========================================================================

/// Open a typed IPC channel on the webview.
/// Returns a ChannelHandle (as uint64_t), or 0 on failure.
ChannelHandle gossamer_channel_open(GossamerHandle handle);

/// Close an IPC channel.
void gossamer_channel_close(ChannelHandle channel);

/// Bind a synchronous IPC command handler.
/// The callback receives a JSON-encoded request string and optional user data.
/// It must return a JSON-encoded response string (will be copied before return).
/// Returns GOSSAMER_OK on success.
GossamerResult gossamer_channel_bind(
    ChannelHandle channel,
    const char* name,
    const char* (*callback)(const char* request, void* user_data),
    void* user_data
);

/// Bind an asynchronous IPC command handler.
/// The callback runs on a worker thread and its response is delivered
/// back to JavaScript via g_idle_add when complete.
/// Returns GOSSAMER_OK on success.
GossamerResult gossamer_channel_bind_async(
    ChannelHandle channel,
    const char* name,
    const char* (*callback)(const char* request, void* user_data),
    void* user_data
);

// ===========================================================================
// Window Registry
// ===========================================================================

/// Add a webview handle to the global registry.
/// Returns a unique window ID, or 0 on failure.
uint32_t gossamer_registry_add(GossamerHandle handle);

/// Remove a webview handle from the global registry.
void gossamer_registry_remove(GossamerHandle handle);

/// Get the number of registered webview windows.
uint32_t gossamer_registry_count(void);

// ===========================================================================
// Window Groups
// ===========================================================================

/// Create a new window group.
/// Returns a group ID, or 0 on failure.
uint32_t gossamer_group_create(const char* label);

/// Add a window to a group.
GossamerResult gossamer_group_add(uint32_t group_id, uint32_t window_id);

/// Remove a window from a group.
GossamerResult gossamer_group_remove(uint32_t group_id, uint32_t window_id);

/// Destroy a window group.
void gossamer_group_destroy(uint32_t group_id);

/// Apply an operation to all windows in a group.
/// Operations: 0=show, 1=hide, 2=minimize, 3=maximize, 4=restore, 5=close
GossamerResult gossamer_group_apply(uint32_t group_id, uint32_t op);

// ===========================================================================
// Window Arrangement (Transmute)
// ===========================================================================

/// Set the transmute (split-screen/tab) mode for a window.
GossamerResult gossamer_transmute(GossamerHandle handle, GossamerTransmuteMode mode);

/// Get the current transmute mode for a window.
GossamerTransmuteMode gossamer_transmute_get(GossamerHandle handle);

// ===========================================================================
// Activity Tracking
// ===========================================================================

/// Set the activity level for a window.
GossamerResult gossamer_activity_set(GossamerHandle handle, GossamerActivityLevel level);

/// Get the current activity level for a window.
GossamerActivityLevel gossamer_activity_get(GossamerHandle handle);

// ===========================================================================
// Debug Tools
// ===========================================================================

/// Open the developer tools / web inspector for a window.
GossamerResult gossamer_debug_open(GossamerHandle handle);

/// Close the developer tools.
GossamerResult gossamer_debug_close(GossamerHandle handle);

/// Toggle the developer tools.
GossamerResult gossamer_debug_toggle(GossamerHandle handle);

// ===========================================================================
// Clipboard
// ===========================================================================

/// Read text from the system clipboard into the caller-provided buffer.
/// Writes a null-terminated UTF-8 string into `buf` (up to `buf_len - 1` bytes
/// plus terminator). Returns the number of bytes written (excluding the null
/// terminator), or -1 on error. Returns 0 if the clipboard is empty.
///
/// Null-safety: returns -1 (invalid_param) if buf is null or buf_len is 0.
int32_t gossamer_clipboard_read(char* buf, uint32_t buf_len);

/// Write a null-terminated UTF-8 string to the system clipboard.
/// Returns GOSSAMER_OK on success, or an error code on failure.
///
/// Null-safety: returns GOSSAMER_INVALID_PARAM if text is null.
GossamerResult gossamer_clipboard_write(const char* text);

/// Read text from the system clipboard into a newly-allocated buffer.
/// The caller must free the returned pointer with gossamer_free().
///
/// Validates the capability token is active and of type Clipboard (kind=3).
///
/// Returns NULL on error (check gossamer_last_error).
const char* gossamer_clipboard_read_text(uint64_t cap_token);

/// Write text to the system clipboard.
///
/// Validates the capability token is active and of type Clipboard (kind=3).
///
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_clipboard_write_text(const char* text, uint64_t cap_token);

// ===========================================================================
// Theme System
// ===========================================================================

/// Theme kinds for predefined themes.
typedef enum {
    GOSSAMER_THEME_LIGHT = 0,
    GOSSAMER_THEME_DARK = 1,
    GOSSAMER_THEME_HIGH_CONTRAST = 2,
    GOSSAMER_THEME_CUSTOM = 3
} GossamerThemeKind;

/// Apply a theme to a webview by injecting CSS.
/// Uses JavaScript to create a style element and append it to the document head.
///
/// Parameters:
///   handle - The GossamerHandle
///   kind - The theme kind (GOSSAMER_THEME_*)
///   custom_css - Custom CSS string (used when kind == GOSSAMER_THEME_CUSTOM, else NULL)
///
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_theme_apply(GossamerHandle handle, GossamerThemeKind kind, const char* custom_css);

/// Set the theme to light mode.
GossamerResult gossamer_theme_light(GossamerHandle handle);

/// Set the theme to dark mode.
GossamerResult gossamer_theme_dark(GossamerHandle handle);

/// Set the theme to high contrast mode.
GossamerResult gossamer_theme_high_contrast(GossamerHandle handle);

/// Set a custom theme via raw CSS string.
GossamerResult gossamer_theme_custom(GossamerHandle handle, const char* css);

/// Detect the system's preferred color scheme.
/// Returns 1 for dark mode, 0 for light mode, -1 on error/unavailable.
int32_t gossamer_theme_system_detect(void);

// ===========================================================================
// Accessibility
// ===========================================================================

/// Announce a message to screen readers via ARIA live region.
/// Creates or updates a live region element and sets its text content.
///
/// Parameters:
///   handle - The GossamerHandle
///   message - The message to announce (UTF-8 null-terminated)
///   politeness - "polite" or "assertive" (controls interruption behavior)
///
/// Returns GOSSAMER_OK on success, or an error code on failure.
GossamerResult gossamer_a11y_announce(GossamerHandle handle, const char* message, const char* politeness);

/// Set the ARIA live region politeness mode.
/// Politeness can be "polite" (waits for user idle) or "assertive" (interrupts immediately).
GossamerResult gossamer_a11y_set_politeness(GossamerHandle handle, const char* politeness);

/// Set focus to a specific element by CSS selector.
/// Useful for keyboard navigation and accessibility.
GossamerResult gossamer_a11y_focus(GossamerHandle handle, const char* selector);

/// Check if the user prefers reduced motion.
/// Returns 1 for prefers-reduced-motion, 0 for no-preference, -1 on error.
int32_t gossamer_a11y_prefers_reduced_motion(GossamerHandle handle);

/// Check if the user prefers high contrast mode.
/// Returns 1 for prefers-contrast: more, 0 for no-preference, -1 on error.
int32_t gossamer_a11y_prefers_high_contrast(GossamerHandle handle);

// ===========================================================================
// Z-Ordering
// ===========================================================================

/// Raise the window to the top of the z-order.
GossamerResult gossamer_raise(GossamerHandle handle);

/// Lower the window to the bottom of the z-order.
GossamerResult gossamer_lower(GossamerHandle handle);

// ===========================================================================
// Event Broadcasting
// ===========================================================================

/// Broadcast an event to all registered webviews.
/// Returns the number of recipients.
uint32_t gossamer_broadcast(const char* event_name, const char* payload_json);

/// Send an event to a specific window by ID.
GossamerResult gossamer_send_to(uint32_t target_id, const char* event_name, const char* payload_json);

// ===========================================================================
// Groove Discovery
// ===========================================================================

/// Discover available Groove services.
/// Returns the number of services discovered.
uint32_t gossamer_groove_discover(void);

/// Get the status of a specific Groove target.
/// Returns a status code.
uint32_t gossamer_groove_status(uint32_t target_id);

/// Get the manifest JSON for a specific Groove target.
/// Returns a null-terminated JSON string, or NULL on failure.
/// Caller must free the returned pointer with gossamer_free().
const char* gossamer_groove_manifest(uint32_t target_id);

/// Find a Groove target by capability name.
/// Returns the target ID, or 0 if not found.
uint32_t gossamer_groove_find_capability(const char* cap_name);

/// Check compatibility between two Groove targets.
/// Returns 1 if compatible, 0 otherwise.
uint32_t gossamer_groove_check_compat(uint32_t target_a, uint32_t target_b);

/// Send a message to a Groove target.
/// Returns GOSSAMER_OK on success.
GossamerResult gossamer_groove_send(uint32_t target_id, const char* msg);

/// Receive a message from a Groove target.
/// Returns a null-terminated JSON string, or NULL on failure.
/// Caller must free the returned pointer with gossamer_free().
const char* gossamer_groove_recv(uint32_t target_id);

/// Disconnect from a Groove target.
void gossamer_groove_disconnect(uint32_t target_id);

/// Disconnect from all Groove targets.
void gossamer_groove_disconnect_all(void);

// ===========================================================================
// Application Bundler
// ===========================================================================

/// Initialize the bundler for an application.
/// Must be called before other bundler functions.
/// Returns GOSSAMER_OK on success.
GossamerResult gossamer_bundler_init(GossamerHandle handle, const char* app_name);

/// Get the extraction directory path.
/// Returns a C string that the caller must free with gossamer_free().
const char* gossamer_bundler_get_dir(GossamerHandle handle, const char* app_name);

/// Get the full path to an asset in the extraction directory.
/// Returns a C string that the caller must free with gossamer_free().
const char* gossamer_bundler_get_path(GossamerHandle handle, const char* app_name, const char* asset_name);

/// Get a file:// URL for an asset.
/// Returns a C string that the caller must free with gossamer_free().
const char* gossamer_bundler_get_url(GossamerHandle handle, const char* app_name, const char* asset_name);

/// Clean up the extraction directory.
void gossamer_bundler_cleanup(const char* app_name);

// ===========================================================================
// Auto-Updater
// ===========================================================================

/// Set the current application version string.
/// Must be called before checking for updates.
GossamerResult gossamer_updater_set_version(GossamerHandle handle, const char* version);

/// Get the current application version string.
/// Returns a C string that the caller must free with gossamer_free().
const char* gossamer_updater_get_version(void);

/// Configure the update source.
/// source_type: 0 = http_json, 1 = github_releases, 2 = local_file
/// For http_json: param1 is the API endpoint URL
/// For github_releases: param1 is "owner/repo"
/// For local_file: param1 is the path to the version file
GossamerResult gossamer_updater_configure(GossamerHandle handle, uint32_t source_type, const char* param1);

/// Check for updates.
/// Returns: -1 = error, 0 = no update available, 1 = update available
int32_t gossamer_updater_check(GossamerHandle handle);

/// Get the latest version string from the configured source.
/// Returns a C string that the caller must free with gossamer_free().
const char* gossamer_updater_get_latest_version(GossamerHandle handle);

/// Get the update version string if an update is available.
/// Returns a C string that the caller must free with gossamer_free().
/// Returns NULL if no update is available.
const char* gossamer_updater_get_update_version(GossamerHandle handle);

// ===========================================================================
// Memory Management
// ===========================================================================

/// Free a string returned by a Gossamer function.
/// This is a no-op for strings that don't need freeing.
void gossamer_free(const char* ptr);

#ifdef __cplusplus
}
#endif

#endif // GOSSAMER_H
