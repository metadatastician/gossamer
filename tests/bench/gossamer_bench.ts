// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer_bench.ts — Benchmarks for core Gossamer operations.
//
// Benchmarks using Deno.bench (built-in harness):
//   - IPC message serialisation throughput
//   - Capability lookup speed (100, 1000, 10000 entries)
//   - Path normalisation throughput
//   - Dialog state machine transitions
//   - Result code round-trip throughput
//
// Run with: deno bench --allow-env tests/bench/gossamer_bench.ts

// ---------------------------------------------------------------------------
// IPC message serialisation
// ---------------------------------------------------------------------------

interface IPCMessage {
  source: string;
  command: string;
  payload: unknown;
  requestId?: number;
}

const SAMPLE_MESSAGES: IPCMessage[] = [
  { source: "webview-0", command: "open-file", payload: { path: "/tmp/file.txt" } },
  { source: "panel-1", command: "save", payload: { data: "content", compress: true } },
  { source: "cli", command: "ping", payload: null },
  { source: "backend", command: "list-dir", payload: { dir: "/home/user", recursive: false } },
  {
    source: "webview-2",
    command: "eval-js",
    payload: { script: "document.title", timeout: 5000 },
    requestId: 42,
  },
];

Deno.bench("ipc/serialise: single small message", { group: "ipc" }, () => {
  JSON.stringify(SAMPLE_MESSAGES[0]);
});

Deno.bench("ipc/serialise: large payload (1KB)", { group: "ipc" }, () => {
  const msg: IPCMessage = {
    source: "webview-0",
    command: "send-data",
    payload: { data: "x".repeat(1024) },
  };
  JSON.stringify(msg);
});

Deno.bench("ipc/deserialise: parse message from JSON string", { group: "ipc" }, () => {
  const json = '{"source":"webview-0","command":"open-file","payload":{"path":"/tmp/file.txt"}}';
  JSON.parse(json);
});

Deno.bench("ipc/serialise: batch of 100 messages", { group: "ipc" }, () => {
  for (let i = 0; i < 100; i++) {
    JSON.stringify(SAMPLE_MESSAGES[i % SAMPLE_MESSAGES.length]);
  }
});

// ---------------------------------------------------------------------------
// Capability lookup — Map-based registry
// ---------------------------------------------------------------------------

class BenchCapRegistry {
  private map: Map<bigint, { kind: number; revoked: boolean }>;

  constructor(size: number) {
    this.map = new Map();
    for (let i = 0n; i < BigInt(size); i++) {
      this.map.set(i + 1n, { kind: Number(i % 7n), revoked: false });
    }
  }

  check(token: bigint): boolean {
    const e = this.map.get(token);
    return !!e && !e.revoked;
  }
}

const reg100 = new BenchCapRegistry(100);
const reg1000 = new BenchCapRegistry(1000);
const reg10000 = new BenchCapRegistry(10000);

Deno.bench("capability/check: lookup in 100-entry registry", { group: "capability" }, () => {
  reg100.check(50n);
});

Deno.bench(
  "capability/check: lookup in 1000-entry registry",
  { group: "capability" },
  () => {
    reg1000.check(500n);
  },
);

Deno.bench(
  "capability/check: lookup in 10000-entry registry",
  { group: "capability" },
  () => {
    reg10000.check(5000n);
  },
);

Deno.bench(
  "capability/check: miss (token not in registry)",
  { group: "capability" },
  () => {
    reg10000.check(99999n);
  },
);

Deno.bench(
  "capability/check: first entry (best case)",
  { group: "capability" },
  () => {
    reg10000.check(1n);
  },
);

Deno.bench(
  "capability/check: last entry (worst case)",
  { group: "capability" },
  () => {
    reg10000.check(10000n);
  },
);

// ---------------------------------------------------------------------------
// Path normalisation
// ---------------------------------------------------------------------------

/**
 * Normalise a filesystem path:
 * - Collapse consecutive slashes
 * - Remove trailing slash (except root)
 * - Validate no null bytes
 */
function normalisePath(p: string): string | null {
  if (p.includes("\0")) return null;
  const normalised = p.replace(/\/+/g, "/").replace(/\/+$/, "") || "/";
  return normalised;
}

const SAMPLE_PATHS = [
  "/home/user/docs",
  "/tmp//file.txt",
  "relative/path/to/file",
  "/var/lib/gossamer/data/",
  "/a/b/c/d/e/f/g/h",
  "./local/file",
];

