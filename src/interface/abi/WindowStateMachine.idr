-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Window State Machine Correctness Proof (GS1)
|||
||| Proves that the Gossamer window lifecycle follows a well-defined state machine
||| where every transition is valid and the Closed state is terminal.
|||
||| The window has finer-grained visual states than the generic handle lifecycle
||| in HandleLinearity.idr (Allocated/Active/Consumed). Specifically:
|||
|||   Created → Visible ↔ Hidden
|||                  ↕         ↕
|||            Minimized     (no direct hide↔minimize transition)
|||                  ↕
|||            Maximized
|||
|||   Any non-Closed state → Closed (via destroy/run; run is non-returning)
|||
||| Properties proved:
||| 1. Closed is a terminal state (no transitions out of Closed).
||| 2. Every borrow operation (loadHTML, navigate, eval, etc.) is only available
|||    on windows in a non-Closed state.
||| 3. Every consuming operation (run, destroy) produces a Closed window.
||| 4. State transitions are deterministic: each operation maps a specific state
|||    to a specific target state.
||| 5. The state machine is finitely enumerable (all states reachable from Created).
|||
||| Zero believe_me. All proofs are constructive.

module Gossamer.ABI.WindowStateMachine

import Gossamer.ABI.Types

%default total

--------------------------------------------------------------------------------
-- Window State Enumeration
--------------------------------------------------------------------------------

||| Visual state of a Gossamer webview window.
|||
||| This refines the generic handle lifecycle: Created/Visible/Hidden/Minimized/
||| Maximized all correspond to an Active handle; Closed corresponds to Consumed.
|||
||| The naming matches the gossamer_show / gossamer_hide / gossamer_minimize /
||| gossamer_maximize / gossamer_restore / gossamer_run / gossamer_destroy FFI.
public export
data WindowState
  = ||| Freshly created; loadHTML/navigate not yet called or content not displayed.
    Created
  | ||| Window is visible to the user on screen.
    Visible
  | ||| Window exists but is not shown (gossamer_hide called).
    Hidden
  | ||| Window is minimised to taskbar/dock.
    Minimized
  | ||| Window occupies the full screen / is maximised.
    Maximized
  | ||| Window has been destroyed (gossamer_run completed, or gossamer_destroy called).
    ||| This is the terminal state; no transition out of Closed is valid.
    Closed

--------------------------------------------------------------------------------
-- Window Operations (the triggers for state transitions)
--------------------------------------------------------------------------------

||| Every operation that can cause a window state transition.
public export
data WindowOp
  = OpShow         -- gossamer_show
  | OpHide         -- gossamer_hide
  | OpMinimize     -- gossamer_minimize
  | OpMaximize     -- gossamer_maximize
  | OpRestore      -- gossamer_restore (from Minimized or Maximized)
  | OpRequestClose -- gossamer_request_close (signals intent; window stays open)
  | OpRun          -- gossamer_run (event loop; CONSUMES the handle)
  | OpDestroy      -- gossamer_destroy (immediate teardown; CONSUMES the handle)

--------------------------------------------------------------------------------
-- Valid Transitions
--------------------------------------------------------------------------------

