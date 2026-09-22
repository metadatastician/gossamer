#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHECKER="$ROOT/scripts/check-lock-sync.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

tests=0
failures=0
case_dir=""
output=""
status=0

new_case() {
  tests=$((tests + 1))
  case_dir="$WORK/case-$tests"
  mkdir -p "$case_dir"
}

write_workflow() {
  local name="$1"
  shift
  printf '%s\n' "$@" > "$case_dir/$name"
}

write_lock() {
  printf '%s\n' "$@" > "$case_dir/actions.lock"
}

run_checker() {
  if output="$("$CHECKER" "$case_dir" 2>&1)"; then
    status=0
  else
    status=$?
  fi
}

report_failure() {
  local name="$1"
  local reason="$2"
  failures=$((failures + 1))
  printf 'FAIL: %s — %s\n' "$name" "$reason" >&2
  printf '%s\n' "$output" | sed 's/^/      /' >&2
}

expect_pass() {
  local name="$1"
  shift
  run_checker
  if [ "$status" -ne 0 ]; then
    report_failure "$name" "expected exit 0, got $status"
    return
  fi
  local expected
  for expected in "$@"; do
    if ! grep -Fq -- "$expected" <<< "$output"; then
      report_failure "$name" "missing output: $expected"
      return
    fi
  done
  printf 'PASS: %s\n' "$name"
}

expect_fail() {
  local name="$1"
  shift
  run_checker
  if [ "$status" -eq 0 ]; then
    report_failure "$name" "expected a non-zero exit"
    return
  fi
  local expected
  for expected in "$@"; do
    if ! grep -Fq -- "$expected" <<< "$output"; then
      report_failure "$name" "missing output: $expected"
      return
    fi
  done
  printf 'PASS: %s\n' "$name"
}

# A quoted step-level subpath is normalized to owner/repo, owner/repo matching is
# case-insensitive, trailing comments are ignored, and local actions need no pin.
new_case
write_workflow ci.yaml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    runs-on: ubuntu-latest' \
  '    steps:' \
  '      - uses: "Example/Action/subdirectory@v1" # pinned by actions.lock' \
  '      - uses: ./local-action'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yaml':" \
  "        - 'example/action@v1'" \
  'dependencies:' \
  "    'EXAMPLE/ACTION@v1':" \
  "        ref: 'v1'"
expect_pass 'accepts a synchronized workflow' \
  'actions.lock is in sync and transitively closed' \
  '0 dangling edges'

# Reusable workflows are job-level references. The checker deliberately reports
# an absent lock entry without rejecting it.
new_case
write_workflow reusable.yml \
  'name: Reusable caller' \
  'jobs:' \
  '  call:' \
  '    uses: Example/Automation/.github/workflows/build.yml@v2'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/reusable.yml': []" \
  'dependencies:'
expect_pass 'reports but permits an unlocked reusable workflow' \
  'job-level reusable refs not locked (harmless; see clause 1)' \
  'Example/Automation@v2'

# An unused dependency record is harmless and should be distinguished from an
# orphaned workflow lock entry.
new_case
write_workflow local.yml \
  'name: Local only' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: ./local-action'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/local.yml': []" \
  'dependencies:' \
  "    'unused/action@v1':" \
  "        ref: 'v1'"
expect_pass 'permits an unreferenced dependency record' \
  '1 dependencies: record(s) are unreferenced - harmless, but prunable'

new_case
write_workflow ci.yml 'name: CI'
expect_fail 'rejects a missing lockfile' \
  'FATAL: no lockfile at'

new_case
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  'dependencies:'
expect_fail 'rejects a directory with no workflows' \
  'FATAL: no workflow files under'

# Clause 1: a workflow entry may exist but omit one of its step-level actions.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml': []" \
  'dependencies:' \
  "    'owner/action@v1':" \
  "        ref: 'v1'"
expect_fail 'rejects a missing step-level lock entry' \
  'step-level refs missing from the lockfile: owner/action@v1'

# A completely absent workflow key is both not onboarded and a coverage error.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  'dependencies:' \
  "    'owner/action@v1':" \
  "        ref: 'v1'"
expect_fail 'rejects an unonboarded workflow with an action' \
  'not onboarded: no lockfile entry for this path' \
  'FAIL actions.lock: UNLISTED WORKFLOWS'

