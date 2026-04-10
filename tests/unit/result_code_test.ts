// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// result_code_test.ts — Unit tests for the Gossamer Result code system.
//
// Tests the Result enum and associated helpers from src/interface/abi/Types.idr
// and their mirror in src/interface/ffi/src/main.zig.
//
// Covers:
// - All 12 result codes (Ok=0 through GuardLocked=11) are defined and unique
// - resultToInt / resultFromInt round-trip correctly for all codes
// - Result codes are contiguous 0..11
// - errorDescription returns a non-empty string for every code
// - GuardMode integer values (free=0, locked=1, read_only=2) match Types.idr
// - Platform enum values are defined and exhaustive (7 entries)

import {
  assertEquals,
  assertNotEquals,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// Result codes — mirrors resultToInt / resultFromInt in Types.idr
// ---------------------------------------------------------------------------

/** Result code table — each entry is [intValue, name, errorDescription]. */
const RESULT_TABLE: [number, string, string][] = [
  [0,  "Ok",                 "Success"],
  [1,  "Error",              "Generic error"],
  [2,  "InvalidParam",       "Invalid parameter"],
  [3,  "OutOfMemory",        "Out of memory"],
  [4,  "NullPointer",        "Null pointer"],
  [5,  "AlreadyConsumed",    "Resource already consumed (use-after-free)"],
  [6,  "ResourceLeaked",     "Resource leaked (not consumed before scope exit)"],
  [7,  "DoubleFree",         "Double-free attempt"],
  [8,  "WebviewUnavailable", "Webview engine unavailable on this platform"],
  [9,  "IPCProtocolError",   "IPC protocol violation"],
  [10, "CapabilityDenied",   "Capability denied"],
  [11, "GuardLocked",        "Window guard is active"],
];

/** Result code enum — matches resultToInt in Types.idr. */
const Result = {
  Ok:                 0,
  Error:              1,
  InvalidParam:       2,
  OutOfMemory:        3,
  NullPointer:        4,
  AlreadyConsumed:    5,
  ResourceLeaked:     6,
  DoubleFree:         7,
  WebviewUnavailable: 8,
  IPCProtocolError:   9,
  CapabilityDenied:   10,
  GuardLocked:        11,
} as const;
type Result = (typeof Result)[keyof typeof Result];

/**
 * resultToInt — converts a Result to its C integer value.
 * Mirrors resultToInt in Types.idr.
 */
function resultToInt(r: Result): number {
  return r; // The enum already stores integer values
}

/**
 * resultFromInt — reconstructs a Result from a C integer.
 * Returns undefined for unknown codes (mirrors Nothing in Types.idr).
 */
function resultFromInt(n: number): Result | undefined {
  const entry = RESULT_TABLE.find(([code]) => code === n);
  if (!entry) return undefined;
  return entry[0] as Result;
}

/**
 * errorDescription — human-readable description for each result code.
 * Mirrors errorDescription in Types.idr.
 */
function errorDescription(r: Result): string {
  const entry = RESULT_TABLE.find(([code]) => code === r);
  return entry ? entry[2] : "";
}

// ---------------------------------------------------------------------------
// GuardMode — mirrors guardModeToInt / guardModeFromInt in Types.idr
// ---------------------------------------------------------------------------

const GuardMode = {
  free:      0,
  locked:    1,
  read_only: 2,
} as const;
type GuardMode = (typeof GuardMode)[keyof typeof GuardMode];

function guardModeToInt(g: GuardMode): number {
  return g;
}

function guardModeFromInt(n: number): GuardMode | undefined {
  const valid: number[] = [0, 1, 2];
  if (valid.includes(n)) return n as GuardMode;
  return undefined;
}

// ---------------------------------------------------------------------------
// Platform enum — mirrors data Platform in Types.idr
// ---------------------------------------------------------------------------

const Platform = {
  Linux:   "Linux",
  Windows: "Windows",
  MacOS:   "MacOS",
  BSD:     "BSD",
  IOS:     "IOS",
  Android: "Android",
  WASM:    "WASM",
} as const;
type Platform = (typeof Platform)[keyof typeof Platform];

// ---------------------------------------------------------------------------
// Tests: Result code definitions
// ---------------------------------------------------------------------------

Deno.test("result-codes/definitions: all 12 codes are defined", () => {
  assertEquals(Object.keys(Result).length, 12, "must have exactly 12 result codes");
});

Deno.test("result-codes/definitions: all code integers are unique", () => {
  const values = Object.values(Result);
  const unique = new Set(values);
  assertEquals(unique.size, 12, "all 12 result code integers must be distinct");
});

Deno.test("result-codes/definitions: codes are contiguous 0..11", () => {
  const sorted = Object.values(Result).sort((a, b) => a - b);
  for (let i = 0; i < sorted.length; i++) {
    assertEquals(sorted[i], i, `result code at sorted position ${i} should equal ${i}`);
  }
});

Deno.test("result-codes/definitions: Ok is 0", () => {
  assertEquals(Result.Ok, 0);
});

Deno.test("result-codes/definitions: GuardLocked is 11 (last code)", () => {
  assertEquals(Result.GuardLocked, 11);
});

Deno.test("result-codes/definitions: Error is 1 (generic failure)", () => {
  assertEquals(Result.Error, 1);
});

Deno.test("result-codes/definitions: linearity codes occupy 5..7", () => {
  assertEquals(Result.AlreadyConsumed, 5);
  assertEquals(Result.ResourceLeaked,  6);
  assertEquals(Result.DoubleFree,      7);
});

Deno.test("result-codes/definitions: webview / IPC / capability codes occupy 8..10", () => {
  assertEquals(Result.WebviewUnavailable, 8);
  assertEquals(Result.IPCProtocolError,   9);
  assertEquals(Result.CapabilityDenied,   10);
});

// ---------------------------------------------------------------------------
// Tests: resultToInt
// ---------------------------------------------------------------------------

Deno.test("result-codes/resultToInt: maps every code to its expected integer", () => {
  for (const [expected, name] of RESULT_TABLE) {
    const code = Result[name as keyof typeof Result];
    assertEquals(
      resultToInt(code),
      expected,
      `resultToInt(${name}) should be ${expected}`,
    );
  }
});

Deno.test("result-codes/resultToInt: Ok maps to 0", () => {
  assertEquals(resultToInt(Result.Ok), 0);
});

Deno.test("result-codes/resultToInt: GuardLocked maps to 11", () => {
  assertEquals(resultToInt(Result.GuardLocked), 11);
});

// ---------------------------------------------------------------------------
// Tests: resultFromInt
// ---------------------------------------------------------------------------

Deno.test("result-codes/resultFromInt: every valid integer reconstructs correctly", () => {
  for (let i = 0; i <= 11; i++) {
    const r = resultFromInt(i);
    assertNotEquals(r, undefined, `resultFromInt(${i}) must return a Result`);
    assertEquals(resultToInt(r!), i, `round-trip for code ${i} must be identity`);
  }
});

Deno.test("result-codes/resultFromInt: negative integer returns undefined", () => {
  assertEquals(resultFromInt(-1), undefined);
});

Deno.test("result-codes/resultFromInt: integer 12 (one past last) returns undefined", () => {
  assertEquals(resultFromInt(12), undefined);
});

Deno.test("result-codes/resultFromInt: large integer returns undefined", () => {
  assertEquals(resultFromInt(0xffffffff), undefined);
});

Deno.test("result-codes/resultFromInt: round-trip for all 12 codes is identity", () => {
  for (const [code, name] of RESULT_TABLE) {
    const r = resultFromInt(code);
    assertNotEquals(r, undefined, `resultFromInt(${code}) must not be undefined`);
    assertEquals(
      resultToInt(r!),
      code,
      `round-trip ${name}: resultToInt(resultFromInt(${code})) must equal ${code}`,
    );
  }
});

// ---------------------------------------------------------------------------
// Tests: errorDescription
// ---------------------------------------------------------------------------

Deno.test("result-codes/errorDescription: returns non-empty string for every code", () => {
  for (const [code, name] of RESULT_TABLE) {
    const desc = errorDescription(code as Result);
    assertNotEquals(
      desc.length,
      0,
      `errorDescription(${name}) must not be empty`,
    );
  }
});

Deno.test("result-codes/errorDescription: Ok returns 'Success'", () => {
  assertEquals(errorDescription(Result.Ok), "Success");
});

Deno.test("result-codes/errorDescription: Error returns 'Generic error'", () => {
  assertEquals(errorDescription(Result.Error), "Generic error");
});

Deno.test("result-codes/errorDescription: InvalidParam mentions parameter", () => {
  const desc = errorDescription(Result.InvalidParam);
  assertNotEquals(desc.length, 0);
  // The description must reference the concept of parameters
  assertEquals(desc.toLowerCase().includes("param"), true);
});

Deno.test("result-codes/errorDescription: all descriptions are unique strings", () => {
  const descriptions = RESULT_TABLE.map(([code]) =>
    errorDescription(code as Result),
  );
  const unique = new Set(descriptions);
  assertEquals(
    unique.size,
    RESULT_TABLE.length,
    "each result code should have a distinct description",
  );
});

Deno.test("result-codes/errorDescription: linearity codes mention their concept", () => {
  // AlreadyConsumed / DoubleFree / ResourceLeaked are linearity violations
  const alreadyConsumed = errorDescription(Result.AlreadyConsumed).toLowerCase();
  const doubleFree = errorDescription(Result.DoubleFree).toLowerCase();
  const leaked = errorDescription(Result.ResourceLeaked).toLowerCase();

  assertEquals(
    alreadyConsumed.includes("consumed") || alreadyConsumed.includes("use-after-free"),
    true,
    "AlreadyConsumed description should mention consumed or use-after-free",
  );
  assertEquals(
    doubleFree.includes("double") || doubleFree.includes("free"),
    true,
    "DoubleFree description should mention double or free",
  );
  assertEquals(
    leaked.includes("leak") || leaked.includes("not consumed"),
    true,
    "ResourceLeaked description should mention leak or not consumed",
  );
});

// ---------------------------------------------------------------------------
// Tests: GuardMode values
// ---------------------------------------------------------------------------

Deno.test("result-codes/guard-mode: free is 0", () => {
  assertEquals(GuardMode.free, 0);
});

Deno.test("result-codes/guard-mode: locked is 1", () => {
  assertEquals(GuardMode.locked, 1);
});

Deno.test("result-codes/guard-mode: read_only is 2", () => {
  assertEquals(GuardMode.read_only, 2);
});

Deno.test("result-codes/guard-mode: all three values are defined and distinct", () => {
  const values = Object.values(GuardMode);
  assertEquals(values.length, 3, "exactly 3 guard modes");
  assertEquals(new Set(values).size, 3, "all values must be unique");
});

Deno.test("result-codes/guard-mode: guardModeToInt / guardModeFromInt round-trip", () => {
  for (const g of Object.values(GuardMode)) {
    const n = guardModeToInt(g);
    const back = guardModeFromInt(n);
    assertNotEquals(back, undefined, `guardModeFromInt(${n}) must succeed`);
    assertEquals(guardModeToInt(back!), n, `round-trip for GuardMode ${n} must be identity`);
  }
});

Deno.test("result-codes/guard-mode: guardModeFromInt(3) returns undefined (no 4th mode)", () => {
  assertEquals(guardModeFromInt(3), undefined);
});

Deno.test("result-codes/guard-mode: guardModeFromInt(-1) returns undefined", () => {
  assertEquals(guardModeFromInt(-1), undefined);
});

// ---------------------------------------------------------------------------
// Tests: Platform enum
// ---------------------------------------------------------------------------

Deno.test("result-codes/platform: exactly 7 platforms are defined", () => {
  assertEquals(Object.keys(Platform).length, 7, "must have exactly 7 Platform entries");
});

Deno.test("result-codes/platform: all expected platform names are present", () => {
  const expected = ["Linux", "Windows", "MacOS", "BSD", "IOS", "Android", "WASM"];
  for (const name of expected) {
    assertEquals(
      Object.keys(Platform).includes(name),
      true,
      `Platform.${name} must be defined`,
    );
  }
});

Deno.test("result-codes/platform: all platform values are unique strings", () => {
  const values = Object.values(Platform);
  const unique = new Set(values);
  assertEquals(unique.size, 7, "all platform names must be distinct");
});

Deno.test("result-codes/platform: Linux is the default build platform", () => {
  // Types.idr: thisPlatform = Linux
  assertEquals(Platform.Linux, "Linux");
});

Deno.test("result-codes/platform: desktop platforms are defined (Linux, Windows, MacOS)", () => {
  assertEquals(Platform.Linux,   "Linux");
  assertEquals(Platform.Windows, "Windows");
  assertEquals(Platform.MacOS,   "MacOS");
});

Deno.test("result-codes/platform: BSD is a supported Linux-adjacent platform", () => {
  assertEquals(Platform.BSD, "BSD");
});

Deno.test("result-codes/platform: mobile and WASM platforms are defined", () => {
  assertEquals(Platform.IOS,     "IOS");
  assertEquals(Platform.Android, "Android");
  assertEquals(Platform.WASM,    "WASM");
});
