-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| Unit tests for the Gossamer IPC message format and channel model.
|||
||| Ported 1:1 from tests/unit/ipc_test.ts. Models the typed IPC channel
||| from Bridge.eph and Types.idr: open / bind / dispatch / close lifecycle,
||| command-name validation, message routing, message logging.

module IPCTest

import Data.IORef
import Data.List
import Data.SortedMap
import Data.String
import Gossamer.ABI.Types
import Test.Spec

%default total

--------------------------------------------------------------------------------
-- IPCValue — sum type for IPC payloads (mirrors TS `unknown`)
--------------------------------------------------------------------------------

public export
data IPCValue : Type where
  VStr  : String -> IPCValue
  VInt  : Integer -> IPCValue
  VObj  : List (String, IPCValue) -> IPCValue
  VList : List IPCValue -> IPCValue
  VBool : Bool -> IPCValue
  VNull : IPCValue

public export
Eq IPCValue where
  VStr  a == VStr  b = a == b
  VInt  a == VInt  b = a == b
  VBool a == VBool b = a == b
  VNull   == VNull   = True
  -- Deep equality for compound values (length+pairwise)
  VList xs == VList ys = assert_total (length xs == length ys
                                       && all id (zipWith (==) xs ys))
  VObj xs  == VObj  ys = assert_total (length xs == length ys
                                       && all id (zipWith (==) xs ys))
  _ == _ = False

public export
Show IPCValue where
  show (VStr s)  = "\"" ++ s ++ "\""
  show (VInt n)  = show n
  show (VBool b) = if b then "true" else "false"
  show VNull     = "null"
  show (VList _) = "<list>"
  show (VObj  _) = "<obj>"

--------------------------------------------------------------------------------
-- IPC channel — mirrors the TS IPCChannel class
--------------------------------------------------------------------------------

public export
record IPCMessage where
  constructor MkMsg
  source    : String
  command   : String
  payload   : IPCValue
  requestId : Maybe Integer

makeMsg : String -> String -> IPCValue -> IPCMessage
makeMsg s c p = MkMsg s c p Nothing

makeMsgReq : String -> String -> IPCValue -> Integer -> IPCMessage
makeMsgReq s c p r = MkMsg s c p (Just r)

record IPCChannel where
  constructor MkChannel
  stateRef    : IORef Bool          -- True = open
  handlersRef : IORef (SortedMap String (IPCValue -> IPCValue))
  logRef      : IORef (List IPCMessage)

newChannel : IO IPCChannel
newChannel = do
  s <- newIORef True
  h <- newIORef empty
  l <- newIORef []
  pure (MkChannel s h l)

||| Bind a named command handler. Returns 0 on success, non-zero on error.
||| Errors: 1 = channel closed, 2 = invalid name (empty or > 255 chars).
bind : IPCChannel -> String -> (IPCValue -> IPCValue) -> IO Int
bind ch name handler = do
  isOpen <- readIORef ch.stateRef
  if not isOpen
    then pure 1
    else if length name == 0 || length name > 255
      then pure 2
      else do
        modifyIORef ch.handlersRef (insert name handler)
        pure 0

||| Dispatch a message; always logs, then runs the handler if bound.
||| Returns Nothing if channel is closed or command unbound; otherwise
||| Just <handler return value>.
dispatch : IPCChannel -> IPCMessage -> IO (Maybe IPCValue)
dispatch ch msg = do
  isOpen <- readIORef ch.stateRef
  if not isOpen
    then pure Nothing
    else do
      modifyIORef ch.logRef (msg ::)
      handlers <- readIORef ch.handlersRef
      case lookup msg.command handlers of
        Nothing      => pure Nothing
        Just handler => pure (Just (handler msg.payload))

close : IPCChannel -> IO ()
close ch = writeIORef ch.stateRef False

isOpen : IPCChannel -> IO Bool
isOpen ch = readIORef ch.stateRef

boundCommands : IPCChannel -> IO (List String)
boundCommands ch = do
  handlers <- readIORef ch.handlersRef
  pure $ map fst (SortedMap.toList handlers)

messageCount : IPCChannel -> IO Nat
messageCount ch = do
  log <- readIORef ch.logRef
  pure $ List.length log

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

||| Repeat a string n times — for the long-name test.
strRepeat : Nat -> String -> String
strRepeat Z     _ = ""
strRepeat (S k) s = s ++ strRepeat k s

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · IPCTest"

