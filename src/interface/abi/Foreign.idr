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
import Data.List
import Data.List1
import Data.String

%default total

-- NOTE ON LINEARITY:
-- The safe wrappers document borrowing/consuming semantics in doc comments.
-- Idris2's IO monad does not yet support linear bindings, so the quantity
-- annotations are omitted from function signatures. The type-level intent
-- is preserved in documentation; runtime enforcement is in the Zig FFI layer.

--------------------------------------------------------------------------------
-- String Utilities
--------------------------------------------------------------------------------

||| Convert C string pointer (as Bits64) to Idris String.
||| At the C ABI level, Bits64 and char* have the same representation
||| on 64-bit platforms. This FFI declaration bridges the gap.
export
%foreign "C:gossamer_ptr_to_string, libgossamer"
ptrToString : Bits64 -> String

||| Split a string on newline characters. Helper for dialogOpenMultiple.
splitOnNewline : String -> List String
splitOnNewline s =
  filter (/= "") (forget $ Data.String.split (== '\n') s)

--------------------------------------------------------------------------------
-- Webview Lifecycle
--------------------------------------------------------------------------------

||| Legacy create for backwards compatibility.
||| Returns a pointer to the webview handle, or 0 on failure.
||| MUST be called from the main thread.
export
%foreign "C:gossamer_create, libgossamer"
prim__create : String -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> PrimIO Bits64

||| Create a new webview window with launch-time size constraints and visibility.
||| min/max values use 0 as the "unset" sentinel.
export
%foreign "C:gossamer_create_ex, libgossamer"
prim__createEx : String -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> PrimIO Bits64

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
  let visible_flag : Bits32 = if cfg.visible then 1 else 0
  ptr <- primIO (prim__createEx cfg.title cfg.width cfg.height
                                cfg.minWidth cfg.minHeight cfg.maxWidth cfg.maxHeight
                                resizable_flag decorations_flag fullscreen_flag visible_flag)
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
loadHTML : WebviewHandle -> (html : String)
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
navigate : WebviewHandle -> (url : String)
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
eval : WebviewHandle -> (js : String)
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
setTitle : WebviewHandle -> (title : String)
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
resize : WebviewHandle -> (width : Bits32) -> (height : Bits32)
       -> IO (WebviewHandle, Either Result ())
resize wv w h = do
  code <- primIO (prim__resize (webviewPtr wv) w h)
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Show the webview window.
||| BORROWING operation.
export
%foreign "C:gossamer_show, libgossamer"
prim__show : Bits64 -> PrimIO Bits32

||| Safe wrapper for showing the window.
export
show : WebviewHandle -> IO (WebviewHandle, Either Result ())
show wv = do
  code <- primIO (prim__show (webviewPtr wv))
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Hide the webview window.
||| BORROWING operation.
export
%foreign "C:gossamer_hide, libgossamer"
prim__hide : Bits64 -> PrimIO Bits32

||| Safe wrapper for hiding the window.
export
hide : WebviewHandle -> IO (WebviewHandle, Either Result ())
hide wv = do
  code <- primIO (prim__hide (webviewPtr wv))
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Minimize the webview window.
||| BORROWING operation.
export
%foreign "C:gossamer_minimize, libgossamer"
prim__minimize : Bits64 -> PrimIO Bits32

||| Safe wrapper for minimizing the window.
export
minimize : WebviewHandle -> IO (WebviewHandle, Either Result ())
minimize wv = do
  code <- primIO (prim__minimize (webviewPtr wv))
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Maximize the webview window.
||| BORROWING operation.
export
%foreign "C:gossamer_maximize, libgossamer"
prim__maximize : Bits64 -> PrimIO Bits32

||| Safe wrapper for maximizing the window.
export
maximize : WebviewHandle -> IO (WebviewHandle, Either Result ())
maximize wv = do
  code <- primIO (prim__maximize (webviewPtr wv))
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Restore the webview window from minimized or maximized state.
||| BORROWING operation.
export
%foreign "C:gossamer_restore, libgossamer"
prim__restore : Bits64 -> PrimIO Bits32

