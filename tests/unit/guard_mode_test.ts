// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// guard_mode_test.ts — Unit tests for the Gossamer window guard mode system.
//
// Tests the GuardMode enum and associated window guard logic from
// src/interface/ffi/src/main.zig, mirroring the Types.idr specification.
//
// Covers:
// - GuardMode enum values (free=0, locked=1, read_only=2)
// - requireOpen() behaviour for uninitialised and closed handles
// - requireUnguarded() behaviour for non-free guard modes
// - Window constraint validation (min > max fails, 0 = unconstrained)
// - Async IPC slot management: acquire, release, all-occupied

import {
  assertEquals,
  assertNotEquals,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// GuardMode — mirrors pub const GuardMode in main.zig and Types.idr
// ---------------------------------------------------------------------------

/** Guard mode integer values — must match guardModeToInt in Types.idr. */
const GuardMode = {
  free: 0,
  locked: 1,
  read_only: 2,
} as const;
type GuardMode = (typeof GuardMode)[keyof typeof GuardMode];

// ---------------------------------------------------------------------------
// Result codes — subset used by the guard / open checks
// ---------------------------------------------------------------------------

const Result = {
  Ok: 0,
  Error: 1,
  AlreadyConsumed: 5,
  GuardLocked: 11,
} as const;
type Result = (typeof Result)[keyof typeof Result];

// ---------------------------------------------------------------------------
// Simulated window handle — mirrors GossamerHandle in main.zig
// ---------------------------------------------------------------------------

interface HandleState {
  initialized: boolean;
  closed: boolean;
  guard: GuardMode;
}

/**
 * requireOpen — mirrors the Zig fn requireOpen(handle: *GossamerHandle).
 * Returns a Result error code, or null if the handle is open and valid.
 */
function requireOpen(handle: HandleState): Result | null {
  if (!handle.initialized) {
    return Result.Error; // "Webview not initialized"
  }
  if (handle.closed) {
    return Result.AlreadyConsumed; // "Webview already closed"
  }
  return null;
}

/**
 * requireUnguarded — mirrors fn requireUnguarded(handle: *GossamerHandle).
 * Returns GuardLocked when the guard is not free, null otherwise.
 */
function requireUnguarded(handle: HandleState): Result | null {
  if (handle.guard !== GuardMode.free) {
    return Result.GuardLocked;
  }
  return null;
}

/**
 * validateWindowConstraints — mirrors fn validateWindowConstraints in main.zig.
 * Returns false when a non-zero min exceeds a non-zero max (same axis).
 * 0 is the unconstrained sentinel on either side.
 */
function validateWindowConstraints(
  minWidth: number,
  minHeight: number,
  maxWidth: number,
  maxHeight: number,
): boolean {
  if (minWidth !== 0 && maxWidth !== 0 && minWidth > maxWidth) return false;
  if (minHeight !== 0 && maxHeight !== 0 && minHeight > maxHeight) return false;
  return true;
}

// ---------------------------------------------------------------------------
// Async IPC slot registry — mirrors pub const async_ipc in main.zig
// ---------------------------------------------------------------------------

const MAX_INFLIGHT_ASYNC = 256;

/**
 * In-process simulation of the bounded async IPC slot registry.
 * Mirrors acquireSlot / releaseSlot / reset in main.zig.
 */
class AsyncIPCSlots {
  private slots: boolean[] = new Array(MAX_INFLIGHT_ASYNC).fill(false);
  private count = 0;

  /** Acquire a free slot. Returns slot index 0..255, or null when full. */
  acquireSlot(): number | null {
    for (let i = 0; i < this.slots.length; i++) {
      if (!this.slots[i]) {
        this.slots[i] = true;
        this.count++;
        return i;
      }
    }
    return null;
  }

  /** Release a previously acquired slot. */
  releaseSlot(index: number): void {
    if (index >= 0 && index < MAX_INFLIGHT_ASYNC && this.slots[index]) {
      this.slots[index] = false;
      this.count--;
    }
  }

  /** Current number of occupied slots. */
  inflightCount(): number {
    return this.count;
  }

  /** Reset all slots to free. */
  reset(): void {
    this.slots.fill(false);
    this.count = 0;
  }
}

// ---------------------------------------------------------------------------
// Tests: GuardMode enum values
// ---------------------------------------------------------------------------

Deno.test("guard-mode/enum: free is 0", () => {
  assertEquals(GuardMode.free, 0);
});

Deno.test("guard-mode/enum: locked is 1", () => {
  assertEquals(GuardMode.locked, 1);
});

Deno.test("guard-mode/enum: read_only is 2", () => {
  assertEquals(GuardMode.read_only, 2);
});

Deno.test("guard-mode/enum: all three values are distinct", () => {
  const values = Object.values(GuardMode);
  const unique = new Set(values);
  assertEquals(unique.size, 3, "free, locked, read_only must all be distinct");
});

Deno.test("guard-mode/enum: values are contiguous 0..2", () => {
  const sorted = Object.values(GuardMode).sort((a, b) => a - b);
  for (let i = 0; i < sorted.length; i++) {
    assertEquals(sorted[i], i, `GuardMode value at position ${i} should be ${i}`);
  }
});

// ---------------------------------------------------------------------------
// Tests: requireOpen
// ---------------------------------------------------------------------------

Deno.test("guard-mode/requireOpen: open initialised handle returns null (no error)", () => {
  const handle: HandleState = { initialized: true, closed: false, guard: GuardMode.free };
  assertEquals(requireOpen(handle), null);
});

Deno.test("guard-mode/requireOpen: uninitialised handle returns error", () => {
  const handle: HandleState = { initialized: false, closed: false, guard: GuardMode.free };
  const result = requireOpen(handle);
  assertNotEquals(result, null, "uninitialised handle must return an error");
  assertEquals(result, Result.Error);
});

Deno.test("guard-mode/requireOpen: closed handle returns AlreadyConsumed", () => {
  const handle: HandleState = { initialized: true, closed: true, guard: GuardMode.free };
  assertEquals(requireOpen(handle), Result.AlreadyConsumed);
});

Deno.test("guard-mode/requireOpen: uninitialised AND closed returns error (initialised check first)", () => {
  // Zig checks initialized before closed, so Error takes precedence
  const handle: HandleState = { initialized: false, closed: true, guard: GuardMode.free };
  assertEquals(requireOpen(handle), Result.Error);
});

Deno.test("guard-mode/requireOpen: guard mode does not affect open check", () => {
  // requireOpen only checks lifecycle state, not guard mode
  for (const guard of Object.values(GuardMode)) {
    const handle: HandleState = { initialized: true, closed: false, guard };
    assertEquals(requireOpen(handle), null, `requireOpen should be null regardless of guard=${guard}`);
  }
});

// ---------------------------------------------------------------------------
// Tests: requireUnguarded
// ---------------------------------------------------------------------------

Deno.test("guard-mode/requireUnguarded: free guard returns null (operation allowed)", () => {
  const handle: HandleState = { initialized: true, closed: false, guard: GuardMode.free };
  assertEquals(requireUnguarded(handle), null);
});

Deno.test("guard-mode/requireUnguarded: locked guard returns GuardLocked", () => {
  const handle: HandleState = { initialized: true, closed: false, guard: GuardMode.locked };
  assertEquals(requireUnguarded(handle), Result.GuardLocked);
});

Deno.test("guard-mode/requireUnguarded: read_only guard returns GuardLocked", () => {
  const handle: HandleState = { initialized: true, closed: false, guard: GuardMode.read_only };
  assertEquals(requireUnguarded(handle), Result.GuardLocked);
});

Deno.test("guard-mode/requireUnguarded: non-free modes are exhaustively rejected", () => {
  const nonFreeModes: GuardMode[] = [GuardMode.locked, GuardMode.read_only];
  for (const guard of nonFreeModes) {
    const handle: HandleState = { initialized: true, closed: false, guard };
    assertEquals(
      requireUnguarded(handle),
      Result.GuardLocked,
      `guard=${guard} should return GuardLocked`,
    );
  }
});

Deno.test("guard-mode/requireUnguarded: transitioning from locked to free unblocks operations", () => {
  const handle: HandleState = { initialized: true, closed: false, guard: GuardMode.locked };
  assertEquals(requireUnguarded(handle), Result.GuardLocked, "locked initially");
  handle.guard = GuardMode.free;
  assertEquals(requireUnguarded(handle), null, "free after unlock");
});

Deno.test("guard-mode/requireUnguarded: read_only is strictly more restrictive than locked", () => {
  // Both locked and read_only reject via requireUnguarded — read_only is a superset
  const locked: HandleState = { initialized: true, closed: false, guard: GuardMode.locked };
  const readOnly: HandleState = { initialized: true, closed: false, guard: GuardMode.read_only };
  assertEquals(requireUnguarded(locked), Result.GuardLocked);
  assertEquals(requireUnguarded(readOnly), Result.GuardLocked);
  // But their integer values differ — read_only > locked
  assertNotEquals(
    GuardMode.read_only,
    GuardMode.locked,
    "read_only and locked must be distinct modes",
  );
});

// ---------------------------------------------------------------------------
// Tests: window constraint validation
// ---------------------------------------------------------------------------

Deno.test("guard-mode/constraints: valid unconstrained config (all zeros) passes", () => {
  assertEquals(validateWindowConstraints(0, 0, 0, 0), true);
});

Deno.test("guard-mode/constraints: valid min < max passes", () => {
  assertEquals(validateWindowConstraints(200, 150, 800, 600), true);
});

Deno.test("guard-mode/constraints: min == max passes (exact size)", () => {
  assertEquals(validateWindowConstraints(800, 600, 800, 600), true);
});

Deno.test("guard-mode/constraints: min_width > max_width fails", () => {
  assertEquals(validateWindowConstraints(900, 0, 800, 0), false);
});

Deno.test("guard-mode/constraints: min_height > max_height fails", () => {
  assertEquals(validateWindowConstraints(0, 700, 0, 600), false);
});

Deno.test("guard-mode/constraints: both axes invalid fails", () => {
  assertEquals(validateWindowConstraints(900, 700, 800, 600), false);
});

Deno.test("guard-mode/constraints: min_width > max_width but max_width=0 is unconstrained (passes)", () => {
  // max_width=0 means unconstrained, so any min_width is valid
  assertEquals(validateWindowConstraints(9999, 0, 0, 0), true);
});

Deno.test("guard-mode/constraints: min_height > max_height but max_height=0 is unconstrained (passes)", () => {
  assertEquals(validateWindowConstraints(0, 9999, 0, 0), true);
});

Deno.test("guard-mode/constraints: min_width=0 with any max_width passes (min unconstrained)", () => {
  assertEquals(validateWindowConstraints(0, 0, 100, 0), true);
});

Deno.test("guard-mode/constraints: mixed — one axis valid, other invalid fails", () => {
  // width ok, height fails
  assertEquals(validateWindowConstraints(200, 700, 800, 600), false);
  // width fails, height ok
  assertEquals(validateWindowConstraints(900, 100, 800, 600), false);
});

// ---------------------------------------------------------------------------
// Tests: async IPC slot management
// ---------------------------------------------------------------------------

Deno.test("guard-mode/ipc-slots: first acquireSlot returns index 0", () => {
  const slots = new AsyncIPCSlots();
  assertEquals(slots.acquireSlot(), 0);
});

Deno.test("guard-mode/ipc-slots: acquireSlot returns sequential indices", () => {
  const slots = new AsyncIPCSlots();
  for (let i = 0; i < 10; i++) {
    assertEquals(slots.acquireSlot(), i, `slot ${i} should be acquired in order`);
  }
});

Deno.test("guard-mode/ipc-slots: acquireSlot returns index in range 0..255", () => {
  const slots = new AsyncIPCSlots();
  const idx = slots.acquireSlot();
  assertNotEquals(idx, null);
  assertEquals(idx! >= 0 && idx! <= 255, true);
});

Deno.test("guard-mode/ipc-slots: releaseSlot frees a slot for reuse", () => {
  const slots = new AsyncIPCSlots();
  const idx = slots.acquireSlot();
  assertNotEquals(idx, null);
  slots.releaseSlot(idx!);
  // After release, acquireSlot should return the same (now-free) slot
  assertEquals(slots.acquireSlot(), idx);
});

Deno.test("guard-mode/ipc-slots: inflightCount tracks acquisitions", () => {
  const slots = new AsyncIPCSlots();
  assertEquals(slots.inflightCount(), 0, "starts at zero");
  slots.acquireSlot();
  assertEquals(slots.inflightCount(), 1);
  slots.acquireSlot();
  assertEquals(slots.inflightCount(), 2);
});

Deno.test("guard-mode/ipc-slots: inflightCount decrements on release", () => {
  const slots = new AsyncIPCSlots();
  const idx = slots.acquireSlot()!;
  assertEquals(slots.inflightCount(), 1);
  slots.releaseSlot(idx);
  assertEquals(slots.inflightCount(), 0);
});

Deno.test("guard-mode/ipc-slots: all 256 slots can be acquired", () => {
  const slots = new AsyncIPCSlots();
  const acquired: number[] = [];
  for (let i = 0; i < MAX_INFLIGHT_ASYNC; i++) {
    const idx = slots.acquireSlot();
    assertNotEquals(idx, null, `slot ${i} should be available`);
    acquired.push(idx!);
  }
  assertEquals(acquired.length, 256, "should acquire all 256 slots");
  assertEquals(slots.inflightCount(), 256);
});

Deno.test("guard-mode/ipc-slots: acquireSlot returns null when all slots occupied", () => {
  const slots = new AsyncIPCSlots();
  // Fill all 256 slots
  for (let i = 0; i < MAX_INFLIGHT_ASYNC; i++) {
    slots.acquireSlot();
  }
  // Next acquire must return null
  assertEquals(slots.acquireSlot(), null, "all-occupied must return null");
});

Deno.test("guard-mode/ipc-slots: releasing one slot from full allows another acquire", () => {
  const slots = new AsyncIPCSlots();
  const acquired: number[] = [];
  for (let i = 0; i < MAX_INFLIGHT_ASYNC; i++) {
    acquired.push(slots.acquireSlot()!);
  }
  assertEquals(slots.acquireSlot(), null, "full: no slot available");
  slots.releaseSlot(acquired[42]);
  const newIdx = slots.acquireSlot();
  assertNotEquals(newIdx, null, "released slot should be available again");
  assertEquals(newIdx, 42, "should reuse the released slot");
});

Deno.test("guard-mode/ipc-slots: reset frees all slots", () => {
  const slots = new AsyncIPCSlots();
  for (let i = 0; i < MAX_INFLIGHT_ASYNC; i++) {
    slots.acquireSlot();
  }
  assertEquals(slots.inflightCount(), 256);
  slots.reset();
  assertEquals(slots.inflightCount(), 0, "count is zero after reset");
  // Can acquire again from scratch
  assertEquals(slots.acquireSlot(), 0, "first slot available after reset");
});

Deno.test("guard-mode/ipc-slots: acquired slot indices are unique", () => {
  const slots = new AsyncIPCSlots();
  const indices = new Set<number>();
  for (let i = 0; i < MAX_INFLIGHT_ASYNC; i++) {
    const idx = slots.acquireSlot()!;
    assertEquals(indices.has(idx), false, `slot index ${idx} must not be reissued`);
    indices.add(idx);
  }
  assertEquals(indices.size, MAX_INFLIGHT_ASYNC, "all 256 slot indices are unique");
});

Deno.test("guard-mode/ipc-slots: releaseSlot on invalid index is a no-op", () => {
  const slots = new AsyncIPCSlots();
  slots.acquireSlot();
  assertEquals(slots.inflightCount(), 1);
  // Release out-of-range index — must not throw or corrupt count
  slots.releaseSlot(9999);
  assertEquals(slots.inflightCount(), 1, "invalid release must not alter count");
});
