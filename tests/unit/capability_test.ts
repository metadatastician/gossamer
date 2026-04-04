// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// capability_test.ts — Unit tests for the Gossamer capability system.
//
// Tests the capability token model: grant, check, revoke, resource kind mapping.
// All tests run without FFI — the capability model is exercised as TypeScript
// contracts mirroring Capabilities.eph and Types.idr.

import {
  assertEquals,
  assertNotEquals,
  assertThrows,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// Capability model mirroring Capabilities.eph + Types.idr
// ---------------------------------------------------------------------------

/** Resource kind ordinals — must match Capabilities.eph RESOURCE_* constants */
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

/** Result codes — must match resultToInt in Types.idr */
const Result = {
  Ok: 0,
  Error: 1,
  InvalidParam: 2,
  OutOfMemory: 3,
  NullPointer: 4,
  AlreadyConsumed: 5,
  ResourceLeaked: 6,
  DoubleFree: 7,
  WebviewUnavailable: 8,
  IPCProtocolError: 9,
  CapabilityDenied: 10,
  GuardLocked: 11,
} as const;
type Result = (typeof Result)[keyof typeof Result];

/** In-memory capability registry — mirrors ffi/zig gossamer_cap_* functions */
class CapabilityRegistry {
  private nextToken: bigint = 1n;
  private tokens: Map<bigint, { kind: ResourceKind; revoked: boolean }> =
    new Map();

  /**
   * Grant a capability token for the given resource kind.
   * Returns a non-zero token (linear — must be revoked), or 0n on failure.
   */
  grant(kind: ResourceKind): bigint {
    if (kind < 0 || kind > 6) return 0n;
    const token = this.nextToken++;
    this.tokens.set(token, { kind, revoked: false });
    return token;
  }

  /**
   * Check a capability token. Returns Result.Ok if active, Result.CapabilityDenied otherwise.
   * Borrows the token — does NOT consume it.
   */
  check(token: bigint): Result {
    const entry = this.tokens.get(token);
    if (!entry || entry.revoked) return Result.CapabilityDenied;
    return Result.Ok;
  }

  /**
   * Query the resource kind for a token. Returns 0xFFFFFFFF if invalid.
   */
  resourceKind(token: bigint): number {
    const entry = this.tokens.get(token);
    if (!entry) return 0xffffffff;
    return entry.kind;
  }

  /**
   * Revoke a capability token. CONSUMES it — future check() calls will fail.
   */
  revoke(token: bigint): void {
    const entry = this.tokens.get(token);
    if (entry) entry.revoked = true;
  }

  /** Count active (non-revoked) tokens — useful for test assertions */
  activeCount(): number {
    let count = 0;
    for (const entry of this.tokens.values()) {
      if (!entry.revoked) count++;
    }
    return count;
  }
}

// ---------------------------------------------------------------------------
// Tests: grant
// ---------------------------------------------------------------------------

Deno.test("capability/grant: returns non-zero token for valid resource kinds", () => {
  const reg = new CapabilityRegistry();
  for (const kind of Object.values(ResourceKind)) {
    const token = reg.grant(kind);
    assertNotEquals(token, 0n, `grant(${kind}) should return non-zero token`);
  }
});

Deno.test("capability/grant: each grant returns a unique token", () => {
  const reg = new CapabilityRegistry();
  const tokens = new Set<bigint>();
  for (let i = 0; i < 100; i++) {
    const token = reg.grant(ResourceKind.Filesystem);
    tokens.add(token);
  }
  assertEquals(tokens.size, 100, "100 grants must produce 100 unique tokens");
});

Deno.test("capability/grant: returns 0 for invalid resource kind", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(99 as ResourceKind);
  assertEquals(token, 0n, "invalid resource kind should yield null token");
});

Deno.test("capability/grant: multiple grants for same resource are independent", () => {
  const reg = new CapabilityRegistry();
  const t1 = reg.grant(ResourceKind.Shell);
  const t2 = reg.grant(ResourceKind.Shell);
  assertNotEquals(t1, t2, "two grants for same resource must be distinct tokens");
  // Revoking one must not affect the other
  reg.revoke(t1);
  assertEquals(reg.check(t1), Result.CapabilityDenied);
  assertEquals(reg.check(t2), Result.Ok);
});

// ---------------------------------------------------------------------------
// Tests: check
// ---------------------------------------------------------------------------

Deno.test("capability/check: active token returns Ok", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(ResourceKind.Filesystem);
  assertEquals(reg.check(token), Result.Ok);
});

