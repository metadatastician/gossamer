-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Transmute State Machine Correctness Proof
|||
||| Proves that the Transmute feature ("the killer feature": a window switching
||| its rendering mode at runtime — Types.idr TransmuteMode) follows a
||| well-defined state machine, and that the gui-backup/restore discipline is
||| sound. The implementing mirror is `gossamer_transmute` in
||| src/interface/ffi/src/main.zig: its `validTransition` is written
||| arm-for-arm identical to `validTransmute` below (each cites the other —
||| the same mirroring convention as ForeignGen/the cleave gate), and the
||| runtime rejects any transition this relation does not license.
|||
||| The transition topology (19 of 36 ordered pairs are legal):
|||
|||        ┌────────────── tui ──────────────┐
|||        │                                 │
|||   gui ─┼─── cli ────────────────────────┐│
|||    ↑↓  │                                ↓↓
|||    │└──┼─── terminal_export ──────→ panll_detach
|||    │   │                                ↑
|||    │   └─── panll_attach ───────────────┘
|||    └──────────── (detach → gui only) ───┘
|||
|||   gui → {tui, cli, terminal_export, panll_attach, panll_detach}
|||   tui/cli/terminal_export → {gui, panll_detach}
|||   panll_attach → panll_detach            (must release the PanLL slot first)
|||   panll_detach → gui                     (normalize through gui)
|||   m → m for every m                      (accepted, effect-free no-op)
|||
||| Load-bearing rejections:
|||   * panll_attach → gui/tui/cli/export — attach holds an external PanLL
|||     panel slot; jumping straight to a local mode would strand it. The slot
|||     must be released via AttachToDetach first (the same acquire/release
|||     bracket discipline as HandleLinearity).
|||   * panll_detach → tui/cli/export/attach — detach is transient; forcing
|||     normalization through gui guarantees the DOM restore ran before any
|||     new transform starts.
|||   * tui ↔ cli, tui/cli → export, tui/cli/export → attach — every DOM
|||     transform assumes the pristine gui DOM as its source; composing
|||     transforms double-renders degraded content.
|||
||| Properties proved:
||| 1. `validSound` / `validComplete` — the Bool decision function used by the
|||    Zig runtime IS the transition relation (sound and complete).
||| 2. `everyModeHasExit` — no terminal trap: every mode has an outgoing
|||    transition to a different mode (dual of WindowStateMachine's
|||    closedIsTerminal — transmute deliberately has NO absorbing state).
||| 3. `guiAlwaysRecoverable` — strong liveness: gui is reachable from every
|||    mode (attach needs two steps: release the slot, then normalize).
||| 4. `guiHasNoBackup` — the backup/restore discipline is sound under the
|||    restore-on-EVERY-gui-entry policy: any legal path returning to gui has
|||    no live JS backup (no stuck rendering, no leaked backup).
||| 5. `b1BugWitness` — bug B1 stated as a theorem: under the OLD policy
|||    (restore only from tui/cli/terminal_export), a gui state WITH a live
|||    backup is reachable via gui→tui→panll_detach→gui — the window renders
|||    the stale TUI transform while reporting gui. The old guard was provably
|||    insufficient; the fix is provably sufficient.
||| 6. `toFromId` / `toIntInjective` — the C ABI encoding round-trips.
|||
||| This module lives in the SHELL package: it imports Gossamer.ABI.Types only
||| and treats the panll modes as opaque enum labels. The groove-protocol
||| semantics of attach/detach (capability handshake, groove handles) are
||| proved in the groove package (GrooveLinearity, GrooveResidue) — importing
||| them here would violate the #95 shell/groove decoupling.
|||
||| Zero believe_me. All proofs are constructive.

module Gossamer.ABI.TransmuteStateMachine

import Gossamer.ABI.Types

%default total

--------------------------------------------------------------------------------
-- Valid Transitions
--------------------------------------------------------------------------------

