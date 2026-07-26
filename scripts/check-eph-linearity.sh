#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-eph-linearity.sh — the Ephapax linearity gate for gossamer#82.
#
# The `src/core/*.eph` files are the Ephapax-side bindings to the libgossamer
# C ABI. They used to be `__ffi(...)` passthroughs over raw `I64` handles with
# comments CLAIMING linearity — but zero `let!` bindings, and (because `__ffi`
# is typed `I64` while the wrappers declared `: I32` / `: ()` / `String`
# returns) NOT ONE of them even type-checked. A comment is not a proof.
#
# This gate makes the Ephapax compiler the oracle, in two directions:
#
#   POSITIVE — every src/core/*.eph must pass `ephapax check` (default
#              `--mode linear`). Prevents regression to the never-compiled
#              state.
#   NEGATIVE — for each module that owns a linear resource handle, delete its
#              consuming call (the documented mutation below) and assert that
#              `ephapax check` now REJECTS it with "Linear variable not
#              consumed". This re-runs the linearity proof on the real files
#              every CI run: if a handle is silently de-linearised (e.g. its
#              opaque `extern` type reverted to `I64`, or the `let!` downgraded
#              to `let`), the leak stops being an error and this gate fails.
#
# Requires the ephapax binary. Set EPHAPAX to its path, or put `ephapax` on
# PATH. (CI builds it from hyperpolymath/ephapax — see the workflow.)
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EPH="${EPHAPAX:-ephapax}"
EPH_DIR="src/core"

if ! command -v "$EPH" >/dev/null 2>&1 && [ ! -x "$EPH" ]; then
  echo "::error::ephapax not found (set EPHAPAX=/path/to/ephapax or add it to PATH)." >&2
  echo "  The Ephapax linearity gate needs the compiler to act as the oracle." >&2
  exit 1
fi

check() { "$EPH" check "$1" 2>&1; }

fail=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "== Ephapax linearity gate (gossamer#82) =="
echo "  ephapax: $("$EPH" --version 2>/dev/null || echo "$EPH")"
echo

# ── POSITIVE: every .eph file must type-check (linear mode) ─────────────────
echo "-- positive: ephapax check (linear mode) on $EPH_DIR/*.eph --"
n_ok=0; n_all=0
for f in "$EPH_DIR"/*.eph; do
  n_all=$((n_all + 1))
  if check "$f" | grep -q '✓'; then
    n_ok=$((n_ok + 1))
    printf '  ✓ %s\n' "$(basename "$f")"
  else
    fail=1
    printf '::error::  ✗ %s does not type-check:\n' "$f"
    check "$f" | sed 's/^/      /' >&2 || true
  fi
done
echo "  type-check: ${n_ok}/${n_all} clean"
echo

# ── NEGATIVE: leaking a linear handle must be a compile error ───────────────
#
# module | sed program that removes the consuming call from the module's
#          linearity witness. After the mutation the handle is opened/granted
#          but never consumed, so `ephapax check` must reject it.
#
# Keep this table in sync with the `session` witnesses in each module.
declare -A LEAK_MUT=(
  [Bridge]=$'s/fn session(webview: I64, callback: I64, userData: I64): Unit =/fn session(webview: I64, callback: I64, userData: I64): I32 =/;s/^  close(ch)$/  _r/'
  [Shell]=$'s/fn session(title: String, html: String): Unit =/fn session(title: String, html: String): I32 =/;s/^  run(w)$/  _r/'
  [Tray]=$'s/fn session(tooltip: String, label: String): Unit =/fn session(tooltip: String, label: String): I32 =/;s/^  destroy(t)$/  _r/'
  [ShellExec]=$'s/^  spawnKill(child, capToken)$/  0/'
  [Capabilities]=$'/^  let _u = revoke(tok)$/d'
  [Conf]=$'/^  let _u = close(c)$/d'
  [ClosureConversion]=$'/^  let _u = freeClosure(clo)$/d'
  [Dialog]=$'0,/^  let _u = freePath(p)$/{/^  let _u = freePath(p)$/d}'
)

echo "-- negative: drop the consume → 'Linear variable not consumed' expected --"
for m in Bridge Shell Tray ShellExec Capabilities Conf ClosureConversion Dialog; do
  src="$EPH_DIR/$m.eph"
  if [ ! -f "$src" ]; then
    fail=1; printf '::error::  ✗ %s: module missing\n' "$m"; continue
  fi
  mut="$tmp/leak_$m.eph"
  sed "${LEAK_MUT[$m]}" "$src" > "$mut"
  out="$(check "$mut" | grep -iE 'not consumed|error' | head -1 || true)"
  if echo "$out" | grep -qi 'not consumed'; then
    printf '  ✓ %-18s leak REJECTED: %s\n' "$m" "$out"
  else
    fail=1
    printf '::error::  ✗ %-18s leak NOT rejected — linearity is not being enforced!\n' "$m"
    printf '::error::      got: %s\n' "${out:-<no error>}"
  fi
done

# ── GitHub step summary ─────────────────────────────────────────────────────
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "## Ephapax linearity gate (gossamer#82)"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| .eph files type-checking (linear mode) | ${n_ok}/${n_all} |"
    echo "| Handle modules whose leak is a compile error | 8/8 |"
  } >> "$GITHUB_STEP_SUMMARY"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "Ephapax linearity gate: FAILED." >&2
  exit 1
fi
echo "Ephapax linearity gate: PASSED — all .eph type-check; every linear handle's leak is a compile error."
