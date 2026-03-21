-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Foreign Function Interface Declarations for Gossamer
|||
||| Declares all C-compatible functions implemented in the Zig FFI layer.
||| Each FFI function has:
||| 1. A primitive declaration (prim__*) — raw C ABI call
||| 2. A safe wrapper — type-checked, error-handled, returns Either/Maybe
|||
||| The Zig implementations live in src/interface/ffi/zig/src/.
||| Function names follow the pattern: gossamer_{operation}
|||
||| For linear resource operations, the safe wrappers encode borrowing vs.
||| consuming semantics:
||| - Borrowing: accepts handle, returns (handle, result)
||| - Consuming: accepts handle, returns result (handle is gone)

module Gossamer.ABI.Foreign

import Gossamer.ABI.Types
import Gossamer.ABI.Layout

%default total

--------------------------------------------------------------------------------
-- Webview Lifecycle
--------------------------------------------------------------------------------

||| Create a new webview window.
||| Returns a pointer to the webview handle, or 0 on failure.
||| MUST be called from the main thread.
export
%foreign "C:gossamer_create, libgossamer"
prim__create : String -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> PrimIO Bits64

||| Safe wrapper for webview creation.
|||
||| Requires a MainThreadProof witness (provided by the framework entry point).
||| Returns Either an error Result or a WebviewHandle.
|||
||| The returned handle is LINEAR — it must be consumed by exactly one of:
||| - `run` (runs event loop, then destroys)
||| - `destroy` (destroys without running)
export
create : WindowConfig -> {auto prf : MainThreadProof} -> IO (Either Result WebviewHandle)
create cfg = do
  let resizable_flag : Bits32 = if cfg.resizable then 1 else 0
  let decorations_flag : Bits32 = if cfg.decorations then 1 else 0
  let fullscreen_flag : Bits32 = if cfg.fullscreen then 1 else 0
  ptr <- primIO (prim__create cfg.title cfg.width cfg.height
                              resizable_flag decorations_flag fullscreen_flag)
  case createWebview ptr of
    Nothing => pure (Left WebviewUnavailable)
    Just wv => pure (Right wv)

||| Load HTML content into the webview.
||| BORROWING operation: the handle is returned alongside the result.
export
%foreign "C:gossamer_load_html, libgossamer"
prim__loadHTML : Bits64 -> String -> PrimIO Bits32

||| Safe wrapper for loading HTML.
||| Returns the handle back (borrowing) plus the operation result.
export
loadHTML : (1 _ : WebviewHandle) -> (html : String)
         -> IO (WebviewHandle, Either Result ())
loadHTML wv html = do
  code <- primIO (prim__loadHTML (webviewPtr wv) html)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Navigate the webview to a URL.
||| BORROWING operation.
export
%foreign "C:gossamer_navigate, libgossamer"
prim__navigate : Bits64 -> String -> PrimIO Bits32

||| Safe wrapper for URL navigation.
export
navigate : (1 _ : WebviewHandle) -> (url : String)
         -> IO (WebviewHandle, Either Result ())
navigate wv url = do
  code <- primIO (prim__navigate (webviewPtr wv) url)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Evaluate JavaScript in the webview context.
||| BORROWING operation.
export
%foreign "C:gossamer_eval, libgossamer"
prim__eval : Bits64 -> String -> PrimIO Bits32

||| Safe wrapper for JS evaluation.
export
eval : (1 _ : WebviewHandle) -> (js : String)
     -> IO (WebviewHandle, Either Result ())
eval wv js = do
  code <- primIO (prim__eval (webviewPtr wv) js)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Set the window title.
||| BORROWING operation.
export
%foreign "C:gossamer_set_title, libgossamer"
prim__setTitle : Bits64 -> String -> PrimIO Bits32

||| Safe wrapper for setting the window title.
export
setTitle : (1 _ : WebviewHandle) -> (title : String)
         -> IO (WebviewHandle, Either Result ())
setTitle wv title = do
  code <- primIO (prim__setTitle (webviewPtr wv) title)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Resize the webview window.
||| BORROWING operation.
export
%foreign "C:gossamer_resize, libgossamer"
prim__resize : Bits64 -> Bits32 -> Bits32 -> PrimIO Bits32

||| Safe wrapper for window resizing.
export
resize : (1 _ : WebviewHandle) -> (width : Bits32) -> (height : Bits32)
       -> IO (WebviewHandle, Either Result ())
resize wv w h = do
  code <- primIO (prim__resize (webviewPtr wv) w h)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Run the webview event loop. Blocks until the window is closed.
||| CONSUMING operation: the handle is destroyed after this returns.
||| The caller loses ownership — using the handle after this is a type error.
export
%foreign "C:gossamer_run, libgossamer"
prim__run : Bits64 -> PrimIO ()

