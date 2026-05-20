-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unit tests for the Gossamer capability system.
|||
||| Ported 1:1 from tests/unit/capability_test.ts. Models the capability
||| registry mirroring Capabilities.eph (grant / check / revoke / resource
||| kind mapping). Tokens are Bits64; revocation flips a per-token flag;
||| check is borrowing (idempotent).

module CapabilityTest

import Data.IORef
import Data.List
import Data.SortedMap
import Data.String
import Gossamer.ABI.Types
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- Resource kind ordinals — mirror Capabilities.eph RESOURCE_* constants
--------------------------------------------------------------------------------

ResourceKindOrd : Type
ResourceKindOrd = Bits32

rkFilesystem, rkNetwork, rkShell, rkClipboard, rkNotification, rkTray, rkGroove
  : ResourceKindOrd
rkFilesystem   = 0
rkNetwork      = 1
rkShell        = 2
rkClipboard    = 3
rkNotification = 4
rkTray         = 5
rkGroove       = 6

allResourceKinds : List ResourceKindOrd
allResourceKinds =
  [rkFilesystem, rkNetwork, rkShell, rkClipboard, rkNotification, rkTray, rkGroove]

resultOk, resultCapabilityDenied : Bits32
resultOk               = resultToInt Ok
resultCapabilityDenied = resultToInt CapabilityDenied

--------------------------------------------------------------------------------
-- In-memory capability registry — mirrors ffi/zig gossamer_cap_* functions
--------------------------------------------------------------------------------

||| Per-token entry: (resource kind ordinal, revoked flag).
TokenEntry : Type
TokenEntry = (Bits32, Bool)

record CapabilityRegistry where
  constructor MkRegistry
  nextTokenRef : IORef Bits64
  tokensRef    : IORef (SortedMap Bits64 TokenEntry)

newRegistry : IO CapabilityRegistry
newRegistry = do
  n <- newIORef 1
  t <- newIORef empty
  pure (MkRegistry n t)

||| Grant a capability token for the given resource kind ordinal.
||| Returns a non-zero token (linear — must be revoked) or 0 on failure.
grant : CapabilityRegistry -> ResourceKindOrd -> IO Bits64
grant reg kind =
  if kind > 6
    then pure 0
    else do
      token <- readIORef reg.nextTokenRef
      writeIORef reg.nextTokenRef (token + 1)
      modifyIORef reg.tokensRef (insert token (kind, False))
      pure token

||| Check a capability token. Returns Ok if active, CapabilityDenied otherwise.
||| Borrows the token — does NOT consume it.
check : CapabilityRegistry -> Bits64 -> IO Bits32
check reg token = do
  tokens <- readIORef reg.tokensRef
  case lookup token tokens of
    Nothing            => pure resultCapabilityDenied
    Just (_, True)     => pure resultCapabilityDenied  -- revoked
    Just (_, False)    => pure resultOk

||| Query the resource kind ordinal for a token. Returns 0xFFFFFFFF if unknown.
resourceKind : CapabilityRegistry -> Bits64 -> IO Bits32
resourceKind reg token = do
  tokens <- readIORef reg.tokensRef
  case lookup token tokens of
    Nothing       => pure 0xffffffff
    Just (k, _)   => pure k

||| Revoke a capability token. CONSUMES it — future checks fail.
||| Double-revoke is safe (idempotent).
revoke : CapabilityRegistry -> Bits64 -> IO ()
revoke reg token = do
  tokens <- readIORef reg.tokensRef
  case lookup token tokens of
    Nothing       => pure ()
    Just (k, _)   => writeIORef reg.tokensRef (insert token (k, True) tokens)

||| Count active (non-revoked) tokens.
activeCount : CapabilityRegistry -> IO Nat
activeCount reg = do
  tokens <- readIORef reg.tokensRef
  let pairs = SortedMap.toList tokens
  pure $ List.length $ List.filter (\(_, _, revoked) => not revoked)
                                    (map (\(t, k, r) => (t, k, r))
                                         (map (\(t, (k, r)) => (t, k, r)) pairs))

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · CapabilityTest"

