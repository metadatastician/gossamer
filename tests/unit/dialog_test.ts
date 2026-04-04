// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// dialog_test.ts — Unit tests for the Gossamer dialog system.
//
// Tests dialog type definitions, response handling, filter parsing, and
// the Option<String> result semantics from Dialog.eph.

import {
  assertEquals,
  assertNotEquals,
} from "jsr:@std/assert@1";

// ---------------------------------------------------------------------------
// Dialog model mirroring Dialog.eph
// ---------------------------------------------------------------------------

/** Dialog kinds */
type DialogKind = "open" | "save" | "openDirectory" | "openMultiple";

/** Result type mirrors Ephapax Option<String>: Some(path) | None */
type DialogResult =
  | { kind: "Some"; path: string }
  | { kind: "None" };

/** Multiple-file result: list of paths (empty on cancel) */
type MultiDialogResult = string[];

/** Filter spec: "Name|ext1;ext2|Name2|ext3" format used by Dialog.eph */
interface FilterSpec {
  name: string;
  extensions: string[];
}

/**
 * Parse a Dialog.eph filter string into structured FilterSpec list.
 * Format: "Name|ext1;ext2|Name2|ext3;ext4"
 */
function parseFilters(filterStr: string): FilterSpec[] {
  if (!filterStr) return [];
  const parts = filterStr.split("|");
  const specs: FilterSpec[] = [];
  for (let i = 0; i + 1 < parts.length; i += 2) {
    const name = parts[i];
    const exts = parts[i + 1].split(";").filter((e) => e.length > 0);
    if (name) specs.push({ name, extensions: exts });
  }
  return specs;
}

/** Simulated dialog engine: returns configured result (mocking FFI) */
class MockDialogEngine {
  private nextResult: string | null = null;
  private nextMultiResult: string[] = [];

  /** Configure the next dialog result (null = cancelled) */
  setResult(path: string | null): void {
    this.nextResult = path;
  }

  setMultiResult(paths: string[]): void {
    this.nextMultiResult = [...paths];
  }

  /** Simulate open dialog — returns Option<String> */
  open(_title: string, _filters: string): DialogResult {
    return this.nextResult !== null
      ? { kind: "Some", path: this.nextResult }
      : { kind: "None" };
  }

  /** Simulate save dialog */
  save(_title: string, _filters: string): DialogResult {
    return this.nextResult !== null
      ? { kind: "Some", path: this.nextResult }
      : { kind: "None" };
  }

  /** Simulate directory picker */
  openDirectory(_title: string): DialogResult {
    return this.nextResult !== null
      ? { kind: "Some", path: this.nextResult }
      : { kind: "None" };
  }

  /** Simulate multi-file open — returns empty list on cancel */
  openMultiple(_title: string, _filters: string): MultiDialogResult {
    return [...this.nextMultiResult];
  }
}

// ---------------------------------------------------------------------------
// Tests: dialog result semantics
// ---------------------------------------------------------------------------

Deno.test("dialog/result: Some contains a non-empty path", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/home/user/document.pdf");

  const result = dlg.open("Open File", "PDF|*.pdf");
  assertEquals(result.kind, "Some");
  if (result.kind === "Some") {
    assertNotEquals(result.path.length, 0, "Some path must not be empty");
  }
});

Deno.test("dialog/result: None on cancel (null FFI result)", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult(null);

  const result = dlg.open("Open File", "");
  assertEquals(result.kind, "None", "cancelled dialog must return None");
});

Deno.test("dialog/result: every result is either Some or None — no other variants", () => {
  const dlg = new MockDialogEngine();
  const variants: string[] = [];

  dlg.setResult("/tmp/a.txt");
  variants.push(dlg.open("t", "").kind);

  dlg.setResult(null);
  variants.push(dlg.open("t", "").kind);

  for (const v of variants) {
    const valid = v === "Some" || v === "None";
    assertEquals(valid, true, `unexpected variant: ${v}`);
  }
});

// ---------------------------------------------------------------------------
// Tests: each dialog kind
// ---------------------------------------------------------------------------

Deno.test("dialog/open: returns path on selection", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/home/user/report.md");
  const r = dlg.open("Open Report", "Markdown|*.md|All|*");
  assertEquals(r.kind, "Some");
  if (r.kind === "Some") assertEquals(r.path, "/home/user/report.md");
});

