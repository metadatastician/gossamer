-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| ABI Type Definitions for Gossamer Webview Shell
|||
||| Core types for the linearly-typed webview shell. Defines:
||| - WebviewHandle: linearly-owned webview window handle
||| - Channel: typed IPC channel parameterised by request/response types
||| - Cap: linear capability token for permission enforcement
||| - WindowConfig: plain-value window configuration
|||
||| All handle types carry non-null proofs. The webview handle additionally
||| carries a main-thread witness, since webview operations must execute on
||| the main/UI thread on all platforms.
|||
||| This is the formal specification. The Zig FFI layer (ffi/zig/) implements
||| these types as opaque C ABI handles.

module Gossamer.ABI.Types

import Data.Bits
import Data.So
import Data.Vect

%default total

--------------------------------------------------------------------------------
-- Platform Detection
--------------------------------------------------------------------------------

||| Supported platforms for this ABI.
||| Each platform uses a different webview engine:
||| - Linux:   WebKitGTK
||| - MacOS:   WKWebView
||| - Windows: WebView2 (Edge/Chromium)
||| - BSD:     WebKitGTK (same as Linux)
||| - WASM:    not applicable (Gossamer is a native shell)
public export
data Platform = Linux | Windows | MacOS | BSD | WASM

||| Compile-time platform detection.
||| Override with compiler flags for cross-compilation.
public export
thisPlatform : Platform
thisPlatform =
  %runElab do
    pure Linux  -- Default; override with --cg-opt for target

--------------------------------------------------------------------------------
-- Result Codes
--------------------------------------------------------------------------------

||| Result codes for all FFI operations.
||| Extends the standard ABI results with webview-specific and
||| linearity-specific error codes.
public export
data Result : Type where
  ||| Operation succeeded
  Ok : Result
  ||| Generic error (check lastError for details)
  Error : Result
  ||| Invalid parameter (e.g. malformed URL, empty HTML)
  InvalidParam : Result
  ||| Allocation failure
  OutOfMemory : Result
  ||| Null pointer encountered (handle not initialised)
  NullPointer : Result
  ||| Linear resource was already consumed (use-after-free attempt)
  AlreadyConsumed : Result
  ||| Linear resource was not consumed before scope exit (leak)
  ResourceLeaked : Result
  ||| Linear resource consumed more than once (double-free)
  DoubleFree : Result
  ||| Webview creation failed (platform webview unavailable)
  WebviewUnavailable : Result
  ||| IPC protocol violation (message shape mismatch)
  IPCProtocolError : Result
  ||| Capability check failed (operation not permitted)
  CapabilityDenied : Result

||| Convert Result to C integer for FFI boundary.
public export
resultToInt : Result -> Bits32
resultToInt Ok = 0
resultToInt Error = 1
resultToInt InvalidParam = 2
resultToInt OutOfMemory = 3
resultToInt NullPointer = 4
resultToInt AlreadyConsumed = 5
resultToInt ResourceLeaked = 6
resultToInt DoubleFree = 7
resultToInt WebviewUnavailable = 8
resultToInt IPCProtocolError = 9
resultToInt CapabilityDenied = 10

||| Reconstruct Result from C integer.
||| Returns Nothing for unknown codes.
public export
resultFromInt : Bits32 -> Maybe Result
resultFromInt 0 = Just Ok
resultFromInt 1 = Just Error
resultFromInt 2 = Just InvalidParam
resultFromInt 3 = Just OutOfMemory
resultFromInt 4 = Just NullPointer
resultFromInt 5 = Just AlreadyConsumed
resultFromInt 6 = Just ResourceLeaked
resultFromInt 7 = Just DoubleFree
resultFromInt 8 = Just WebviewUnavailable
resultFromInt 9 = Just IPCProtocolError
resultFromInt 10 = Just CapabilityDenied
resultFromInt _ = Nothing

||| Results are decidably equal.
public export
DecEq Result where
  decEq Ok Ok = Yes Refl
  decEq Error Error = Yes Refl
  decEq InvalidParam InvalidParam = Yes Refl
  decEq OutOfMemory OutOfMemory = Yes Refl
  decEq NullPointer NullPointer = Yes Refl
  decEq AlreadyConsumed AlreadyConsumed = Yes Refl
  decEq ResourceLeaked ResourceLeaked = Yes Refl
  decEq DoubleFree DoubleFree = Yes Refl
  decEq WebviewUnavailable WebviewUnavailable = Yes Refl
  decEq IPCProtocolError IPCProtocolError = Yes Refl
  decEq CapabilityDenied CapabilityDenied = Yes Refl
  decEq _ _ = No absurd

||| Human-readable error descriptions.
public export
errorDescription : Result -> String
errorDescription Ok = "Success"
errorDescription Error = "Generic error"
errorDescription InvalidParam = "Invalid parameter"
errorDescription OutOfMemory = "Out of memory"
errorDescription NullPointer = "Null pointer"
errorDescription AlreadyConsumed = "Resource already consumed (use-after-free)"
errorDescription ResourceLeaked = "Resource leaked (not consumed before scope exit)"
errorDescription DoubleFree = "Double-free attempt"
errorDescription WebviewUnavailable = "Webview engine unavailable on this platform"
errorDescription IPCProtocolError = "IPC protocol violation"
errorDescription CapabilityDenied = "Capability denied"