||| A proof that transmuting from mode `s` to mode `t` is legal. Each
||| constructor witnesses one legal edge; `SelfLoop` covers the six
||| effect-free identity edges (the runtime early-returns `.ok` before any
||| JS/groove effects, so re-requesting the current mode can never
||| double-render).
public export
data TransmuteTransition : (s : TransmuteMode) -> (t : TransmuteMode) -> Type where
  ||| m → m: accepted, effect-free no-op (runtime early-return).
  SelfLoop : (m : TransmuteMode) -> TransmuteTransition m m

  -- gui is the hub: every mode is directly enterable from the pristine DOM.
  GuiToTui    : TransmuteTransition TransmuteGui TransmuteTui
  GuiToCli    : TransmuteTransition TransmuteGui TransmuteCli
  GuiToExport : TransmuteTransition TransmuteGui TransmuteTerminalExport
  GuiToAttach : TransmuteTransition TransmuteGui TransmutePanllAttach
  GuiToDetach : TransmuteTransition TransmuteGui TransmutePanllDetach

  -- The transformed terminal modes restore to gui, or bail to detach.
  TuiToGui    : TransmuteTransition TransmuteTui TransmuteGui
  TuiToDetach : TransmuteTransition TransmuteTui TransmutePanllDetach
  CliToGui    : TransmuteTransition TransmuteCli TransmuteGui
  CliToDetach : TransmuteTransition TransmuteCli TransmutePanllDetach

  -- terminal_export is a one-shot side effect: it never transforms the DOM
  -- or saves a backup (verified against the export JS in main.zig), so
  -- returning to gui is a pure flag reset.
  ExportToGui    : TransmuteTransition TransmuteTerminalExport TransmuteGui
  ExportToDetach : TransmuteTransition TransmuteTerminalExport TransmutePanllDetach

  ||| attach holds an external PanLL panel slot: its ONLY exit (besides the
  ||| self-loop) is to release the slot. This is the acquire/release bracket.
  AttachToDetach : TransmuteTransition TransmutePanllAttach TransmutePanllDetach

  ||| detach is transient: normalize through gui (which runs the restore).
  DetachToGui : TransmuteTransition TransmutePanllDetach TransmuteGui

--------------------------------------------------------------------------------
-- The Bool decision function (the Zig mirror)
--------------------------------------------------------------------------------

||| Decision function for the transition relation. This is the SPEC for
||| `validTransition` in src/interface/ffi/src/main.zig — keep the two
||| arm-for-arm identical (each clause group below names its Zig arm).
||| `validSound`/`validComplete` prove this function IS the relation.
public export
validTransmute : TransmuteMode -> TransmuteMode -> Bool
-- Zig: `if (old == new) return true;` — SelfLoop
validTransmute TransmuteGui            TransmuteGui            = True
validTransmute TransmuteTui            TransmuteTui            = True
validTransmute TransmuteCli            TransmuteCli            = True
validTransmute TransmuteTerminalExport TransmuteTerminalExport = True
validTransmute TransmutePanllAttach    TransmutePanllAttach    = True
validTransmute TransmutePanllDetach    TransmutePanllDetach    = True
-- Zig: `.gui => true` — GuiToTui/GuiToCli/GuiToExport/GuiToAttach/GuiToDetach
validTransmute TransmuteGui            _                       = True
-- Zig: `.tui, .cli, .terminal_export => new == .gui or new == .panll_detach`
validTransmute TransmuteTui            TransmuteGui            = True  -- TuiToGui
validTransmute TransmuteTui            TransmutePanllDetach    = True  -- TuiToDetach
validTransmute TransmuteCli            TransmuteGui            = True  -- CliToGui
validTransmute TransmuteCli            TransmutePanllDetach    = True  -- CliToDetach
validTransmute TransmuteTerminalExport TransmuteGui            = True  -- ExportToGui
validTransmute TransmuteTerminalExport TransmutePanllDetach    = True  -- ExportToDetach
-- Zig: `.panll_attach => new == .panll_detach` — AttachToDetach
validTransmute TransmutePanllAttach    TransmutePanllDetach    = True
-- Zig: `.panll_detach => new == .gui` — DetachToGui
validTransmute TransmutePanllDetach    TransmuteGui            = True
-- everything else is illegal (17 of the 36 ordered pairs)
validTransmute _ _ = False

||| Local absurdity helper for the illegal cases of validSound.
falseNotTrue : Not (False = True)
falseNotTrue Refl impossible

