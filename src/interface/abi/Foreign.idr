-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| SPDX-License-Identifier: MPL-2.0
||| Foreign Function Interface Declarations for GOSSAMER (HONEST ABI)
|||
||| Restored 2026-06-16: every `%foreign "C:gossamer_*"` below names a symbol that
||| is a real `export fn` in `src/interface/ffi/src/` — verified by the
||| %foreign-subset-of-exports check (see `just check-abi-honest` / CI).
|||
||| The previous version declared EIGHT phantom symbols that no Zig export ever
||| provided (`gossamer_init`, `_free`, `_process`, `_free_string`, `_get_string`,
||| `_process_array`, `_register_callback`, `_is_initialized`) — a wrong generic
||| template laid over a real `create/eval/run/channel/cap` codebase. Those are
||| removed. Signatures here mirror `bindings/rust/src/lib.rs` (the real consumer
||| surface) and the Zig `export fn` declarations.
|||
||| Scope: a curated CORE of the 126-symbol surface (lifecycle, content/navigation,
||| window control, channels, capabilities, notify, version/error). The remaining
||| real exports (tray, fs, conf, dialog, group, registry, emit, debug, clipboard,
||| platform, groove) are NOT yet bound here — an honest *coverage* gap, not a
||| phantom. The groove-typed surface is deliberately excluded: it relocates to the
||| groove/cleave experiment.

module Gossamer.ABI.Foreign

import Gossamer.ABI.Types
import Gossamer.ABI.Layout
import Gossamer.ABI.TransmuteStateMachine

%default total

||| Decode a C Result int into the Result enum (Error on an unknown code).
resOf : Bits32 -> Result
resOf n = case resultFromInt n of
            Just r  => r
            Nothing => Error

--------------------------------------------------------------------------------
-- String support (real: Idris2 support runtime)
--------------------------------------------------------------------------------

export
%foreign "support:idris2_getString, libidris2_support"
prim__getString : Bits64 -> String

--------------------------------------------------------------------------------
-- Lifecycle  (gossamer_create / run / destroy)
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_create, libgossamer"
prim__create : String -> Bits32 -> Bits32 -> Bits8 -> Bits8 -> Bits8 -> PrimIO Bits64

||| Create a webview window. Main-thread-bound (carries a MainThreadProof).
export
create : {auto prf : MainThreadProof}
      -> (title : String) -> (width : Bits32) -> (height : Bits32)
      -> (resizable : Bool) -> (decorations : Bool) -> (fullscreen : Bool)
      -> IO (Maybe WebviewHandle)
create title w h r d f = do
  ptr <- primIO (prim__create title w h (bit r) (bit d) (bit f))
  pure (createWebview ptr)
  where
    bit : Bool -> Bits8
    bit True  = 1
    bit False = 0

export
%foreign "C:gossamer_run, libgossamer"
prim__run : Bits64 -> PrimIO ()

||| Enter the webview run loop (blocks until the window closes).
export
run : WebviewHandle -> IO ()
run h = primIO (prim__run (webviewPtr h))

export
%foreign "C:gossamer_destroy, libgossamer"
prim__destroy : Bits64 -> PrimIO ()

||| Destroy the webview and release its native resources.
export
destroy : WebviewHandle -> IO ()
destroy h = primIO (prim__destroy (webviewPtr h))

--------------------------------------------------------------------------------
-- Content / navigation   (handle, string) -> Result
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_load_html, libgossamer"
prim__loadHtml : Bits64 -> String -> PrimIO Bits32

export
loadHtml : WebviewHandle -> String -> IO Result
loadHtml h html = do n <- primIO (prim__loadHtml (webviewPtr h) html); pure (resOf n)

export
%foreign "C:gossamer_navigate, libgossamer"
prim__navigate : Bits64 -> String -> PrimIO Bits32

export
navigate : WebviewHandle -> String -> IO Result
navigate h url = do n <- primIO (prim__navigate (webviewPtr h) url); pure (resOf n)

