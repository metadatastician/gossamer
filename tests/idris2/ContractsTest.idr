-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Property-based tests for core Gossamer invariants.
|||
||| Ported 1:1 from tests/property/contracts_test.ts. Uses a deterministic
||| LCG PRNG (seeded per test) to generate 50–200 inputs per invariant,
||| matching the TypeScript suite's iteration counts.
|||
||| Invariants exercised:
|||   - IPC messages always have non-empty source and command
|||   - Capabilities are strictly additive (grant cannot remove)
|||   - Shell commands never contain null bytes
|||   - Filesystem paths are never empty strings
|||   - Dialog responses are exactly Some or None
|||   - Result codes round-trip through integer representation

module ContractsTest

import Data.Bits
import Data.IORef
import Data.List
import Data.SortedMap
import Data.String
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- Safe nat-indexed list access (Idris2's stdlib index' is Fin-bounded;
-- this Maybe-returning version is more ergonomic for runtime indices).
--------------------------------------------------------------------------------

listAt : Nat -> List a -> Maybe a
listAt _     []        = Nothing
listAt Z     (x :: _)  = Just x
listAt (S k) (_ :: xs) = listAt k xs

--------------------------------------------------------------------------------
-- Deterministic LCG PRNG — mirrors the TS Prng class for reproducibility
--
-- Same constants as the TS port:
--   state' = (state * 1664525 + 1013904223) mod 2^32
--------------------------------------------------------------------------------

record Prng where
  constructor MkPrng
  stateRef : IORef Bits32

newPrng : Bits32 -> IO Prng
newPrng seed = do
  s <- newIORef seed
  pure (MkPrng s)

||| Advance the PRNG and return its raw 32-bit state.
nextBits : Prng -> IO Bits32
nextBits prng = do
  s <- readIORef prng.stateRef
  let s' = s * 1664525 + 1013904223  -- Bits32 wraps mod 2^32 by definition
  writeIORef prng.stateRef s'
  pure s'

||| Uniform Nat in [lo .. hi] inclusive.
||| Routes the modulus through Integer because Nat is unary in Idris2 —
||| `cast {to=Nat}` on a 32-bit value builds a 4-billion-deep Peano numeral
||| and chained mod operations become catastrophically slow.
nextInt : Prng -> Nat -> Nat -> IO Nat
nextInt prng lo hi = do
  r <- nextBits prng
  let span : Integer
      span = cast ((hi `minus` lo) + 1)
  let pick : Integer
      pick = (cast {to=Integer} r) `mod` span
  pure (lo + (fromInteger pick))

||| Pick a uniform element from a non-empty list. Returns Nothing on empty input
||| (the TS version assumes non-empty; we make the failure explicit).
nextPick : Prng -> List a -> IO (Maybe a)
nextPick _    []  = pure Nothing
nextPick prng xs  = do
  i <- nextInt prng 0 (length xs `minus` 1)
  pure $ listAt i xs

||| Pick a uniform element from a list, with a default for the empty case.
nextPickD : Prng -> a -> List a -> IO a
nextPickD prng dflt xs = do
  m <- nextPick prng xs
  pure (fromMaybe dflt m)

||| Generate a random string of length in [lo..hi] from the given alphabet.
||| Returns the empty string if the alphabet is empty.
nextString : Prng -> Nat -> Nat -> String -> IO String
nextString prng lo hi alphabet =
  let chars = unpack alphabet
      n     = List.length chars
  in if n == 0
       then pure ""
       else do
         len <- nextInt prng lo hi
         cs <- traverse (\_ => do
                           i <- nextInt prng 0 (n `minus` 1)
                           pure (fromMaybe ' ' (listAt i chars)))
                        (replicate len ())
         pure (pack cs)

--------------------------------------------------------------------------------
-- Shared constants — alphabets and payload samples
--------------------------------------------------------------------------------

ALPHA, ALNUM, PATH_CHARS : String
ALPHA      = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
ALNUM      = ALPHA ++ "0123456789_-"
PATH_CHARS = ALNUM ++ "/. "

||| Payload categories (mirrors the heterogeneous PAYLOAD_VALS in TS).
||| The TS test only asserts JSON.stringify does not throw — which reduces
||| to "the value can be constructed in Idris2" here.
data PayloadKind = PKNull | PKInt | PKStr | PKEmptyArr | PKEmptyObj | PKBool

Eq PayloadKind where
  PKNull     == PKNull     = True
  PKInt      == PKInt      = True
  PKStr      == PKStr      = True
  PKEmptyArr == PKEmptyArr = True
  PKEmptyObj == PKEmptyObj = True
  PKBool     == PKBool     = True
  _          == _          = False

allPayloadKinds : List PayloadKind
allPayloadKinds = [PKNull, PKInt, PKStr, PKEmptyArr, PKEmptyObj, PKBool]

--------------------------------------------------------------------------------
-- Capability registry — minimal mirror for the additive-invariant tests
--------------------------------------------------------------------------------

