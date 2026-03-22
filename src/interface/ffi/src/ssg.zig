// Gossamer SSG — Static Site Generator Zig FFI Backend
//
// Implements the C-compatible FFI functions declared in features/ssg/SSG.eph.
// Provides file I/O, front matter parsing, Markdown-to-HTML conversion,
// template substitution, and full site build orchestration.
//
// All functions use C ABI conventions: null-terminated strings allocated via
// c_allocator. Callers (the Ephapax runtime) are responsible for freeing
// returned strings.
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");
const fs = std.fs;
const mem = std.mem;

const alloc = std.heap.c_allocator;

// Type alias for the unmanaged byte ArrayList used throughout this module.
const ByteList = std.ArrayList(u8);

//==============================================================================
// File I/O
//==============================================================================

/// Read an entire file into a null-terminated C string.
/// Returns null on failure (file not found, read error, OOM).
///
/// FFI for: gossamer_ssg_read_file(path: String): String
export fn gossamer_ssg_read_file(path: [*:0]const u8) ?[*:0]u8 {
    const path_slice = mem.span(path);

    const file = fs.cwd().openFile(path_slice, .{}) catch return null;
    defer file.close();

    const stat = file.stat() catch return null;
    const size = stat.size;

    // Guard against reading unreasonably large files (64 MiB limit).
    if (size > 64 * 1024 * 1024) return null;

    const buf = alloc.alloc(u8, size + 1) catch return null;
    const bytes_read = file.readAll(buf[0..size]) catch {
        alloc.free(buf);
        return null;
    };
    buf[bytes_read] = 0;
    return @ptrCast(buf.ptr);
}

/// Write content to a file, creating parent directories as needed.
/// Returns 0 on success, 1 on failure.
///
/// FFI for: gossamer_ssg_write_file(path: String, content: String): I32
export fn gossamer_ssg_write_file(path: [*:0]const u8, content: [*:0]const u8) c_int {
    const path_slice = mem.span(path);
    const content_slice = mem.span(content);

    // Create parent directories if they don't exist.
    if (std.fs.path.dirname(path_slice)) |dir| {
        fs.cwd().makePath(dir) catch {};
    }

    const file = fs.cwd().createFile(path_slice, .{}) catch return 1;
    defer file.close();

    file.writeAll(content_slice) catch return 1;
    return 0;
}

/// List files in a directory matching a given extension.
/// Returns a newline-separated list of file paths (null-terminated).
/// Returns empty string if directory doesn't exist or has no matches.
///
/// FFI for: gossamer_ssg_list_files(dir: String, extension: String): String
export fn gossamer_ssg_list_files(dir: [*:0]const u8, extension: [*:0]const u8) ?[*:0]u8 {
    const dir_slice = mem.span(dir);
    const ext_slice = mem.span(extension);

    var result: ByteList = .empty;
    defer result.deinit(alloc);

    var iter_dir = fs.cwd().openDir(dir_slice, .{ .iterate = true }) catch {
        // Return empty string for non-existent directories.
        const empty = alloc.dupeZ(u8, "") catch return null;
        return empty.ptr;
    };
    defer iter_dir.close();

    var iter = iter_dir.iterate();
    while (iter.next() catch null) |entry| {
        if (entry.kind != .file) continue;

        // Match extension (e.g. ".md").
        if (ext_slice.len > 0) {
            if (!mem.endsWith(u8, entry.name, ext_slice)) continue;
        }

        // Append "dir/filename\n" to result.
        result.appendSlice(alloc, dir_slice) catch return null;
        result.append(alloc, '/') catch return null;
        result.appendSlice(alloc, entry.name) catch return null;
        result.append(alloc, '\n') catch return null;
    }

    // Null-terminate and return.
    const out = alloc.alloc(u8, result.items.len + 1) catch return null;
    @memcpy(out[0..result.items.len], result.items);
    out[result.items.len] = 0;
    return @ptrCast(out.ptr);
}

//==============================================================================
// Front Matter Parsing
//==============================================================================