export
%foreign "C:gossamer_eval, libgossamer"
prim__eval : Bits64 -> String -> PrimIO Bits32

export
eval : WebviewHandle -> String -> IO Result
eval h js = do n <- primIO (prim__eval (webviewPtr h) js); pure (resOf n)

export
%foreign "C:gossamer_set_title, libgossamer"
prim__setTitle : Bits64 -> String -> PrimIO Bits32

export
setTitle : WebviewHandle -> String -> IO Result
setTitle h t = do n <- primIO (prim__setTitle (webviewPtr h) t); pure (resOf n)

export
%foreign "C:gossamer_set_csp, libgossamer"
prim__setCsp : Bits64 -> String -> PrimIO Bits32

export
setCsp : WebviewHandle -> String -> IO Result
setCsp h csp = do n <- primIO (prim__setCsp (webviewPtr h) csp); pure (resOf n)

--------------------------------------------------------------------------------
-- Window control   (handle) -> Result,  plus resize
--------------------------------------------------------------------------------

||| Apply a (handle -> Result) primitive and decode the Result.
hop : (Bits64 -> PrimIO Bits32) -> WebviewHandle -> IO Result
hop prim h = do n <- primIO (prim (webviewPtr h)); pure (resOf n)

export
%foreign "C:gossamer_show, libgossamer"
prim__show : Bits64 -> PrimIO Bits32
export
showWindow : WebviewHandle -> IO Result
showWindow = hop prim__show

export
%foreign "C:gossamer_hide, libgossamer"
prim__hide : Bits64 -> PrimIO Bits32
export
hideWindow : WebviewHandle -> IO Result
hideWindow = hop prim__hide

export
%foreign "C:gossamer_minimize, libgossamer"
prim__minimize : Bits64 -> PrimIO Bits32
export
minimize : WebviewHandle -> IO Result
minimize = hop prim__minimize

export
%foreign "C:gossamer_maximize, libgossamer"
prim__maximize : Bits64 -> PrimIO Bits32
export
maximize : WebviewHandle -> IO Result
maximize = hop prim__maximize

export
%foreign "C:gossamer_restore, libgossamer"
prim__restore : Bits64 -> PrimIO Bits32
export
restoreWindow : WebviewHandle -> IO Result
restoreWindow = hop prim__restore

export
%foreign "C:gossamer_request_close, libgossamer"
prim__requestClose : Bits64 -> PrimIO Bits32
export
requestClose : WebviewHandle -> IO Result
requestClose = hop prim__requestClose

export
%foreign "C:gossamer_resize, libgossamer"
prim__resize : Bits64 -> Bits32 -> Bits32 -> PrimIO Bits32

export
resize : WebviewHandle -> (width : Bits32) -> (height : Bits32) -> IO Result
resize h w ht = do n <- primIO (prim__resize (webviewPtr h) w ht); pure (resOf n)

--------------------------------------------------------------------------------
-- Transmute  (runtime rendering-mode switching)
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_transmute, libgossamer"
prim__transmute : Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_transmute_get, libgossamer"
prim__transmuteGet : Bits64 -> PrimIO Bits32

||| Switch the window's rendering mode. Main-thread-bound: every mode change
||| evaluates JavaScript in the webview (same rationale as `create`).
|||
||| The runtime enforces the transition relation proved in
||| Gossamer.ABI.TransmuteStateMachine: an illegal transition (e.g.
||| panll_attach -> gui without releasing the panel slot) returns
||| InvalidParam and leaves the stored mode untouched.
export
transmute : {auto prf : MainThreadProof}
         -> WebviewHandle -> TransmuteMode -> IO Result
transmute h m = do
  n <- primIO (prim__transmute (webviewPtr h) (transmuteModeToInt m))
  pure (resOf n)

||| Statically-witnessed transmute for flows where the current mode is known
||| at compile time: the erased `TransmuteTransition from to` auto-implicit
||| makes an illegal request a COMPILE error rather than a runtime rejection.
||| (The runtime still re-checks — the witness only rules out writing the
||| illegal call in the first place.)
export
transmuteFrom : {auto prf : MainThreadProof}
             -> WebviewHandle
             -> (from, to : TransmuteMode)
             -> {auto 0 legal : TransmuteTransition from to}
             -> IO Result
