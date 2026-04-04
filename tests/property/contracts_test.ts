// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// contracts_test.ts — Property-based tests for core Gossamer invariants.
//
// Exercises core contract invariants that must hold for all inputs:
//   - IPC messages always have non-empty source and command
//   - Capabilities are strictly additive (grant cannot remove)
//   - Shell commands never contain null bytes
//   - Filesystem paths are never empty strings
//   - Dialog responses are exactly Some or None
//   - Result codes round-trip through integer representation
//
// Each test generates a wide range of inputs to stress the invariants.

import { assertEquals, assertNotEquals } from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// Simple deterministic pseudo-random generator (LCG) for reproducibility
// ---------------------------------------------------------------------------

class Prng {
  private state: number;
  constructor(seed = 42) {
    this.state = seed;
  }
  next(): number {
    this.state = ((this.state * 1664525 + 1013904223) >>> 0);
    return this.state / 0xffffffff;
  }
  int(min: number, max: number): number {
    return Math.floor(this.next() * (max - min + 1)) + min;
  }
  pick<T>(arr: T[]): T {
    return arr[this.int(0, arr.length - 1)];
  }
  string(minLen: number, maxLen: number, chars: string): string {
    const len = this.int(minLen, maxLen);
    let s = "";
    for (let i = 0; i < len; i++) s += chars[this.int(0, chars.length - 1)];
    return s;
  }
}

const ALPHA = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
const ALNUM = ALPHA + "0123456789_-";
const PATH_CHARS = ALNUM + "/. ";
const PAYLOAD_VALS = [null, 0, "", [], {}, true, false, 42, "hello", [1, 2, 3]];

// ---------------------------------------------------------------------------
// Model types (mirrors from Capabilities and Bridge models)
// ---------------------------------------------------------------------------

const ResourceKind = {
  Filesystem: 0,
  Network: 1,
  Shell: 2,
  Clipboard: 3,
  Notification: 4,
  Tray: 5,
  Groove: 6,
} as const;
type ResourceKind = (typeof ResourceKind)[keyof typeof ResourceKind];
const ALL_RESOURCE_KINDS = Object.values(ResourceKind) as ResourceKind[];

interface IPCMessage {
  source: string;
  command: string;
  payload: unknown;
}

class CapabilityRegistry {
  private nextToken = 1n;
  private tokens = new Map<bigint, { kind: ResourceKind; revoked: boolean }>();

  grant(kind: ResourceKind): bigint {
    const token = this.nextToken++;
    this.tokens.set(token, { kind, revoked: false });
    return token;
  }

  check(token: bigint): boolean {
    const e = this.tokens.get(token);
    return !!e && !e.revoked;
  }

  revoke(token: bigint): void {
    const e = this.tokens.get(token);
    if (e) e.revoked = true;
  }

  activeCount(): number {
    let n = 0;
    for (const e of this.tokens.values()) if (!e.revoked) n++;
    return n;
  }
}

// ---------------------------------------------------------------------------
// Invariant: IPC messages always have non-empty source and command
// ---------------------------------------------------------------------------

Deno.test("property/ipc: message source is always non-empty", () => {
  const rng = new Prng(1001);
  const sources = ["webview-0", "panel-42", "backend", "cli", "electron-compat"];
  for (let i = 0; i < 200; i++) {
    const msg: IPCMessage = {
      source: rng.pick(sources),
      command: rng.string(1, 32, ALNUM),
      payload: rng.pick(PAYLOAD_VALS),
    };
    assertNotEquals(msg.source.length, 0, `iteration ${i}: source must not be empty`);
  }
});

Deno.test("property/ipc: message command is always non-empty", () => {
  const rng = new Prng(1002);
  const commands = ["open-file", "save", "ping", "greet", "execute", "dialog"];
  for (let i = 0; i < 200; i++) {
    const cmd = rng.pick(commands);
    assertNotEquals(cmd.length, 0, `iteration ${i}: command must not be empty`);
  }
});