Deno.bench("path/normalise: single path", { group: "path" }, () => {
  normalisePath("/home/user//docs/");
});

Deno.bench("path/normalise: batch of 100 paths", { group: "path" }, () => {
  for (let i = 0; i < 100; i++) {
    normalisePath(SAMPLE_PATHS[i % SAMPLE_PATHS.length]);
  }
});

Deno.bench("path/normalise: path with null byte (rejection)", { group: "path" }, () => {
  normalisePath("/tmp/file\0evil");
});

Deno.bench(
  "path/normalise: deeply nested path (10 levels)",
  { group: "path" },
  () => {
    normalisePath("/a/b/c/d/e/f/g/h/i/j/file.txt");
  },
);

// ---------------------------------------------------------------------------
// Dialog state machine transitions
// ---------------------------------------------------------------------------

type DialogState = "idle" | "open" | "save" | "openDir" | "multi" | "cancelled" | "selected";

function transitionDialog(from: DialogState, action: string): DialogState {
  switch (from) {
    case "idle":
      if (action === "show-open") return "open";
      if (action === "show-save") return "save";
      if (action === "show-dir") return "openDir";
      if (action === "show-multi") return "multi";
      return "idle";
    case "open":
    case "save":
    case "openDir":
    case "multi":
      if (action === "confirm") return "selected";
      if (action === "cancel") return "cancelled";
      return from;
    case "selected":
    case "cancelled":
      if (action === "reset") return "idle";
      return from;
    default:
      return "idle";
  }
}

Deno.bench("dialog/transition: single state transition", { group: "dialog" }, () => {
  transitionDialog("idle", "show-open");
});

Deno.bench("dialog/transition: full open→select→reset cycle", { group: "dialog" }, () => {
  let state: DialogState = "idle";
  state = transitionDialog(state, "show-open");
  state = transitionDialog(state, "confirm");
  state = transitionDialog(state, "reset");
});

Deno.bench("dialog/transition: 1000 transitions", { group: "dialog" }, () => {
  let state: DialogState = "idle";
  const actions = ["show-open", "confirm", "reset", "show-save", "cancel", "reset"];
  for (let i = 0; i < 1000; i++) {
    state = transitionDialog(state, actions[i % actions.length]);
  }
});

// ---------------------------------------------------------------------------
// Result code round-trip
// ---------------------------------------------------------------------------

const RESULT_MAP: Record<number, string> = {
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

function resultToName(code: number): string | undefined {
  return RESULT_MAP[code];
}

Deno.bench("result/lookup: single code lookup", { group: "result" }, () => {
  resultToName(10); // CapabilityDenied
});

Deno.bench("result/lookup: all 12 codes", { group: "result" }, () => {
  for (let i = 0; i <= 11; i++) {
    resultToName(i);
  }
});

Deno.bench("result/lookup: 1000 random code lookups", { group: "result" }, () => {
  for (let i = 0; i < 1000; i++) {
    resultToName(i % 12);
  }
});

// ---------------------------------------------------------------------------
// IPC command validation throughput
// ---------------------------------------------------------------------------

function isValidIPCCommand(name: string): boolean {
  if (name.length === 0 || name.length > 255) return false;
  return /^[a-zA-Z0-9_-]+$/.test(name);
}

const VALID_COMMANDS = [
  "open-file",
  "save",
  "ping",
  "list-dir",
  "close-window",
  "navigate",
  "eval-js",
  "set-title",
  "show-dialog",
  "request-cap",
];

Deno.bench("ipc/validate: single valid command name", { group: "ipc-validate" }, () => {
  isValidIPCCommand("open-file");
});

Deno.bench("ipc/validate: single invalid command name", { group: "ipc-validate" }, () => {
  isValidIPCCommand("cmd;evil");
});

Deno.bench("ipc/validate: 1000 valid commands", { group: "ipc-validate" }, () => {
  for (let i = 0; i < 1000; i++) {
    isValidIPCCommand(VALID_COMMANDS[i % VALID_COMMANDS.length]);
  }
});

Deno.bench(
  "ipc/validate: max-length valid name (255 chars)",
  { group: "ipc-validate" },
  () => {
    isValidIPCCommand("a".repeat(255));
  },
);

Deno.bench(
  "ipc/validate: over-length name (256 chars) rejection",
  { group: "ipc-validate" },
  () => {
    isValidIPCCommand("a".repeat(256));
  },
);
