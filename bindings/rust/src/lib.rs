// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! # gossamer-rs — Rust bindings for the Gossamer webview shell
//!
//! Provides a safe, ergonomic Rust API for building desktop applications
//! with Gossamer. Drop-in replacement for Tauri's command registration pattern.
//!
//! ## Quick Start
//!
//! ```rust,no_run
//! use gossamer_rs::App;
//!
//! fn main() -> Result<(), gossamer_rs::Error> {
//!     let mut app = App::new("My App", 800, 600)?;
//!
//!     app.command("greet", |payload| {
//!         let name = payload["name"].as_str().unwrap_or("world");
//!         Ok(serde_json::json!({ "message": format!("Hello, {}!", name) }))
//!     });
//!
//!     app.load_html("<html><body><h1>Hello</h1></body></html>")?;
//!     app.run();
//!     Ok(())
//! }
//! ```
//!
//! ## Migration from Tauri
//!
//! Replace `#[tauri::command]` functions with `app.command()` calls.
//! The handler signature is `Fn(serde_json::Value) -> Result<serde_json::Value, String>`.
//! Gossamer dispatches JSON payloads identically to Tauri's invoke system —
//! your frontend code (ReScript/JS) works unchanged via RuntimeBridge.

#![forbid(unsafe_op_in_unsafe_fn)]

use std::ffi::{c_char, c_int, c_void, CStr, CString};

// =============================================================================
// FFI declarations — matches gossamer/src/interface/ffi/src/main.zig exports
// =============================================================================

#[link(name = "gossamer")]
#[allow(dead_code)]
extern "C" {
    fn gossamer_create(
        title: *const c_char,
        width: u32,
        height: u32,
        resizable: u8,
        decorations: u8,
        fullscreen: u8,
    ) -> u64;

    fn gossamer_create_ex(
        title: *const c_char,
        width: u32,
        height: u32,
        min_width: u32,
        min_height: u32,
        max_width: u32,
        max_height: u32,
        resizable: u8,
        decorations: u8,
        fullscreen: u8,
        visible: u8,
    ) -> u64;

    fn gossamer_load_html(handle: u64, html: *const c_char) -> c_int;
    fn gossamer_navigate(handle: u64, url: *const c_char) -> c_int;
    fn gossamer_eval(handle: u64, js: *const c_char) -> c_int;
    fn gossamer_set_title(handle: u64, title: *const c_char) -> c_int;
    fn gossamer_resize(handle: u64, width: u32, height: u32) -> c_int;
    fn gossamer_show(handle: u64) -> c_int;
    fn gossamer_hide(handle: u64) -> c_int;
    fn gossamer_minimize(handle: u64) -> c_int;
    fn gossamer_maximize(handle: u64) -> c_int;
    fn gossamer_restore(handle: u64) -> c_int;
    fn gossamer_request_close(handle: u64) -> c_int;
    fn gossamer_run(handle: u64);
    fn gossamer_destroy(handle: u64);

    fn gossamer_channel_open(handle: u64) -> u64;
    fn gossamer_channel_bind(
        channel: u64,
        name: *const c_char,
        callback: Option<extern "C" fn(*const c_char, *mut c_void) -> *const c_char>,
        user_data: *mut c_void,
    ) -> c_int;
    fn gossamer_channel_bind_async(
        channel: u64,
        name: *const c_char,
        callback: Option<extern "C" fn(*const c_char, *mut c_void) -> *const c_char>,
        user_data: *mut c_void,
    ) -> c_int;
    fn gossamer_channel_close(channel: u64);
    fn gossamer_async_inflight_count() -> u32;

    fn gossamer_cap_grant(resource_kind: u32) -> u64;
    fn gossamer_cap_check(token: u64) -> c_int;
    fn gossamer_cap_revoke(token: u64);

    fn gossamer_version() -> *const c_char;
    fn gossamer_last_error() -> *const c_char;

    #[allow(dead_code)]
    fn gossamer_tray_create(tooltip: *const c_char) -> u64;
    #[allow(dead_code)]
    fn gossamer_tray_add_item(
        tray: u64,
        label: *const c_char,
        item_id: u32,
    ) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_add_separator(tray: u64) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_callback(
        tray: u64,
        callback: *const c_void,
    ) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_icon(tray: u64, icon_name: *const c_char) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_icon_from_file(tray: u64, path: *const c_char) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_tooltip(tray: u64, tooltip: *const c_char) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_visible(tray: u64, visible: u32) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_set_window(tray: u64, window: u64) -> c_int;
    #[allow(dead_code)]
    fn gossamer_tray_destroy(tray: u64);
    fn gossamer_notify(title: *const c_char, body: *const c_char) -> c_int;

    fn gossamer_set_csp(handle: u64, csp: *const c_char) -> c_int;
    fn gossamer_emit(
        handle: u64,
        event_name: *const c_char,
        payload_json: *const c_char,
    ) -> c_int;
}