||| Safe wrapper for restoring the window.
export
restore : WebviewHandle -> IO (WebviewHandle, Either Result ())
restore wv = do
  code <- primIO (prim__restore (webviewPtr wv))
  case resultFromInt code of
    Just Ok => pure (wv, Right ())
    Just err => pure (wv, Left err)
    Nothing => pure (wv, Left Error)

||| Request that the webview window close.
||| BORROWING operation: returns the handle for later cleanup, but the
||| window becomes logically closed and further borrowing operations fail.
export
%foreign "C:gossamer_request_close, libgossamer"
prim__requestClose : Bits64 -> PrimIO Bits32

||| Safe wrapper for a close request.
export
requestClose : WebviewHandle -> IO (WebviewHandle, Either Result ())
requestClose wv = do
  code <- primIO (prim__requestClose (webviewPtr wv))
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
run : WebviewHandle -> IO ()
run wv = primIO (prim__run (webviewPtr wv))

||| Destroy the webview without running the event loop.
||| CONSUMING operation: alternative to `run` for teardown.
export
%foreign "C:gossamer_destroy, libgossamer"
prim__destroy : Bits64 -> PrimIO ()

||| Safe wrapper for webview destruction.
||| Consumes the handle — it cannot be used after this call.
export
destroy : WebviewHandle -> IO ()
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
||| The AnyPtr parameters are: callback function pointer, user data pointer.
||| user_data is passed through to the callback on each invocation,
||| enabling language bindings (Rust, etc.) to pass closure context.
export
%foreign "C:gossamer_channel_bind, libgossamer"
prim__channelBind : Bits64 -> String -> AnyPtr -> AnyPtr -> PrimIO Bits32

||| Close the IPC channel.
||| CONSUMING operation — the channel handle is destroyed.
export
%foreign "C:gossamer_channel_close, libgossamer"
prim__channelClose : Bits64 -> PrimIO ()

||| Safe wrapper for closing an IPC channel.
export
channelClose : (Channel req resp) -> IO ()
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

||| Query the resource kind associated with a capability token.
||| Returns the resource kind ordinal, or 0xFFFFFFFF if the token is invalid.
export
%foreign "C:gossamer_cap_resource_kind, libgossamer"
prim__capResourceKind : Bits64 -> PrimIO Bits32

||| Safe wrapper for querying a capability's resource kind.
||| BORROWING operation — the token is returned alongside the result.
export
capResourceKind : Cap resource -> IO (Cap resource, Bits32)
capResourceKind cap@(MkCap token) = do
  kind <- primIO (prim__capResourceKind token)
  pure (cap, kind)

||| Revoke a capability token.
||| CONSUMING operation — the token is destroyed.
export
%foreign "C:gossamer_cap_revoke, libgossamer"
prim__capRevoke : Bits64 -> PrimIO ()

||| Safe wrapper for revoking a capability.
||| CONSUMING operation — the token cannot be used after this call.
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

||| Show a file open dialog (single file selection).
||| Returns a pointer to the selected file path (as Bits64), or 0 if cancelled.
||| The caller must free the returned path via prim__dialogFreePath.
export
%foreign "C:gossamer_dialog_open, libgossamer"
prim__dialogOpen : String -> String -> PrimIO Bits64

||| Show a file save dialog.
||| Returns a pointer to the selected file path (as Bits64), or 0 if cancelled.
||| The caller must free the returned path via prim__dialogFreePath.
export
%foreign "C:gossamer_dialog_save, libgossamer"
prim__dialogSave : String -> String -> PrimIO Bits64

||| Show a directory picker dialog.
||| Returns a pointer to the selected directory path (as Bits64), or 0 if cancelled.
||| The caller must free the returned path via prim__dialogFreePath.
export
%foreign "C:gossamer_dialog_open_directory, libgossamer"
prim__dialogOpenDirectory : String -> PrimIO Bits64

