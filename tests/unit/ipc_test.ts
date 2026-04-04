// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ipc_test.ts — Unit tests for the Gossamer IPC message format and channel model.
//
// Tests the typed IPC channel model mirroring Bridge.eph and Types.idr:
// open, bind, close lifecycle; message routing; command name validation.

import {
  assertEquals,
  assertNotEquals,
  assertThrows,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// IPC model mirroring Bridge.eph and the Channel type in Types.idr
// ---------------------------------------------------------------------------

/** IPC message shape — every message must have a source and payload */
interface IPCMessage {
  source: string;
  command: string;
  payload: unknown;
  requestId?: number;
}

/** Possible channel states — mirrors webview handle lifecycle */
type ChannelState = "open" | "closed";

/** A simulated IPC channel with in-process message dispatch */
class IPCChannel {
  private state: ChannelState = "open";
  private handlers: Map<string, (payload: unknown) => unknown> = new Map();
  private messageLog: IPCMessage[] = [];

  /** Bind a named command handler. Returns 0 on success, non-zero on error. */
  bind(name: string, handler: (payload: unknown) => unknown): number {
    if (this.state !== "open") return 1; // channel closed
    if (!name || name.length === 0) return 2; // invalid name
    if (name.length > 255) return 2; // name too long
    this.handlers.set(name, handler);
    return 0;
  }

  /** Dispatch a message to the bound handler. Returns the handler result or null. */
  dispatch(msg: IPCMessage): unknown {
    if (this.state !== "open") return null;
    this.messageLog.push(msg);
    const handler = this.handlers.get(msg.command);
    if (!handler) return null;
    return handler(msg.payload);
  }

  /** Close the channel — CONSUMES it. */
  close(): void {
    this.state = "closed";
  }

  isOpen(): boolean {
    return this.state === "open";
  }

  boundCommands(): string[] {
    return Array.from(this.handlers.keys());
  }

  messageCount(): number {
    return this.messageLog.length;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function makeMsg(
  source: string,
  command: string,
  payload: unknown = {},
  requestId?: number,
): IPCMessage {
  return { source, command, payload, requestId };
}

// ---------------------------------------------------------------------------
// Tests: message shape invariants
// ---------------------------------------------------------------------------

Deno.test("ipc/message: valid message has non-empty source", () => {
  const msg = makeMsg("webview-0", "ping", {});
  assertNotEquals(msg.source.length, 0, "source must not be empty");
});

Deno.test("ipc/message: valid message has non-empty command", () => {
  const msg = makeMsg("webview-0", "open-file", { path: "/tmp/foo" });
  assertNotEquals(msg.command.length, 0, "command must not be empty");
});

Deno.test("ipc/message: payload can be any JSON-serialisable type", () => {
  const payloads: unknown[] = [
    {},
    { key: "value" },
    42,
    "string-payload",
    [1, 2, 3],
    null,
    true,
  ];
  for (const p of payloads) {
    // Serialisable means JSON.stringify does not throw
    const serialised = JSON.stringify(p);
    assertNotEquals(serialised, undefined, "payload must be serialisable");
  }
});

// ---------------------------------------------------------------------------
// Tests: channel bind
// ---------------------------------------------------------------------------

Deno.test("ipc/bind: bind to open channel returns 0 (success)", () => {
  const ch = new IPCChannel();
  const result = ch.bind("open-file", (_payload) => "ok");
  assertEquals(result, 0);
});

Deno.test("ipc/bind: empty command name rejected (non-zero result)", () => {
  const ch = new IPCChannel();
  const result = ch.bind("", (_payload) => "ok");
  assertNotEquals(result, 0, "empty name must be rejected");
});

Deno.test("ipc/bind: name longer than 255 chars rejected", () => {
  const ch = new IPCChannel();
  const longName = "x".repeat(256);
  const result = ch.bind(longName, (_payload) => "ok");
  assertNotEquals(result, 0, "256-char name must be rejected");
});

Deno.test("ipc/bind: exactly 255 char name accepted", () => {
  const ch = new IPCChannel();
  const maxName = "x".repeat(255);
  const result = ch.bind(maxName, (_payload) => "ok");
  assertEquals(result, 0, "255-char name must be accepted");
});

Deno.test("ipc/bind: bind to closed channel returns non-zero", () => {
  const ch = new IPCChannel();
  ch.close();
  const result = ch.bind("any-command", (_payload) => "ok");
  assertNotEquals(result, 0, "bind after close must fail");
});

Deno.test("ipc/bind: rebinding same command updates handler", () => {
  const ch = new IPCChannel();
  ch.bind("echo", (_p) => "first");
  ch.bind("echo", (_p) => "second");
  const result = ch.dispatch(makeMsg("src", "echo", "payload"));
  assertEquals(result, "second", "rebind should use new handler");
});

// ---------------------------------------------------------------------------
// Tests: channel dispatch
// ---------------------------------------------------------------------------

Deno.test("ipc/dispatch: message routed to correct handler", () => {
  const ch = new IPCChannel();
  ch.bind("ping", (_p) => "pong");
  ch.bind("greet", (p) => `hello ${p}`);

  assertEquals(ch.dispatch(makeMsg("src", "ping", {})), "pong");
  assertEquals(ch.dispatch(makeMsg("src", "greet", "world")), "hello world");
});

Deno.test("ipc/dispatch: unregistered command returns null", () => {
  const ch = new IPCChannel();
  const result = ch.dispatch(makeMsg("src", "unknown-command", {}));
  assertEquals(result, null);
});

Deno.test("ipc/dispatch: dispatch after close returns null", () => {
  const ch = new IPCChannel();
  ch.bind("ping", (_p) => "pong");
  ch.close();
  const result = ch.dispatch(makeMsg("src", "ping", {}));
  assertEquals(result, null, "closed channel must not dispatch");
});

Deno.test("ipc/dispatch: messages are logged in order", () => {
  const ch = new IPCChannel();
  ch.bind("a", (_p) => null);
  ch.bind("b", (_p) => null);
  ch.dispatch(makeMsg("src", "a", 1, 1));
  ch.dispatch(makeMsg("src", "b", 2, 2));
  ch.dispatch(makeMsg("src", "a", 3, 3));
  assertEquals(ch.messageCount(), 3);
});

// ---------------------------------------------------------------------------
// Tests: channel lifecycle
// ---------------------------------------------------------------------------

Deno.test("ipc/lifecycle: channel open → bind → dispatch → close", () => {
  const ch = new IPCChannel();
  assertEquals(ch.isOpen(), true, "channel starts open");

  const bindResult = ch.bind("save", (p) => ({ saved: p }));
  assertEquals(bindResult, 0, "bind succeeds");

  const result = ch.dispatch(makeMsg("frontend", "save", { data: "hello" }));
  assertEquals((result as Record<string, unknown>).saved, { data: "hello" });

  ch.close();
  assertEquals(ch.isOpen(), false, "channel is closed after close()");

  // Post-close operations must fail gracefully
  assertEquals(ch.dispatch(makeMsg("src", "save", {})), null);
  assertNotEquals(ch.bind("another", (_p) => "ok"), 0);
});

Deno.test("ipc/lifecycle: multiple channels are independent", () => {
  const ch1 = new IPCChannel();
  const ch2 = new IPCChannel();

  ch1.bind("cmd", (_p) => "channel1");
  ch2.bind("cmd", (_p) => "channel2");

  assertEquals(ch1.dispatch(makeMsg("src", "cmd", {})), "channel1");
  assertEquals(ch2.dispatch(makeMsg("src", "cmd", {})), "channel2");

  ch1.close();
  assertEquals(ch1.isOpen(), false, "ch1 closed");
  assertEquals(ch2.isOpen(), true, "ch2 still open");
});

// ---------------------------------------------------------------------------
// Tests: result code round-trip
// ---------------------------------------------------------------------------

const RESULT_MAP: [number, string][] = [
  [0, "Ok"],
  [1, "Error"],
  [2, "InvalidParam"],
  [3, "OutOfMemory"],
  [4, "NullPointer"],
  [5, "AlreadyConsumed"],
  [6, "ResourceLeaked"],
  [7, "DoubleFree"],
  [8, "WebviewUnavailable"],
  [9, "IPCProtocolError"],
  [10, "CapabilityDenied"],
  [11, "GuardLocked"],
];

Deno.test("ipc/result-codes: all 12 result codes are distinct integers", () => {
  const codes = RESULT_MAP.map(([code]) => code);
  const unique = new Set(codes);
  assertEquals(unique.size, 12, "all result codes must be unique");
});

Deno.test("ipc/result-codes: codes are contiguous 0..11", () => {
  const codes = RESULT_MAP.map(([code]) => code).sort((a, b) => a - b);
  for (let i = 0; i < codes.length; i++) {
    assertEquals(codes[i], i, `result code at position ${i} should be ${i}`);
  }
});