// =============================================================================
// Error types
// =============================================================================

/// Gossamer operation error.
#[derive(Debug, Clone)]
pub enum Error {
    /// Failed to create webview window.
    WebviewCreateFailed(String),
    /// FFI operation returned an error code.
    OperationFailed { code: i32, message: String },
    /// String conversion error (null byte in input).
    InvalidString(String),
    /// IPC channel could not be opened.
    ChannelOpenFailed,
}

impl std::fmt::Display for Error {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Error::WebviewCreateFailed(msg) => write!(f, "webview create failed: {msg}"),
            Error::OperationFailed { code, message } => {
                write!(f, "operation failed (code {code}): {message}")
            }
            Error::InvalidString(msg) => write!(f, "invalid string: {msg}"),
            Error::ChannelOpenFailed => write!(f, "IPC channel open failed"),
        }
    }
}

impl std::error::Error for Error {}

// =============================================================================
// Result code helpers
// =============================================================================

/// Check an FFI result code and return Ok or an appropriate Error.
fn check_result(code: c_int) -> Result<(), Error> {
    if code == 0 {
        Ok(())
    } else {
        let message = last_error().unwrap_or_else(|| format!("unknown error (code {code})"));
        Err(Error::OperationFailed {
            code: code as i32,
            message,
        })
    }
}

/// Get the last error message from the Zig FFI layer.
fn last_error() -> Option<String> {
    // SAFETY: gossamer_last_error returns a valid C string or null
    let ptr = unsafe { gossamer_last_error() };
    if ptr.is_null() {
        None
    } else {
        // SAFETY: FFI guarantees null-terminated string
        Some(
            unsafe { CStr::from_ptr(ptr) }
                .to_string_lossy()
                .into_owned(),
        )
    }
}

// =============================================================================
// Command handler infrastructure
// =============================================================================

/// Type-erased command handler: receives JSON payload, returns JSON result.
type CommandHandler = Box<dyn Fn(serde_json::Value) -> Result<serde_json::Value, String> + Send>;

/// Per-command context stored on the heap and passed as user_data through the C ABI.
struct CommandContext {
    handler: CommandHandler,
}

/// The C-ABI trampoline called by Gossamer's IPC dispatcher.
/// Receives the JSON payload string and the user_data pointer (a *CommandContext).
/// Returns a heap-allocated JSON response string that Zig will read and then
/// the caller is responsible for (Zig copies it before returning).
extern "C" fn command_trampoline(payload: *const c_char, user_data: *mut c_void) -> *const c_char {
    // SAFETY: user_data is a Box<CommandContext> that we leaked in App::command().
    // We borrow it here (not consume) — the pointer remains valid.
    let ctx = unsafe { &*(user_data as *const CommandContext) };

    // Parse the payload
    // SAFETY: payload is a valid null-terminated string from Zig
    let payload_str = unsafe { CStr::from_ptr(payload) }.to_str().unwrap_or("{}");

    let payload_value: serde_json::Value =
        serde_json::from_str(payload_str).unwrap_or(serde_json::Value::Object(Default::default()));

    // Call the Rust handler
    let result = match (ctx.handler)(payload_value) {
        Ok(val) => val,
        Err(e) => serde_json::json!({ "error": e }),
    };

    // Serialize the response to a C string
    let response = serde_json::to_string(&result).unwrap_or_else(|_| "{}".to_string());
    let c_response = CString::new(response)
        .unwrap_or_else(|_| CString::new("{}").expect("the literal \"{}\" contains no interior NUL byte"));

    // Leak the CString — Zig copies it via std.mem.span, so this is safe.
    // The leaked memory is small and bounded by the number of IPC calls.
    // In a production version, Zig would call a free function.
    c_response.into_raw() as *const c_char
}