# Clause 2: lock entries must still be referenced by the corresponding workflow.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: ./local-action'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/removed-action@v1'" \
  'dependencies:' \
  "    'owner/removed-action@v1':" \
  "        ref: 'v1'"
expect_fail 'rejects an orphaned workflow lock entry' \
  'stale lockfile entries, no uses: references them: owner/removed-action@v1'

# Lockfile paths are also checked in the opposite direction.
new_case
write_workflow ci.yml 'name: CI'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml': []" \
  "    '.github/workflows/deleted.yml': []" \
  'dependencies:'
expect_fail 'rejects a lock entry for a deleted workflow' \
  'FAIL .github/workflows/deleted.yml' \
  'lockfile entry for a workflow file that does not exist'

# Clause 4 includes workflows that contain no uses entries at all.
new_case
write_workflow listed.yml 'name: Listed'
write_workflow omitted.yaml 'name: Omitted'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/listed.yml': []" \
  'dependencies:'
expect_fail 'rejects an unlisted zero-uses workflow' \
  'FAIL actions.lock: UNLISTED WORKFLOWS' \
  '1 workflow file(s) have no key in the lockfile' \
  '.github/workflows/omitted.yaml'

# Clause 3 checks direct workflow pins.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@v1'" \
  'dependencies:'
expect_fail 'rejects a direct dangling dependency edge' \
  'FAIL actions.lock: DANGLING EDGES' \
  'owner/action@v1' \
  'named by: .github/workflows/ci.yml'

# Clause 3 also walks dependencies' nested uses lists.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@v1'" \
  'dependencies:' \
  "    'owner/action@v1':" \
  "        ref: 'v1'" \
  '        uses:' \
  "            - 'nested/helper@v2'"
expect_fail 'rejects a transitive dangling dependency edge' \
  'FAIL actions.lock: DANGLING EDGES' \
  'nested/helper@v2' \
  'dependencies:owner/action@v1'

new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@v1'" \
  'dependencies:' \
  "    'owner/action@v1':" \
  "        ref: 'v1'" \
  '        uses:' \
  "            - 'nested/helper@v2'" \
  "    'nested/helper@v2':" \
  "        ref: 'v2'"
expect_pass 'accepts a transitively closed dependency graph' \
  'actions.lock is in sync and transitively closed'

# Repository names are case-insensitive, but refs are deliberately not.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: Owner/Action/path@Release'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@Release'" \
  'dependencies:' \
  "    'OWNER/ACTION@Release':" \
  "        ref: 'Release'"
expect_pass 'folds owner and repository case only' \
  'actions.lock is in sync and transitively closed'

new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@Release'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@release'" \
  'dependencies:' \
  "    'owner/action@release':" \
  "        ref: 'release'"
expect_fail 'preserves ref case during comparison' \
  'step-level refs missing from the lockfile: owner/action@Release' \
  'stale lockfile entries, no uses: references them: owner/action@release'

# Duplicate references must not require duplicate lock entries.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: owner/action@v1' \
  "      - uses: 'owner/action/subpath@v1'"
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml':" \
  "        - 'owner/action@v1'" \
  'dependencies:' \
  "    'owner/action@v1':" \
  "        ref: 'v1'"
expect_pass 'deduplicates normalized workflow references' \
  'actions.lock is in sync and transitively closed'

# gh actions-lock can rewrite ./ paths to $/ paths. The checker promises to
# reject that invalid migration rather than silently treating it as a local action.
new_case
write_workflow ci.yml \
  'name: CI' \
  'jobs:' \
  '  test:' \
  '    steps:' \
  '      - uses: $/local-action'
write_lock \
  "version: 'v0.0.2'" \
  'workflows:' \
  "    '.github/workflows/ci.yml': []" \
  'dependencies:'
expect_fail 'rejects an invalid dollar-prefixed local action' \
  'invalid local-action rewrite (uses: $/...)' \
  '$/local-action'

if [ "$failures" -ne 0 ]; then
  printf '\n%d of %d tests failed\n' "$failures" "$tests" >&2
  exit 1
fi

printf '\nAll %d check-lock-sync tests passed\n' "$tests"