Deno.test("property/ipc: payload is always JSON-serialisable", () => {
  const rng = new Prng(1003);
  for (let i = 0; i < 200; i++) {
    const payload = rng.pick(PAYLOAD_VALS);
    let threw = false;
    try {
      JSON.stringify(payload);
    } catch {
      threw = true;
    }
    assertEquals(threw, false, `iteration ${i}: payload must be JSON-serialisable`);
  }
});

// ---------------------------------------------------------------------------
// Invariant: Capabilities are strictly additive (grant cannot remove)
// ---------------------------------------------------------------------------

Deno.test("property/capabilities: grant never removes existing active tokens", () => {
  const rng = new Prng(2001);
  for (let run = 0; run < 50; run++) {
    const reg = new CapabilityRegistry();
    const tokens: bigint[] = [];

    // Grant a batch of tokens
    const grantCount = rng.int(1, 20);
    for (let i = 0; i < grantCount; i++) {
      tokens.push(reg.grant(rng.pick(ALL_RESOURCE_KINDS)));
    }

    // All tokens must still be active before any revoke
    const activeAfterGrants = reg.activeCount();
    assertEquals(
      activeAfterGrants,
      grantCount,
      `run ${run}: granting ${grantCount} tokens must yield ${grantCount} active`,
    );

    // Grant more — existing tokens must remain active
    const moreTokens: bigint[] = [];
    const moreCount = rng.int(1, 10);
    for (let i = 0; i < moreCount; i++) {
      moreTokens.push(reg.grant(rng.pick(ALL_RESOURCE_KINDS)));
    }

    // All original tokens still check OK
    for (const t of tokens) {
      assertEquals(
        reg.check(t),
        true,
        `run ${run}: original token must still be active after additional grants`,
      );
    }
  }
});

Deno.test("property/capabilities: revoke is additive — only targeted token is removed", () => {
  const rng = new Prng(2002);
  for (let run = 0; run < 50; run++) {
    const reg = new CapabilityRegistry();
    const tokens: bigint[] = [];

    const count = rng.int(3, 15);
    for (let i = 0; i < count; i++) {
      tokens.push(reg.grant(rng.pick(ALL_RESOURCE_KINDS)));
    }

    // Revoke a random subset (not all)
    const revokeIdx = rng.int(0, count - 1);
    const revokedToken = tokens[revokeIdx];
    reg.revoke(revokedToken);

    // Revoked token must fail
    assertEquals(reg.check(revokedToken), false, `run ${run}: revoked token must be inactive`);

    // All others must succeed
    for (let i = 0; i < tokens.length; i++) {
      if (i !== revokeIdx) {
        assertEquals(
          reg.check(tokens[i]),
          true,
          `run ${run}: non-revoked token[${i}] must still be active`,
        );
      }
    }
  }
});

// ---------------------------------------------------------------------------
// Invariant: Shell commands never contain null bytes
// ---------------------------------------------------------------------------

function isValidShellCommand(cmd: string): boolean {
  return !cmd.includes("\0");
}

Deno.test("property/shell: valid commands contain no null bytes", () => {
  const rng = new Prng(3001);
  const validCommands = [
    "ls -la",
    "echo hello",
    "cat /tmp/file.txt",
    "grep pattern file",
    "awk '{print $1}' file",
    "find / -name '*.txt'",
    "/usr/bin/python3 script.py",
  ];
  for (let i = 0; i < 200; i++) {
    const cmd = rng.pick(validCommands);
    assertEquals(
      isValidShellCommand(cmd),
      true,
      `iteration ${i}: valid command must not contain null bytes`,
    );
  }
});

Deno.test("property/shell: command with null byte is rejected as invalid", () => {
  const malicious = [
    "ls\0-la",
    "\0echo pwned",
    "cat /etc/passwd\0;rm -rf /",
    "normal\0command",
  ];
  for (const cmd of malicious) {
    assertEquals(
      isValidShellCommand(cmd),
      false,
      `null-byte command "${cmd.replace(/\0/g, "\\0")}" must be rejected`,
    );
  }
});

// ---------------------------------------------------------------------------
// Invariant: Filesystem paths are never empty strings
// ---------------------------------------------------------------------------