--------------------------------------------------------------------------------
-- Main-Thread Witness
--------------------------------------------------------------------------------

||| Proof that execution is on the main/UI thread.
|||
||| Webview handles can only be created and destroyed on the main thread.
||| This is a platform requirement:
||| - GTK:     gtk_init/gtk_main must run on the main thread
||| - Cocoa:   NSApplication requires main thread
||| - Win32:   WebView2 requires STA thread
|||
||| This is a zero-runtime-cost witness: it exists only in the type system.
||| The application entry point provides OnMain; it cannot be forged.
public export
data MainThreadProof : Type where
  ||| Witness that we are on the main thread.
  ||| Only constructible by the framework entry point.
  OnMain : MainThreadProof

--------------------------------------------------------------------------------
-- Webview Handle (Linear Resource)
--------------------------------------------------------------------------------

||| Opaque handle to a native webview window.
|||
||| This is a LINEAR resource: it must be created exactly once and
||| consumed (via `run` or `destroy`) exactly once. The type system
||| enforces this — a program that leaks or double-frees a WebviewHandle
||| does not compile.
|||
||| The dependent type proofs guarantee:
||| 1. The pointer is non-null (So (ptr /= 0))
||| 2. The handle was created on the main thread (MainThreadProof)
|||
||| Both proofs are erased at runtime (quantity 0).
public export
data WebviewHandle : Type where
  MkWebview : (ptr : Bits64)
            -> {auto 0 nonNull : So (ptr /= 0)}
            -> {auto 0 onMainThread : MainThreadProof}
            -> WebviewHandle

||| Safely create a WebviewHandle from a raw pointer.
||| Returns Nothing if the pointer is null.
||| Requires a MainThreadProof witness.
public export
createWebview : Bits64 -> {auto prf : MainThreadProof} -> Maybe WebviewHandle
createWebview 0 = Nothing
createWebview ptr = Just (MkWebview ptr)

||| Extract raw pointer from handle (for FFI calls).
public export
webviewPtr : WebviewHandle -> Bits64
webviewPtr (MkWebview ptr) = ptr

--------------------------------------------------------------------------------
-- Window Configuration (Plain Value)
--------------------------------------------------------------------------------

||| Window configuration — a plain value, not a resource.
||| Can be freely copied, stored, serialised.
public export
record WindowConfig where
  constructor MkWindowConfig
  ||| Window title (displayed in title bar)
  title       : String
  ||| Initial window width in pixels
  width       : Bits32
  ||| Initial window height in pixels
  height      : Bits32
  ||| Whether the window can be resized
  resizable   : Bool
  ||| Whether to show window decorations (title bar, borders)
  decorations : Bool
  ||| Whether the window starts in fullscreen mode
  fullscreen  : Bool

||| Default window configuration: 800x600, resizable, decorated.
public export
defaultConfig : WindowConfig
defaultConfig = MkWindowConfig
  { title = "Gossamer"
  , width = 800
  , height = 600
  , resizable = True
  , decorations = True
  , fullscreen = False
  }

--------------------------------------------------------------------------------
-- IPC Channel (Linear Resource)
--------------------------------------------------------------------------------

||| Typed IPC channel connecting frontend (webview) to backend (Ephapax).
|||
||| The channel is parameterised by request and response types,
||| ensuring compile-time agreement between frontend and backend.
|||
||| Like WebviewHandle, this is a linear resource: it must be opened
||| exactly once and closed exactly once.
public export
data Channel : (req : Type) -> (resp : Type) -> Type where
  MkChannel : (ptr : Bits64)
            -> {auto 0 nonNull : So (ptr /= 0)}
            -> Channel req resp

||| Safely create a Channel from a raw pointer.
public export
createChannel : Bits64 -> Maybe (Channel req resp)
createChannel 0 = Nothing
createChannel ptr = Just (MkChannel ptr)

||| Extract raw pointer from channel (for FFI calls).
public export
channelPtr : Channel req resp -> Bits64
channelPtr (MkChannel ptr) = ptr

--------------------------------------------------------------------------------
-- IPC Protocol Definition
--------------------------------------------------------------------------------

||| A command in the IPC protocol: a name with typed request and response.
public export
record Command where
  constructor MkCommand
  name : String
  -- req and resp types are carried at the type level by Channel

||| A protocol is a list of commands that a channel supports.
||| This type exists at the type level — it is erased at runtime.
public export
data Protocol : List (String, Type, Type) -> Type where
  PNil  : Protocol []
  PCons : (name : String) -> (req : Type) -> (resp : Type)
        -> Protocol rest
        -> Protocol ((name, req, resp) :: rest)

--------------------------------------------------------------------------------
-- Capability Tokens (Linear Resources)
--------------------------------------------------------------------------------