||| Show a file open dialog with multiple selection.
||| Returns a pointer to a newline-separated list of selected file paths
||| (as Bits64), or 0 if cancelled. Caller frees via prim__dialogFreePath.
export
%foreign "C:gossamer_dialog_open_multiple, libgossamer"
prim__dialogOpenMultiple : String -> String -> PrimIO Bits64

||| Free a path string returned by any dialog function.
||| Safe to call with 0.
export
%foreign "C:gossamer_dialog_free_path, libgossamer"
prim__dialogFreePath : Bits64 -> PrimIO ()

--------------------------------------------------------------------------------
-- Dialog Safe Wrappers
--------------------------------------------------------------------------------

||| Show a file open dialog and return the selected path.
||| Returns Nothing if the user cancelled.
export
dialogOpen : (title : String) -> (filters : String) -> IO (Maybe String)
dialogOpen title filters = do
  ptr <- primIO (prim__dialogOpen title filters)
  if ptr == 0
    then pure Nothing
    else do
      let path = ptrToString ptr
      primIO (prim__dialogFreePath ptr)
      pure (Just path)

||| Show a file save dialog and return the selected path.
||| Returns Nothing if the user cancelled.
export
dialogSave : (title : String) -> (filters : String) -> IO (Maybe String)
dialogSave title filters = do
  ptr <- primIO (prim__dialogSave title filters)
  if ptr == 0
    then pure Nothing
    else do
      let path = ptrToString ptr
      primIO (prim__dialogFreePath ptr)
      pure (Just path)

||| Show a directory picker dialog and return the selected directory path.
||| Returns Nothing if the user cancelled.
export
dialogOpenDirectory : (title : String) -> IO (Maybe String)
dialogOpenDirectory title = do
  ptr <- primIO (prim__dialogOpenDirectory title)
  if ptr == 0
    then pure Nothing
    else do
      let path = ptrToString ptr
      primIO (prim__dialogFreePath ptr)
      pure (Just path)

||| Show a multi-file open dialog and return selected paths.
||| Returns an empty list if the user cancelled.
||| Paths are returned as a newline-separated string split into a List.
export
dialogOpenMultiple : (title : String) -> (filters : String) -> IO (List String)
dialogOpenMultiple title filters = do
  ptr <- primIO (prim__dialogOpenMultiple title filters)
  if ptr == 0
    then pure []
    else do
      let paths = ptrToString ptr
      primIO (prim__dialogFreePath ptr)
      pure (splitOnNewline paths)


--------------------------------------------------------------------------------
-- Filesystem Operations (capability-gated)
--------------------------------------------------------------------------------

||| Read a text file from the local filesystem.
||| Requires a valid FileSystem capability token.
||| Returns a pointer to the file contents (caller frees), or 0 on error.
export
%foreign "C:gossamer_fs_read_text, libgossamer"
prim__fsReadText : String -> Bits64 -> PrimIO Bits64

||| Safe wrapper for reading a text file.
||| Returns Nothing on error or capability denial.
export
fsReadText : (path : String) -> (cap : Cap (FileSystem scope))
           -> IO (Cap (FileSystem scope), Maybe String)
fsReadText path cap@(MkCap token) = do
  ptr <- primIO (prim__fsReadText path token)
  if ptr == 0
    then pure (cap, Nothing)
    else do
      let contents = ptrToString ptr
      pure (cap, Just contents)

||| Write text to a file on the local filesystem.
||| Requires a valid FileSystem capability token.
||| Returns a Result code (0=ok, 10=capability_denied).
export
%foreign "C:gossamer_fs_write_text, libgossamer"
prim__fsWriteText : String -> String -> Bits64 -> PrimIO Bits32

||| Safe wrapper for writing a text file.
||| Returns an Either with the result.
export
fsWriteText : (path : String) -> (contents : String)
            -> (cap : Cap (FileSystem scope))
            -> IO (Cap (FileSystem scope), Either Result ())
fsWriteText path contents cap@(MkCap token) = do
  code <- primIO (prim__fsWriteText path contents token)
  case resultFromInt code of
    Just Ok => pure (cap, Right ())
    Just err => pure (cap, Left err)
    Nothing => pure (cap, Left Error)

