-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
||| Minimal Idris2 test harness for the Gossamer ABI test suite.
|||
||| Mirrors the Deno.test interface used by the previous TypeScript suite:
||| each test is a named IO action returning Bool (True = pass, False = fail).
||| The runner reports per-test status and exits non-zero on any failure so
||| Justfile / CI can detect breakage.

module Test.Spec

import Data.IORef
import Data.List
import System

%default total

public export
record TestCase where
  constructor MkTest
  name : String
  body : IO Bool

public export
test : String -> IO Bool -> TestCase
test = MkTest

||| Assert that two showable, comparable values are equal.
||| Prints expected/actual on mismatch.
public export
assertEq : (Show a, Eq a) => a -> a -> IO Bool
assertEq actual expected =
  if actual == expected
    then pure True
    else do
      putStrLn ""
      putStrLn $ "  expected: " ++ show expected
      putStrLn $ "  actual:   " ++ show actual
      pure False

||| Assert that two values are not equal.
public export
assertNotEq : (Show a, Eq a) => a -> a -> IO Bool
assertNotEq actual notExpected =
  if actual /= notExpected
    then pure True
    else do
      putStrLn ""
      putStrLn $ "  did not expect: " ++ show notExpected
      pure False

||| Assert that a Bool is True; print the supplied message on failure.
public export
assertTrue : String -> Bool -> IO Bool
assertTrue msg b =
  if b
    then pure True
    else do
      putStrLn ""
      putStrLn $ "  assertion failed: " ++ msg
      pure False

||| Combine a list of sub-assertions; all must pass.
||| Use in a do-block to compose multiple checks in one test case.
public export
allPass : List (IO Bool) -> IO Bool
allPass [] = pure True
allPass (x :: xs) = do
  r <- x
  if r then allPass xs else pure False

runOne : TestCase -> IO Bool
runOne (MkTest name body) = do
  putStr $ "  " ++ name ++ " ... "
  result <- body
  if result
    then putStrLn "PASS"
    else putStrLn "FAIL"
  pure result

runAll : List TestCase -> Nat -> Nat -> IO (Nat, Nat)
runAll [] p f = pure (p, f)
runAll (t :: ts) p f = do
  ok <- runOne t
  if ok
    then runAll ts (S p) f
    else runAll ts p (S f)

||| Run a list of test cases. Reports a summary and exits non-zero
||| if any test failed. Use for single-suite executables.
public export
runTests : List TestCase -> IO ()
runTests cases = do
  (p, f) <- runAll cases 0 0
  putStrLn ""
  putStrLn $ show p ++ " passed, " ++ show f ++ " failed"
  if f > 0
    then exitWith (ExitFailure 1)
    else pure ()

||| Run a named suite without exiting. Returns (passed, failed) so a parent
||| aggregator (e.g. Main) can accumulate across multiple suites and only
||| exit at the end.
public export
runTestSuite : String -> List TestCase -> IO (Nat, Nat)
runTestSuite name cases = do
  putStrLn $ "=== " ++ name ++ " ==="
  (p, f) <- runAll cases 0 0
  putStrLn $ show p ++ " passed, " ++ show f ++ " failed"
  putStrLn ""
  pure (p, f)
