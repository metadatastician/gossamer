-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Estate Mathematics ABI Test Suite
|||
||| Exercises the executable and proof-backed definitions from:
|||   * Gossamer.ABI.ResourceAlgebra    (resource-algebra, occupancy-types, tropical-types)
|||   * Gossamer.ABI.NullOps            (echo-types, absolute-zero CNO & OND)
|||   * Gossamer.ABI.EpistemicTransport (epistemic-types, secret-types, residual-evidence-types)
|||   * Gossamer.ABI.ReversibleFS       (januskey, typed-wasm ResourceCapabilities)

module EstateMathTest

import Data.List
import Data.Maybe
import Test.Spec
import Gossamer.ABI.Types
import Gossamer.ABI.WindowStateMachine
import Gossamer.ABI.ResourceAlgebra
import Gossamer.ABI.NullOps
import Gossamer.ABI.EpistemicTransport
import Gossamer.ABI.ReversibleFS

%default total

public export
suiteName : String
suiteName = "Gossamer ABI · EstateMathTest"

public export
tests : List TestCase
tests =
  [ -- 1. ResourceAlgebra: LossGrade (min-plus tropical semiring)
    test "estate/algebra: LossGrade sequential composition adds finite loss" $
      assertEq (otimes (Finite 3) (Finite 4)) (Finite 7)

  , test "estate/algebra: LossGrade Infinity absorbs any finite grade" $
      allPass
        [ assertEq (otimes Infinity (Finite 5)) Infinity
        , assertEq (otimes (Finite 5) Infinity) Infinity
        ]

  , test "estate/algebra: LossGrade parallel choice selects less lossy branch" $
      assertEq (oplus (Finite 2) (Finite 9)) (Finite 2)

    -- 2. ResourceAlgebra: MaxPlusGrade (critical-path latency) & ActivityLevel
  , test "estate/algebra: MaxPlusGrade critical path takes max on choice and sum on seq" $
      let seqPath = otimes (Val 4) (Val 12)
          altPath = oplus (Val 8) (Val 16)
      in allPass
           [ assertEq seqPath (Val 16)
           , assertEq altPath (Val 16)
           ]

  , test "estate/algebra: ActivityLevel frame budgets increase monotonically with activity" $
      allPass
        [ assertEq (activityBudget Paused)   (Val 0)
        , assertEq (activityBudget Low)      (Val 1)
        , assertEq (activityBudget Mid)      (Val 15)
        , assertEq (activityBudget High)     (Val 30)
        , assertEq (activityBudget Realtime) (Val 60)
        ]

    -- 3. ResourceAlgebra: HWMGrade (occupancy-types reclaim law & cut factor)
  , test "estate/algebra: HWMGrade reclaim law prevents peak additivity" $
      let step1 = MkHWM 4 0 LTEZero   -- allocate 4, release 4 (drift 0)
          step2 = MkHWM 5 0 LTEZero   -- allocate 5, release 5 (drift 0)
          seq12 = hwmSeq step1 step2
      in allPass
           [ assertEq seq12.peak  5
           , assertEq seq12.drift 0
           ]

  , test "estate/algebra: HWMGrade timelineGrade factors across cuts" $
      let xs = [MkHWM 2 0 LTEZero]
          ys = [MkHWM 3 0 LTEZero]
      in assertEq (timelineGrade (xs ++ ys)) (otimes (timelineGrade xs) (timelineGrade ys))

    -- 4. NullOps: CNO guard enforcement & revocation ring protection
  , test "estate/nullops: Locked and ReadOnly GuardMode operations are CNOs" $
      let mutate : WindowState -> WindowState
          mutate _ = Minimized
      in allPass
           [ assertEq (evalGuardedWindowOp Locked   mutate Visible) Visible
           , assertEq (evalGuardedWindowOp ReadOnly mutate Focused) Focused
           , assertEq (evalGuardedWindowOp Free     mutate Visible) Minimized
           ]

  , test "estate/nullops: safeRevokeCap is a CNO on inactive or already-revoked tokens" $
      let st0 = MkCapRevState [10, 20] [5]
          st1 = safeRevokeCap 99 st0   -- unknown token -> CNO
          st2 = safeRevokeCap 5  st0   -- already revoked -> CNO
          st3 = safeRevokeCap 10 st0   -- active token -> revoked
      in allPass
           [ assertEq ( length st1.revokedRing ) 1
           , assertEq ( length st2.revokedRing ) 1
           , assertEq ( length st3.revokedRing ) 2
           , assertEq ( length st3.activeTokens ) 1
           ]

  , test "estate/nullops: ctCapCheck satisfies constant-time OND across secrets" $
      assertEq (obsAll (runOp ctCapCheck 0 42) == obsAll (runOp ctCapCheck 999 42)) True

    -- 5. EpistemicTransport: ProofTransport & SecLabel Lattice
  , test "estate/epistemic: SecLabel lattice join computes least upper bound" $
      allPass
        [ assertEq (secJoin PublicLow PluginMid) PluginMid
        , assertEq (secJoin PluginMid HostHigh)  HostHigh
        , assertEq (secJoin PublicLow PublicLow) PublicLow
        ]

    -- 6. ReversibleFS: ValidPath & ReversiblePair
  , test "estate/reversible: validatePath rejects traversal and null bytes" $
      allPass
        [ assertEq (isJust (validatePath "/home/user/config.json")) True
        , assertEq (isJust (validatePath "../etc/passwd"))          False
        , assertEq (isJust (validatePath "/tmp/bad\0file"))         False
        , assertEq (isJust (validatePath ""))                       False
        ]

  , test "estate/reversible: ReversiblePair wrap then unwrap has grade Finite 0 and restores state" $
      let pair : ReversiblePair Nat
          pair = MkReversiblePair (\n => n) (\n => n) (\_ => Refl)
          trace = [wrapStep pair, unwrapStep pair]
      in allPass
           [ assertEq (traceGrade trace) (Finite 0)
           , assertEq (runTrace trace 42) 42
           ]
  ]