/// Extract YAML front matter from content delimited by "---" lines.
/// Returns the front matter block (without delimiters), or empty string if none.
///
/// FFI for: gossamer_ssg_parse_front_matter(content: String): String
export fn gossamer_ssg_parse_front_matter(content: [*:0]const u8) ?[*:0]u8 {
    const slice = mem.span(content);

    // Front matter must start with "---\n" at the beginning.
    if (!mem.startsWith(u8, slice, "---\n") and !mem.startsWith(u8, slice, "---\r\n")) {
        const empty = alloc.dupeZ(u8, "") catch return null;
        return empty.ptr;
    }

    // Find the closing "---" delimiter.
    const after_open = if (mem.startsWith(u8, slice, "---\r\n")) @as(usize, 5) else @as(usize, 4);
    const rest = slice[after_open..];

    // Search for "\n---\n" or "\n---\r\n" as the closing delimiter.
    const close_pos = mem.indexOf(u8, rest, "\n---\n") orelse
        mem.indexOf(u8, rest, "\n---\r\n") orelse {
        const empty = alloc.dupeZ(u8, "") catch return null;
        return empty.ptr;
    };

    const front_matter = rest[0..close_pos];
    const result = alloc.dupeZ(u8, front_matter) catch return null;
    return result.ptr;
}

/// Extract the body content after the front matter block.
/// Returns everything after the closing "---" delimiter.
/// If no front matter, returns the entire content.
///
/// FFI for: gossamer_ssg_parse_body(content: String): String
export fn gossamer_ssg_parse_body(content: [*:0]const u8) ?[*:0]u8 {
    const slice = mem.span(content);

    // No front matter — return entire content.
    if (!mem.startsWith(u8, slice, "---\n") and !mem.startsWith(u8, slice, "---\r\n")) {
        const result = alloc.dupeZ(u8, slice) catch return null;
        return result.ptr;
    }

    const after_open = if (mem.startsWith(u8, slice, "---\r\n")) @as(usize, 5) else @as(usize, 4);
    const rest = slice[after_open..];

    // Find closing delimiter and skip past it.
    if (mem.indexOf(u8, rest, "\n---\n")) |pos| {
        const body = rest[pos + 5 ..];
        const result = alloc.dupeZ(u8, body) catch return null;
        return result.ptr;
    }
    if (mem.indexOf(u8, rest, "\n---\r\n")) |pos| {
        const body = rest[pos + 6 ..];
        const result = alloc.dupeZ(u8, body) catch return null;
        return result.ptr;
    }

    // Malformed front matter — return everything after the opening delimiter.
    const result = alloc.dupeZ(u8, rest) catch return null;
    return result.ptr;
}

//==============================================================================
// Markdown to HTML Conversion
//==============================================================================

