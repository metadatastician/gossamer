// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// startup_bench.ts — Benchmarks for Gossamer initialization metrics.
//
// Benchmarks using Deno.bench (built-in harness):
//   - WindowConfig creation time
//   - IPC channel creation + bind + dispatch round-trip
//   - Result code lookup time
//   - Capability set subset checking time
//
// Run with: deno bench --allow-env tests/bench/startup_bench.ts

// ---------------------------------------------------------------------------
// WindowConfig creation
// ---------------------------------------------------------------------------

interface WindowConfig {
  label: string;
  title: string;
  width: number;
  height: number;
  minWidth: number | null;
  minHeight: number | null;
  maxWidth: number | null;
  maxHeight: number | null;
  resizable: boolean;
  fullscreen: boolean;
  decorations: boolean;
  transparent: boolean;
  center: boolean;
  alwaysOnTop: boolean;
  visible: boolean;
  url: string;
}

const WINDOW_CONFIGS: WindowConfig[] = [
  {
    label: "main",
    title: "My Gossamer App",
    width: 1400,
    height: 900,
    minWidth: 1000,
    minHeight: 600,
    maxWidth: null,
    maxHeight: null,
    resizable: true,
    fullscreen: false,
    decorations: true,
    transparent: false,
    center: true,
    alwaysOnTop: false,
    visible: true,
    url: "/",
  },
  {
    label: "settings",
    title: "Settings",
    width: 800,
    height: 600,
    minWidth: 600,
    minHeight: 400,
    maxWidth: 1200,
    maxHeight: 1000,
    resizable: true,
    fullscreen: false,
    decorations: true,
    transparent: false,
    center: true,
    alwaysOnTop: false,
    visible: false,
    url: "/settings",
  },
];

Deno.bench("startup/window-config: create single config", { group: "startup" }, () => {
  const config: WindowConfig = {
    label: "main",
    title: "App",
    width: 800,
    height: 600,
    minWidth: 400,
    minHeight: 300,
    maxWidth: null,
    maxHeight: null,
    resizable: true,
    fullscreen: false,
    decorations: true,
    transparent: false,
    center: true,
    alwaysOnTop: false,
    visible: true,
    url: "/",
  };
});

Deno.bench("startup/window-config: create 10 configs", { group: "startup" }, () => {
  for (let i = 0; i < 10; i++) {
    const config: WindowConfig = {
      label: `window-${i}`,
      title: `Window ${i}`,
      width: 1024 + i * 10,
      height: 768 + i * 10,
      minWidth: 600,
      minHeight: 400,
      maxWidth: null,
      maxHeight: null,
      resizable: true,
      fullscreen: false,
      decorations: true,
      transparent: false,
      center: true,
      alwaysOnTop: false,
      visible: true,
      url: `/window-${i}`,
    };
  }
});

Deno.bench(
  "startup/window-config: clone config with Object.assign",
  { group: "startup" },
  () => {
    const original = WINDOW_CONFIGS[0];
    Object.assign({}, original);
  },
);

// ---------------------------------------------------------------------------
// IPC channel creation + bind + dispatch
// ---------------------------------------------------------------------------

interface IPCChannel {
  id: bigint;
  name: string;
  bound: boolean;
  messageCount: number;
}

class IPCChannelManager {
  private channels: Map<bigint, IPCChannel>;
  private nextId: bigint;

  constructor() {
    this.channels = new Map();
    this.nextId = 1n;
  }

  create(name: string): bigint {
    const id = this.nextId++;
    this.channels.set(id, {
      id,
      name,
      bound: false,
      messageCount: 0,
    });
    return id;
  }

  bind(id: bigint): boolean {
    const ch = this.channels.get(id);
    if (!ch) return false;
    ch.bound = true;
    return true;
  }

  dispatch(id: bigint): boolean {
    const ch = this.channels.get(id);
    if (!ch || !ch.bound) return false;
    ch.messageCount++;
    return true;
  }

  close(id: bigint): boolean {
    return this.channels.delete(id);
  }
}

const ipcManager = new IPCChannelManager();

// Pre-create some channels for dispatch benchmarks
const preCreatedChannels: bigint[] = [];
for (let i = 0; i < 100; i++) {
  const id = ipcManager.create(`channel-${i}`);
  ipcManager.bind(id);
  preCreatedChannels.push(id);
}

