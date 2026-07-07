# SPDX-License-Identifier: MPL-2.0
"""Validate eclexiaiser.toml structure (called by dogfood-gate.yml).

Lives here rather than inline in the workflow because a multi-line
python -c block at column 0 inside a `run: |` scalar is invalid YAML —
it silently killed the whole dogfood-gate workflow.
"""
import sys
import tomllib

with open("eclexiaiser.toml", "rb") as f:
    data = tomllib.load(f)

project = data.get("project", {})
if not project.get("name", "").strip():
    print("ERROR: project.name is required", file=sys.stderr)
    sys.exit(1)

functions = data.get("functions", [])
if not functions:
    print("ERROR: at least one [[functions]] entry is required", file=sys.stderr)
    sys.exit(1)

for fn in functions:
    if not fn.get("name", "").strip():
        print("ERROR: function name cannot be empty", file=sys.stderr)
        sys.exit(1)
    if not fn.get("source", "").strip():
        print(f"ERROR: function {fn['name']} has no source path", file=sys.stderr)
        sys.exit(1)

print(f"Valid: {project['name']} ({len(functions)} function(s))")