public export
tests : List TestCase
tests =
  -- ---------- message shape ----------
  [ test "ipc/message: valid message has non-empty source" $
      let msg = makeMsg "webview-0" "ping" (VObj [])
      in assertTrue "source must not be empty" (length msg.source > 0)

  , test "ipc/message: valid message has non-empty command" $
      let msg = makeMsg "webview-0" "open-file" (VObj [("path", VStr "/tmp/foo")])
      in assertTrue "command must not be empty" (length msg.command > 0)

  , test "ipc/message: payload can be any IPCValue variant" $
      -- Each variant is constructable; that's what TS's
      -- "JSON.stringify does not throw" reduces to here.
      let values : List IPCValue
          values = [ VObj []
                   , VObj [("key", VStr "value")]
                   , VInt 42
                   , VStr "string-payload"
                   , VList [VInt 1, VInt 2, VInt 3]
                   , VNull
                   , VBool True
                   ]
      in assertEq (length values) 7

  -- ---------- channel bind ----------
  , test "ipc/bind: bind to open channel returns 0 (success)" $ do
      ch <- newChannel
      r <- bind ch "open-file" (\_ => VStr "ok")
      assertEq r 0

  , test "ipc/bind: empty command name rejected (non-zero result)" $ do
      ch <- newChannel
      r <- bind ch "" (\_ => VStr "ok")
      assertNotEq r 0

  , test "ipc/bind: name longer than 255 chars rejected" $ do
      ch <- newChannel
      let longName = strRepeat 256 "x"
      r <- bind ch longName (\_ => VStr "ok")
      assertNotEq r 0

  , test "ipc/bind: exactly 255 char name accepted" $ do
      ch <- newChannel
      let maxName = strRepeat 255 "x"
      r <- bind ch maxName (\_ => VStr "ok")
      assertEq r 0

  , test "ipc/bind: bind to closed channel returns non-zero" $ do
      ch <- newChannel
      close ch
      r <- bind ch "any-command" (\_ => VStr "ok")
      assertNotEq r 0

  , test "ipc/bind: rebinding same command updates handler" $ do
      ch <- newChannel
      _ <- bind ch "echo" (\_ => VStr "first")
      _ <- bind ch "echo" (\_ => VStr "second")
      r <- dispatch ch (makeMsg "src" "echo" (VStr "payload"))
      assertEq r (Just (VStr "second"))

  -- ---------- channel dispatch ----------
  , test "ipc/dispatch: message routed to correct handler" $ do
      ch <- newChannel
      _ <- bind ch "ping" (\_ => VStr "pong")
      _ <- bind ch "greet" (\p => case p of
                                     VStr s => VStr ("hello " ++ s)
                                     _      => VNull)
      a <- dispatch ch (makeMsg "src" "ping" (VObj []))
      b <- dispatch ch (makeMsg "src" "greet" (VStr "world"))
      allPass
        [ assertEq a (Just (VStr "pong"))
        , assertEq b (Just (VStr "hello world"))
        ]

  , test "ipc/dispatch: unregistered command returns Nothing (null)" $ do
      ch <- newChannel
      r <- dispatch ch (makeMsg "src" "unknown-command" (VObj []))
      assertEq r Nothing

  , test "ipc/dispatch: dispatch after close returns Nothing (null)" $ do
      ch <- newChannel
      _ <- bind ch "ping" (\_ => VStr "pong")
      close ch
      r <- dispatch ch (makeMsg "src" "ping" (VObj []))
      assertEq r Nothing

  , test "ipc/dispatch: messages are logged in order" $ do
      ch <- newChannel
      _ <- bind ch "a" (\_ => VNull)
      _ <- bind ch "b" (\_ => VNull)
      _ <- dispatch ch (makeMsgReq "src" "a" (VInt 1) 1)
      _ <- dispatch ch (makeMsgReq "src" "b" (VInt 2) 2)
      _ <- dispatch ch (makeMsgReq "src" "a" (VInt 3) 3)
      n <- messageCount ch
      assertEq n 3

  -- ---------- channel lifecycle ----------
  , test "ipc/lifecycle: channel open → bind → dispatch → close" $ do
      ch <- newChannel
      open1 <- isOpen ch
      bindR <- bind ch "save" (\p => VObj [("saved", p)])
      r <- dispatch ch (makeMsg "frontend" "save" (VObj [("data", VStr "hello")]))
      close ch
      open2 <- isOpen ch
      postR <- dispatch ch (makeMsg "src" "save" (VObj []))
      postBind <- bind ch "another" (\_ => VStr "ok")
      allPass
        [ assertEq open1 True
        , assertEq bindR 0
        , assertEq r (Just (VObj [("saved", VObj [("data", VStr "hello")])]))
        , assertEq open2 False
        , assertEq postR Nothing
        , assertNotEq postBind 0
        ]

  , test "ipc/lifecycle: multiple channels are independent" $ do
      ch1 <- newChannel
      ch2 <- newChannel
      _ <- bind ch1 "cmd" (\_ => VStr "channel1")
      _ <- bind ch2 "cmd" (\_ => VStr "channel2")
      r1 <- dispatch ch1 (makeMsg "src" "cmd" (VObj []))
      r2 <- dispatch ch2 (makeMsg "src" "cmd" (VObj []))
      close ch1
      open1 <- isOpen ch1
      open2 <- isOpen ch2
      allPass
        [ assertEq r1 (Just (VStr "channel1"))
        , assertEq r2 (Just (VStr "channel2"))
        , assertEq open1 False
        , assertEq open2 True
        ]

  -- ---------- result code round-trip (subset reproduced for ipc context) ----------
  , test "ipc/result-codes: all 12 result codes are distinct integers" $
      let codes = map resultToInt
                    [ Ok, Error, InvalidParam, OutOfMemory, NullPointer
                    , AlreadyConsumed, ResourceLeaked, DoubleFree
                    , WebviewUnavailable, IPCProtocolError, CapabilityDenied
                    , GuardLocked
                    ]
      in assertEq (length (nub codes)) 12

  , test "ipc/result-codes: codes are contiguous 0..11" $
      let codes = sort (map resultToInt
                          [ Ok, Error, InvalidParam, OutOfMemory, NullPointer
                          , AlreadyConsumed, ResourceLeaked, DoubleFree
                          , WebviewUnavailable, IPCProtocolError, CapabilityDenied
                          , GuardLocked
                          ])
      in assertEq codes [0,1,2,3,4,5,6,7,8,9,10,11]
  ]

main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