/// Convert a minimal Markdown subset to HTML.
///
/// Supported syntax:
///   # Heading 1, ## Heading 2, ..., ###### Heading 6
///   **bold**, *italic*
///   `inline code`
///   [link text](url)
///   Blank-line-separated paragraphs
///   Lines starting with ``` are treated as <pre><code> blocks
///
/// FFI for: gossamer_ssg_md_to_html(markdown: String): String
export fn gossamer_ssg_md_to_html(markdown: [*:0]const u8) ?[*:0]u8 {
    const input = mem.span(markdown);
    var out: ByteList = .empty;
    defer out.deinit(alloc);

    var in_code_block = false;
    var in_paragraph = false;

    var line_iter = mem.splitSequence(u8, input, "\n");

    while (line_iter.next()) |raw_line| {
        // Strip trailing \r for Windows line endings.
        const line = if (raw_line.len > 0 and raw_line[raw_line.len - 1] == '\r')
            raw_line[0 .. raw_line.len - 1]
        else
            raw_line;

        // Code fence toggle.
        if (mem.startsWith(u8, line, "```")) {
            if (in_code_block) {
                out.appendSlice(alloc, "</code></pre>\n") catch return null;
                in_code_block = false;
            } else {
                if (in_paragraph) {
                    out.appendSlice(alloc, "</p>\n") catch return null;
                    in_paragraph = false;
                }
                out.appendSlice(alloc, "<pre><code>") catch return null;
                in_code_block = true;
            }
            continue;
        }

        if (in_code_block) {
            // Inside a code block — output verbatim with HTML escaping.
            appendHtmlEscaped(&out, line) catch return null;
            out.append(alloc, '\n') catch return null;
            continue;
        }

        // Blank line — close paragraph.
        if (line.len == 0) {
            if (in_paragraph) {
                out.appendSlice(alloc, "</p>\n") catch return null;
                in_paragraph = false;
            }
            continue;
        }

        // Headings (# through ######).
        if (line[0] == '#') {
            if (in_paragraph) {
                out.appendSlice(alloc, "</p>\n") catch return null;
                in_paragraph = false;
            }
            var level: usize = 0;
            while (level < line.len and level < 6 and line[level] == '#') {
                level += 1;
            }
            if (level < line.len and line[level] == ' ') {
                const heading_text = line[level + 1 ..];
                var level_buf: [1]u8 = undefined;
                level_buf[0] = '0' + @as(u8, @intCast(level));
                out.appendSlice(alloc, "<h") catch return null;
                out.appendSlice(alloc, &level_buf) catch return null;
                out.append(alloc, '>') catch return null;
                appendInlineMarkdown(&out, heading_text) catch return null;
                out.appendSlice(alloc, "</h") catch return null;
                out.appendSlice(alloc, &level_buf) catch return null;
                out.appendSlice(alloc, ">\n") catch return null;
                continue;
            }
        }

        // Regular text — wrap in paragraph.
        if (!in_paragraph) {
            out.appendSlice(alloc, "<p>") catch return null;
            in_paragraph = true;
        } else {
            out.append(alloc, '\n') catch return null;
        }
        appendInlineMarkdown(&out, line) catch return null;
    }

    // Close any open tags.
    if (in_paragraph) {
        out.appendSlice(alloc, "</p>\n") catch return null;
    }
    if (in_code_block) {
        out.appendSlice(alloc, "</code></pre>\n") catch return null;
    }

    const result = alloc.alloc(u8, out.items.len + 1) catch return null;
    @memcpy(result[0..out.items.len], out.items);
    result[out.items.len] = 0;
    return @ptrCast(result.ptr);
}

/// Append HTML-escaped text to the output buffer.
fn appendHtmlEscaped(out: *ByteList, text: []const u8) !void {
    for (text) |c| {
        switch (c) {
            '<' => try out.appendSlice(alloc, "&lt;"),
            '>' => try out.appendSlice(alloc, "&gt;"),
            '&' => try out.appendSlice(alloc, "&amp;"),
            '"' => try out.appendSlice(alloc, "&quot;"),
            else => try out.append(alloc, c),
        }
    }
}

/// Process inline Markdown: **bold**, *italic*, `code`, [text](url).
fn appendInlineMarkdown(out: *ByteList, text: []const u8) !void {
    var i: usize = 0;
    while (i < text.len) {
        // Bold: **text**
        if (i + 1 < text.len and text[i] == '*' and text[i + 1] == '*') {
            if (mem.indexOfPos(u8, text, i + 2, "**")) |close| {
                try out.appendSlice(alloc, "<strong>");
                try appendHtmlEscaped(out, text[i + 2 .. close]);
                try out.appendSlice(alloc, "</strong>");
                i = close + 2;
                continue;
            }
        }

        // Italic: *text*
        if (text[i] == '*') {
            if (mem.indexOfPos(u8, text, i + 1, "*")) |close| {
                // Make sure it's not the start of a bold marker.
                if (close > i + 1) {
                    try out.appendSlice(alloc, "<em>");
                    try appendHtmlEscaped(out, text[i + 1 .. close]);
                    try out.appendSlice(alloc, "</em>");
                    i = close + 1;
                    continue;
                }
            }
        }

        // Inline code: `text`
        if (text[i] == '`') {
            if (mem.indexOfPos(u8, text, i + 1, "`")) |close| {
                try out.appendSlice(alloc, "<code>");
                try appendHtmlEscaped(out, text[i + 1 .. close]);
                try out.appendSlice(alloc, "</code>");
                i = close + 1;
                continue;
            }
        }

        // Links: [text](url)
        if (text[i] == '[') {
            if (mem.indexOfPos(u8, text, i + 1, "](")) |bracket_close| {
                if (mem.indexOfPos(u8, text, bracket_close + 2, ")")) |paren_close| {
                    const link_text = text[i + 1 .. bracket_close];
                    const url = text[bracket_close + 2 .. paren_close];
                    try out.appendSlice(alloc, "<a href=\"");
                    try appendHtmlEscaped(out, url);
                    try out.appendSlice(alloc, "\">");
                    try appendHtmlEscaped(out, link_text);
                    try out.appendSlice(alloc, "</a>");
                    i = paren_close + 1;
                    continue;
                }
            }
        }

        // Regular character — HTML-escape and emit.
        switch (text[i]) {
            '<' => try out.appendSlice(alloc, "&lt;"),
            '>' => try out.appendSlice(alloc, "&gt;"),
            '&' => try out.appendSlice(alloc, "&amp;"),
            '"' => try out.appendSlice(alloc, "&quot;"),
            else => try out.append(alloc, text[i]),
        }
        i += 1;
    }
}