transmuteFrom h _ to = transmute h to

||| Current transmute mode (Nothing on error / unregistered window — the C
||| side returns -1, which decodes to Nothing via transmuteModeFromInt).
export
transmuteGet : WebviewHandle -> IO (Maybe TransmuteMode)
transmuteGet h = do
  n <- primIO (prim__transmuteGet (webviewPtr h))
  pure (transmuteModeFromInt n)

--------------------------------------------------------------------------------
-- Channels
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_channel_open, libgossamer"
prim__channelOpen : Bits64 -> PrimIO Bits64

||| Open an IPC channel on a webview; returns the raw channel handle (0 = failure).
export
channelOpen : WebviewHandle -> IO Bits64
channelOpen h = primIO (prim__channelOpen (webviewPtr h))

export
%foreign "C:gossamer_channel_close, libgossamer"
prim__channelClose : Bits64 -> PrimIO ()

export
channelClose : (channel : Bits64) -> IO ()
channelClose c = primIO (prim__channelClose c)

export
%foreign "C:gossamer_async_inflight_count, libgossamer"
prim__asyncInflightCount : PrimIO Bits32

export
asyncInflightCount : IO Bits32
asyncInflightCount = primIO prim__asyncInflightCount

--------------------------------------------------------------------------------
-- Capabilities  (raw token surface)
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_cap_grant, libgossamer"
prim__capGrant : Bits32 -> PrimIO Bits64

||| Grant a capability for a resource-kind code; returns a token (0 = denied).
export
capGrant : (resourceKind : Bits32) -> IO Bits64
capGrant k = primIO (prim__capGrant k)

export
%foreign "C:gossamer_cap_check, libgossamer"
prim__capCheck : Bits64 -> PrimIO Bits32

export
capCheck : (token : Bits64) -> IO Result
capCheck t = do n <- primIO (prim__capCheck t); pure (resOf n)

export
%foreign "C:gossamer_cap_revoke, libgossamer"
prim__capRevoke : Bits64 -> PrimIO ()

export
capRevoke : (token : Bits64) -> IO ()
capRevoke t = primIO (prim__capRevoke t)

--------------------------------------------------------------------------------
-- Notifications
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_notify, libgossamer"
prim__notify : String -> String -> PrimIO Bits32

||| Post a desktop notification; returns a backend-defined status word.
export
notify : (title : String) -> (body : String) -> IO Bits32
notify t b = primIO (prim__notify t b)

--------------------------------------------------------------------------------
-- Version / build / error  (return char*, read via idris2_getString)
--------------------------------------------------------------------------------

export
%foreign "C:gossamer_version, libgossamer"
prim__version : PrimIO Bits64

export
version : IO String
version = do ptr <- primIO prim__version; pure (prim__getString ptr)

export
%foreign "C:gossamer_build_info, libgossamer"
prim__buildInfo : PrimIO Bits64

export
buildInfo : IO String
buildInfo = do ptr <- primIO prim__buildInfo; pure (prim__getString ptr)

export
%foreign "C:gossamer_last_error, libgossamer"
prim__lastError : PrimIO Bits64

||| Last error message, or Nothing if no error is set (null char*).
export
lastError : IO (Maybe String)
lastError = do
  ptr <- primIO prim__lastError
  if ptr == 0 then pure Nothing else pure (Just (prim__getString ptr))

--------------------------------------------------------------------------------
-- Callback ABI type (kept for downstream consumers; no phantom binding)
--------------------------------------------------------------------------------

||| Callback function type (C ABI). Channel/tray callback binding is not yet
||| restored here (the real `gossamer_channel_bind`/`gossamer_tray_set_callback`
||| take function pointers); this type is retained for downstream use.
public export
Callback : Type
Callback = Bits64 -> Bits32 -> Bits32