||| Soundness: if the decision function accepts, the transition is legal.
public export
validSound : (a, b : TransmuteMode) -> validTransmute a b = True -> TransmuteTransition a b
validSound TransmuteGui            TransmuteGui            _ = SelfLoop TransmuteGui
validSound TransmuteGui            TransmuteTui            _ = GuiToTui
validSound TransmuteGui            TransmuteCli            _ = GuiToCli
validSound TransmuteGui            TransmuteTerminalExport _ = GuiToExport
validSound TransmuteGui            TransmutePanllAttach    _ = GuiToAttach
validSound TransmuteGui            TransmutePanllDetach    _ = GuiToDetach
validSound TransmuteTui            TransmuteGui            _ = TuiToGui
validSound TransmuteTui            TransmuteTui            _ = SelfLoop TransmuteTui
validSound TransmuteTui            TransmuteCli            p = absurd (falseNotTrue p)
validSound TransmuteTui            TransmuteTerminalExport p = absurd (falseNotTrue p)
validSound TransmuteTui            TransmutePanllAttach    p = absurd (falseNotTrue p)
validSound TransmuteTui            TransmutePanllDetach    _ = TuiToDetach
validSound TransmuteCli            TransmuteGui            _ = CliToGui
validSound TransmuteCli            TransmuteTui            p = absurd (falseNotTrue p)
validSound TransmuteCli            TransmuteCli            _ = SelfLoop TransmuteCli
validSound TransmuteCli            TransmuteTerminalExport p = absurd (falseNotTrue p)
validSound TransmuteCli            TransmutePanllAttach    p = absurd (falseNotTrue p)
validSound TransmuteCli            TransmutePanllDetach    _ = CliToDetach
validSound TransmuteTerminalExport TransmuteGui            _ = ExportToGui
validSound TransmuteTerminalExport TransmuteTui            p = absurd (falseNotTrue p)
validSound TransmuteTerminalExport TransmuteCli            p = absurd (falseNotTrue p)
validSound TransmuteTerminalExport TransmuteTerminalExport _ = SelfLoop TransmuteTerminalExport
validSound TransmuteTerminalExport TransmutePanllAttach    p = absurd (falseNotTrue p)
validSound TransmuteTerminalExport TransmutePanllDetach    _ = ExportToDetach
validSound TransmutePanllAttach    TransmuteGui            p = absurd (falseNotTrue p)
validSound TransmutePanllAttach    TransmuteTui            p = absurd (falseNotTrue p)
validSound TransmutePanllAttach    TransmuteCli            p = absurd (falseNotTrue p)
validSound TransmutePanllAttach    TransmuteTerminalExport p = absurd (falseNotTrue p)
validSound TransmutePanllAttach    TransmutePanllAttach    _ = SelfLoop TransmutePanllAttach
validSound TransmutePanllAttach    TransmutePanllDetach    _ = AttachToDetach
validSound TransmutePanllDetach    TransmuteGui            _ = DetachToGui
validSound TransmutePanllDetach    TransmuteTui            p = absurd (falseNotTrue p)
validSound TransmutePanllDetach    TransmuteCli            p = absurd (falseNotTrue p)
validSound TransmutePanllDetach    TransmuteTerminalExport p = absurd (falseNotTrue p)
validSound TransmutePanllDetach    TransmutePanllAttach    p = absurd (falseNotTrue p)
validSound TransmutePanllDetach    TransmutePanllDetach    _ = SelfLoop TransmutePanllDetach

||| Completeness: every legal transition is accepted by the decision function.
public export
validComplete : TransmuteTransition a b -> validTransmute a b = True
validComplete (SelfLoop TransmuteGui)            = Refl
validComplete (SelfLoop TransmuteTui)            = Refl
validComplete (SelfLoop TransmuteCli)            = Refl
validComplete (SelfLoop TransmuteTerminalExport) = Refl
validComplete (SelfLoop TransmutePanllAttach)    = Refl
validComplete (SelfLoop TransmutePanllDetach)    = Refl
validComplete GuiToTui       = Refl
validComplete GuiToCli       = Refl
validComplete GuiToExport    = Refl
validComplete GuiToAttach    = Refl
validComplete GuiToDetach    = Refl
validComplete TuiToGui       = Refl
validComplete TuiToDetach    = Refl
validComplete CliToGui       = Refl
validComplete CliToDetach    = Refl
validComplete ExportToGui    = Refl
validComplete ExportToDetach = Refl
validComplete AttachToDetach = Refl
validComplete DetachToGui    = Refl

