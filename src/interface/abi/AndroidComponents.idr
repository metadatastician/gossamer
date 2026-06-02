-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Android Non-UI Component Lifecycles for Gossamer (GS-ANDROID)
|||
||| Gossamer hosts a WebView in an Activity, but a production Android app also
||| needs background components with no webview in scope: a foreground Service,
||| a BroadcastReceiver, and an AppWidgetProvider. This module gives those
||| components the same formal treatment the webview already enjoys:
|||
|||   1. Each component is a state machine with a TERMINAL teardown state and
|||      no transition out of it (mirrors WindowStateMachine's `Closed`).
|||   2. Event dispatch is only well-typed while the component is LIVE — the
|||      type-level analogue of the runtime plugin-liveness check that prevents
|||      use-after-free in the IPC dispatcher.
|||   3. The long-lived Service is modelled as a `LinearHandle` over the SAME
|||      lifecycle framework as the webview (HandleLinearity), so the linear
|||      "consume exactly once" guarantee crosses the new JNI boundary intact.
|||
||| The native side of these contracts lives in src/interface/ffi/src/
||| android_{service,receiver,widget}.zig; the JVM side is gossamer-GENERATED
||| Java (android/generated/). An app binds pure handlers via the
||| gossamer_{service,receiver,widget}_bind FFI declared at the foot of this
||| module and never touches JNI itself.
|||
||| OPEN (tracked as a gossamer issue): the deep region-calculus question of how
||| a long-lived, JVM-owned Service handle relates to the shorter-lived webview
||| region — and how cross-region references (a Service pushing a Widget update)
||| are tracked — is NOT settled here. This module proves the parts that are
||| unambiguous (terminal teardown, dispatch-only-while-live, single-consume)
||| and leaves the region-nesting design to that issue.
|||
||| No unsafe escape hatches; every proof is constructive.

module Gossamer.ABI.AndroidComponents

import Gossamer.ABI.Types
import Gossamer.ABI.HandleLinearity
import Data.So

%default total

--------------------------------------------------------------------------------
-- Component Taxonomy
--------------------------------------------------------------------------------

||| The three non-UI Android components Gossamer hosts natively.
public export
data ComponentKind = ServiceC | ReceiverC | WidgetC

||| Whether a component owns a LONG-LIVED handle (one whose lifetime spans many
||| dispatches) versus a TRANSIENT one (constructed per dispatch by the JVM).
|||
||| Only the Service owns a long-lived handle: the JVM keeps the Service object
||| alive across many onStartCommand calls. A BroadcastReceiver and an
||| AppWidgetProvider update are constructed, called once, and discarded — each
||| dispatch is a scoped borrow, not an owned handle.
public export
data LongLived : ComponentKind -> Type where
  ServiceIsLongLived : LongLived ServiceC

||| Receiver dispatch is transient (no owned long-lived handle).
public export
data Transient : ComponentKind -> Type where
  ReceiverIsTransient : Transient ReceiverC
  WidgetIsTransient   : Transient WidgetC

||| Long-lived and transient are disjoint classifications.
public export
longLivedNotTransient : LongLived k -> Transient k -> Void
longLivedNotTransient ServiceIsLongLived x = case x of {}

--------------------------------------------------------------------------------
-- Foreground Service lifecycle:  Created -> Started* -> Destroyed
--------------------------------------------------------------------------------

||| States of a gossamer-hosted foreground Service.
||| Mirrors android.app.Service: onCreate, onStartCommand (repeatable),
||| onDestroy (terminal).
public export
data SvcState = SvcCreated | SvcStarted | SvcDestroyed

||| Service lifecycle operations (the JNI entry points in services_android.zig).
public export
data SvcOp = OnCreate | OnStartCommand | OnDestroy

||| Valid Service transitions. No constructor has source SvcDestroyed, so
||| SvcDestroyed is absorbing. onStartCommand may fire repeatedly (START_STICKY
||| redelivery), modelled by the Started -> Started self-loop.
public export
data SvcTransition : (s : SvcState) -> (op : SvcOp) -> (t : SvcState) -> Type where
  StartFromCreated   : SvcTransition SvcCreated OnStartCommand SvcStarted
  StartFromStarted   : SvcTransition SvcStarted OnStartCommand SvcStarted
  DestroyFromCreated : SvcTransition SvcCreated OnDestroy      SvcDestroyed
  DestroyFromStarted : SvcTransition SvcStarted OnDestroy      SvcDestroyed

||| GS-ANDROID-INV-1: onDestroy is terminal — no transition leaves SvcDestroyed.
public export
svcDestroyedTerminal : SvcTransition SvcDestroyed op t -> Void
svcDestroyedTerminal _ impossible

||| A Service is "live" (safe to dispatch events into) iff it is not destroyed.
public export
data SvcLive : SvcState -> Type where
  LiveCreated : SvcLive SvcCreated
  LiveStarted : SvcLive SvcStarted

||| A destroyed Service is not live (no dispatch after teardown).
public export
svcDestroyedNotLive : SvcLive SvcDestroyed -> Void
svcDestroyedNotLive x = case x of {}

||| onStartCommand always lands in the Started state — the foreground work is
||| running regardless of whether this was the first start or a redelivery.
public export
startCommandStarts : SvcTransition s OnStartCommand t -> t = SvcStarted
startCommandStarts StartFromCreated = Refl
startCommandStarts StartFromStarted = Refl

||| onDestroy always lands in the terminal state.
public export
destroyDestroys : SvcTransition s OnDestroy t -> t = SvcDestroyed
destroyDestroys DestroyFromCreated = Refl
destroyDestroys DestroyFromStarted = Refl

--------------------------------------------------------------------------------
-- BroadcastReceiver lifecycle:  Live -> Complete  (one-shot)
--------------------------------------------------------------------------------

||| States of a single BroadcastReceiver invocation. The JVM constructs the
||| receiver, calls onReceive exactly once, and discards it; onReceive must
||| complete within its window (Android tears the receiver down on return).
public export
data RcvState = RcvLive | RcvComplete

||| The single valid receiver transition: handle the broadcast, then complete.
public export
data RcvTransition : (s : RcvState) -> (t : RcvState) -> Type where
  ReceiveOnce : RcvTransition RcvLive RcvComplete

||| GS-ANDROID-INV-2: a completed receiver is terminal — onReceive cannot fire
||| twice on the same instance.
public export
rcvCompleteTerminal : RcvTransition RcvComplete t -> Void
rcvCompleteTerminal _ impossible

--------------------------------------------------------------------------------
-- AppWidgetProvider lifecycle:  Enabled -> Disabled  (updates are borrows)
--------------------------------------------------------------------------------

||| States of a gossamer-hosted home-screen widget provider. onEnabled fires
||| when the first instance is placed; onDisabled when the last is removed
||| (terminal). onUpdate is a BORROW: it renders without changing provider
||| state, exactly like the webview's loadHTML/navigate borrows.
public export
data WdgState = WdgEnabled | WdgDisabled

public export
data WdgOp = WidgetOnUpdate | WidgetOnDisabled

||| Valid widget transitions. onUpdate is absent here because, as a borrow, it
||| does not move the provider between states (see `widgetUpdateBorrow`).
public export
data WdgTransition : (s : WdgState) -> (op : WdgOp) -> (t : WdgState) -> Type where
  DisableFromEnabled : WdgTransition WdgEnabled WidgetOnDisabled WdgDisabled

||| GS-ANDROID-INV-3: onDisabled is terminal.
public export
wdgDisabledTerminal : WdgTransition WdgDisabled op t -> Void
wdgDisabledTerminal _ impossible

||| onUpdate is a borrow: it is only valid on an enabled provider and leaves the
||| state unchanged. Encoded as a predicate rather than a state transition.
public export
data WidgetUpdateBorrow : WdgState -> Type where
  UpdateWhileEnabled : WidgetUpdateBorrow WdgEnabled

||| A disabled provider cannot service updates.
public export
wdgDisabledNoUpdate : WidgetUpdateBorrow WdgDisabled -> Void
wdgDisabledNoUpdate x = case x of {}

--------------------------------------------------------------------------------
-- Service as a Linear Handle (linearity preserved across the JNI boundary)
--------------------------------------------------------------------------------

||| Opaque handle to a gossamer-hosted foreground Service.
||| Like WebviewHandle, this is a LINEAR resource carrying a non-null proof:
||| it is allocated once (onCreate) and consumed once (onDestroy).
public export
data ServiceHandle : Type where
  MkService : (ptr : Bits64)
            -> {auto 0 nonNull : So (ptr /= 0)}
            -> ServiceHandle

||| Extract the raw pointer (for FFI calls).
public export
servicePtr : ServiceHandle -> Bits64
servicePtr (MkService ptr) = ptr

||| Recover the erased non-null witness as a ValidToken, mirroring
||| HandleLinearity.webviewValid. The witness already lives inside MkService;
||| this re-exposes it so allocation is total with no runtime null re-check.
public export
serviceValid : (s : ServiceHandle) -> ValidToken (servicePtr s)
serviceValid (MkService ptr {nonNull}) = MkValid {nonNull}

||| A linearly-tracked Service handle, reusing the generic Allocated/Active/
||| Consumed machine from HandleLinearity. This is the load-bearing claim that
||| the new Service boundary keeps Gossamer's linear guarantees: a Service that
||| is leaked (never onDestroy) or torn down twice does not type-check.
public export
LinearService : HandleState -> Type
LinearService = LinearHandle ServiceHandle

||| Allocate a linear Service handle (state Allocated), set up at onCreate.
public export
allocateService : ServiceHandle -> LinearService Allocated
allocateService s = MkLinear s (servicePtr s) {valid = serviceValid s}

||| Consume the Service handle at onDestroy. Active -> Consumed, returning the
||| raw handle for the final FFI teardown call. There is no way to reconstruct
||| an Active handle from the Consumed one, so no dispatch can follow.
public export
consumeForStop : LinearService Active -> (ServiceHandle, LinearService Consumed)
consumeForStop = consume

||| The Service lifecycle state maps onto the generic handle lifecycle:
||| Created↔Allocated, Started↔Active, Destroyed↔Consumed.
public export
svcToHandleState : SvcState -> HandleState
svcToHandleState SvcCreated   = Allocated
svcToHandleState SvcStarted   = Active
svcToHandleState SvcDestroyed = Consumed

||| The mapping sends the terminal Service state to the terminal handle state,
||| witnessing that "Service destroyed" and "handle consumed" coincide.
public export
destroyedIsConsumed : svcToHandleState SvcDestroyed = Consumed
destroyedIsConsumed = Refl

--------------------------------------------------------------------------------
-- FFI: native callback registration (implemented in services_android.zig)
--------------------------------------------------------------------------------
--
-- The #71 companion uses the subclass model: the JVM-side base classes
-- (io.gossamer.services.*) own the Android contracts, and the app's native core
-- (Rust/Zig) plugs in by registering plain C callbacks at JNI_OnLoad. gossamer
-- owns every JNI call. Each callback is a raw C function pointer (Bits64); the
-- concrete handler is supplied by the app, so these declarations fix only the C
-- symbol and arity. The foreground-Service handle threaded to the callbacks is
-- the independent ServiceHandle modelled above.

||| Register the foreground-Service callbacks: create, startCommand, destroy,
||| sensorEvent (four raw C function pointers).
export
%foreign "C:gossamer_android_register_service_callbacks, libgossamer"
prim__registerServiceCallbacks : Bits64 -> Bits64 -> Bits64 -> Bits64 -> PrimIO ()

||| Register the AppWidget callbacks: fetchState, handleAction.
export
%foreign "C:gossamer_android_register_widget_callbacks, libgossamer"
prim__registerWidgetCallbacks : Bits64 -> Bits64 -> PrimIO ()

||| Register the boot-receiver shouldRestart predicate callback.
export
%foreign "C:gossamer_android_register_boot_callback, libgossamer"
prim__registerBootCallback : Bits64 -> PrimIO ()

||| Register the Activity intent callback.
export
%foreign "C:gossamer_android_register_intent_callback, libgossamer"
prim__registerIntentCallback : Bits64 -> PrimIO ()

||| Safe wrapper: register the foreground-Service native callbacks.
export
registerServiceCallbacks : (create : Bits64) -> (start : Bits64) -> (destroy : Bits64) -> (sensor : Bits64) -> IO ()
registerServiceCallbacks c s d sn = primIO (prim__registerServiceCallbacks c s d sn)

||| Safe wrapper: register the AppWidget native callbacks.
export
registerWidgetCallbacks : (fetchState : Bits64) -> (handleAction : Bits64) -> IO ()
registerWidgetCallbacks f h = primIO (prim__registerWidgetCallbacks f h)

||| Safe wrapper: register the boot-receiver callback.
export
registerBootCallback : (shouldRestart : Bits64) -> IO ()
registerBootCallback sr = primIO (prim__registerBootCallback sr)

||| Safe wrapper: register the Activity intent callback.
export
registerIntentCallback : (onIntent : Bits64) -> IO ()
registerIntentCallback oi = primIO (prim__registerIntentCallback oi)
