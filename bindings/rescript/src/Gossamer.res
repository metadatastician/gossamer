// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

/// Gossamer ReScript Bindings — Drop-in replacement for @tauri-apps/api.
///
/// Provides typed bindings to the Gossamer webview shell's IPC bridge.
/// The JavaScript bridge is injected by libgossamer when a channel is opened,
/// exposing `window.__gossamer_invoke(name, payload)` and the
/// `window.gossamer` proxy object.
///
/// Usage:
///   open Gossamer
///   let result = await Gossamer.invoke("my_command", {"key": "value"})

// ---------------------------------------------------------------------------
// Runtime detection
// ---------------------------------------------------------------------------

/// Check if the Gossamer runtime is available in this webview.
%%raw(`
function isGossamerRuntime() {
  return typeof window !== 'undefined'
    && typeof window.__gossamer_invoke === 'function';
}
`)
@val external isAvailable: unit => bool = "isGossamerRuntime"

// ---------------------------------------------------------------------------
// Core IPC — invoke
// ---------------------------------------------------------------------------

/// Raw invoke: calls window.__gossamer_invoke(name, payload).
/// Returns a Promise that resolves with the handler's response.
%%raw(`
function gossamerInvokeImpl(cmd, args) {
  if (typeof window === 'undefined' || typeof window.__gossamer_invoke !== 'function') {
    return Promise.reject(new Error('Gossamer runtime not available — "' + cmd + '" requires the desktop app'));
  }
  return window.__gossamer_invoke(cmd, args);
}
`)
@val external invoke: (string, 'a) => promise<'b> = "gossamerInvokeImpl"

// ---------------------------------------------------------------------------
// Version and build info
// ---------------------------------------------------------------------------

/// Get the Gossamer library version string.
let version = (): promise<string> => invoke("__gossamer_version", ())

/// Get the Gossamer build info string.
let buildInfo = (): promise<string> => invoke("__gossamer_build_info", ())

/// Get the number of currently inflight async IPC calls (0..256).
/// Useful for diagnostics, back-pressure monitoring, and graceful shutdown.
let asyncInflightCount = (): promise<int> => invoke("__gossamer_async_inflight_count", ())

// ---------------------------------------------------------------------------
// Dialog module — file open/save dialogs
// ---------------------------------------------------------------------------

module Dialog = {
  /// File filter for dialog boxes.
  type filter = {
    name: string,
    extensions: array<string>,
  }

  /// Options for an open-file dialog.
  type openOptions = {
    title?: string,
    filters?: array<filter>,
    multiple?: bool,
    directory?: bool,
    defaultPath?: string,
  }

  /// Options for a save-file dialog.
  type saveOptions = {
    title?: string,
    filters?: array<filter>,
    defaultPath?: string,
  }

  /// Open a file picker dialog. Returns the selected path(s) or null.
  let open = (opts: openOptions): promise<Nullable.t<JSON.t>> =>
    invoke("__gossamer_dialog_open", opts)

  /// Open a save dialog. Returns the selected path or null.
  let save = (opts: saveOptions): promise<Nullable.t<JSON.t>> =>
    invoke("__gossamer_dialog_save", opts)

  /// Open a directory picker dialog. Returns the selected directory or null.
  let openDirectory = (opts: openOptions): promise<Nullable.t<string>> =>
    invoke("__gossamer_dialog_open", {...opts, directory: ?Some(true)})
}

// ---------------------------------------------------------------------------
// Filesystem module — read/write files
// ---------------------------------------------------------------------------

module Fs = {
  /// Read a text file from the local filesystem.
  let readTextFile = (path: string): promise<string> =>
    invoke("__gossamer_fs_read_text", {"path": path})

  /// Write a text file to the local filesystem.
  let writeTextFile = (path: string, contents: string): promise<unit> =>
    invoke("__gossamer_fs_write_text", {"path": path, "contents": contents})

  /// Check if a file exists.
  let exists = (path: string): promise<bool> =>
    invoke("__gossamer_fs_exists", {"path": path})

  /// Read a binary file as a Uint8Array.
  let readBinaryFile = (path: string): promise<Js.TypedArray2.Uint8Array.t> =>
    invoke("__gossamer_fs_read_binary", {"path": path})
}

// ---------------------------------------------------------------------------
// Shell module — spawn commands
// ---------------------------------------------------------------------------

module Shell = {
  /// Result of a shell command execution.
  type commandOutput = {
    stdout: string,
    stderr: string,
    code: int,
  }

  /// Execute a shell command and return its output.
  let execute = (program: string, args: array<string>): promise<commandOutput> =>
    invoke("__gossamer_shell_execute", {"program": program, "args": args})

  /// Open a path or URL with the system's default handler.
  let openUrl = (url: string): promise<unit> =>
    invoke("__gossamer_shell_open", {"url": url})
}

// ---------------------------------------------------------------------------
// Capability module — linear capability tokens
// ---------------------------------------------------------------------------

module Capability = {
  /// Resource kinds matching Gossamer.ABI.Types.ResourceKind.
  type resourceKind =
    | @as(0) FileSystem
    | @as(1) Network
    | @as(2) Shell
    | @as(3) Clipboard
    | @as(4) Notification
    | @as(5) Tray

  /// An opaque capability token. Must be revoked when no longer needed.
  type token = {id: float}

  /// Request a capability token for the given resource kind.
  let grant = (kind: resourceKind): promise<token> =>
    invoke("__gossamer_cap_grant", {"kind": kind})

  /// Check if a capability token is still valid.
  let check = (t: token): promise<bool> =>
    invoke("__gossamer_cap_check", {"token": t.id})

  /// Revoke a capability token. After this, the token is consumed.
  let revoke = (t: token): promise<unit> =>
    invoke("__gossamer_cap_revoke", {"token": t.id})
}

// ---------------------------------------------------------------------------
// Window module — webview window management
// ---------------------------------------------------------------------------

module Window = {
  /// Set the window title.
  let setTitle = (title: string): promise<unit> =>
    invoke("__gossamer_set_title", {"title": title})

  /// Resize the window.
  let resize = (width: int, height: int): promise<unit> =>
    invoke("__gossamer_resize", {"width": width, "height": height})

  /// Navigate the webview to a URL.
  let navigate = (url: string): promise<unit> =>
    invoke("__gossamer_navigate", {"url": url})

  /// Evaluate JavaScript in the webview context.
  let eval = (js: string): promise<unit> =>
    invoke("__gossamer_eval", {"js": js})
}

// ---------------------------------------------------------------------------
// Event module — streaming IPC (backend → frontend push)
// ---------------------------------------------------------------------------

module Event = {
  /// Register a listener for backend-pushed events.
  /// Returns an unsubscribe function that removes the listener when called.
  ///
  /// Usage:
  ///   let unsub = Gossamer.Event.on("file_changed", data => {
  ///     Js.log2("Changed:", data)
  ///   })
  ///   // Later: unsub() to stop listening
  %%raw(`
  function gossamerOnImpl(eventName, callback) {
    if (typeof window !== 'undefined' && typeof window.__gossamer_on === 'function') {
      return window.__gossamer_on(eventName, callback);
    }
    return function() {};
  }
  `)
  @val external on: (string, 'a => unit) => (unit => unit) = "gossamerOnImpl"
}

// ---------------------------------------------------------------------------
// Security module — CSP enforcement
// ---------------------------------------------------------------------------

module Security = {
  /// Apply a Content-Security-Policy to the webview via IPC.
  /// The CSP string should be a valid Content-Security-Policy directive.
  let setCsp = (csp: string): promise<unit> =>
    invoke("__gossamer_set_csp", {"csp": csp})
}

// ---------------------------------------------------------------------------
// Tray module — system tray management
// ---------------------------------------------------------------------------

module Tray = {
  /// Create a system tray icon with tooltip.
  let create = (tooltip: string): promise<float> =>
    invoke("__gossamer_tray_create", {"tooltip": tooltip})

  /// Add a menu item to the tray.
  let addItem = (label: string, itemId: int): promise<unit> =>
    invoke("__gossamer_tray_add_item", {"label": label, "itemId": itemId})

  /// Set the tray icon by theme name.
  let setIcon = (iconName: string): promise<unit> =>
    invoke("__gossamer_tray_set_icon", {"iconName": iconName})

  /// Show a desktop notification.
  let notify = (title: string, body: string): promise<unit> =>
    invoke("__gossamer_notify", {"title": title, "body": body})
}