--------------------------------------------------------------------------------
-- Illegality lemmas (the load-bearing rejections, machine-checked)
--------------------------------------------------------------------------------

||| A transform cannot be applied on top of another transform.
public export
noTuiToCli : TransmuteTransition TransmuteTui TransmuteCli -> Void
noTuiToCli _ impossible

public export
noCliToTui : TransmuteTransition TransmuteCli TransmuteTui -> Void
noCliToTui _ impossible

||| attach cannot jump straight home — the PanLL slot must be released first.
public export
noAttachToGui : TransmuteTransition TransmutePanllAttach TransmuteGui -> Void
noAttachToGui _ impossible

public export
noAttachToTui : TransmuteTransition TransmutePanllAttach TransmuteTui -> Void
noAttachToTui _ impossible

||| detach cannot re-attach without normalizing through gui first.
public export
noDetachToAttach : TransmuteTransition TransmutePanllDetach TransmutePanllAttach -> Void
noDetachToAttach _ impossible

||| A transformed window cannot attach to PanLL (attach assumes pristine DOM).
public export
noTuiToAttach : TransmuteTransition TransmuteTui TransmutePanllAttach -> Void
noTuiToAttach _ impossible

||| Besides its self-loop, attach's only exit is to release the slot.
public export
attachExitsOnlyDetach : TransmuteTransition TransmutePanllAttach m
                     -> Either (m = TransmutePanllAttach) (m = TransmutePanllDetach)
attachExitsOnlyDetach (SelfLoop TransmutePanllAttach) = Left Refl
attachExitsOnlyDetach AttachToDetach                  = Right Refl

--------------------------------------------------------------------------------
-- No terminal trap
--------------------------------------------------------------------------------

||| Every mode can always request detach ("any → panll_detach" in the doc
||| table; the detach case itself is the effect-free self-loop).
public export
detachAlwaysLegal : (m : TransmuteMode) -> TransmuteTransition m TransmutePanllDetach
detachAlwaysLegal TransmuteGui            = GuiToDetach
detachAlwaysLegal TransmuteTui            = TuiToDetach
detachAlwaysLegal TransmuteCli            = CliToDetach
detachAlwaysLegal TransmuteTerminalExport = ExportToDetach
detachAlwaysLegal TransmutePanllAttach    = AttachToDetach
detachAlwaysLegal TransmutePanllDetach    = SelfLoop TransmutePanllDetach

guiNotTui : Not (TransmuteTui = TransmuteGui)
guiNotTui Refl impossible

tuiNotGui : Not (TransmuteGui = TransmuteTui)
tuiNotGui Refl impossible

cliNotGui : Not (TransmuteGui = TransmuteCli)
cliNotGui Refl impossible

exportNotGui : Not (TransmuteGui = TransmuteTerminalExport)
exportNotGui Refl impossible

detachNotAttach : Not (TransmutePanllDetach = TransmutePanllAttach)
detachNotAttach Refl impossible

guiNotDetach : Not (TransmuteGui = TransmutePanllDetach)
guiNotDetach Refl impossible

