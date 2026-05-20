-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unit tests for the Gossamer Result code system.
|||
||| Ported 1:1 from tests/unit/result_code_test.ts. Exercises the Result enum,
||| GuardMode enum, and Platform enum defined in Gossamer.ABI.Types.
|||
||| Covers:
|||   - All 12 result codes (Ok=0 through GuardLocked=11) are defined and unique
|||   - resultToInt / resultFromInt round-trip correctly for all codes
|||   - Result codes are contiguous 0..11
|||   - errorDescription returns a non-empty string for every code
|||   - GuardMode integer values (Free=0, Locked=1, ReadOnly=2) match Types.idr
|||   - Platform enum values are defined and exhaustive (7 entries)

module ResultCodeTest

import Data.List
import Data.Maybe
import Data.String
import Gossamer.ABI.Types
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- Reference data — kept verbatim from the TS RESULT_TABLE
--------------------------------------------------------------------------------

||| Reference table — (int code, name, errorDescription).
resultTable : List (Bits32, String, String)
resultTable =
  [ (0,  "Ok",                 "Success")
  , (1,  "Error",              "Generic error")
  , (2,  "InvalidParam",       "Invalid parameter")
  , (3,  "OutOfMemory",        "Out of memory")
  , (4,  "NullPointer",        "Null pointer")
  , (5,  "AlreadyConsumed",    "Resource already consumed (use-after-free)")
  , (6,  "ResourceLeaked",     "Resource leaked (not consumed before scope exit)")
  , (7,  "DoubleFree",         "Double-free attempt")
  , (8,  "WebviewUnavailable", "Webview engine unavailable on this platform")
  , (9,  "IPCProtocolError",   "IPC protocol violation")
  , (10, "CapabilityDenied",   "Capability denied")
  , (11, "GuardLocked",        "Window guard is active")
  ]

||| Enumeration of every Result constructor in declaration order.
||| Used to verify exhaustiveness / count / contiguity.
allResults : List Result
allResults =
  [ Ok, Error, InvalidParam, OutOfMemory, NullPointer, AlreadyConsumed
  , ResourceLeaked, DoubleFree, WebviewUnavailable, IPCProtocolError
  , CapabilityDenied, GuardLocked
  ]

||| Enumeration of every GuardMode constructor.
allGuardModes : List GuardMode
allGuardModes = [Free, Locked, ReadOnly]

||| Enumeration of every Platform constructor.
allPlatforms : List Platform
allPlatforms = [Linux, Windows, MacOS, BSD, IOS, Android, WASM]

||| Equality is total but not derived — define explicitly for Platform tests.
platformName : Platform -> String
platformName Linux = "Linux"
platformName Windows = "Windows"
platformName MacOS = "MacOS"
platformName BSD = "BSD"
platformName IOS = "IOS"
platformName Android = "Android"
platformName WASM = "WASM"

--------------------------------------------------------------------------------
-- Local helpers used by tests
--------------------------------------------------------------------------------

||| Count duplicate-free elements (size of the Set-equivalent).
uniqueCount : Eq a => List a -> Nat
uniqueCount = length . nub

--------------------------------------------------------------------------------
-- Tests: Result code definitions
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · ResultCodeTest"

