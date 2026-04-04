// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// webview_lifecycle_test.ts — E2E lifecycle simulation for the Gossamer webview shell.
//
// Simulates the full webview lifecycle and integration flows using mocked FFI:
//   - WebviewHandle state machine: Created → Loaded → Running → Destroyed
//   - IPC request/response round-trip via mocked channel
//   - Capability grant → use → revoke sequence
//   - Error propagation through the handle lifecycle
//
// No native code is invoked. All FFI calls are intercepted by MockFFI.

import {
  assertEquals,
  assertNotEquals,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// WebviewState — mirrors Types.idr WebviewState
// ---------------------------------------------------------------------------

type WebviewState = "Created" | "Loaded" | "Running" | "Destroyed";

/** Valid transitions — mirrors ValidTransition in Types.idr */
const VALID_TRANSITIONS: Record<WebviewState, WebviewState[]> = {
  Created: ["Loaded", "Destroyed"],
  Loaded: ["Loaded", "Running", "Destroyed"],
  Running: ["Destroyed"],
  Destroyed: [],
};

// ---------------------------------------------------------------------------
// Mock FFI — intercepts gossamer_* calls
// ---------------------------------------------------------------------------

interface FFICall {
  fn: string;
  args: unknown[];
}

class MockFFI {
  readonly calls: FFICall[] = [];
  private handleCounter = 1000n;
  private channelCounter = 2000n;
  private capCounter = 3000n;
  private revokedCaps = new Set<bigint>();
  private failOnNext: string | null = null;

  /** Cause the next call to a named FFI function to return an error */
  setFailNext(fn: string): void {
    this.failOnNext = fn;
  }

  private record(fn: string, args: unknown[]): void {
    this.calls.push({ fn, args });
  }

  private shouldFail(fn: string): boolean {
    if (this.failOnNext === fn) {
      this.failOnNext = null;
      return true;
    }
    return false;
  }

  gossamer_create(_title: string, _w: number, _h: number): bigint {
    this.record("gossamer_create", [_title, _w, _h]);
    if (this.shouldFail("gossamer_create")) return 0n;
    return this.handleCounter++;
  }

  gossamer_load_html(handle: bigint, _html: string): number {
    this.record("gossamer_load_html", [handle, _html]);
    if (this.shouldFail("gossamer_load_html")) return 1;
    return 0;
  }

  gossamer_navigate(handle: bigint, _url: string): number {
    this.record("gossamer_navigate", [handle, _url]);
    if (this.shouldFail("gossamer_navigate")) return 1;
    return 0;
  }

  gossamer_eval(handle: bigint, _js: string): number {
    this.record("gossamer_eval", [handle, _js]);
    return 0;
  }

  gossamer_set_title(handle: bigint, _title: string): number {
    this.record("gossamer_set_title", [handle, _title]);
    return 0;
  }

  gossamer_run(handle: bigint): void {
    this.record("gossamer_run", [handle]);
  }

  gossamer_destroy(handle: bigint): void {
    this.record("gossamer_destroy", [handle]);
  }

  gossamer_channel_open(handle: bigint): bigint {
    this.record("gossamer_channel_open", [handle]);
    return this.channelCounter++;
  }

  gossamer_channel_bind(
    channel: bigint,
    name: string,
    _cb: bigint,
    _userData: bigint,
  ): number {
    this.record("gossamer_channel_bind", [channel, name]);
    return 0;
  }

  gossamer_channel_close(channel: bigint): void {
    this.record("gossamer_channel_close", [channel]);
  }

  gossamer_cap_grant(kind: number): bigint {
    this.record("gossamer_cap_grant", [kind]);
    if (this.shouldFail("gossamer_cap_grant")) return 0n;
    return this.capCounter++;
  }

  gossamer_cap_check(token: bigint): number {
    this.record("gossamer_cap_check", [token]);
    // Token 0n is the null/invalid token — always denied
    if (token === 0n) return 10;
    return this.revokedCaps.has(token) ? 10 : 0;
  }

  gossamer_cap_revoke(token: bigint): void {
    this.record("gossamer_cap_revoke", [token]);
    this.revokedCaps.add(token);
  }

  /** Count calls to a specific FFI function */
  countCalls(fn: string): number {
    return this.calls.filter((c) => c.fn === fn).length;
  }
}

// ---------------------------------------------------------------------------
// Webview shell — thin wrapper exercising the FFI via state machine
// ---------------------------------------------------------------------------

class WebviewShell {
  private state: WebviewState = "Created";
  private handle: bigint;

  constructor(private ffi: MockFFI, title: string, w = 800, h = 600) {
    this.handle = ffi.gossamer_create(title, w, h);
    if (this.handle === 0n) {
      throw new Error("gossamer_create failed: got null handle");
    }
  }

  getState(): WebviewState {
    return this.state;
  }

  loadHTML(html: string): number {
    this.assertValidTransition("Loaded");
    const result = this.ffi.gossamer_load_html(this.handle, html);
    if (result === 0) this.state = "Loaded";
    return result;
  }

  navigate(url: string): number {
    this.assertValidTransition("Loaded");
    const result = this.ffi.gossamer_navigate(this.handle, url);
    if (result === 0) this.state = "Loaded";
    return result;
  }

  eval(js: string): number {
    return this.ffi.gossamer_eval(this.handle, js);
  }

  setTitle(title: string): number {
    return this.ffi.gossamer_set_title(this.handle, title);
  }

  run(): void {
    this.assertValidTransition("Running");
    this.ffi.gossamer_run(this.handle);
    this.state = "Destroyed";
  }

  destroy(): void {
    this.assertValidTransition("Destroyed");
    this.ffi.gossamer_destroy(this.handle);
    this.state = "Destroyed";
  }

  private assertValidTransition(to: WebviewState): void {
    const allowed = VALID_TRANSITIONS[this.state];
    if (!allowed.includes(to)) {
      throw new Error(
        `Invalid transition: ${this.state} → ${to}. Allowed: ${allowed.join(", ")}`,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Tests: webview lifecycle state machine
// ---------------------------------------------------------------------------

Deno.test("e2e/lifecycle: Created → Loaded → Running → Destroyed", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Test Window");

  assertEquals(w.getState(), "Created");

  const loadResult = w.loadHTML("<html><body>Hello</body></html>");
  assertEquals(loadResult, 0);
  assertEquals(w.getState(), "Loaded");

  w.run();
  assertEquals(w.getState(), "Destroyed");

  // Verify FFI call sequence
  assertEquals(ffi.countCalls("gossamer_create"), 1);
  assertEquals(ffi.countCalls("gossamer_load_html"), 1);
  assertEquals(ffi.countCalls("gossamer_run"), 1);
});

Deno.test("e2e/lifecycle: Created → navigate → Running → Destroyed", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Nav Window");

  assertEquals(w.getState(), "Created");
  const navResult = w.navigate("https://example.com");
  assertEquals(navResult, 0);
  assertEquals(w.getState(), "Loaded");

  w.run();
  assertEquals(w.getState(), "Destroyed");
});

Deno.test("e2e/lifecycle: Created → Loaded → Destroyed (without run)", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Destroy Window");

  w.loadHTML("<html></html>");
  assertEquals(w.getState(), "Loaded");

  w.destroy();
  assertEquals(w.getState(), "Destroyed");
  assertEquals(ffi.countCalls("gossamer_destroy"), 1);
});

Deno.test("e2e/lifecycle: Created → Destroyed (skip load)", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Empty");

  assertEquals(w.getState(), "Created");
  w.destroy();
  assertEquals(w.getState(), "Destroyed");
});

Deno.test("e2e/lifecycle: Loaded → Loaded (reload content)", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Reload");

  w.loadHTML("<h1>First</h1>");
  assertEquals(w.getState(), "Loaded");

  w.loadHTML("<h1>Second</h1>");
  assertEquals(w.getState(), "Loaded");

  assertEquals(ffi.countCalls("gossamer_load_html"), 2);
});