Deno.bench("startup/ipc: create single channel", { group: "ipc-startup" }, () => {
  ipcManager.create("test-channel");
});

Deno.bench("startup/ipc: create + bind channel", { group: "ipc-startup" }, () => {
  const id = ipcManager.create("bound-channel");
  ipcManager.bind(id);
});

Deno.bench(
  "startup/ipc: create + bind + dispatch round-trip",
  { group: "ipc-startup" },
  () => {
    const id = ipcManager.create("round-trip-channel");
    ipcManager.bind(id);
    ipcManager.dispatch(id);
  },
);

Deno.bench("startup/ipc: dispatch 100 times on bound channel", { group: "ipc-startup" }, () => {
  const ch = preCreatedChannels[0];
  for (let i = 0; i < 100; i++) {
    ipcManager.dispatch(ch);
  }
});

Deno.bench(
  "startup/ipc: dispatch on 100 different channels (scatter)",
  { group: "ipc-startup" },
  () => {
    for (let i = 0; i < 100; i++) {
      ipcManager.dispatch(preCreatedChannels[i]);
    }
  },
);

// ---------------------------------------------------------------------------
// Result code lookup
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
  12: "TimeoutExpired",
  13: "ThreadPanic",
  14: "DeadlockDetected",
};

function resultToName(code: number): string | undefined {
  return RESULT_MAP[code];
}

Deno.bench("startup/result: single code lookup (Ok)", { group: "result-startup" }, () => {
  resultToName(0);
});

Deno.bench(
  "startup/result: single code lookup (middle value)",
  { group: "result-startup" },
  () => {
    resultToName(7);
  },
);

Deno.bench(
  "startup/result: single code lookup (high value)",
  { group: "result-startup" },
  () => {
    resultToName(14);
  },
);

Deno.bench("startup/result: all 15 code lookups", { group: "result-startup" }, () => {
  for (let i = 0; i <= 14; i++) {
    resultToName(i);
  }
});

Deno.bench(
  "startup/result: 1000 lookups (cycling through 15 codes)",
  { group: "result-startup" },
  () => {
    for (let i = 0; i < 1000; i++) {
      resultToName(i % 15);
    }
  },
);

// ---------------------------------------------------------------------------
// Capability set subset checking
// ---------------------------------------------------------------------------

type Capability = "filesystem" | "network" | "shell" | "clipboard" | "notification" | "tray";

function checkSubset(requested: Capability[], allowed: Capability[]): boolean {
  const allowedSet = new Set(allowed);
  return requested.every((cap) => allowedSet.has(cap));
}

const CAPABILITY_SETS = {
  all: ["filesystem", "network", "shell", "clipboard", "notification", "tray"] as Capability[],
  common: ["filesystem", "network", "clipboard"] as Capability[],
  restricted: ["clipboard"] as Capability[],
  network_only: ["network"] as Capability[],
};

Deno.bench(
  "startup/capability: check single cap subset (1 vs 6)",
  { group: "cap-startup" },
  () => {
    checkSubset(["filesystem"], CAPABILITY_SETS.all);
  },
);

Deno.bench(
  "startup/capability: check 3-cap subset (3 vs 6)",
  { group: "cap-startup" },
  () => {
    checkSubset(CAPABILITY_SETS.common, CAPABILITY_SETS.all);
  },
);

Deno.bench(
  "startup/capability: check 6-cap subset (6 vs 6, full match)",
  { group: "cap-startup" },
  () => {
    checkSubset(CAPABILITY_SETS.all, CAPABILITY_SETS.all);
  },
);

Deno.bench(
  "startup/capability: check denied subset (1 vs 3, fails)",
  { group: "cap-startup" },
  () => {
    checkSubset(["shell"], CAPABILITY_SETS.restricted);
  },
);

Deno.bench(
  "startup/capability: check 100 random subsets (6-cap allowed)",
  { group: "cap-startup" },
  () => {
    const allCaps = CAPABILITY_SETS.all;
    for (let i = 0; i < 100; i++) {
      const randomSubset = allCaps.slice(0, (i % allCaps.length) + 1);
      checkSubset(randomSubset, allCaps);
    }
  },
);

Deno.bench(
  "startup/capability: check empty vs full (security check fast-path)",
  { group: "cap-startup" },
  () => {
    checkSubset([], CAPABILITY_SETS.all);
  },
);