public export
tests : List TestCase
tests =
  -- ---------- grant ----------
  [ test "capability/grant: returns non-zero token for valid resource kinds" $ do
      reg <- newRegistry
      tokens <- traverse (\k => grant reg k) allResourceKinds
      assertTrue "every grant returns non-zero token"
                 (all (/= 0) tokens)

  , test "capability/grant: each grant returns a unique token" $ do
      reg <- newRegistry
      tokens <- traverse (\_ => grant reg rkFilesystem) [0 .. 99]
      assertEq (length (nub tokens)) 100

  , test "capability/grant: returns 0 for invalid resource kind" $ do
      reg <- newRegistry
      token <- grant reg 99
      assertEq token 0

  , test "capability/grant: multiple grants for same resource are independent" $ do
      reg <- newRegistry
      t1 <- grant reg rkShell
      t2 <- grant reg rkShell
      revoke reg t1
      c1 <- check reg t1
      c2 <- check reg t2
      allPass
        [ assertNotEq t1 t2
        , assertEq c1 resultCapabilityDenied
        , assertEq c2 resultOk
        ]

  -- ---------- check ----------
  , test "capability/check: active token returns Ok" $ do
      reg <- newRegistry
      token <- grant reg rkFilesystem
      r <- check reg token
      assertEq r resultOk

  , test "capability/check: revoked token returns CapabilityDenied" $ do
      reg <- newRegistry
      token <- grant reg rkNetwork
      revoke reg token
      r <- check reg token
      assertEq r resultCapabilityDenied

  , test "capability/check: forged token returns CapabilityDenied" $ do
      reg <- newRegistry
      r <- check reg 9999
      assertEq r resultCapabilityDenied

  , test "capability/check: null token (0) returns CapabilityDenied" $ do
      reg <- newRegistry
      r <- check reg 0
      assertEq r resultCapabilityDenied

  , test "capability/check: borrow does not consume — check is idempotent" $ do
      reg <- newRegistry
      token <- grant reg rkClipboard
      results <- traverse (\_ => check reg token) [0 .. 9]
      assertTrue "every check returns Ok"
                 (all (== resultOk) results)

  -- ---------- revoke ----------
  , test "capability/revoke: revoked token fails subsequent check" $ do
      reg <- newRegistry
      token <- grant reg rkTray
      before <- check reg token
      revoke reg token
      after <- check reg token
      allPass
        [ assertEq before resultOk
        , assertEq after resultCapabilityDenied
        ]

  , test "capability/revoke: double revoke is safe (idempotent)" $ do
      reg <- newRegistry
      token <- grant reg rkNotification
      revoke reg token
      revoke reg token  -- must not throw
      r <- check reg token
      assertEq r resultCapabilityDenied

  , test "capability/revoke: revoking one token does not affect others" $ do
      reg <- newRegistry
      fs <- grant reg rkFilesystem
      net <- grant reg rkNetwork
      sh <- grant reg rkShell
      revoke reg net
      fsResult <- check reg fs
      netResult <- check reg net
      shResult <- check reg sh
      allPass
        [ assertEq fsResult resultOk
        , assertEq netResult resultCapabilityDenied
        , assertEq shResult resultOk
        ]

  , test "capability/revoke: all tokens revoked leaves zero active" $ do
      reg <- newRegistry
      tokens <- traverse (\k => grant reg k) allResourceKinds
      traverse_ (revoke reg) tokens
      n <- activeCount reg
      assertEq n 0

  -- ---------- resourceKind ----------
  , test "capability/resourceKind: returns correct kind for granted token" $ do
      reg <- newRegistry
      pairs <- traverse (\k => do t <- grant reg k; pure (k, t)) allResourceKinds
      results <- traverse (\(k, t) => do r <- resourceKind reg t; pure (r, k)) pairs
      assertTrue "every token resolves to its granted kind"
                 (all (\(r, k) => r == k) results)

  , test "capability/resourceKind: returns 0xFFFFFFFF for unknown token" $ do
      reg <- newRegistry
      r <- resourceKind reg 99999
      assertEq r 0xffffffff

  -- ---------- lifecycle ----------
  , test "capability/lifecycle: grant→check→revoke full cycle" $ do
      reg <- newRegistry
      c0 <- activeCount reg
      token <- grant reg rkGroove
      c1 <- activeCount reg
      r1 <- check reg token
      revoke reg token
      c2 <- activeCount reg
      r2 <- check reg token
      allPass
        [ assertEq c0 0
        , assertEq c1 1
        , assertEq r1 resultOk
        , assertEq c2 0
        , assertEq r2 resultCapabilityDenied
        ]

  , test "capability/lifecycle: capabilities are strictly additive — grant cannot remove" $ do
      reg <- newRegistry
      t1 <- grant reg rkFilesystem
      t2 <- grant reg rkFilesystem
      r1 <- check reg t1
      r2 <- check reg t2
      cnt <- activeCount reg
      allPass
        [ assertEq r1 resultOk
        , assertEq r2 resultOk
        , assertEq cnt 2
        ]
  ]

main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