// =============================================================================
// Resource kinds (matches Types.idr ResourceKind)
// =============================================================================

/// Capability resource kinds matching the Idris2 ABI definitions.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u32)]
pub enum ResourceKind {
    /// Filesystem access.
    FileSystem = 0,
    /// Network access.
    Network = 1,
    /// Shell/subprocess execution.
    Shell = 2,
    /// Clipboard access.
    Clipboard = 3,
    /// Desktop notifications.
    Notification = 4,
    /// System tray.
    Tray = 5,
}

/// A capability token granting access to a specific resource kind.
/// Linear semantics: must be revoked exactly once when no longer needed.
pub struct Capability {
    token: u64,
    kind: ResourceKind,
}

impl Capability {
    /// Grant a new capability token for the given resource kind.
    pub fn grant(kind: ResourceKind) -> Option<Self> {
        // SAFETY: FFI call, returns 0 on failure
        let token = unsafe { gossamer_cap_grant(kind as u32) };
        if token == 0 {
            None
        } else {
            Some(Capability { token, kind })
        }
    }

    /// Check if this capability is still valid.
    pub fn check(&self) -> bool {
        // SAFETY: FFI call with valid token
        unsafe { gossamer_cap_check(self.token) == 0 }
    }

    /// Get the resource kind of this capability.
    pub fn kind(&self) -> ResourceKind {
        self.kind
    }

    /// Revoke this capability. Consumes the token.
    pub fn revoke(self) {
        // SAFETY: FFI call, safe to call with any token value
        unsafe { gossamer_cap_revoke(self.token) };
        // self is consumed — token cannot be used again
    }
}

// =============================================================================
// Window configuration
// =============================================================================

/// Configuration for the Gossamer webview window.
pub struct WindowConfig {
    pub title: String,
    pub width: u32,
    pub height: u32,
    pub min_width: Option<u32>,
    pub min_height: Option<u32>,
    pub max_width: Option<u32>,
    pub max_height: Option<u32>,
    pub resizable: bool,
    pub decorations: bool,
    pub fullscreen: bool,
    pub visible: bool,
}

impl Default for WindowConfig {
    fn default() -> Self {
        Self {
            title: "Gossamer App".to_string(),
            width: 800,
            height: 600,
            min_width: None,
            min_height: None,
            max_width: None,
            max_height: None,
            resizable: true,
            decorations: true,
            fullscreen: false,
            visible: true,
        }
    }
}

// =============================================================================
// App — the main entry point
// =============================================================================

/// A Gossamer application.
///
/// Owns a webview window handle and manages IPC command registration.
/// Drop-in replacement for Tauri's application builder pattern.
pub struct App {
    handle: u64,
    channel: u64,
    /// Leaked CommandContext pointers — kept so we can free them on drop.
    /// (In practice, the app runs until process exit, so this is belt-and-suspenders.)
    _contexts: Vec<*mut CommandContext>,
}

impl App {
    /// Create a new Gossamer application with the given title and dimensions.
    ///
    /// This creates a webview window and opens an IPC channel for command dispatch.
    pub fn new(title: &str, width: u32, height: u32) -> Result<Self, Error> {
        Self::with_config(WindowConfig {
            title: title.to_string(),
            width,
            height,
            ..Default::default()
        })
    }

    /// Get the raw Gossamer window handle.
    ///
    /// This is useful for compatibility layers that need to call lower-level
    /// FFI helpers such as event emission or tray/window controls.
    pub fn raw_handle(&self) -> u64 {
        self.handle
    }

    /// Create a new Gossamer application with full window configuration.
    pub fn with_config(config: WindowConfig) -> Result<Self, Error> {
        let title =
            CString::new(config.title.clone()).map_err(|e| Error::InvalidString(e.to_string()))?;

        // SAFETY: FFI call to create a webview window
        let handle = unsafe {
            gossamer_create_ex(
                title.as_ptr(),
                config.width,
                config.height,
                config.min_width.unwrap_or(0),
                config.min_height.unwrap_or(0),
                config.max_width.unwrap_or(0),
                config.max_height.unwrap_or(0),
                config.resizable as u8,
                config.decorations as u8,
                config.fullscreen as u8,
                config.visible as u8,
            )
        };

        if handle == 0 {
            let msg = last_error().unwrap_or_else(|| "unknown".to_string());
            return Err(Error::WebviewCreateFailed(msg));
        }

        // Open IPC channel
        // SAFETY: handle is valid (non-zero check above)
        let channel = unsafe { gossamer_channel_open(handle) };
        if channel == 0 {
            // SAFETY: handle is valid
            unsafe { gossamer_destroy(handle) };
            return Err(Error::ChannelOpenFailed);
        }

        Ok(App {
            handle,
            channel,
            _contexts: Vec::new(),
        })
    }