Deno.test("e2e/lifecycle: invalid transition throws", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "BadTransition");

  w.loadHTML("<html></html>");
  w.run(); // → Destroyed

  let threw = false;
  try {
    w.loadHTML("<html>after destroy</html>"); // invalid: Destroyed → Loaded
  } catch {
    threw = true;
  }
  assertEquals(threw, true, "Destroyed → Loaded must throw");
});

Deno.test("e2e/lifecycle: create failure throws", () => {
  const ffi = new MockFFI();
  ffi.setFailNext("gossamer_create");

  let threw = false;
  try {
    new WebviewShell(ffi, "FailCreate");
  } catch {
    threw = true;
  }
  assertEquals(threw, true, "null handle from create must throw");
});

// ---------------------------------------------------------------------------
// Tests: IPC round-trip
// ---------------------------------------------------------------------------

Deno.test("e2e/ipc: open channel → bind → simulate round-trip → close", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "IPC Window");
  w.loadHTML("<html></html>");

  const channel = ffi.gossamer_channel_open(1000n);
  assertNotEquals(channel, 0n, "channel handle must be non-zero");

  const bindResult = ffi.gossamer_channel_bind(channel, "open-file", 0n, 0n);
  assertEquals(bindResult, 0, "bind must succeed");

  // Simulate round-trip: eval JS to trigger handler
  const evalResult = w.eval("window.__gossamer.send('open-file', {})");
  assertEquals(evalResult, 0);

  ffi.gossamer_channel_close(channel);
  assertEquals(ffi.countCalls("gossamer_channel_close"), 1);

  w.destroy();
});