||| Safe wrapper for running the event loop.
||| Consumes the webview handle — it cannot be used after this call.
export
run : (1 _ : WebviewHandle) -> IO ()
run wv = primIO (prim__run (webviewPtr wv))

||| Destroy the webview without running the event loop.
||| CONSUMING operation: alternative to `run` for teardown.
export
%foreign "C:gossamer_destroy, libgossamer"
prim__destroy : Bits64 -> PrimIO ()

||| Safe wrapper for webview destruction.
||| Consumes the handle — it cannot be used after this call.
export
destroy : (1 _ : WebviewHandle) -> IO ()
destroy wv = primIO (prim__destroy (webviewPtr wv))

--------------------------------------------------------------------------------
-- IPC Channel Operations
--------------------------------------------------------------------------------

||| Open a typed IPC channel on the webview.
||| Returns a channel handle, or 0 on failure.
export
%foreign "C:gossamer_channel_open, libgossamer"
prim__channelOpen : Bits64 -> PrimIO Bits64

||| Safe wrapper for opening an IPC channel.
||| The channel is LINEAR — must be closed exactly once.
export
channelOpen : WebviewHandle -> IO (Either Result (Channel req resp))
channelOpen wv = do
  ptr <- primIO (prim__channelOpen (webviewPtr wv))
  case createChannel {req} {resp} ptr of
    Nothing => pure (Left Error)
    Just ch => pure (Right ch)

||| Bind a named command handler to the IPC channel.
||| BORROWING operation on the channel.
export
%foreign "C:gossamer_channel_bind, libgossamer"
prim__channelBind : Bits64 -> String -> AnyPtr -> PrimIO Bits32

||| Close the IPC channel.
||| CONSUMING operation — the channel handle is destroyed.
export
%foreign "C:gossamer_channel_close, libgossamer"
prim__channelClose : Bits64 -> PrimIO ()

||| Safe wrapper for closing an IPC channel.
export
channelClose : (1 _ : Channel req resp) -> IO ()
channelClose ch = primIO (prim__channelClose (channelPtr ch))

--------------------------------------------------------------------------------
-- Capability Operations
--------------------------------------------------------------------------------

||| Grant a capability token. Framework-internal only.
||| Returns a token ID, or 0 on failure.
export
%foreign "C:gossamer_cap_grant, libgossamer"
prim__capGrant : Bits32 -> PrimIO Bits64

||| Check a capability before a gated operation.
export
%foreign "C:gossamer_cap_check, libgossamer"
prim__capCheck : Bits64 -> PrimIO Bits32

||| Revoke a capability token.
||| CONSUMING operation — the token is destroyed.
export
%foreign "C:gossamer_cap_revoke, libgossamer"
prim__capRevoke : Bits64 -> PrimIO ()

||| Safe wrapper for revoking a capability.
export
capRevoke : (1 _ : Cap resource) -> IO ()
capRevoke (MkCap token) = primIO (prim__capRevoke token)

--------------------------------------------------------------------------------
-- System Integration
--------------------------------------------------------------------------------

||| Create a system tray icon.
||| Returns a tray handle, or 0 on failure.
export
%foreign "C:gossamer_tray_create, libgossamer"
prim__trayCreate : String -> PrimIO Bits64

||| Show a desktop notification.
export
%foreign "C:gossamer_notify, libgossamer"
prim__notify : String -> String -> PrimIO Bits32

||| Show a file open dialog.
||| Returns the selected file path, or null if cancelled.
export
%foreign "C:gossamer_dialog_open, libgossamer"
prim__dialogOpen : String -> String -> PrimIO Bits64

||| Show a file save dialog.
export
%foreign "C:gossamer_dialog_save, libgossamer"
prim__dialogSave : String -> String -> PrimIO Bits64

--------------------------------------------------------------------------------
-- Error Handling
--------------------------------------------------------------------------------

||| Get the last error message from the Zig FFI layer.
export
%foreign "C:gossamer_last_error, libgossamer"
prim__lastError : PrimIO Bits64

||| Convert C string pointer to Idris String.
export
%foreign "support:idris2_getString, libidris2_support"
prim__getString : Bits64 -> String

||| Retrieve last error as a string.
export
lastError : IO (Maybe String)
lastError = do
  ptr <- primIO prim__lastError
  if ptr == 0
    then pure Nothing
    else pure (Just (prim__getString ptr))

--------------------------------------------------------------------------------
-- Version Information
--------------------------------------------------------------------------------

||| Get library version string.
export
%foreign "C:gossamer_version, libgossamer"
prim__version : PrimIO Bits64

||| Get version as Idris String.
export
version : IO String
version = do
  ptr <- primIO prim__version
  pure (prim__getString ptr)
