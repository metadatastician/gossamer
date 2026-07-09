-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unit tests for the Transmute state machine.
|||
||| Unlike GuardModeTest (which re-implements the Zig predicates), this suite
||| imports the REAL proof module Gossamer.ABI.TransmuteStateMachine: the
||| compile-time theorems (validSound/validComplete, guiHasNoBackup,
||| b1BugWitness, ...) are already discharged by `idris2 --typecheck`; this
||| suite guards the RUNTIME artifacts the Zig mirror is pinned to —
||| `validTransmute` (the Bool decision function) and the C-ABI mode
||| encoding — so a drifting edit fails a test, not just a proof re-read.
|||
||| Covers:
|||   - TransmuteMode ordinals (gui=0 .. panll_detach=5), distinct, contiguous
|||   - transmuteModeFromInt/toInt round-trip + out-of-range rejection
|||   - validTransmute: exactly 19 of 36 pairs legal; the exact legal set;
|||     the load-bearing rejections (attach->gui, detach->attach, tui->cli)
|||   - runtime reflections of everyModeHasExit and guiAlwaysRecoverable
|||   - compile-time auto-search witnesses for the transmuteFrom wrapper

module TransmuteTest

import Data.List
import Data.Maybe
import Gossamer.ABI.Types
import Gossamer.ABI.TransmuteStateMachine
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- Compile-time witnesses (typecheck = pass)
--------------------------------------------------------------------------------
--
-- Foreign.transmuteFrom takes `{auto 0 legal : TransmuteTransition from to}`;
-- these definitions prove auto-search resolves the witnesses users will need.

witGuiTui : TransmuteTransition TransmuteGui TransmuteTui
witGuiTui = %search

witAttachDetach : TransmuteTransition TransmutePanllAttach TransmutePanllDetach
witAttachDetach = %search

witDetachGui : TransmuteTransition TransmutePanllDetach TransmuteGui
witDetachGui = %search

witSelfLoop : TransmuteTransition TransmuteCli TransmuteCli
witSelfLoop = %search

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

allModes : List TransmuteMode
allModes = [ TransmuteGui, TransmuteTui, TransmuteCli
           , TransmuteTerminalExport, TransmutePanllAttach, TransmutePanllDetach ]

modeInts : List Bits32
modeInts = map transmuteModeToInt allModes

uniqueCount : Eq a => List a -> Nat
uniqueCount = length . nub

||| All ordered pairs the decision function accepts, as (from, to) ordinals.
legalPairs : List (Bits32, Bits32)
legalPairs =
  [ (transmuteModeToInt a, transmuteModeToInt b)
  | a <- allModes, b <- allModes, validTransmute a b ]

||| Whether `from` can reach gui within two validTransmute steps.
reachesGuiWithin2 : TransmuteMode -> Bool
reachesGuiWithin2 m =
     validTransmute m TransmuteGui
  || transmuteModeToInt m == 0
  || any (\mid => validTransmute m mid && validTransmute mid TransmuteGui) allModes

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · TransmuteTest"

public export
tests : List TestCase
tests =
  -- ---------- enum encoding ----------
  [ test "transmute/enum: ordinals are gui=0 tui=1 cli=2 export=3 attach=4 detach=5" $
      assertEq modeInts [0, 1, 2, 3, 4, 5]

  , test "transmute/enum: all six values are distinct" $
      assertEq (uniqueCount modeInts) 6

  , test "transmute/enum: fromInt inverts toInt for every mode" $
      allPass $
        map (\m => assertEq (map transmuteModeToInt (transmuteModeFromInt (transmuteModeToInt m)))
                            (Just (transmuteModeToInt m)))
            allModes

  , test "transmute/enum: fromInt rejects out-of-range ordinals" $
      allPass
        [ assertTrue "6 is rejected"          (isNothing (transmuteModeFromInt 6))
        , assertTrue "99 is rejected"         (isNothing (transmuteModeFromInt 99))
        , assertTrue "0xFFFFFFFF is rejected" (isNothing (transmuteModeFromInt 0xFFFFFFFF))
        ]

  -- ---------- the decision function (the Zig mirror's spec) ----------
  , test "transmute/relation: exactly 19 of 36 ordered pairs are legal" $
      assertEq (length legalPairs) 19

  , test "transmute/relation: the exact legal set matches the proof module" $
      assertEq legalPairs
        [ (0,0), (0,1), (0,2), (0,3), (0,4), (0,5)   -- gui: hub, all targets
        , (1,0), (1,1), (1,5)                        -- tui: gui / self / detach
        , (2,0), (2,2), (2,5)                        -- cli: gui / self / detach
        , (3,0), (3,3), (3,5)                        -- export: gui / self / detach
        , (4,4), (4,5)                               -- attach: self / detach ONLY
        , (5,0), (5,5)                               -- detach: gui / self
        ]

  , test "transmute/relation: attach cannot jump home without releasing (noAttachToGui)" $
      assertEq (validTransmute TransmutePanllAttach TransmuteGui) False

  , test "transmute/relation: detach cannot re-attach without normalizing (noDetachToAttach)" $
      assertEq (validTransmute TransmutePanllDetach TransmutePanllAttach) False

  , test "transmute/relation: transforms do not compose (noTuiToCli / noCliToTui)" $
      allPass
        [ assertEq (validTransmute TransmuteTui TransmuteCli) False
        , assertEq (validTransmute TransmuteCli TransmuteTui) False
        ]

  , test "transmute/relation: every source may request detach (detachAlwaysLegal)" $
      allPass $
        map (\m => assertTrue "any -> detach" (validTransmute m TransmutePanllDetach))
            allModes

  , test "transmute/relation: self-loops are all legal" $
      allPass $
        map (\m => assertTrue "m -> m" (validTransmute m m)) allModes

  -- ---------- runtime reflections of the liveness theorems ----------
  , test "transmute/liveness: every mode has an exit to a different mode (everyModeHasExit)" $
      allPass $
        map (\m => assertTrue "has exit"
                     (any (\m' => validTransmute m m'
                               && transmuteModeToInt m' /= transmuteModeToInt m)
                          allModes))
            allModes

  , test "transmute/liveness: gui is recoverable from every mode in <= 2 steps (guiAlwaysRecoverable)" $
      allPass $ map (\m => assertTrue "reaches gui" (reachesGuiWithin2 m)) allModes
  ]

||| Standalone runner — see ResultCodeTest.main for context.
main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