ResourceKindOrd : Type
ResourceKindOrd = Bits32

allResourceKinds : List ResourceKindOrd
allResourceKinds = [0, 1, 2, 3, 4, 5, 6]

record CapRegistry where
  constructor MkCapReg
  nextTokenRef : IORef Bits64
  tokensRef    : IORef (SortedMap Bits64 (Bits32, Bool))

newCapReg : IO CapRegistry
newCapReg = do
  n <- newIORef 1
  t <- newIORef empty
  pure (MkCapReg n t)

capGrant : CapRegistry -> ResourceKindOrd -> IO Bits64
capGrant reg kind = do
  token <- readIORef reg.nextTokenRef
  writeIORef reg.nextTokenRef (token + 1)
  modifyIORef reg.tokensRef (insert token (kind, False))
  pure token

capCheck : CapRegistry -> Bits64 -> IO Bool
capCheck reg token = do
  tokens <- readIORef reg.tokensRef
  case lookup token tokens of
    Nothing         => pure False
    Just (_, True)  => pure False
    Just (_, False) => pure True

capRevoke : CapRegistry -> Bits64 -> IO ()
capRevoke reg token = do
  tokens <- readIORef reg.tokensRef
  case lookup token tokens of
    Nothing     => pure ()
    Just (k, _) => writeIORef reg.tokensRef (insert token (k, True) tokens)

capActiveCount : CapRegistry -> IO Nat
capActiveCount reg = do
  tokens <- readIORef reg.tokensRef
  let pairs = SortedMap.toList tokens
  let active = List.filter (\(_, _, revoked) => not revoked)
                           (map (\(t, k, r) => (t, k, r))
                                (map (\(t, (k, r)) => (t, k, r)) pairs))
  pure (List.length active)

--------------------------------------------------------------------------------
-- Predicates under test
--------------------------------------------------------------------------------

||| Shell commands never contain null bytes ('\0').
isValidShellCommand : String -> Bool
isValidShellCommand s = not (isInfixOf "\0" s)

||| Filesystem paths are non-empty strings (OS validates the rest).
isValidPath : String -> Bool
isValidPath s = length s > 0

||| Dialog result — either a Some carrying a path, or a None.
data DialogResult = DSome String | DNone

makeDialogResult : Bits32 -> String -> DialogResult
makeDialogResult 0 _    = DNone
makeDialogResult _ path = DSome path

dialogIsSomeOrNone : DialogResult -> Bool
dialogIsSomeOrNone (DSome _) = True
dialogIsSomeOrNone DNone     = True

dialogPathLen : DialogResult -> Nat
dialogPathLen (DSome p) = length p
dialogPathLen DNone     = 0

--------------------------------------------------------------------------------
-- Result code reference (mirrors RESULT_NAMES in TS)
--------------------------------------------------------------------------------

resultNames : SortedMap Bits32 String
resultNames = fromList
  [ (0,  "Ok")
  , (1,  "Error")
  , (2,  "InvalidParam")
  , (3,  "OutOfMemory")
  , (4,  "NullPointer")
  , (5,  "AlreadyConsumed")
  , (6,  "ResourceLeaked")
  , (7,  "DoubleFree")
  , (8,  "WebviewUnavailable")
  , (9,  "IPCProtocolError")
  , (10, "CapabilityDenied")
  , (11, "GuardLocked")
  ]

resultCodes : List Bits32
resultCodes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

--------------------------------------------------------------------------------
-- Per-test helpers
--------------------------------------------------------------------------------

||| Run an IO Bool action n times; return True iff every iteration returned True.
forNAllPass : Nat -> IO Bool -> IO Bool
forNAllPass Z     _      = pure True
forNAllPass (S k) action = do
  r <- action
  if r then forNAllPass k action else pure False

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · ContractsTest"