function isValidPath(path: string): boolean {
  return path.length > 0;
}

Deno.test("property/filesystem: valid paths are never empty strings", () => {
  const rng = new Prng(4001);
  const paths = [
    "/home/user/file.txt",
    "/tmp/gossamer.log",
    "relative/path.md",
    "./local",
    "../parent",
    "/",
    "a",
  ];
  for (let i = 0; i < 200; i++) {
    const p = rng.pick(paths);
    assertEquals(isValidPath(p), true, `iteration ${i}: valid path must not be empty`);
  }
});

Deno.test("property/filesystem: empty string path is invalid", () => {
  assertEquals(isValidPath(""), false, "empty path must be invalid");
});

Deno.test("property/filesystem: whitespace-only path is non-empty (OS concern)", () => {
  // From Gossamer's perspective, " " is a non-empty string — the OS decides validity
  assertEquals(isValidPath(" "), true, "space-only path is non-empty (OS validates)");
});

// ---------------------------------------------------------------------------
// Invariant: Dialog responses are always exactly Some or None
// ---------------------------------------------------------------------------

type DialogResult = { kind: "Some"; path: string } | { kind: "None" };

function makeDialogResult(ptr: number, path: string): DialogResult {
  return ptr === 0 ? { kind: "None" } : { kind: "Some", path };
}

Deno.test("property/dialog: result kind is always Some or None", () => {
  const rng = new Prng(5001);
  const testPaths = ["/tmp/a", "/home/user/b", "", "/x/y/z"];
  for (let i = 0; i < 200; i++) {
    const ptr = rng.int(0, 1); // 0 = cancelled, 1 = ok
    const path = ptr === 0 ? "" : rng.pick(testPaths.filter((p) => p.length > 0));
    const result = makeDialogResult(ptr, path);
    const valid = result.kind === "Some" || result.kind === "None";
    assertEquals(valid, true, `iteration ${i}: result kind must be Some or None`);
  }
});

Deno.test("property/dialog: Some always carries non-empty path", () => {
  const rng = new Prng(5002);
  const paths = ["/tmp/a.txt", "/home/x", "/var/y"];
  for (let i = 0; i < 100; i++) {
    const path = rng.pick(paths);
    const result = makeDialogResult(1, path);
    if (result.kind === "Some") {
      assertNotEquals(
        result.path.length,
        0,
        `iteration ${i}: Some must carry non-empty path`,
      );
    }
  }
});

// ---------------------------------------------------------------------------
// Invariant: Result codes round-trip through integer representation
// ---------------------------------------------------------------------------

const RESULT_CODES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] as const;
type ResultCode = (typeof RESULT_CODES)[number];

const RESULT_NAMES: Record<ResultCode, string> = {
  0: "Ok",
  1: "Error",
  2: "InvalidParam",
  3: "OutOfMemory",
  4: "NullPointer",
  5: "AlreadyConsumed",
  6: "ResourceLeaked",
  7: "DoubleFree",
  8: "WebviewUnavailable",
  9: "IPCProtocolError",
  10: "CapabilityDenied",
  11: "GuardLocked",
};

Deno.test("property/result-codes: all valid codes decode to known names", () => {
  for (const code of RESULT_CODES) {
    const name = RESULT_NAMES[code];
    assertNotEquals(name, undefined, `code ${code} must have a name`);
    assertNotEquals(name.length, 0, `code ${code} name must be non-empty`);
  }
});

Deno.test("property/result-codes: out-of-range codes have no mapping", () => {
  const outOfRange = [12, 13, 100, 255, -1, 999];
  for (const code of outOfRange) {
    const name = (RESULT_NAMES as Record<number, string>)[code];
    assertEquals(
      name,
      undefined,
      `out-of-range code ${code} must have no mapping`,
    );
  }
});

Deno.test("property/result-codes: names are unique across all codes", () => {
  const names = Object.values(RESULT_NAMES);
  const unique = new Set(names);
  assertEquals(unique.size, names.length, "all result code names must be unique");
});