Deno.test("capability/check: revoked token returns CapabilityDenied", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(ResourceKind.Network);
  reg.revoke(token);
  assertEquals(reg.check(token), Result.CapabilityDenied);
});

Deno.test("capability/check: forged token returns CapabilityDenied", () => {
  const reg = new CapabilityRegistry();
  // Token 9999n was never granted
  assertEquals(reg.check(9999n), Result.CapabilityDenied);
});

Deno.test("capability/check: null token (0n) returns CapabilityDenied", () => {
  const reg = new CapabilityRegistry();
  assertEquals(reg.check(0n), Result.CapabilityDenied);
});

Deno.test("capability/check: borrow does not consume — check is idempotent", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(ResourceKind.Clipboard);
  // Multiple checks should all succeed
  for (let i = 0; i < 10; i++) {
    assertEquals(reg.check(token), Result.Ok, `check ${i} should be Ok`);
  }
});

// ---------------------------------------------------------------------------
// Tests: revoke
// ---------------------------------------------------------------------------

Deno.test("capability/revoke: revoked token fails subsequent check", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(ResourceKind.Tray);
  assertEquals(reg.check(token), Result.Ok);
  reg.revoke(token);
  assertEquals(reg.check(token), Result.CapabilityDenied);
});

Deno.test("capability/revoke: double revoke is safe (idempotent)", () => {
  const reg = new CapabilityRegistry();
  const token = reg.grant(ResourceKind.Notification);
  reg.revoke(token);
  // Second revoke must not throw
  reg.revoke(token);
  assertEquals(reg.check(token), Result.CapabilityDenied);
});

Deno.test("capability/revoke: revoking one token does not affect others", () => {
  const reg = new CapabilityRegistry();
  const fs = reg.grant(ResourceKind.Filesystem);
  const net = reg.grant(ResourceKind.Network);
  const sh = reg.grant(ResourceKind.Shell);
  reg.revoke(net);
  assertEquals(reg.check(fs), Result.Ok, "filesystem token unaffected");
  assertEquals(reg.check(net), Result.CapabilityDenied, "network revoked");
  assertEquals(reg.check(sh), Result.Ok, "shell token unaffected");
});

Deno.test("capability/revoke: all tokens revoked leaves zero active", () => {
  const reg = new CapabilityRegistry();
  const tokens = Object.values(ResourceKind).map((k) => reg.grant(k));
  tokens.forEach((t) => reg.revoke(t));
  assertEquals(reg.activeCount(), 0, "all tokens revoked → zero active");
});

// ---------------------------------------------------------------------------
// Tests: resourceKind
// ---------------------------------------------------------------------------

Deno.test("capability/resourceKind: returns correct kind for granted token", () => {
  const reg = new CapabilityRegistry();
  for (const [name, kind] of Object.entries(ResourceKind)) {
    const token = reg.grant(kind);
    assertEquals(
      reg.resourceKind(token),
      kind,
      `resourceKind for ${name} token should be ${kind}`,
    );
  }
});

Deno.test("capability/resourceKind: returns 0xFFFFFFFF for unknown token", () => {
  const reg = new CapabilityRegistry();
  assertEquals(reg.resourceKind(99999n), 0xffffffff);
});

// ---------------------------------------------------------------------------
// Tests: capability count / lifecycle
// ---------------------------------------------------------------------------

Deno.test("capability/lifecycle: grant→check→revoke full cycle", () => {
  const reg = new CapabilityRegistry();
  assertEquals(reg.activeCount(), 0, "start with zero active tokens");

  const token = reg.grant(ResourceKind.Groove);
  assertEquals(reg.activeCount(), 1);
  assertEquals(reg.check(token), Result.Ok);

  reg.revoke(token);
  assertEquals(reg.activeCount(), 0, "after revoke: zero active tokens");
  assertEquals(reg.check(token), Result.CapabilityDenied);
});

Deno.test("capability/lifecycle: capabilities are strictly additive — grant cannot remove", () => {
  const reg = new CapabilityRegistry();
  const t1 = reg.grant(ResourceKind.Filesystem);
  const t2 = reg.grant(ResourceKind.Filesystem);
  // Granting a new token must not affect previously granted tokens
  assertEquals(reg.check(t1), Result.Ok, "t1 still active after t2 granted");
  assertEquals(reg.check(t2), Result.Ok, "t2 is also active");
  assertEquals(reg.activeCount(), 2, "two active filesystem capabilities");
});