//==============================================================================
// Template Substitution
//==============================================================================

/// Substitute {{key}} placeholders in a template with values from a
/// newline-separated "key=value" string.
///
/// FFI for: gossamer_ssg_template_substitute(template: String, vars: String): String
export fn gossamer_ssg_template_substitute(
    template: [*:0]const u8,
    vars: [*:0]const u8,
) ?[*:0]u8 {
    const tmpl = mem.span(template);
    const vars_slice = mem.span(vars);

    // Parse key=value pairs into a hash map.
    var kv_map = std.StringHashMap([]const u8).init(alloc);
    defer kv_map.deinit();

    var line_iter = mem.splitSequence(u8, vars_slice, "\n");
    while (line_iter.next()) |line| {
        const trimmed = mem.trim(u8, line, &[_]u8{ '\r', ' ', '\t' });
        if (trimmed.len == 0) continue;
        if (mem.indexOf(u8, trimmed, "=")) |eq_pos| {
            const key = trimmed[0..eq_pos];
            const val = trimmed[eq_pos + 1 ..];
            kv_map.put(key, val) catch continue;
        }
    }

    // Scan the template for {{key}} and replace with values.
    var out: ByteList = .empty;
    defer out.deinit(alloc);

    var i: usize = 0;
    while (i < tmpl.len) {
        if (i + 1 < tmpl.len and tmpl[i] == '{' and tmpl[i + 1] == '{') {
            // Find closing }}.
            if (mem.indexOfPos(u8, tmpl, i + 2, "}}")) |close| {
                const key = mem.trim(u8, tmpl[i + 2 .. close], &[_]u8{ ' ', '\t' });
                if (kv_map.get(key)) |val| {
                    out.appendSlice(alloc, val) catch return null;
                } else {
                    // Unknown key — preserve the placeholder.
                    out.appendSlice(alloc, tmpl[i .. close + 2]) catch return null;
                }
                i = close + 2;
                continue;
            }
        }
        out.append(alloc, tmpl[i]) catch return null;
        i += 1;
    }

    const result = alloc.alloc(u8, out.items.len + 1) catch return null;
    @memcpy(result[0..out.items.len], out.items);
    result[out.items.len] = 0;
    return @ptrCast(result.ptr);
}

//==============================================================================
// Full Site Build
//==============================================================================