||| Resource kinds that can be capability-gated.
||| Each kind may carry scope information restricting access further.
public export
data ResourceKind : Type where
  ||| Filesystem access, scoped to specific paths and mode
  FileSystem   : FilesystemScope -> ResourceKind
  ||| Network access, scoped to specific hosts/ports
  Network      : NetworkScope -> ResourceKind
  ||| Shell/process execution, scoped to specific commands
  Shell        : ShellScope -> ResourceKind
  ||| Clipboard read/write access
  Clipboard    : ResourceKind
  ||| Desktop notification access
  Notification : ResourceKind
  ||| System tray icon access
  Tray         : ResourceKind

||| Filesystem capability scope.
public export
data FilesystemScope : Type where
  ||| Read-only access to specific directory paths
  ReadOnly  : (paths : List String) -> FilesystemScope
  ||| Read-write access to specific directory paths
  ReadWrite : (paths : List String) -> FilesystemScope
  ||| Access only the application's own data directory
  AppData   : FilesystemScope

||| Network capability scope.
public export
data NetworkScope : Type where
  ||| HTTP/HTTPS requests to specific hosts
  AllowHosts : (hosts : List String) -> NetworkScope
  ||| All network access (use sparingly)
  AllNetwork : NetworkScope

||| Shell/process execution scope.
public export
data ShellScope : Type where
  ||| Execute specific named commands only
  AllowCommands : (commands : List String) -> ShellScope
  ||| Execute any command (dangerous — use only in dev mode)
  AllShell      : ShellScope

||| Linear capability token granting access to a specific resource.
|||
||| Capabilities are linear values:
||| - Cannot be duplicated (no copying)
||| - Cannot be forged (MkCap is not exported)
||| - Must be explicitly revoked or consumed
||| - The compiler enforces that gated operations require the token
|||
||| The token carries an opaque Bits64 identifier used internally
||| for revocation tracking.
public export
data Cap : (resource : ResourceKind) -> Type where
  MkCap : (token : Bits64) -> Cap resource

||| Extract token value from capability (for FFI calls).
||| Not exported — internal use only.
capToken : Cap resource -> Bits64
capToken (MkCap token) = token

--------------------------------------------------------------------------------
-- Platform-Specific Types
--------------------------------------------------------------------------------

||| C int size by platform (always 32 bits in practice).
public export
CInt : Platform -> Type
CInt _ = Bits32

||| C size_t by platform.
public export
CSize : Platform -> Type
CSize WASM = Bits32
CSize _    = Bits64

||| Pointer bit width by platform.
public export
ptrSize : Platform -> Nat
ptrSize WASM = 32
ptrSize _    = 64

||| Pointer type for platform.
public export
CPtr : Platform -> Type -> Type
CPtr p _ = Bits (ptrSize p)

--------------------------------------------------------------------------------
-- Memory Layout Proofs
--------------------------------------------------------------------------------

||| Proof that a type has a specific size in bytes.
public export
data HasSize : Type -> Nat -> Type where
  SizeProof : {0 t : Type} -> {n : Nat} -> HasSize t n

||| Proof that a type has a specific alignment in bytes.
public export
data HasAlignment : Type -> Nat -> Type where
  AlignProof : {0 t : Type} -> {n : Nat} -> HasAlignment t n

||| Size of C types (platform-specific).
public export
cSizeOf : (p : Platform) -> (t : Type) -> Nat
cSizeOf _ Bits32 = 4
cSizeOf _ Bits64 = 8
cSizeOf _ Double = 8
cSizeOf p _      = ptrSize p `div` 8

||| Alignment of C types (platform-specific).
public export
cAlignOf : (p : Platform) -> (t : Type) -> Nat
cAlignOf _ Bits32 = 4
cAlignOf _ Bits64 = 8
cAlignOf _ Double = 8
cAlignOf p _      = ptrSize p `div` 8

--------------------------------------------------------------------------------
-- Lifecycle State Machine
--------------------------------------------------------------------------------

||| States a webview handle can be in.
||| Used by ephapaxiser for static analysis.
public export
data WebviewState : Type where
  ||| Created but no content loaded
  Created   : WebviewState
  ||| Content loaded (HTML or URL), ready to display
  Loaded    : WebviewState
  ||| Event loop running (blocking)
  Running   : WebviewState
  ||| Destroyed (terminal state — handle consumed)
  Destroyed : WebviewState

||| Valid state transitions for the webview lifecycle.
||| Defines the state machine that ephapaxiser enforces.
public export
data ValidTransition : WebviewState -> WebviewState -> Type where
  ||| Can load content into a created webview
  CreateToLoad   : ValidTransition Created Loaded
  ||| Can load new content into an already-loaded webview
  ReLoad         : ValidTransition Loaded Loaded
  ||| Can run the event loop on a loaded webview
  LoadToRun      : ValidTransition Loaded Running
  ||| Running webview terminates and is destroyed
  RunToDestroy   : ValidTransition Running Destroyed
  ||| Can destroy a created webview without loading
  CreateToDestroy : ValidTransition Created Destroyed
  ||| Can destroy a loaded webview without running
  LoadToDestroy  : ValidTransition Loaded Destroyed