||| Check if a file or directory exists.
||| Returns 1 (exists), 0 (not found), or 0xFFFFFFFF on error.
export
%foreign "C:gossamer_fs_exists, libgossamer"
prim__fsExists : String -> Bits64 -> PrimIO Bits32

||| Safe wrapper for file existence check.
export
fsExists : (path : String) -> (cap : Cap (FileSystem scope))
         -> IO (Cap (FileSystem scope), Bool)
fsExists path cap@(MkCap token) = do
  result <- primIO (prim__fsExists path token)
  pure (cap, result == 1)

||| List directory contents as a JSON array.
||| Returns a pointer to a JSON string, or 0 on error.
export
%foreign "C:gossamer_fs_list_dir, libgossamer"
prim__fsListDir : String -> Bits64 -> PrimIO Bits64

||| Delete a file.
||| Requires a valid FileSystem capability token.
export
%foreign "C:gossamer_fs_remove, libgossamer"
prim__fsRemove : String -> Bits64 -> PrimIO Bits32

--------------------------------------------------------------------------------
-- Platform Detection Query API
--------------------------------------------------------------------------------

||| Get the platform identifier string at runtime.
||| Returns one of: "linux", "macos", "windows", "freebsd", "openbsd",
||| "netbsd", "ios", or "unknown".
export
%foreign "C:gossamer_platform, libgossamer"
prim__platform : PrimIO Bits64

||| Safe wrapper for platform detection.
export
platform : IO String
platform = do
  ptr <- primIO prim__platform
  pure (ptrToString ptr)

||| Get the CPU architecture string at runtime.
||| Returns one of: "x86_64", "aarch64", "riscv64", "wasm32", or "unknown".
export
%foreign "C:gossamer_arch, libgossamer"
prim__arch : PrimIO Bits64

||| Safe wrapper for architecture detection.
export
arch : IO String
arch = do
  ptr <- primIO prim__arch
  pure (ptrToString ptr)

||| Get the webview engine name for the current platform.
||| Returns one of: "webkitgtk", "wkwebview", "webview2", or "none".
export
%foreign "C:gossamer_webview_engine, libgossamer"
prim__webviewEngine : PrimIO Bits64

||| Safe wrapper for webview engine detection.
export
webviewEngine : IO String
webviewEngine = do
  ptr <- primIO prim__webviewEngine
  pure (ptrToString ptr)

||| Check whether the current platform is a desktop platform.
||| Returns True for Linux, macOS, Windows, BSD; False for mobile/other.
export
%foreign "C:gossamer_is_desktop, libgossamer"
prim__isDesktop : PrimIO Bits32

||| Safe wrapper for desktop detection.
export
isDesktop : IO Bool
isDesktop = do
  val <- primIO prim__isDesktop
  pure (val == 1)

||| Get all platform information as a JSON string.
||| Includes platform, architecture, webview engine, version, and desktop flag.
export
%foreign "C:gossamer_platform_json, libgossamer"
prim__platformJson : PrimIO Bits64

||| Safe wrapper for platform JSON.
export
platformJson : IO String
platformJson = do
  ptr <- primIO prim__platformJson
  pure (ptrToString ptr)

--------------------------------------------------------------------------------
-- Error Handling
--------------------------------------------------------------------------------

||| Get the last error message from the Zig FFI layer.
export
%foreign "C:gossamer_last_error, libgossamer"
prim__lastError : PrimIO Bits64

||| Retrieve last error as a string.
export
lastError : IO (Maybe String)
lastError = do
  ptr <- primIO prim__lastError
  if ptr == 0
    then pure Nothing
    else pure (Just (ptrToString ptr))

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
  pure (ptrToString ptr)

--------------------------------------------------------------------------------
-- Static Site Generator (SSG)
--------------------------------------------------------------------------------
-- Zig implementations: src/interface/ffi/src/ssg.zig
-- Ephapax frontend: features/ssg/SSG.eph