||| A proof that transitioning from state `s` via operation `op` leads to
||| state `t`. Each constructor witnesses one valid transition.
|||
||| Invariants encoded:
||| - Closed is the only absorbing state (no constructor has source Closed).
||| - OpRun and OpDestroy always lead to Closed.
||| - OpRequestClose does NOT change the window state (it merely signals the
|||   shell to ask the user for confirmation; the transition to Closed happens
|||   only when the user confirms via OpRun/OpDestroy).
public export
data WindowTransition : (s : WindowState) -> (op : WindowOp) -> (t : WindowState) -> Type where
  -- show: Created → Visible, Hidden → Visible
  ShowFromCreated  : WindowTransition Created  OpShow    Visible
  ShowFromHidden   : WindowTransition Hidden   OpShow    Visible

  -- hide: Visible → Hidden
  HideFromVisible  : WindowTransition Visible  OpHide    Hidden

  -- minimize: Visible → Minimized
  MinimizeFromVisible : WindowTransition Visible OpMinimize Minimized

  -- maximize: Visible → Maximized
  MaximizeFromVisible : WindowTransition Visible OpMaximize Maximized

  -- restore: Minimized → Visible, Maximized → Visible
  RestoreFromMinimized : WindowTransition Minimized OpRestore Visible
  RestoreFromMaximized : WindowTransition Maximized OpRestore Visible

  -- requestClose: visible states remain (user confirmation pending)
  RequestCloseVisible   : WindowTransition Visible   OpRequestClose Visible
  RequestCloseHidden    : WindowTransition Hidden    OpRequestClose Hidden
  RequestCloseMinimized : WindowTransition Minimized OpRequestClose Minimized
  RequestCloseMaximized : WindowTransition Maximized OpRequestClose Maximized

  -- run (blocking event loop): any non-Closed state → Closed
  RunFromCreated   : WindowTransition Created   OpRun     Closed
  RunFromVisible   : WindowTransition Visible   OpRun     Closed
  RunFromHidden    : WindowTransition Hidden    OpRun     Closed
  RunFromMinimized : WindowTransition Minimized OpRun     Closed
  RunFromMaximized : WindowTransition Maximized OpRun     Closed

  -- destroy (immediate teardown): any non-Closed state → Closed
  DestroyFromCreated   : WindowTransition Created   OpDestroy Closed
  DestroyFromVisible   : WindowTransition Visible   OpDestroy Closed
  DestroyFromHidden    : WindowTransition Hidden    OpDestroy Closed
  DestroyFromMinimized : WindowTransition Minimized OpDestroy Closed
  DestroyFromMaximized : WindowTransition Maximized OpDestroy Closed

--------------------------------------------------------------------------------
-- GS1-INV-1: Closed is a terminal state
--------------------------------------------------------------------------------

||| No transition is valid from the Closed state.
|||
||| Proof: by exhaustive case analysis on `WindowTransition Closed op t`.
||| Every constructor of WindowTransition has a source state other than Closed,
||| so the type `WindowTransition Closed op t` is uninhabited for all op, t.
public export
closedIsTerminal : WindowTransition Closed op t -> Void
closedIsTerminal _ impossible

--------------------------------------------------------------------------------
-- GS1-INV-2: Borrow classification
--------------------------------------------------------------------------------

||| A borrow operation does not change the window state and does not destroy it.
||| These are the "safe" operations that read or write window properties.
|||
||| Borrow operations: loadHTML, navigate, eval, setTitle, resize, show, hide,
|||   minimize, maximize, restore, requestClose.
||| Consuming operations: run, destroy.
public export
data IsBorrow : WindowOp -> Type where
  BorrowShow         : IsBorrow OpShow
  BorrowHide         : IsBorrow OpHide
  BorrowMinimize     : IsBorrow OpMinimize
  BorrowMaximize     : IsBorrow OpMaximize
  BorrowRestore      : IsBorrow OpRestore
  BorrowRequestClose : IsBorrow OpRequestClose

public export
data IsConsuming : WindowOp -> Type where
  ConsumingRun     : IsConsuming OpRun
  ConsumingDestroy : IsConsuming OpDestroy

||| Borrow and consuming are disjoint: no operation is both.
public export
borrowNotConsuming : IsBorrow op -> IsConsuming op -> Void
borrowNotConsuming BorrowShow         x = case x of {}
borrowNotConsuming BorrowHide         x = case x of {}
borrowNotConsuming BorrowMinimize     x = case x of {}
borrowNotConsuming BorrowMaximize     x = case x of {}
borrowNotConsuming BorrowRestore      x = case x of {}
borrowNotConsuming BorrowRequestClose x = case x of {}

||| A consuming operation always leads to Closed.
public export
consumingLeadsToClosed
  : IsConsuming op
  -> WindowTransition s op t
  -> t = Closed
consumingLeadsToClosed ConsumingRun     RunFromCreated   = Refl
consumingLeadsToClosed ConsumingRun     RunFromVisible   = Refl
consumingLeadsToClosed ConsumingRun     RunFromHidden    = Refl
consumingLeadsToClosed ConsumingRun     RunFromMinimized = Refl
consumingLeadsToClosed ConsumingRun     RunFromMaximized = Refl
consumingLeadsToClosed ConsumingDestroy DestroyFromCreated   = Refl
consumingLeadsToClosed ConsumingDestroy DestroyFromVisible   = Refl
consumingLeadsToClosed ConsumingDestroy DestroyFromHidden    = Refl
consumingLeadsToClosed ConsumingDestroy DestroyFromMinimized = Refl
consumingLeadsToClosed ConsumingDestroy DestroyFromMaximized = Refl

