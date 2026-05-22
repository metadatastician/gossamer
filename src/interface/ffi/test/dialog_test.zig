// Gossamer Dialog Unit Tests
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Ported 1:1 from tests/unit/dialog_test.ts. Tests dialog type definitions,
// response handling, filter parsing, and the Option<String> result semantics
// from Dialog.eph. Uses a MockDialogEngine for hermetic, FFI-free testing
// (same shape as the TS port — these are unit tests of the mock + parse
// logic, not display integration).
//
// Run via:
//   zig test src/interface/ffi/test/dialog_test.zig
// Wired into Justfile target `test-dialog` and `just test`.

const std = @import("std");
const testing = std.testing;

//==============================================================================
// Dialog model — mirrors Dialog.eph (Option<String> / list)
//==============================================================================

const DialogResult = union(enum) {
    some: []const u8,
    none: void,
};

const FilterSpec = struct {
    name: []const u8,
    extensions: std.ArrayList([]const u8),

    pub fn deinit(self: *FilterSpec, allocator: std.mem.Allocator) void {
        self.extensions.deinit(allocator);
    }
};

//==============================================================================
// parseFilters — parses "Name|ext1;ext2|Name2|ext3" format
//==============================================================================

fn parseFilters(allocator: std.mem.Allocator, filter_str: []const u8) !std.ArrayList(FilterSpec) {
    var specs: std.ArrayList(FilterSpec) = .empty;
    if (filter_str.len == 0) return specs;

    // Split on '|'
    var parts: std.ArrayList([]const u8) = .empty;
    defer parts.deinit(allocator);

    var it = std.mem.splitScalar(u8, filter_str, '|');
    while (it.next()) |part| {
        try parts.append(allocator, part);
    }

    // Pair up (name, exts); skip trailing odd entry as the TS port does
    var i: usize = 0;
    while (i + 1 < parts.items.len) : (i += 2) {
        const name = parts.items[i];
        const exts_raw = parts.items[i + 1];
        if (name.len == 0) continue;

        var exts: std.ArrayList([]const u8) = .empty;
        var ext_it = std.mem.splitScalar(u8, exts_raw, ';');
        while (ext_it.next()) |e| {
            if (e.len > 0) try exts.append(allocator, e);
        }

        try specs.append(allocator, .{ .name = name, .extensions = exts });
    }

    return specs;
}

//==============================================================================
// MockDialogEngine — in-process simulation of the Dialog FFI surface
//==============================================================================

const MockDialogEngine = struct {
    allocator: std.mem.Allocator,
    next_result: ?[]const u8 = null,
    next_multi_result: std.ArrayList([]const u8),

    pub fn init(allocator: std.mem.Allocator) MockDialogEngine {
        return .{
            .allocator = allocator,
            .next_result = null,
            .next_multi_result = .empty,
        };
    }

    pub fn deinit(self: *MockDialogEngine) void {
        self.next_multi_result.deinit(self.allocator);
    }

    pub fn setResult(self: *MockDialogEngine, path: ?[]const u8) void {
        self.next_result = path;
    }

    pub fn setMultiResult(self: *MockDialogEngine, paths: []const []const u8) !void {
        self.next_multi_result.clearRetainingCapacity();
        for (paths) |p| try self.next_multi_result.append(self.allocator, p);
    }

    fn currentResult(self: *const MockDialogEngine) DialogResult {
        if (self.next_result) |p|
            return .{ .some = p }
        else
            return .{ .none = {} };
    }

    pub fn open(self: *const MockDialogEngine, _: []const u8, _: []const u8) DialogResult {
        return self.currentResult();
    }

    pub fn save(self: *const MockDialogEngine, _: []const u8, _: []const u8) DialogResult {
        return self.currentResult();
    }

    pub fn openDirectory(self: *const MockDialogEngine, _: []const u8) DialogResult {
        return self.currentResult();
    }

    pub fn openMultiple(self: *const MockDialogEngine, _: []const u8, _: []const u8) []const []const u8 {
        return self.next_multi_result.items;
    }
};

//==============================================================================
// Tests: dialog result semantics
//==============================================================================

test "dialog/result: Some contains a non-empty path" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/home/user/document.pdf");

    const result = dlg.open("Open File", "PDF|*.pdf");
    try testing.expect(result == .some);
    try testing.expect(result.some.len > 0);
}

test "dialog/result: None on cancel (null FFI result)" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult(null);

    const result = dlg.open("Open File", "");
    try testing.expect(result == .none);
}

test "dialog/result: every result is either Some or None — no other variants" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();

    dlg.setResult("/tmp/a.txt");
    const r1 = dlg.open("t", "");
    try testing.expect(r1 == .some or r1 == .none);

    dlg.setResult(null);
    const r2 = dlg.open("t", "");
    try testing.expect(r2 == .some or r2 == .none);
}

//==============================================================================
// Tests: each dialog kind
//==============================================================================

test "dialog/open: returns path on selection" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/home/user/report.md");

    const r = dlg.open("Open Report", "Markdown|*.md|All|*");
    try testing.expect(r == .some);
    try testing.expectEqualStrings("/home/user/report.md", r.some);
}