||| Read file contents as a string.
||| Returns null pointer on failure (file not found, too large, etc.).
export
%foreign "C:gossamer_ssg_read_file, libgossamer"
prim__ssgReadFile : (path : String) -> PrimIO Bits64

||| Safe wrapper for file reading.
export
ssgReadFile : String -> IO (Maybe String)
ssgReadFile path = do
  ptr <- primIO (prim__ssgReadFile path)
  if ptr == 0
    then pure Nothing
    else pure (Just (ptrToString ptr))

||| Write content to a file, creating parent directories as needed.
||| Returns 0 on success, non-zero on error.
export
%foreign "C:gossamer_ssg_write_file, libgossamer"
prim__ssgWriteFile : (path : String) -> (content : String) -> PrimIO Int

||| Safe wrapper for file writing.
export
ssgWriteFile : String -> String -> IO Bool
ssgWriteFile path content = do
  rc <- primIO (prim__ssgWriteFile path content)
  pure (rc == 0)

||| List files in a directory matching a given extension.
||| Returns newline-separated file paths, or null on error.
export
%foreign "C:gossamer_ssg_list_files, libgossamer"
prim__ssgListFiles : (dir : String) -> (extension : String) -> PrimIO Bits64

||| Safe wrapper for file listing.
export
ssgListFiles : String -> String -> IO (Maybe String)
ssgListFiles dir ext = do
  ptr <- primIO (prim__ssgListFiles dir ext)
  if ptr == 0
    then pure Nothing
    else pure (Just (ptrToString ptr))

||| Parse YAML front matter from content (between --- delimiters).
||| Returns the front matter text, or empty string if none found.
export
%foreign "C:gossamer_ssg_parse_front_matter, libgossamer"
prim__ssgParseFrontMatter : (content : String) -> PrimIO Bits64

||| Safe wrapper for front matter parsing.
export
ssgParseFrontMatter : String -> IO String
ssgParseFrontMatter content = do
  ptr <- primIO (prim__ssgParseFrontMatter content)
  pure (ptrToString ptr)

||| Parse body content (everything after front matter).
export
%foreign "C:gossamer_ssg_parse_body, libgossamer"
prim__ssgParseBody : (content : String) -> PrimIO Bits64

||| Safe wrapper for body parsing.
export
ssgParseBody : String -> IO String
ssgParseBody content = do
  ptr <- primIO (prim__ssgParseBody content)
  pure (ptrToString ptr)

||| Convert Markdown to HTML.
||| Supports headings, bold, italic, code, links, code blocks.
export
%foreign "C:gossamer_ssg_md_to_html, libgossamer"
prim__ssgMdToHtml : (markdown : String) -> PrimIO Bits64

||| Safe wrapper for Markdown conversion.
export
ssgMdToHtml : String -> IO String
ssgMdToHtml markdown = do
  ptr <- primIO (prim__ssgMdToHtml markdown)
  pure (ptrToString ptr)

||| Substitute {{key}} placeholders in a template with key=value pairs.
export
%foreign "C:gossamer_ssg_template_substitute, libgossamer"
prim__ssgTemplateSubstitute : (template : String) -> (vars : String) -> PrimIO Bits64

||| Safe wrapper for template substitution.
export
ssgTemplateSubstitute : String -> String -> IO String
ssgTemplateSubstitute template vars = do
  ptr <- primIO (prim__ssgTemplateSubstitute template vars)
  pure (ptrToString ptr)

||| Build an entire static site from content directory + template.
||| Returns 0 on success, non-zero on error.
export
%foreign "C:gossamer_ssg_build_site, libgossamer"
prim__ssgBuildSite : (contentDir : String) -> (templateFile : String)
                  -> (outDir : String) -> PrimIO Int

||| Safe wrapper for full site build.
export
ssgBuildSite : String -> String -> String -> IO Bool
ssgBuildSite contentDir templateFile outDir = do
  rc <- primIO (prim__ssgBuildSite contentDir templateFile outDir)
  pure (rc == 0)