    /// Register a command handler.
    ///
    /// The handler receives a `serde_json::Value` payload from the frontend
    /// and returns a `Result<serde_json::Value, String>`. This is the Gossamer
    /// equivalent of Tauri's `#[tauri::command]` macro.
    ///
    /// # Example
    ///
    /// ```rust,no_run
    /// # use gossamer_rs::{App, Error};
    /// # fn main() -> Result<(), Error> {
    /// let mut app = App::new("Example", 800, 600)?;
    /// app.command("load_document", |payload| {
    ///     let path = payload["path"].as_str().ok_or("missing path")?;
    ///     let content = std::fs::read_to_string(path).map_err(|e| e.to_string())?;
    ///     Ok(serde_json::json!({ "content": content }))
    /// });
    /// # Ok(())
    /// # }
    /// ```
    pub fn command<F>(&mut self, name: &str, handler: F)
    where
        F: Fn(serde_json::Value) -> Result<serde_json::Value, String> + Send + 'static,
    {
        let ctx = Box::new(CommandContext {
            handler: Box::new(handler),
        });

        // Leak the context to get a stable pointer for the C ABI
        let ctx_ptr = Box::into_raw(ctx);
        self._contexts.push(ctx_ptr);

        let name_c = CString::new(name).expect("command name must not contain null bytes");

        // SAFETY: channel is valid, name_c is null-terminated, ctx_ptr is stable
        unsafe {
            gossamer_channel_bind(
                self.channel,
                name_c.as_ptr(),
                Some(command_trampoline),
                ctx_ptr as *mut c_void,
            );
        }
    }

    /// Register a command handler that runs ASYNCHRONOUSLY on a worker thread.
    ///
    /// Identical to `command()` except the handler is dispatched off the GTK
    /// main thread. Use this for I/O-heavy operations (HTTP, filesystem, DB)
    /// that would otherwise block the UI event loop and freeze the window.
    ///
    /// The handler signature is identical to `command()` — the async dispatch
    /// is handled internally by Gossamer's IPC layer.
    ///
    /// Maximum 256 inflight async calls at any time; additional calls will
    /// be rejected with an error sent back to JavaScript.
    ///
    /// # Example
    ///
    /// ```rust,no_run
    /// # use gossamer_rs::{App, Error};
    /// # fn main() -> Result<(), Error> {
    /// let mut app = App::new("Example", 800, 600)?;
    /// app.command_async("fetch_data", |payload| {
    ///     let url = payload["url"].as_str().ok_or("missing url")?;
    ///     Ok(serde_json::json!({ "requested": url, "status": "queued" }))
    /// });
    /// # Ok(())
    /// # }
    /// ```
    pub fn command_async<F>(&mut self, name: &str, handler: F)
    where
        F: Fn(serde_json::Value) -> Result<serde_json::Value, String> + Send + 'static,
    {
        let ctx = Box::new(CommandContext {
            handler: Box::new(handler),
        });

        // Leak the context to get a stable pointer for the C ABI
        let ctx_ptr = Box::into_raw(ctx);
        self._contexts.push(ctx_ptr);

        let name_c = CString::new(name).expect("command name must not contain null bytes");

        // SAFETY: channel is valid, name_c is null-terminated, ctx_ptr is stable
        unsafe {
            gossamer_channel_bind_async(
                self.channel,
                name_c.as_ptr(),
                Some(command_trampoline),
                ctx_ptr as *mut c_void,
            );
        }
    }

    /// Query the number of currently inflight async IPC calls (0..256).
    /// Useful for diagnostics, back-pressure monitoring, and graceful shutdown.
    pub fn async_inflight_count() -> u32 {
        // SAFETY: read-only FFI call, always safe
        unsafe { gossamer_async_inflight_count() }
    }

    /// Load HTML content into the webview.
    pub fn load_html(&self, html: &str) -> Result<(), Error> {
        let html_c = CString::new(html).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, html_c is null-terminated
        check_result(unsafe { gossamer_load_html(self.handle, html_c.as_ptr()) })
    }

