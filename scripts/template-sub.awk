# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Template substitution for the Gossamer SSG shell pipeline.
# Replaces {{title}}, {{date}}, and {{content}} in a template file.
#
# Usage: awk -v title="Page Title" -v date="2026-03-28" \
#            -v content_file="/tmp/body.html" \
#            -f template-sub.awk template.html
#
# The content is read from a file (content_file) rather than passed as a
# variable to avoid awk argument length limits and special character issues.

BEGIN {
    # Read content from file into a variable.
    body = ""
    while ((getline line < content_file) > 0) {
        if (body != "") body = body "\n"
        body = body line
    }
    close(content_file)
}

{
    gsub(/\{\{title\}\}/, title)
    gsub(/\{\{date\}\}/, date)
    gsub(/\{\{content\}\}/, body)
    print
}