||| No terminal trap: every mode has an outgoing transition to a DIFFERENT
||| mode. This is the deliberate dual of WindowStateMachine.closedIsTerminal —
||| the transmute machine has no absorbing state, so a window can never get
||| stuck in a rendering mode.
public export
everyModeHasExit : (m : TransmuteMode)
                -> (m' : TransmuteMode ** (TransmuteTransition m m', Not (m' = m)))
everyModeHasExit TransmuteGui            = (TransmuteTui         ** (GuiToTui,       guiNotTui))
everyModeHasExit TransmuteTui            = (TransmuteGui         ** (TuiToGui,       tuiNotGui))
everyModeHasExit TransmuteCli            = (TransmuteGui         ** (CliToGui,       cliNotGui))
everyModeHasExit TransmuteTerminalExport = (TransmuteGui         ** (ExportToGui,    exportNotGui))
everyModeHasExit TransmutePanllAttach    = (TransmutePanllDetach ** (AttachToDetach, detachNotAttach))
everyModeHasExit TransmutePanllDetach    = (TransmuteGui         ** (DetachToGui,    guiNotDetach))

--------------------------------------------------------------------------------
-- Reachability
--------------------------------------------------------------------------------

||| A (possibly empty) legal path through the transmute machine.
public export
data ReachableFrom : (origin : TransmuteMode) -> (dest : TransmuteMode) -> Type where
  RFRefl : ReachableFrom m m
  RFStep : ReachableFrom origin dest
        -> TransmuteTransition dest next
        -> ReachableFrom origin next

||| All five non-gui modes are reachable from the gui hub in one step.
public export
tuiReachable : ReachableFrom TransmuteGui TransmuteTui
tuiReachable = RFStep RFRefl GuiToTui

public export
cliReachable : ReachableFrom TransmuteGui TransmuteCli
cliReachable = RFStep RFRefl GuiToCli

public export
exportReachable : ReachableFrom TransmuteGui TransmuteTerminalExport
exportReachable = RFStep RFRefl GuiToExport

public export
attachReachable : ReachableFrom TransmuteGui TransmutePanllAttach
attachReachable = RFStep RFRefl GuiToAttach

public export
detachReachable : ReachableFrom TransmuteGui TransmutePanllDetach
detachReachable = RFStep RFRefl GuiToDetach

||| Strong liveness: gui is recoverable from EVERY mode. The attach case is
||| the two-step bracket: release the PanLL slot, then normalize.
public export
guiAlwaysRecoverable : (m : TransmuteMode) -> ReachableFrom m TransmuteGui
guiAlwaysRecoverable TransmuteGui            = RFRefl
guiAlwaysRecoverable TransmuteTui            = RFStep RFRefl TuiToGui
guiAlwaysRecoverable TransmuteCli            = RFStep RFRefl CliToGui
guiAlwaysRecoverable TransmuteTerminalExport = RFStep RFRefl ExportToGui
guiAlwaysRecoverable TransmutePanllAttach    = RFStep (RFStep RFRefl AttachToDetach) DetachToGui
guiAlwaysRecoverable TransmutePanllDetach    = RFStep RFRefl DetachToGui

||| The full attach/detach bracket returns home: gui → attach → detach → gui.
public export
attachDetachRoundTrip : ReachableFrom TransmuteGui TransmuteGui
attachDetachRoundTrip = RFStep (RFStep (RFStep RFRefl GuiToAttach) AttachToDetach) DetachToGui

||| Transmute is a BORROW in the window state machine: no transition consumes
||| the window (contrast run/destroy in WindowStateMachine). Formally: from
||| the target of any legal transition, gui remains reachable — a transmuted
||| window is never trapped.
public export
transmutePreservesRecoverable : {b : TransmuteMode} -> TransmuteTransition a b
                             -> ReachableFrom b TransmuteGui
transmutePreservesRecoverable _ = guiAlwaysRecoverable b

--------------------------------------------------------------------------------
-- Backup/restore soundness (bug B1 as a theorem)
--------------------------------------------------------------------------------
--
-- The tui/cli transforms save the original DOM in the JS global
-- `window.__gossamer_gui_backup` (set-if-unset), and entering gui runs a
-- restore that clears it. The question B1 exposed: on WHICH gui entries must
-- the restore run? The old runtime restored only when coming directly from
-- tui/cli/terminal_export — but `tui → panll_detach → gui` is a legal path
-- that carries a live backup into gui via detach, leaving the window stuck
-- rendering the TUI transform while reporting gui.
--
-- We model the backup as one bit threaded along legal paths, parameterized
-- by the restore POLICY (which source modes trigger the restore on gui
-- entry), and prove: the fixed policy (restore always) makes "in gui with a
-- live backup" unreachable, while the old policy provably reaches it.

||| Restore policy: given the mode we are LEAVING, does entering gui run the
||| backup restore?
public export
RestorePolicy : Type
RestorePolicy = TransmuteMode -> Bool

||| The FIXED policy (post-B1): the restore JS runs on every gui entry.
||| (Sound because the JS itself is a no-op when no backup is set.)
public export
restoreAlways : RestorePolicy
restoreAlways _ = True

||| The OLD policy (the B1 bug): restore only from the three terminal modes.
public export
restoreOldGuard : RestorePolicy
restoreOldGuard TransmuteTui            = True
restoreOldGuard TransmuteCli            = True
restoreOldGuard TransmuteTerminalExport = True
restoreOldGuard _                       = False

||| The backup bit after one legal transition `from → to`, under policy `p`.
||| Mirrors the runtime effects: self-loops are effect-free (early return);
||| entering tui/cli saves the backup; entering gui restores iff the policy
||| says so; export/attach/detach never touch it.
public export
bitAfter : RestorePolicy -> (from, to : TransmuteMode) -> (before : Bool) -> Bool
-- self-loops: effect-free
bitAfter p TransmuteGui            TransmuteGui            b = b
bitAfter p TransmuteTui            TransmuteTui            b = b
bitAfter p TransmuteCli            TransmuteCli            b = b
bitAfter p TransmuteTerminalExport TransmuteTerminalExport b = b
bitAfter p TransmutePanllAttach    TransmutePanllAttach    b = b
bitAfter p TransmutePanllDetach    TransmutePanllDetach    b = b
-- entering tui/cli saves the backup (set-if-unset → live regardless)
bitAfter p from TransmuteTui b = True
bitAfter p from TransmuteCli b = True
-- entering gui restores iff the policy triggers for the source mode
bitAfter p from TransmuteGui b = if p from then False else b
-- export/attach/detach never touch the backup
bitAfter p from to b = b

||| Mode × backup-bit state.
public export
data BState : Type where
  MkBState : TransmuteMode -> Bool -> BState

||| Legal paths through the (mode, backup) machine under policy `p`: each
||| step is a legal TransmuteTransition, with the bit updated by `bitAfter`.
public export
data BReach : (p : RestorePolicy) -> BState -> BState -> Type where
  BRefl : BReach p s s
  BStep : BReach p (MkBState m0 b0) (MkBState m1 b1)
       -> TransmuteTransition m1 m2
       -> BReach p (MkBState m0 b0) (MkBState m2 (bitAfter p m1 m2 b1))

||| SOUNDNESS of the fix: under restore-on-every-gui-entry, every legal path
||| from a clean gui start that ends in gui ends with NO live backup. The
||| window can never be stuck rendering a stale transform while reporting
||| gui, and the backup global cannot leak across a gui state.
public export
guiHasNoBackup : BReach TransmuteStateMachine.restoreAlways
                        (MkBState TransmuteGui False)
                        (MkBState TransmuteGui b)
              -> b = False
guiHasNoBackup BRefl = Refl
guiHasNoBackup (BStep path (SelfLoop TransmuteGui)) = guiHasNoBackup path
guiHasNoBackup (BStep path TuiToGui)    = Refl
guiHasNoBackup (BStep path CliToGui)    = Refl
guiHasNoBackup (BStep path ExportToGui) = Refl
guiHasNoBackup (BStep path DetachToGui) = Refl

||| Bug B1, stated as a theorem: under the OLD restore guard, gui-with-a-live-
||| backup IS reachable — the concrete witness is gui → tui → panll_detach →
||| gui (the restore never fires because detach is not in the old guard's
||| source set). This is the machine-checked justification for dropping the
||| source-mode condition on the restore.
public export
b1BugWitness : BReach TransmuteStateMachine.restoreOldGuard
                      (MkBState TransmuteGui False)
                      (MkBState TransmuteGui True)
b1BugWitness = BStep (BStep (BStep BRefl GuiToTui) TuiToDetach) DetachToGui

--------------------------------------------------------------------------------
-- C ABI encoding round-trip
--------------------------------------------------------------------------------

justInj : Just x = Just y -> x = y
justInj Refl = Refl

||| Decoding inverts encoding for every mode.
public export
toFromId : (m : TransmuteMode) -> transmuteModeFromInt (transmuteModeToInt m) = Just m
toFromId TransmuteGui            = Refl
toFromId TransmuteTui            = Refl
toFromId TransmuteCli            = Refl
toFromId TransmuteTerminalExport = Refl
toFromId TransmutePanllAttach    = Refl
toFromId TransmutePanllDetach    = Refl

||| The C encoding is injective: distinct modes never share an ordinal, so
||| the Bits32 crossing the FFI boundary identifies the mode uniquely.
public export
toIntInjective : (a, b : TransmuteMode)
              -> transmuteModeToInt a = transmuteModeToInt b
              -> a = b
toIntInjective a b prf =
  justInj (trans (trans (sym (toFromId a)) (cong transmuteModeFromInt prf)) (toFromId b))
