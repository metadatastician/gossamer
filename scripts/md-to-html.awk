# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Minimal Markdown to HTML converter for the Gossamer SSG shell pipeline.
# Processes a single .md file with YAML front matter (--- delimited).
# Outputs HTML body content (no wrapping <html>/<body> tags).
#
# Supported Markdown:
#   # through ###### headings
#   **bold**, *italic*, `inline code`
#   [link text](url)
#   ``` fenced code blocks (HTML-escaped)
#   - list items
#   Blank-line-separated paragraphs
#
# Usage: awk -f md-to-html.awk input.md

# inline_md: process bold, italic, code, and links in a line of text.
function inline_md(s,   out, rest, pre, inner, tag, url) {
    out = ""
    rest = s
    while (length(rest) > 0) {
        # Bold: **text**
        if (match(rest, /\*\*[^*]+\*\*/)) {
            pre = substr(rest, 1, RSTART - 1)
            inner = substr(rest, RSTART + 2, RLENGTH - 4)
            rest = substr(rest, RSTART + RLENGTH)
            out = out pre "<strong>" inner "</strong>"
            continue
        }
        # Inline code: `text` (before italic to avoid conflict)
        if (match(rest, /`[^`]+`/)) {
            pre = substr(rest, 1, RSTART - 1)
            inner = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            out = out pre "<code>" inner "</code>"
            continue
        }
        # Italic: *text*
        if (match(rest, /\*[^*]+\*/)) {
            pre = substr(rest, 1, RSTART - 1)
            inner = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            out = out pre "<em>" inner "</em>"
            continue
        }
        # Link: [text](url)
        if (match(rest, /\[[^\]]+\]\([^)]+\)/)) {
            pre = substr(rest, 1, RSTART - 1)
            inner = substr(rest, RSTART, RLENGTH)
            rest = substr(rest, RSTART + RLENGTH)
            # Extract text between [ and ]
            match(inner, /\[[^\]]+\]/)
            tag = substr(inner, RSTART + 1, RLENGTH - 2)
            # Extract url between ( and )
            match(inner, /\([^)]+\)/)
            url = substr(inner, RSTART + 1, RLENGTH - 2)
            out = out pre "<a href=\"" url "\">" tag "</a>"
            continue
        }
        # No more inline patterns
        out = out rest
        rest = ""
    }
    return out
}

BEGIN {
    front_matter_count = 0
    in_code = 0
    in_para = 0
}

# Count front matter delimiters and skip front matter content.
/^---$/ {
    front_matter_count++
    next
}
front_matter_count < 2 { next }

# Code fence toggle.
/^```/ {
    if (in_code) {
        printf "</code></pre>\n"
        in_code = 0
    } else {
        if (in_para) { printf "</p>\n"; in_para = 0 }
        printf "<pre><code>"
        in_code = 1
    }
    next
}

# Inside code block: output verbatim with HTML escaping.
in_code {
    gsub(/&/, "\\&amp;")
    gsub(/</, "\\&lt;")
    gsub(/>/, "\\&gt;")
    print
    next
}

# Blank line: close paragraph.
/^$/ {
    if (in_para) { printf "</p>\n"; in_para = 0 }
    next
}

# Headings (# through ######).
/^###### / { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^###### /, ""); printf "<h6>%s</h6>\n", inline_md($0); next }
/^##### /  { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^##### /,  ""); printf "<h5>%s</h5>\n", inline_md($0); next }
/^#### /   { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^#### /,   ""); printf "<h4>%s</h4>\n", inline_md($0); next }
/^### /    { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^### /,    ""); printf "<h3>%s</h3>\n", inline_md($0); next }
/^## /     { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^## /,     ""); printf "<h2>%s</h2>\n", inline_md($0); next }
/^# /      { if (in_para) { printf "</p>\n"; in_para = 0 }; sub(/^# /,      ""); printf "<h1>%s</h1>\n", inline_md($0); next }

# List items.
/^- / {
    if (in_para) { printf "</p>\n"; in_para = 0 }
    sub(/^- /, "")
    printf "<li>%s</li>\n", inline_md($0)
    next
}

# Regular text: wrap in paragraph.
{
    if (!in_para) { printf "<p>"; in_para = 1 }
    else { printf "\n" }
    printf "%s", inline_md($0)
}

END {
    if (in_para) printf "</p>\n"
    if (in_code) printf "</code></pre>\n"
}