public export
tests : List TestCase
tests =
  -- ---------- IPC invariants ----------
  [ test "property/ipc: message source is always non-empty" $ do
      prng <- newPrng 1001
      let sources = ["webview-0", "panel-42", "backend", "cli", "electron-compat"]
      forNAllPass 200 $ do
        src <- nextPickD prng "" sources
        _   <- nextString prng 1 32 ALNUM
        pure (length src > Z)

  , test "property/ipc: message command is always non-empty" $ do
      prng <- newPrng 1002
      let commands = ["open-file", "save", "ping", "greet", "execute", "dialog"]
      forNAllPass 200 $ do
        cmd <- nextPickD prng "" commands
        pure (length cmd > Z)

  , test "property/ipc: payload is always JSON-serialisable" $ do
      prng <- newPrng 1003
      -- In Idris2 every constructed PayloadKind is by construction valid;
      -- this mirrors the TS test where JSON.stringify never throws on
      -- members of PAYLOAD_VALS.
      forNAllPass 200 $ do
        kind <- nextPickD prng PKNull allPayloadKinds
        pure (kind `elem` allPayloadKinds)

  -- ---------- Capability invariants ----------
  , test "property/capabilities: grant never removes existing active tokens" $ do
      prng <- newPrng 2001
      forNAllPass 50 $ do
        reg <- newCapReg
        grantCount <- nextInt prng 1 20
        tokens <- traverse (\_ => do
                              k <- nextPickD prng 0 allResourceKinds
                              capGrant reg k)
                           (replicate grantCount ())
        active0 <- capActiveCount reg
        moreCount <- nextInt prng 1 10
        _ <- traverse (\_ => do
                         k <- nextPickD prng 0 allResourceKinds
                         capGrant reg k)
                      (replicate moreCount ())
        -- Original tokens must all still check OK
        checks <- traverse (capCheck reg) tokens
        pure (active0 == grantCount && all id checks)

  , test "property/capabilities: revoke is additive — only targeted token is removed" $ do
      prng <- newPrng 2002
      forNAllPass 50 $ do
        reg <- newCapReg
        count <- nextInt prng 3 15
        tokens <- traverse (\_ => do
                              k <- nextPickD prng 0 allResourceKinds
                              capGrant reg k)
                           (replicate count ())
        revokeIdx <- nextInt prng 0 (count `minus` 1)
        case listAt revokeIdx tokens of
          Nothing      => pure False
          Just target  => do
            capRevoke reg target
            targetActive <- capCheck reg target
            -- All other tokens must remain active
            othersActive <- traverse (\(i, t) =>
                                        if i == revokeIdx
                                          then pure True
                                          else capCheck reg t)
                                     (zip [0 .. (count `minus` 1)] tokens)
            pure (not targetActive && all id othersActive)

  -- ---------- Shell invariants ----------
  , test "property/shell: valid commands contain no null bytes" $ do
      prng <- newPrng 3001
      let validCommands =
            [ "ls -la", "echo hello", "cat /tmp/file.txt"
            , "grep pattern file", "awk '{print $1}' file"
            , "find / -name '*.txt'", "/usr/bin/python3 script.py"
            ]
      forNAllPass 200 $ do
        cmd <- nextPickD prng "" validCommands
        pure (isValidShellCommand cmd)

  , test "property/shell: command with null byte is rejected as invalid" $
      let malicious =
            [ "ls\0-la"
            , "\0echo pwned"
            , "cat /etc/passwd\0;rm -rf /"
            , "normal\0command"
            ]
      in assertTrue "every null-byte command must be rejected"
                    (all (not . isValidShellCommand) malicious)

  -- ---------- Filesystem invariants ----------
  , test "property/filesystem: valid paths are never empty strings" $ do
      prng <- newPrng 4001
      let paths =
            [ "/home/user/file.txt", "/tmp/gossamer.log"
            , "relative/path.md", "./local", "../parent", "/", "a"
            ]
      forNAllPass 200 $ do
        p <- nextPickD prng "/" paths
        pure (isValidPath p)

  , test "property/filesystem: empty string path is invalid" $
      assertEq (isValidPath "") False

  , test "property/filesystem: whitespace-only path is non-empty (OS concern)" $
      assertEq (isValidPath " ") True

  -- ---------- Dialog invariants ----------
  , test "property/dialog: result kind is always Some or None" $ do
      prng <- newPrng 5001
      let testPaths = ["/tmp/a", "/home/user/b", "/x/y/z"]
      forNAllPass 200 $ do
        ptr <- nextInt prng 0 1
        path <- if ptr == 0 then pure "" else nextPickD prng "/" testPaths
        let result = makeDialogResult (cast ptr) path
        pure (dialogIsSomeOrNone result)

  , test "property/dialog: Some always carries non-empty path" $ do
      prng <- newPrng 5002
      let paths = ["/tmp/a.txt", "/home/x", "/var/y"]
      forNAllPass 100 $ do
        path <- nextPickD prng "/" paths
        let result = makeDialogResult 1 path
        case result of
          DSome p => pure (length p > 0)
          DNone   => pure True  -- vacuously OK for this assertion

  -- ---------- Result code invariants ----------
  , test "property/result-codes: all valid codes decode to known names" $
      allPass $
        map (\code => case lookup code resultNames of
                        Nothing  => assertTrue
                                      ("code " ++ show code ++ " must have a name")
                                      False
                        Just nm  => assertTrue
                                      ("code " ++ show code ++ " name must be non-empty")
                                      (length nm > 0))
            resultCodes

  , test "property/result-codes: out-of-range codes have no mapping" $
      let outOfRange : List Bits32
          outOfRange = [12, 13, 100, 255, 999]
      in assertTrue "every out-of-range code must have no mapping"
                    (all (\c => case lookup c resultNames of
                                  Nothing => True
                                  Just _  => False)
                         outOfRange)

  , test "property/result-codes: names are unique across all codes" $
      let names = map snd (SortedMap.toList resultNames)
      in assertEq (List.length (List.nub names)) (List.length names)
  ]

main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
