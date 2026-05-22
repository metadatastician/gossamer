-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unit tests for the Gossamer window guard mode system.
|||
||| Ported 1:1 from tests/unit/guard_mode_test.ts. Mirrors the Zig FFI guard
||| logic from src/interface/ffi/src/main.zig — the helpers here are an
||| Idris2 re-implementation of the same predicates, so this file checks
||| that the *specification* (as encoded in tests) is consistent with the
||| Types.idr declarations.
|||
||| Covers:
|||   - GuardMode enum values (Free=0, Locked=1, ReadOnly=2)
|||   - requireOpen() behaviour for uninitialised and closed handles
|||   - requireUnguarded() behaviour for non-free guard modes
|||   - Window constraint validation (min > max fails, 0 = unconstrained)
|||   - Async IPC slot management: acquire, release, all-occupied

module GuardModeTest

import Data.IORef
import Data.List
import Data.Maybe
import Data.Vect
import Gossamer.ABI.Types
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- Local copy of Result variants used by the guard checks
--------------------------------------------------------------------------------
--
-- We compare against the raw integer codes rather than the Result constructors
-- to side-step the absence of a Show Result instance in Types.idr.

resultOk, resultError, resultAlreadyConsumed, resultGuardLocked : Bits32
resultOk              = resultToInt Ok
resultError           = resultToInt Error
resultAlreadyConsumed = resultToInt AlreadyConsumed
resultGuardLocked     = resultToInt GuardLocked

--------------------------------------------------------------------------------
-- Simulated window handle — mirrors GossamerHandle in main.zig
--------------------------------------------------------------------------------

record HandleState where
  constructor MkHandle
  initialized : Bool
  closed      : Bool
  guard       : GuardMode

||| Idris2 mirror of Zig fn requireOpen(handle: *GossamerHandle).
||| Returns Just <result code> on error, Nothing if the handle is open.
requireOpen : HandleState -> Maybe Bits32
requireOpen h =
  if not h.initialized then Just resultError
  else if h.closed     then Just resultAlreadyConsumed
  else                      Nothing

||| Idris2 mirror of Zig fn requireUnguarded(handle: *GossamerHandle).
||| Returns Just GuardLocked when guard != Free, Nothing otherwise.
requireUnguarded : HandleState -> Maybe Bits32
requireUnguarded h =
  case h.guard of
    Free => Nothing
    _    => Just resultGuardLocked

||| Idris2 mirror of Zig fn validateWindowConstraints.
||| Returns False when a non-zero min exceeds a non-zero max (same axis).
||| 0 is the unconstrained sentinel on either side.
validateWindowConstraints : Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bool
validateWindowConstraints minW minH maxW maxH =
  let widthBad  = minW /= 0 && maxW /= 0 && minW > maxW
      heightBad = minH /= 0 && maxH /= 0 && minH > maxH
  in not (widthBad || heightBad)

--------------------------------------------------------------------------------
-- Async IPC slot registry — mirrors pub const async_ipc in main.zig
--------------------------------------------------------------------------------

MAX_INFLIGHT_ASYNC : Nat
MAX_INFLIGHT_ASYNC = 256

record AsyncIPCSlots where
  constructor MkSlots
  slotsRef : IORef (Vect 256 Bool)
  countRef : IORef Nat

newSlots : IO AsyncIPCSlots
newSlots = do
  s <- newIORef (replicate 256 False)
  c <- newIORef Z
  pure (MkSlots s c)

||| Acquire the first free slot. Returns Just <index 0..255>, or Nothing when full.
acquireSlot : AsyncIPCSlots -> IO (Maybe Nat)
acquireSlot slots = do
  current <- readIORef slots.slotsRef
  case findIndex (== False) current of
    Nothing  => pure Nothing
    Just fin => do
      writeIORef slots.slotsRef (replaceAt fin True current)
      modifyIORef slots.countRef S
      pure (Just (finToNat fin))

||| Release a previously acquired slot. Out-of-range indices are a no-op.
releaseSlot : AsyncIPCSlots -> Nat -> IO ()
releaseSlot slots n =
  case natToFin n 256 of
    Nothing  => pure ()
    Just fin => do
      current <- readIORef slots.slotsRef
      if index fin current
        then do
          writeIORef slots.slotsRef (replaceAt fin False current)
          modifyIORef slots.countRef (\x => case x of
                                              Z   => Z
                                              S k => k)
        else pure ()

inflightCount : AsyncIPCSlots -> IO Nat
inflightCount slots = readIORef slots.countRef

resetSlots : AsyncIPCSlots -> IO ()
resetSlots slots = do
  writeIORef slots.slotsRef (replicate 256 False)
  writeIORef slots.countRef Z

--------------------------------------------------------------------------------
-- Helpers used by tests
--------------------------------------------------------------------------------