/// Build the entire site: read .md files from contentDir, apply the template,
/// write HTML output to outDir.
///
/// Process for each .md file:
///   1. Read content
///   2. Extract front matter (title, date)
///   3. Extract body, convert Markdown to HTML
///   4. Substitute {{title}}, {{content}}, {{date}} into template
///   5. Write output as .html in outDir
///
/// Returns 0 on success, 1 on failure.
///
/// FFI for: gossamer_ssg_build_site(contentDir: String, templateFile: String, outDir: String): I32
export fn gossamer_ssg_build_site(
    content_dir: [*:0]const u8,
    template_file: [*:0]const u8,
    out_dir: [*:0]const u8,
) c_int {
    // Read the template file.
    const tmpl_ptr = gossamer_ssg_read_file(template_file) orelse return 1;
    const tmpl = mem.span(tmpl_ptr);
    defer alloc.free(tmpl_ptr[0 .. tmpl.len + 1]);

    // Ensure output directory exists.
    const out_dir_slice = mem.span(out_dir);
    fs.cwd().makePath(out_dir_slice) catch return 1;

    // List .md files in the content directory.
    const files_ptr = gossamer_ssg_list_files(content_dir, ".md") orelse return 1;
    const files_str = mem.span(files_ptr);
    defer alloc.free(files_ptr[0 .. files_str.len + 1]);

    if (files_str.len == 0) return 0; // No content files — success (empty site).

    // Process each file.
    var file_iter = mem.splitSequence(u8, files_str, "\n");
    while (file_iter.next()) |file_path| {
        if (file_path.len == 0) continue;

        // Need a null-terminated path for our FFI functions.
        const path_z = alloc.dupeZ(u8, file_path) catch return 1;
        defer alloc.free(path_z);

        // Read file content.
        const content_ptr = gossamer_ssg_read_file(path_z.ptr) orelse continue;
        const content = mem.span(content_ptr);
        defer alloc.free(content_ptr[0 .. content.len + 1]);

        // Parse front matter for title and date.
        const fm_ptr = gossamer_ssg_parse_front_matter(content_ptr) orelse continue;
        const fm = mem.span(fm_ptr);
        defer alloc.free(fm_ptr[0 .. fm.len + 1]);

        var title: []const u8 = "Untitled";
        var date: []const u8 = "";

        // Simple YAML key extraction (handles "title: value" and "date: value").
        var fm_iter = mem.splitSequence(u8, fm, "\n");
        while (fm_iter.next()) |fm_line| {
            const trimmed = mem.trim(u8, fm_line, &[_]u8{ '\r', ' ', '\t' });
            if (mem.startsWith(u8, trimmed, "title:")) {
                title = mem.trim(u8, trimmed["title:".len..], &[_]u8{ ' ', '\t', '"', '\'' });
            } else if (mem.startsWith(u8, trimmed, "date:")) {
                date = mem.trim(u8, trimmed["date:".len..], &[_]u8{ ' ', '\t', '"', '\'' });
            }
        }

        // Extract body and convert to HTML.
        const body_ptr = gossamer_ssg_parse_body(content_ptr) orelse continue;
        const body = mem.span(body_ptr);
        defer alloc.free(body_ptr[0 .. body.len + 1]);

        const html_ptr = gossamer_ssg_md_to_html(body_ptr) orelse continue;
        const html = mem.span(html_ptr);
        defer alloc.free(html_ptr[0 .. html.len + 1]);

        // Build the template variables string (key=value, newline-separated).
        var vars_buf: ByteList = .empty;
        defer vars_buf.deinit(alloc);

        vars_buf.appendSlice(alloc, "title=") catch continue;
        vars_buf.appendSlice(alloc, title) catch continue;
        vars_buf.append(alloc, '\n') catch continue;
        vars_buf.appendSlice(alloc, "content=") catch continue;
        vars_buf.appendSlice(alloc, html) catch continue;
        vars_buf.append(alloc, '\n') catch continue;
        vars_buf.appendSlice(alloc, "date=") catch continue;
        vars_buf.appendSlice(alloc, date) catch continue;
        vars_buf.append(alloc, '\n') catch continue;

        // Null-terminate vars.
        const vars_z = alloc.dupeZ(u8, vars_buf.items) catch continue;
        defer alloc.free(vars_z);

        // Apply template substitution.
        const result_ptr = gossamer_ssg_template_substitute(
            @ptrCast(tmpl.ptr),
            vars_z.ptr,
        ) orelse continue;
        const result_html = mem.span(result_ptr);
        defer alloc.free(result_ptr[0 .. result_html.len + 1]);

        // Determine output filename: content/foo.md -> outDir/foo.html
        const basename = std.fs.path.basename(file_path);
        const stem = if (mem.endsWith(u8, basename, ".md"))
            basename[0 .. basename.len - 3]
        else
            basename;

        var out_path_buf: [4096]u8 = undefined;
        const out_path = std.fmt.bufPrint(&out_path_buf, "{s}/{s}.html", .{ out_dir_slice, stem }) catch continue;
        const out_path_z = alloc.dupeZ(u8, out_path) catch continue;
        defer alloc.free(out_path_z);

        // Write the output file.
        const write_result = gossamer_ssg_write_file(out_path_z.ptr, result_ptr);
        if (write_result != 0) continue;
    }

    return 0;
}

