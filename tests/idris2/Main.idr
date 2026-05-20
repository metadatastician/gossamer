-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Aggregating entry point for the Gossamer ABI test suite.
|||
||| Each individual test module (ResultCodeTest, GuardModeTest, …) exports its
||| `tests` and `suiteName`. This Main runs them all in sequence via
||| `runTestSuite`, sums the pass/fail counts, prints an overall summary,
||| and exits non-zero if anything failed.

module Main

import System
import Test.Spec

import ResultCodeTest
import GuardModeTest
import CapabilityTest
import IPCTest
import ContractsTest
import SecurityTest

-- `covering` rather than `total` because SecurityTest's HTML sanitiser
-- is partial (non-structurally-recursive) — the looseness travels up through
-- the suites list and main.
%default covering

||| All ABI test suites — append new ports here.
suites : List (String, List TestCase)
suites =
  [ (ResultCodeTest.suiteName, ResultCodeTest.tests)
  , (GuardModeTest.suiteName,  GuardModeTest.tests)
  , (CapabilityTest.suiteName, CapabilityTest.tests)
  , (IPCTest.suiteName,        IPCTest.tests)
  , (ContractsTest.suiteName,  ContractsTest.tests)
  , (SecurityTest.suiteName,   SecurityTest.tests)
  ]

runEach : List (String, List TestCase) -> Nat -> Nat -> IO (Nat, Nat)
runEach [] tp tf = pure (tp, tf)
runEach ((name, ts) :: rest) tp tf = do
  (p, f) <- runTestSuite name ts
  runEach rest (tp + p) (tf + f)

main : IO ()
main = do
  putStrLn "######## Gossamer ABI Test Suite ########"
  putStrLn ""
  (totalPass, totalFail) <- runEach suites 0 0
  putStrLn "------------------------------------------"
  putStrLn $ "TOTAL: " ++ show totalPass ++ " passed, "
                       ++ show totalFail ++ " failed"
  if totalFail > 0
    then exitWith (ExitFailure 1)
    else pure ()