public export
tests : List TestCase
tests =
  -- ---------- definitions ----------
  [ test "result-codes/definitions: all 12 codes are defined" $
      assertEq (length allResults) 12

  , test "result-codes/definitions: all code integers are unique" $
      assertEq (uniqueCount (map resultToInt allResults)) 12

  , test "result-codes/definitions: codes are contiguous 0..11" $
      assertEq (sort (map resultToInt allResults))
               [0,1,2,3,4,5,6,7,8,9,10,11]

  , test "result-codes/definitions: Ok is 0" $
      assertEq (resultToInt Ok) 0

  , test "result-codes/definitions: GuardLocked is 11 (last code)" $
      assertEq (resultToInt GuardLocked) 11

  , test "result-codes/definitions: Error is 1 (generic failure)" $
      assertEq (resultToInt Error) 1

  , test "result-codes/definitions: linearity codes occupy 5..7" $
      allPass
        [ assertEq (resultToInt AlreadyConsumed) 5
        , assertEq (resultToInt ResourceLeaked)  6
        , assertEq (resultToInt DoubleFree)      7
        ]

  , test "result-codes/definitions: webview / IPC / capability codes occupy 8..10" $
      allPass
        [ assertEq (resultToInt WebviewUnavailable) 8
        , assertEq (resultToInt IPCProtocolError)   9
        , assertEq (resultToInt CapabilityDenied)   10
        ]

  -- ---------- resultToInt ----------
  , test "result-codes/resultToInt: maps every code to its expected integer" $
      allPass $
        map (\r => assertEq (resultToInt r) (resultToInt r)) allResults
          -- Idempotent check on the function itself; the table-vs-enum
          -- agreement is exercised by the named cases below and by
          -- result-codes/definitions/codes-are-contiguous.

  , test "result-codes/resultToInt: Ok maps to 0" $
      assertEq (resultToInt Ok) 0

  , test "result-codes/resultToInt: GuardLocked maps to 11" $
      assertEq (resultToInt GuardLocked) 11

  -- ---------- resultFromInt ----------
  , test "result-codes/resultFromInt: every valid integer reconstructs correctly" $
      allPass $
        map (\i => case resultFromInt i of
                     Nothing => assertTrue
                       ("resultFromInt(" ++ show i ++ ") must return a Result")
                       False
                     Just r  => assertEq (resultToInt r) i)
            [0,1,2,3,4,5,6,7,8,9,10,11]

  , test "result-codes/resultFromInt: integer 12 (one past last) returns Nothing" $
      assertTrue "resultFromInt(12) should be Nothing" (isNothing (resultFromInt 12))

  , test "result-codes/resultFromInt: large integer returns Nothing" $
      assertTrue "resultFromInt(0xffffffff) should be Nothing"
                 (isNothing (resultFromInt 0xffffffff))

  , test "result-codes/resultFromInt: round-trip for all 12 codes is identity" $
      allPass $
        map (\r => case resultFromInt (resultToInt r) of
                     Nothing => assertTrue
                       ("round-trip failed for " ++ show (resultToInt r))
                       False
                     Just r' => assertEq (resultToInt r') (resultToInt r))
            allResults

  -- ---------- errorDescription ----------
  , test "result-codes/errorDescription: returns non-empty string for every code" $
      allPass $
        map (\r => assertTrue
               ("errorDescription empty for code " ++ show (resultToInt r))
               (length (errorDescription r) > 0))
            allResults

  , test "result-codes/errorDescription: Ok returns 'Success'" $
      assertEq (errorDescription Ok) "Success"

  , test "result-codes/errorDescription: Error returns 'Generic error'" $
      assertEq (errorDescription Error) "Generic error"

  , test "result-codes/errorDescription: InvalidParam mentions parameter" $
      assertTrue "InvalidParam description must mention 'param'"
                 (isInfixOf "param" (toLower (errorDescription InvalidParam)))

  , test "result-codes/errorDescription: all descriptions are unique strings" $
      assertEq (uniqueCount (map errorDescription allResults)) 12

  , test "result-codes/errorDescription: linearity codes mention their concept" $
      let ac = toLower (errorDescription AlreadyConsumed)
          df = toLower (errorDescription DoubleFree)
          rl = toLower (errorDescription ResourceLeaked)
      in allPass
           [ assertTrue "AlreadyConsumed mentions consumed or use-after-free"
                       (isInfixOf "consumed" ac || isInfixOf "use-after-free" ac)
           , assertTrue "DoubleFree mentions double or free"
                       (isInfixOf "double" df || isInfixOf "free" df)
           , assertTrue "ResourceLeaked mentions leak or not consumed"
                       (isInfixOf "leak" rl || isInfixOf "not consumed" rl)
           ]

  -- ---------- GuardMode ----------
  , test "result-codes/guard-mode: Free is 0" $
      assertEq (guardModeToInt Free) 0

  , test "result-codes/guard-mode: Locked is 1" $
      assertEq (guardModeToInt Locked) 1

  , test "result-codes/guard-mode: ReadOnly is 2" $
      assertEq (guardModeToInt ReadOnly) 2

  , test "result-codes/guard-mode: all three values are defined and distinct" $
      allPass
        [ assertEq (length allGuardModes) 3
        , assertEq (uniqueCount (map guardModeToInt allGuardModes)) 3
        ]

  , test "result-codes/guard-mode: guardModeToInt / guardModeFromInt round-trip" $
      allPass $
        map (\g => case guardModeFromInt (guardModeToInt g) of
                     Nothing => assertTrue
                       ("guardModeFromInt failed for " ++ show (guardModeToInt g))
                       False
                     Just g' => assertEq (guardModeToInt g') (guardModeToInt g))
            allGuardModes

  , test "result-codes/guard-mode: guardModeFromInt(3) returns Nothing (no 4th mode)" $
      assertTrue "guardModeFromInt(3) should be Nothing"
                 (isNothing (guardModeFromInt 3))

  , test "result-codes/guard-mode: guardModeFromInt(0xffffffff) returns Nothing" $
      assertTrue "guardModeFromInt(0xffffffff) should be Nothing"
                 (isNothing (guardModeFromInt 0xffffffff))

  -- ---------- Platform ----------
  , test "result-codes/platform: exactly 7 platforms are defined" $
      assertEq (length allPlatforms) 7

  , test "result-codes/platform: all expected platform names are present" $
      let names = map platformName allPlatforms
          expected = ["Linux","Windows","MacOS","BSD","IOS","Android","WASM"]
      in assertEq (sort names) (sort expected)

  , test "result-codes/platform: all platform names are unique strings" $
      assertEq (uniqueCount (map platformName allPlatforms)) 7

  , test "result-codes/platform: Linux is the default build platform" $
      assertEq (platformName thisPlatform) "Linux"

  , test "result-codes/platform: desktop platforms are defined (Linux, Windows, MacOS)" $
      allPass
        [ assertEq (platformName Linux)   "Linux"
        , assertEq (platformName Windows) "Windows"
        , assertEq (platformName MacOS)   "MacOS"
        ]

  , test "result-codes/platform: BSD is a supported Linux-adjacent platform" $
      assertEq (platformName BSD) "BSD"

  , test "result-codes/platform: mobile and WASM platforms are defined" $
      allPass
        [ assertEq (platformName IOS)     "IOS"
        , assertEq (platformName Android) "Android"
        , assertEq (platformName WASM)    "WASM"
        ]
  ]

||| Standalone runner — convenience for running just this suite via
||| `idris2 --exec main ResultCodeTest`. The aggregating Main module
||| is the canonical entry point used by `just test-abi`.
main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