    /// Navigate the webview to a URL.
    pub fn navigate(&self, url: &str) -> Result<(), Error> {
        let url_c = CString::new(url).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, url_c is null-terminated
        check_result(unsafe { gossamer_navigate(self.handle, url_c.as_ptr()) })
    }

    /// Evaluate JavaScript in the webview context.
    pub fn eval(&self, js: &str) -> Result<(), Error> {
        let js_c = CString::new(js).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, js_c is null-terminated
        check_result(unsafe { gossamer_eval(self.handle, js_c.as_ptr()) })
    }

    /// Set the window title.
    pub fn set_title(&self, title: &str) -> Result<(), Error> {
        let title_c = CString::new(title).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, title_c is null-terminated
        check_result(unsafe { gossamer_set_title(self.handle, title_c.as_ptr()) })
    }

    /// Resize the window.
    pub fn resize(&self, width: u32, height: u32) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_resize(self.handle, width, height) })
    }

    /// Show the window.
    pub fn show(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_show(self.handle) })
    }

    /// Hide the window.
    pub fn hide(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_hide(self.handle) })
    }

    /// Minimize the window.
    pub fn minimize(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_minimize(self.handle) })
    }

    /// Maximize the window.
    pub fn maximize(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_maximize(self.handle) })
    }

    /// Restore the window from minimized or maximized state.
    pub fn restore(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_restore(self.handle) })
    }

    /// Request that the window close, while keeping the app handle alive
    /// until normal teardown runs.
    pub fn request_close(&self) -> Result<(), Error> {
        // SAFETY: handle is valid
        check_result(unsafe { gossamer_request_close(self.handle) })
    }

    /// Apply a Content-Security-Policy to the webview.
    ///
    /// Injects a `<meta http-equiv="Content-Security-Policy" content="...">` tag.
    /// Can be called at any time; replaces any previously set CSP.
    ///
    /// # Example
    ///
    /// ```rust,no_run
    /// # use gossamer_rs::{App, Error};
    /// # fn main() -> Result<(), Error> {
    /// let app = App::new("Example", 800, 600)?;
    /// app.set_csp("default-src 'self'; script-src 'self' 'unsafe-inline'")?;
    /// # Ok(())
    /// # }
    /// ```
    pub fn set_csp(&self, csp: &str) -> Result<(), Error> {
        let csp_c = CString::new(csp).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, csp_c is null-terminated
        check_result(unsafe { gossamer_set_csp(self.handle, csp_c.as_ptr()) })
    }

    /// Push an event from the backend to the frontend webview.
    ///
    /// The event is delivered asynchronously via the GTK main thread.
    /// Frontend code registers listeners with `window.__gossamer_on(name, cb)`
    /// or `window.gossamer.on(name, cb)`.
    ///
    /// Thread safety: safe to call from any thread. Uses g_idle_add internally.
    ///
    /// # Example
    ///
    /// ```rust,no_run
    /// # use gossamer_rs::{App, Error};
    /// # fn main() -> Result<(), Error> {
    /// let app = App::new("Example", 800, 600)?;
    /// app.emit("file_changed", r#"{"path":"/tmp/foo.txt"}"#)?;
    /// # Ok(())
    /// # }
    /// ```
    pub fn emit(&self, event_name: &str, payload_json: &str) -> Result<(), Error> {
        let event_c =
            CString::new(event_name).map_err(|e| Error::InvalidString(e.to_string()))?;
        let payload_c =
            CString::new(payload_json).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: handle is valid, both strings are null-terminated
        check_result(unsafe {
            gossamer_emit(self.handle, event_c.as_ptr(), payload_c.as_ptr())
        })
    }

    /// Send a desktop notification.
    pub fn notify(title: &str, body: &str) -> Result<(), Error> {
        let title_c = CString::new(title).map_err(|e| Error::InvalidString(e.to_string()))?;
        let body_c = CString::new(body).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated strings
        check_result(unsafe { gossamer_notify(title_c.as_ptr(), body_c.as_ptr()) })
    }

    /// Create a system tray icon.
    pub fn tray_create(&self, tooltip: &str) -> Result<u64, Error> {
        let tooltip_c = CString::new(tooltip).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated string
        let handle = unsafe { gossamer_tray_create(tooltip_c.as_ptr()) };
        if handle == 0 {
            Err(Error::OperationFailed {
                code: 1,
                message: "Failed to create system tray icon".to_string(),
            })
        } else {
            Ok(handle)
        }
    }

    /// Add a menu item to the system tray context menu.
    pub fn tray_add_menu_item(&self, tray: u64, label: &str) -> Result<(), Error> {
        let label_c = CString::new(label).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated string. We use a dummy ID for now as
        // the callback system is being refactored.
        check_result(unsafe { gossamer_tray_add_item(tray, label_c.as_ptr(), 0) })
    }

    /// Add a separator to the system tray context menu.
    pub fn tray_add_separator(&self, tray: u64) -> Result<(), Error> {
        // SAFETY: valid tray handle
        check_result(unsafe { gossamer_tray_add_separator(tray) })
    }

    /// Set the system tray icon by icon name.
    pub fn tray_set_icon(&self, tray: u64, icon_name: &str) -> Result<(), Error> {
        let icon_name_c = CString::new(icon_name).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated string
        check_result(unsafe { gossamer_tray_set_icon(tray, icon_name_c.as_ptr()) })
    }

    /// Set the system tray icon from a file path.
    pub fn tray_set_icon_from_file(&self, tray: u64, path: &str) -> Result<(), Error> {
        let path_c = CString::new(path).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated string
        check_result(unsafe { gossamer_tray_set_icon_from_file(tray, path_c.as_ptr()) })
    }

    /// Set the system tray tooltip.
    pub fn tray_set_tooltip(&self, tray: u64, tooltip: &str) -> Result<(), Error> {
        let tooltip_c = CString::new(tooltip).map_err(|e| Error::InvalidString(e.to_string()))?;
        // SAFETY: valid null-terminated string
        check_result(unsafe { gossamer_tray_set_tooltip(tray, tooltip_c.as_ptr()) })
    }

    /// Show or hide the system tray icon.
    pub fn tray_set_visible(&self, tray: u64, visible: bool) -> Result<(), Error> {
        // SAFETY: valid tray handle
        check_result(unsafe { gossamer_tray_set_visible(tray, visible as u32) })
    }

    /// Attach the main window to the system tray icon.
    pub fn tray_set_window(&self, tray: u64) -> Result<(), Error> {
        // SAFETY: valid tray handle and window handle
        check_result(unsafe { gossamer_tray_set_window(tray, self.handle) })
    }

    /// Destroy the system tray icon.
    pub fn tray_destroy(&self, tray: u64) -> Result<(), Error> {
        // SAFETY: valid tray handle
        unsafe { gossamer_tray_destroy(tray) };
        Ok(())
    }

    /// Get the Gossamer library version string.
    pub fn version() -> String {
        // SAFETY: FFI call returns a static string
        let ptr = unsafe { gossamer_version() };
        if ptr.is_null() {
            return "unknown".to_string();
        }
        // SAFETY: guaranteed null-terminated by Zig
        unsafe { CStr::from_ptr(ptr) }
            .to_string_lossy()
            .into_owned()
    }

    /// Run the webview event loop. Blocks until the window is closed.
    /// Consumes the App — the window is destroyed after this returns.
    pub fn run(self) {
        // SAFETY: handle is valid, event loop takes ownership
        unsafe { gossamer_run(self.handle) };
        // Note: self is consumed. Drop will NOT double-free because
        // gossamer_run already cleans up the handle internally.
        // We use mem::forget to prevent the Drop impl from calling destroy.
        std::mem::forget(self);
    }
}

impl Drop for App {
    fn drop(&mut self) {
        // Close IPC channel if still open
        if self.channel != 0 {
            // SAFETY: channel handle is valid or 0 (no-op)
            unsafe { gossamer_channel_close(self.channel) };
        }
        // Destroy webview if not consumed by run()
        if self.handle != 0 {
            // SAFETY: handle is valid
            unsafe { gossamer_destroy(self.handle) };
        }
        // Free leaked command contexts
        for ctx_ptr in &self._contexts {
            // SAFETY: these were created by Box::into_raw in command()
            unsafe { drop(Box::from_raw(*ctx_ptr)) };
        }
    }
}

// =============================================================================
// Public API re-exports
// =============================================================================

/// Get the Gossamer library version.
pub fn version() -> String {
    App::version()
}