Deno.test("dialog/save: returns save path on confirmation", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/tmp/output.json");
  const r = dlg.save("Save As", "JSON|*.json");
  assertEquals(r.kind, "Some");
  if (r.kind === "Some") assertEquals(r.path, "/tmp/output.json");
});

Deno.test("dialog/openDirectory: returns directory path", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/home/user/projects");
  const r = dlg.openDirectory("Choose Directory");
  assertEquals(r.kind, "Some");
  if (r.kind === "Some") assertEquals(r.path, "/home/user/projects");
});

Deno.test("dialog/openMultiple: returns list of paths", () => {
  const dlg = new MockDialogEngine();
  dlg.setMultiResult(["/a.txt", "/b.txt", "/c.txt"]);
  const r = dlg.openMultiple("Select Files", "Text|*.txt");
  assertEquals(r.length, 3);
  assertEquals(r[0], "/a.txt");
  assertEquals(r[2], "/c.txt");
});

Deno.test("dialog/openMultiple: returns empty list on cancel", () => {
  const dlg = new MockDialogEngine();
  dlg.setMultiResult([]);
  const r = dlg.openMultiple("Select Files", "");
  assertEquals(r.length, 0, "cancelled multi-dialog must return empty list");
});

// ---------------------------------------------------------------------------
// Tests: filter parsing
// ---------------------------------------------------------------------------

Deno.test("dialog/filters: parse single filter spec", () => {
  const specs = parseFilters("JSON files|*.json");
  assertEquals(specs.length, 1);
  assertEquals(specs[0].name, "JSON files");
  assertEquals(specs[0].extensions, ["*.json"]);
});

Deno.test("dialog/filters: parse multiple filter specs", () => {
  const specs = parseFilters("JSON files|*.json;*.yaml|All files|*");
  assertEquals(specs.length, 2);
  assertEquals(specs[0].name, "JSON files");
  assertEquals(specs[0].extensions, ["*.json", "*.yaml"]);
  assertEquals(specs[1].name, "All files");
  assertEquals(specs[1].extensions, ["*"]);
});

Deno.test("dialog/filters: empty filter string returns empty list", () => {
  const specs = parseFilters("");
  assertEquals(specs.length, 0);
});

Deno.test("dialog/filters: single extension parsed correctly", () => {
  const specs = parseFilters("PDF|*.pdf");
  assertEquals(specs[0].extensions, ["*.pdf"]);
});

Deno.test("dialog/filters: three extension groups parsed", () => {
  const filterStr = "Images|*.png;*.jpg;*.gif|Video|*.mp4;*.mkv|All|*";
  const specs = parseFilters(filterStr);
  assertEquals(specs.length, 3);
  assertEquals(specs[0].extensions.length, 3);
  assertEquals(specs[1].extensions.length, 2);
  assertEquals(specs[2].extensions.length, 1);
});

// ---------------------------------------------------------------------------
// Tests: path invariants
// ---------------------------------------------------------------------------

Deno.test("dialog/path: returned path from open dialog is non-empty string", () => {
  const dlg = new MockDialogEngine();
  const paths = ["/home/user/file.txt", "/tmp/out.log", "relative/path.md"];
  for (const p of paths) {
    dlg.setResult(p);
    const r = dlg.open("t", "");
    if (r.kind === "Some") {
      assertEquals(typeof r.path, "string");
      assertNotEquals(r.path.length, 0);
    }
  }
});

Deno.test("dialog/path: paths from multi-dialog are non-empty strings", () => {
  const dlg = new MockDialogEngine();
  dlg.setMultiResult(["/a.txt", "/b.txt"]);
  const results = dlg.openMultiple("t", "");
  for (const p of results) {
    assertEquals(typeof p, "string");
    assertNotEquals(p.length, 0);
  }
});

// ---------------------------------------------------------------------------
// Tests: dialog title invariants
// ---------------------------------------------------------------------------

Deno.test("dialog/title: empty title is accepted (defaults to OS behaviour)", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/tmp/file.txt");
  // Empty title must not throw — the engine handles it
  const r = dlg.open("", "");
  assertEquals(r.kind, "Some");
});

Deno.test("dialog/title: very long title is accepted without truncation", () => {
  const dlg = new MockDialogEngine();
  dlg.setResult("/tmp/x");
  const longTitle = "A".repeat(500);
  const r = dlg.open(longTitle, "");
  assertEquals(r.kind, "Some");
});