allGuardModes : List GuardMode
allGuardModes = [Free, Locked, ReadOnly]

guardModeInts : List Bits32
guardModeInts = map guardModeToInt allGuardModes

uniqueCount : Eq a => List a -> Nat
uniqueCount = length . nub

--------------------------------------------------------------------------------
-- Tests: GuardMode enum values
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · GuardModeTest"

public export
tests : List TestCase
tests =
  -- ---------- enum ----------
  [ test "guard-mode/enum: Free is 0" $
      assertEq (guardModeToInt Free) 0

  , test "guard-mode/enum: Locked is 1" $
      assertEq (guardModeToInt Locked) 1

  , test "guard-mode/enum: ReadOnly is 2" $
      assertEq (guardModeToInt ReadOnly) 2

  , test "guard-mode/enum: all three values are distinct" $
      assertEq (uniqueCount guardModeInts) 3

  , test "guard-mode/enum: values are contiguous 0..2" $
      assertEq (sort guardModeInts) [0, 1, 2]

  -- ---------- requireOpen ----------
  , test "guard-mode/requireOpen: open initialised handle returns Nothing (no error)" $
      assertTrue "open handle should be Nothing"
                 (isNothing (requireOpen (MkHandle True False Free)))

  , test "guard-mode/requireOpen: uninitialised handle returns Error" $
      assertEq (requireOpen (MkHandle False False Free)) (Just resultError)

  , test "guard-mode/requireOpen: closed handle returns AlreadyConsumed" $
      assertEq (requireOpen (MkHandle True True Free)) (Just resultAlreadyConsumed)

  , test "guard-mode/requireOpen: uninitialised AND closed returns Error (initialised check first)" $
      assertEq (requireOpen (MkHandle False True Free)) (Just resultError)

  , test "guard-mode/requireOpen: guard mode does not affect open check" $
      allPass $
        map (\g => assertTrue
                     ("requireOpen should be Nothing for guard=" ++ show (guardModeToInt g))
                     (isNothing (requireOpen (MkHandle True False g))))
            allGuardModes

  -- ---------- requireUnguarded ----------
  , test "guard-mode/requireUnguarded: Free guard returns Nothing (operation allowed)" $
      assertTrue "Free guard should be Nothing"
                 (isNothing (requireUnguarded (MkHandle True False Free)))

  , test "guard-mode/requireUnguarded: Locked guard returns GuardLocked" $
      assertEq (requireUnguarded (MkHandle True False Locked))
               (Just resultGuardLocked)

  , test "guard-mode/requireUnguarded: ReadOnly guard returns GuardLocked" $
      assertEq (requireUnguarded (MkHandle True False ReadOnly))
               (Just resultGuardLocked)

  , test "guard-mode/requireUnguarded: non-Free modes are exhaustively rejected" $
      allPass
        [ assertEq (requireUnguarded (MkHandle True False Locked))
                   (Just resultGuardLocked)
        , assertEq (requireUnguarded (MkHandle True False ReadOnly))
                   (Just resultGuardLocked)
        ]

  , test "guard-mode/requireUnguarded: transitioning from Locked to Free unblocks operations" $
      allPass
        [ assertEq (requireUnguarded (MkHandle True False Locked))
                   (Just resultGuardLocked)
        , assertTrue "Free should be Nothing after unlock"
                     (isNothing (requireUnguarded (MkHandle True False Free)))
        ]

  , test "guard-mode/requireUnguarded: ReadOnly is strictly more restrictive than Locked" $
      allPass
        [ assertEq (requireUnguarded (MkHandle True False Locked))
                   (Just resultGuardLocked)
        , assertEq (requireUnguarded (MkHandle True False ReadOnly))
                   (Just resultGuardLocked)
        , assertNotEq (guardModeToInt ReadOnly) (guardModeToInt Locked)
        ]

  -- ---------- window constraints ----------
  , test "guard-mode/constraints: valid unconstrained config (all zeros) passes" $
      assertEq (validateWindowConstraints 0 0 0 0) True

  , test "guard-mode/constraints: valid min < max passes" $
      assertEq (validateWindowConstraints 200 150 800 600) True

  , test "guard-mode/constraints: min == max passes (exact size)" $
      assertEq (validateWindowConstraints 800 600 800 600) True

  , test "guard-mode/constraints: min_width > max_width fails" $
      assertEq (validateWindowConstraints 900 0 800 0) False

  , test "guard-mode/constraints: min_height > max_height fails" $
      assertEq (validateWindowConstraints 0 700 0 600) False

  , test "guard-mode/constraints: both axes invalid fails" $
      assertEq (validateWindowConstraints 900 700 800 600) False

  , test "guard-mode/constraints: min_width > max_width but max_width=0 is unconstrained (passes)" $
      assertEq (validateWindowConstraints 9999 0 0 0) True

  , test "guard-mode/constraints: min_height > max_height but max_height=0 is unconstrained (passes)" $
      assertEq (validateWindowConstraints 0 9999 0 0) True

  , test "guard-mode/constraints: min_width=0 with any max_width passes (min unconstrained)" $
      assertEq (validateWindowConstraints 0 0 100 0) True

  , test "guard-mode/constraints: mixed — one axis valid, other invalid fails" $
      allPass
        [ assertEq (validateWindowConstraints 200 700 800 600) False -- height fails
        , assertEq (validateWindowConstraints 900 100 800 600) False -- width fails
        ]

  -- ---------- async IPC slots ----------
  , test "guard-mode/ipc-slots: first acquireSlot returns index 0" $ do
      slots <- newSlots
      idx <- acquireSlot slots
      assertEq idx (Just 0)

  , test "guard-mode/ipc-slots: acquireSlot returns sequential indices" $ do
      slots <- newSlots
      results <- traverse (\_ => acquireSlot slots) [0..9]
      assertEq results (map Just [0,1,2,3,4,5,6,7,8,9])

  , test "guard-mode/ipc-slots: acquireSlot returns index in range 0..255" $ do
      slots <- newSlots
      idx <- acquireSlot slots
      case idx of
        Nothing => assertTrue "acquireSlot should not be Nothing initially" False
        Just n  => assertTrue ("index " ++ show n ++ " in range") (n <= 255)

  , test "guard-mode/ipc-slots: releaseSlot frees a slot for reuse" $ do
      slots <- newSlots
      Just idx <- acquireSlot slots
        | Nothing => assertTrue "initial acquire should succeed" False
      releaseSlot slots idx
      idx2 <- acquireSlot slots
      assertEq idx2 (Just idx)

  , test "guard-mode/ipc-slots: inflightCount tracks acquisitions" $ do
      slots <- newSlots
      c0 <- inflightCount slots
      _ <- acquireSlot slots
      c1 <- inflightCount slots
      _ <- acquireSlot slots
      c2 <- inflightCount slots
      allPass [ assertEq c0 0, assertEq c1 1, assertEq c2 2 ]

  , test "guard-mode/ipc-slots: inflightCount decrements on release" $ do
      slots <- newSlots
      Just idx <- acquireSlot slots
        | Nothing => assertTrue "acquire should succeed" False
      c1 <- inflightCount slots
      releaseSlot slots idx
      c2 <- inflightCount slots
      allPass [ assertEq c1 1, assertEq c2 0 ]

  , test "guard-mode/ipc-slots: all 256 slots can be acquired" $ do
      slots <- newSlots
      results <- traverse (\_ => acquireSlot slots) [0 .. 255]
      cnt <- inflightCount slots
      allPass
        [ assertTrue "all 256 acquires succeeded" (all isJust results)
        , assertEq cnt 256
        ]

  , test "guard-mode/ipc-slots: acquireSlot returns Nothing when all slots occupied" $ do
      slots <- newSlots
      _ <- traverse (\_ => acquireSlot slots) [0 .. 255]
      next <- acquireSlot slots
      assertTrue "all-occupied must return Nothing" (isNothing next)

  , test "guard-mode/ipc-slots: releasing one slot from full allows another acquire" $ do
      slots <- newSlots
      _ <- traverse (\_ => acquireSlot slots) [0 .. 255]
      whenFull <- acquireSlot slots
      releaseSlot slots 42
      reacquired <- acquireSlot slots
      allPass
        [ assertTrue "full: no slot available" (isNothing whenFull)
        , assertEq reacquired (Just 42)
        ]

  , test "guard-mode/ipc-slots: reset frees all slots" $ do
      slots <- newSlots
      _ <- traverse (\_ => acquireSlot slots) [0 .. 255]
      countBefore <- inflightCount slots
      resetSlots slots
      countAfter <- inflightCount slots
      first <- acquireSlot slots
      allPass
        [ assertEq countBefore 256
        , assertEq countAfter 0
        , assertEq first (Just 0)
        ]

  , test "guard-mode/ipc-slots: acquired slot indices are unique" $ do
      slots <- newSlots
      results <- traverse (\_ => acquireSlot slots) [0 .. 255]
      let indices = mapMaybe id results
      allPass
        [ assertEq (length indices) 256
        , assertEq (uniqueCount indices) 256
        ]

  , test "guard-mode/ipc-slots: releaseSlot on invalid index is a no-op" $ do
      slots <- newSlots
      _ <- acquireSlot slots
      c1 <- inflightCount slots
      releaseSlot slots 9999
      c2 <- inflightCount slots
      allPass [ assertEq c1 1, assertEq c2 1 ]
  ]

||| Standalone runner — see ResultCodeTest.main for context.
main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