//==============================================================================
// Tests
//==============================================================================

test "parse front matter extracts YAML block" {
    const content = "---\ntitle: Hello\ndate: 2026-03-22\n---\nBody here.";
    const fm = gossamer_ssg_parse_front_matter(content) orelse unreachable;
    const fm_str = mem.span(fm);
    try std.testing.expectEqualStrings("title: Hello\ndate: 2026-03-22", fm_str);
}

test "parse front matter returns empty for no front matter" {
    const content = "Just a regular file.";
    const fm = gossamer_ssg_parse_front_matter(content) orelse unreachable;
    const fm_str = mem.span(fm);
    try std.testing.expectEqualStrings("", fm_str);
}

test "parse body extracts content after front matter" {
    const content = "---\ntitle: Test\n---\nBody text.";
    const body = gossamer_ssg_parse_body(content) orelse unreachable;
    const body_str = mem.span(body);
    try std.testing.expectEqualStrings("Body text.", body_str);
}

test "parse body returns entire content when no front matter" {
    const content = "No front matter here.";
    const body = gossamer_ssg_parse_body(content) orelse unreachable;
    const body_str = mem.span(body);
    try std.testing.expectEqualStrings("No front matter here.", body_str);
}

test "markdown heading converts to HTML" {
    const md = "# Hello World";
    const html = gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = mem.span(html);
    try std.testing.expectEqualStrings("<h1>Hello World</h1>\n", html_str);
}

test "markdown bold and italic" {
    const md = "This is **bold** and *italic*.";
    const html = gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = mem.span(html);
    try std.testing.expectEqualStrings("<p>This is <strong>bold</strong> and <em>italic</em>.</p>\n", html_str);
}

test "markdown inline code" {
    const md = "Use `foo()` here.";
    const html = gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = mem.span(html);
    try std.testing.expectEqualStrings("<p>Use <code>foo()</code> here.</p>\n", html_str);
}

test "markdown link" {
    const md = "Visit [example](https://example.com) now.";
    const html = gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = mem.span(html);
    try std.testing.expectEqualStrings("<p>Visit <a href=\"https://example.com\">example</a> now.</p>\n", html_str);
}

test "markdown code block" {
    const md = "```\nlet x = 1;\n```";
    const html = gossamer_ssg_md_to_html(md) orelse unreachable;
    const html_str = mem.span(html);
    try std.testing.expectEqualStrings("<pre><code>let x = 1;\n</code></pre>\n", html_str);
}

test "template substitution replaces keys" {
    const tmpl = "<h1>{{title}}</h1><p>{{content}}</p>";
    const vars = "title=Hello\ncontent=World";
    const result = gossamer_ssg_template_substitute(tmpl, vars) orelse unreachable;
    const result_str = mem.span(result);
    try std.testing.expectEqualStrings("<h1>Hello</h1><p>World</p>", result_str);
}

test "template preserves unknown placeholders" {
    const tmpl = "{{known}} and {{unknown}}";
    const vars = "known=yes";
    const result = gossamer_ssg_template_substitute(tmpl, vars) orelse unreachable;
    const result_str = mem.span(result);
    try std.testing.expectEqualStrings("yes and {{unknown}}", result_str);
}

test "write and read file round-trip" {
    const test_path = "/tmp/gossamer_ssg_test_file.txt";
    const content = "Hello, SSG!";

    const write_result = gossamer_ssg_write_file(test_path, content);
    try std.testing.expectEqual(@as(c_int, 0), write_result);

    const read_result = gossamer_ssg_read_file(test_path) orelse unreachable;
    const read_str = mem.span(read_result);
    try std.testing.expectEqualStrings("Hello, SSG!", read_str);

    // Clean up.
    fs.cwd().deleteFile(test_path) catch {};
}