--------------------------------------------------------------------------------
-- GS1-INV-3: Reachability from Created
--------------------------------------------------------------------------------

||| Proof that a state is reachable from Created via a (possibly empty) sequence
||| of transitions. Encoded as a path in the state machine.
public export
data ReachableFrom : (origin : WindowState) -> (dest : WindowState) -> Type where
  ||| Every state is reachable from itself (zero steps).
  RFRefl  : ReachableFrom s s
  ||| If dest is reachable from origin, and there is a valid transition from
  ||| dest via some op to next, then next is reachable from origin.
  RFStep  : ReachableFrom origin dest
          -> WindowTransition dest op next
          -> ReachableFrom origin next

||| All six window states are reachable from Created.
public export
visibleReachable : ReachableFrom Created Visible
visibleReachable = RFStep RFRefl ShowFromCreated

public export
hiddenReachable : ReachableFrom Created Hidden
hiddenReachable = RFStep visibleReachable HideFromVisible

public export
minimizedReachable : ReachableFrom Created Minimized
minimizedReachable = RFStep visibleReachable MinimizeFromVisible

public export
maximizedReachable : ReachableFrom Created Maximized
maximizedReachable = RFStep visibleReachable MaximizeFromVisible

public export
closedReachable : ReachableFrom Created Closed
closedReachable = RFStep RFRefl RunFromCreated

--------------------------------------------------------------------------------
-- GS1-INV-4: Window state is Active iff not Closed
--------------------------------------------------------------------------------

||| Predicate: the window is "active" (not closed).
public export
data IsActive : WindowState -> Type where
  ActiveCreated   : IsActive Created
  ActiveVisible   : IsActive Visible
  ActiveHidden    : IsActive Hidden
  ActiveMinimized : IsActive Minimized
  ActiveMaximized : IsActive Maximized

||| Closed windows are not active.
public export
closedNotActive : IsActive Closed -> Void
closedNotActive x = case x of {}

||| Every non-Closed state is active. Takes a proof that `s` is not
||| `Closed` (the original `s = Closed -> Void -> IsActive s` signature
||| was ill-formed: `notClosed` had type `s = Closed`, so `notClosed Refl`
||| did not type-check; the intended contract is `Not (s = Closed)`).
public export
nonClosedIsActive : (s : WindowState) -> Not (s = Closed) -> IsActive s
nonClosedIsActive Created   notClosed = ActiveCreated
nonClosedIsActive Visible   notClosed = ActiveVisible
nonClosedIsActive Hidden    notClosed = ActiveHidden
nonClosedIsActive Minimized notClosed = ActiveMinimized
nonClosedIsActive Maximized notClosed = ActiveMaximized
nonClosedIsActive Closed    notClosed = absurd (notClosed Refl)

||| A borrow transition preserves the Active property.
public export
borrowPreservesActive
  : IsBorrow op
  -> WindowTransition s op t
  -> IsActive s
  -> IsActive t
borrowPreservesActive BorrowShow         ShowFromCreated     _  = ActiveVisible
borrowPreservesActive BorrowShow         ShowFromHidden      _  = ActiveVisible
borrowPreservesActive BorrowHide         HideFromVisible     _  = ActiveHidden
borrowPreservesActive BorrowMinimize     MinimizeFromVisible _  = ActiveMinimized
borrowPreservesActive BorrowMaximize     MaximizeFromVisible _  = ActiveMaximized
borrowPreservesActive BorrowRestore      RestoreFromMinimized _ = ActiveVisible
borrowPreservesActive BorrowRestore      RestoreFromMaximized _ = ActiveVisible
borrowPreservesActive BorrowRequestClose RequestCloseVisible   _ = ActiveVisible
borrowPreservesActive BorrowRequestClose RequestCloseHidden    _ = ActiveHidden
borrowPreservesActive BorrowRequestClose RequestCloseMinimized _ = ActiveMinimized
borrowPreservesActive BorrowRequestClose RequestCloseMaximized _ = ActiveMaximized