test "dialog/save: returns save path on confirmation" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/tmp/output.json");

    const r = dlg.save("Save As", "JSON|*.json");
    try testing.expect(r == .some);
    try testing.expectEqualStrings("/tmp/output.json", r.some);
}

test "dialog/openDirectory: returns directory path" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/home/user/projects");

    const r = dlg.openDirectory("Choose Directory");
    try testing.expect(r == .some);
    try testing.expectEqualStrings("/home/user/projects", r.some);
}

test "dialog/openMultiple: returns list of paths" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    try dlg.setMultiResult(&.{ "/a.txt", "/b.txt", "/c.txt" });

    const r = dlg.openMultiple("Select Files", "Text|*.txt");
    try testing.expectEqual(@as(usize, 3), r.len);
    try testing.expectEqualStrings("/a.txt", r[0]);
    try testing.expectEqualStrings("/c.txt", r[2]);
}

test "dialog/openMultiple: returns empty list on cancel" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    try dlg.setMultiResult(&.{});

    const r = dlg.openMultiple("Select Files", "");
    try testing.expectEqual(@as(usize, 0), r.len);
}

//==============================================================================
// Tests: filter parsing
//==============================================================================

test "dialog/filters: parse single filter spec" {
    var specs = try parseFilters(testing.allocator, "JSON files|*.json");
    defer {
        for (specs.items) |*s| s.deinit(testing.allocator);
        specs.deinit(testing.allocator);
    }
    try testing.expectEqual(@as(usize, 1), specs.items.len);
    try testing.expectEqualStrings("JSON files", specs.items[0].name);
    try testing.expectEqual(@as(usize, 1), specs.items[0].extensions.items.len);
    try testing.expectEqualStrings("*.json", specs.items[0].extensions.items[0]);
}

test "dialog/filters: parse multiple filter specs" {
    var specs = try parseFilters(testing.allocator, "JSON files|*.json;*.yaml|All files|*");
    defer {
        for (specs.items) |*s| s.deinit(testing.allocator);
        specs.deinit(testing.allocator);
    }
    try testing.expectEqual(@as(usize, 2), specs.items.len);
    try testing.expectEqualStrings("JSON files", specs.items[0].name);
    try testing.expectEqual(@as(usize, 2), specs.items[0].extensions.items.len);
    try testing.expectEqualStrings("*.json", specs.items[0].extensions.items[0]);
    try testing.expectEqualStrings("*.yaml", specs.items[0].extensions.items[1]);
    try testing.expectEqualStrings("All files", specs.items[1].name);
    try testing.expectEqualStrings("*", specs.items[1].extensions.items[0]);
}

test "dialog/filters: empty filter string returns empty list" {
    var specs = try parseFilters(testing.allocator, "");
    defer specs.deinit(testing.allocator);
    try testing.expectEqual(@as(usize, 0), specs.items.len);
}

test "dialog/filters: single extension parsed correctly" {
    var specs = try parseFilters(testing.allocator, "PDF|*.pdf");
    defer {
        for (specs.items) |*s| s.deinit(testing.allocator);
        specs.deinit(testing.allocator);
    }
    try testing.expectEqualStrings("*.pdf", specs.items[0].extensions.items[0]);
}

test "dialog/filters: three extension groups parsed" {
    var specs = try parseFilters(
        testing.allocator,
        "Images|*.png;*.jpg;*.gif|Video|*.mp4;*.mkv|All|*",
    );
    defer {
        for (specs.items) |*s| s.deinit(testing.allocator);
        specs.deinit(testing.allocator);
    }
    try testing.expectEqual(@as(usize, 3), specs.items.len);
    try testing.expectEqual(@as(usize, 3), specs.items[0].extensions.items.len);
    try testing.expectEqual(@as(usize, 2), specs.items[1].extensions.items.len);
    try testing.expectEqual(@as(usize, 1), specs.items[2].extensions.items.len);
}

//==============================================================================
// Tests: path invariants
//==============================================================================

test "dialog/path: returned path from open dialog is non-empty string" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();

    const paths = [_][]const u8{ "/home/user/file.txt", "/tmp/out.log", "relative/path.md" };
    for (paths) |p| {
        dlg.setResult(p);
        const r = dlg.open("t", "");
        try testing.expect(r == .some);
        try testing.expect(r.some.len > 0);
    }
}

test "dialog/path: paths from multi-dialog are non-empty strings" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    try dlg.setMultiResult(&.{ "/a.txt", "/b.txt" });

    const results = dlg.openMultiple("t", "");
    for (results) |p| {
        try testing.expect(p.len > 0);
    }
}

//==============================================================================
// Tests: dialog title invariants
//==============================================================================

test "dialog/title: empty title is accepted (defaults to OS behaviour)" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/tmp/file.txt");

    const r = dlg.open("", "");
    try testing.expect(r == .some);
}

test "dialog/title: very long title is accepted without truncation" {
    var dlg = MockDialogEngine.init(testing.allocator);
    defer dlg.deinit();
    dlg.setResult("/tmp/x");

    var long_title: [500]u8 = undefined;
    @memset(&long_title, 'A');
    const r = dlg.open(&long_title, "");
    try testing.expect(r == .some);
}