Deno.test("e2e/ipc: multiple commands can be bound", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Multi IPC");
  w.loadHTML("<html></html>");

  const channel = ffi.gossamer_channel_open(1000n);
  const commands = ["open-file", "save-file", "close-dialog", "list-dir"];

  for (const cmd of commands) {
    const r = ffi.gossamer_channel_bind(channel, cmd, 0n, 0n);
    assertEquals(r, 0, `bind ${cmd} must succeed`);
  }

  assertEquals(ffi.countCalls("gossamer_channel_bind"), commands.length);

  ffi.gossamer_channel_close(channel);
  w.destroy();
});

// ---------------------------------------------------------------------------
// Tests: capability lifecycle
// ---------------------------------------------------------------------------

Deno.test("e2e/capability: grant → check → use → revoke", () => {
  const ffi = new MockFFI();

  // Grant filesystem capability
  const token = ffi.gossamer_cap_grant(0 /* Filesystem */);
  assertNotEquals(token, 0n, "granted token must be non-zero");

  // Check before use
  assertEquals(ffi.gossamer_cap_check(token), 0 /* Ok */);

  // Simulate gated operation (eval with capability)
  const w = new WebviewShell(ffi, "Cap Window");
  w.loadHTML("<html></html>");
  w.eval("// gated filesystem read");

  // Revoke
  ffi.gossamer_cap_revoke(token);

  // Check after revoke
  assertEquals(ffi.gossamer_cap_check(token), 10 /* CapabilityDenied */);

  w.destroy();
});

Deno.test("e2e/capability: revoke blocks subsequent operations", () => {
  const ffi = new MockFFI();
  const shellToken = ffi.gossamer_cap_grant(2 /* Shell */);
  const fsToken = ffi.gossamer_cap_grant(0 /* Filesystem */);

  // Both active
  assertEquals(ffi.gossamer_cap_check(shellToken), 0);
  assertEquals(ffi.gossamer_cap_check(fsToken), 0);

  // Revoke shell
  ffi.gossamer_cap_revoke(shellToken);

  // Shell denied, filesystem still active
  assertEquals(ffi.gossamer_cap_check(shellToken), 10, "shell must be denied");
  assertEquals(ffi.gossamer_cap_check(fsToken), 0, "filesystem still ok");
});

Deno.test("e2e/capability: grant failure (0n) must be handled", () => {
  const ffi = new MockFFI();
  ffi.setFailNext("gossamer_cap_grant");

  const token = ffi.gossamer_cap_grant(0);
  assertEquals(token, 0n, "failed grant returns 0n");

  // Checking a null token must return denied
  assertEquals(ffi.gossamer_cap_check(0n), 10, "null token must be denied");
});

// ---------------------------------------------------------------------------
// Tests: window control operations
// ---------------------------------------------------------------------------

Deno.test("e2e/window: set title after load succeeds", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "Original Title");
  w.loadHTML("<html></html>");

  const r = w.setTitle("New Title");
  assertEquals(r, 0);
  assertEquals(ffi.countCalls("gossamer_set_title"), 1);

  w.destroy();
});

Deno.test("e2e/window: eval JS after load succeeds", () => {
  const ffi = new MockFFI();
  const w = new WebviewShell(ffi, "JS Window");
  w.loadHTML("<html><body><div id='app'></div></body></html>");

  const r = w.eval("document.getElementById('app').textContent = 'Gossamer';");
  assertEquals(r, 0);

  w.run();
});

// ---------------------------------------------------------------------------
// Tests: multi-window independence
// ---------------------------------------------------------------------------

Deno.test("e2e/multi-window: two windows have independent state machines", () => {
  const ffi = new MockFFI();
  const w1 = new WebviewShell(ffi, "Window 1");
  const w2 = new WebviewShell(ffi, "Window 2");

  w1.loadHTML("<h1>W1</h1>");
  assertEquals(w1.getState(), "Loaded");
  assertEquals(w2.getState(), "Created", "w2 unaffected by w1 load");

  w2.navigate("https://gossamer.example");
  assertEquals(w2.getState(), "Loaded");

  w1.destroy();
  assertEquals(w1.getState(), "Destroyed");
  assertEquals(w2.getState(), "Loaded", "w2 unaffected by w1 destroy");

  w2.run();
  assertEquals(w2.getState(), "Destroyed");

  assertEquals(ffi.countCalls("gossamer_create"), 2);
});
