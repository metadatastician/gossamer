#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-abi-ffi-cleave.sh — the cleave-consistency gate for gossamer#82.
#
# `idris2 --typecheck` proves the ABI is internally sound, but it does NOT check
# that a `%foreign "C:sym, libgossamer"` declaration resolves to a real Zig
# export — that linkage is only exercised at link time. So a green typecheck can
# still describe a PHANTOM surface (gossamer#82's CRITICAL finding: the ABI once
# declared 8 symbols that no Zig function defined).
#
# This gate closes that hole with a pure-text check (no toolchain needed):
#
#   HARD FAIL  — any %foreign "C:sym, libgossamer" in src/interface/abi/*.idr
#                with no matching `export fn sym` in src/interface/ffi/src/*.zig.
#                (The ABI must never lie about the FFI.)
#   REPORT     — coverage: how many of the real gossamer_* C exports the ABI
#                actually declares. Coverage < 100% is the open expansion work
#                (declare/codegen the rest); it is reported, not failed, so new
#                Zig exports don't break CI before their ABI declaration lands.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

ABI_DIR="src/interface/abi"
FFI_DIR="src/interface/ffi/src"

abi_syms="$(mktemp)"
zig_syms="$(mktemp)"
trap 'rm -f "$abi_syms" "$zig_syms"' EXIT

# ABI-declared C:libgossamer symbols (tolerate optional space after the comma).
grep -rhoE '%foreign "C:gossamer_[a-z_0-9]+, ?libgossamer"' "$ABI_DIR"/*.idr 2>/dev/null \
  | sed -E 's/.*C:(gossamer_[a-z_0-9]+),.*/\1/' | sort -u > "$abi_syms" || true

# Real Zig C exports (both `export fn` and `pub export fn`).
grep -rhoE '(pub )?export fn gossamer_[a-z_0-9]+' "$FFI_DIR"/*.zig 2>/dev/null \
  | sed -E 's/.*export fn (gossamer_[a-z_0-9]+).*/\1/' | sort -u > "$zig_syms"

n_abi=$(wc -l < "$abi_syms")
n_zig=$(wc -l < "$zig_syms")
phantom=$(comm -23 "$abi_syms" "$zig_syms")
covered=$(comm -12 "$abi_syms" "$zig_syms" | wc -l)
uncovered=$(comm -13 "$abi_syms" "$zig_syms")
n_uncovered=$(printf '%s\n' "$uncovered" | grep -c . || true)

fail=0

echo "== ABI <-> FFI cleave (gossamer#82) =="
echo "  ABI %foreign C:libgossamer declarations: $n_abi"
echo "  Zig gossamer_* C exports:                $n_zig"
echo "  covered (declared AND exported):         $covered"

# --- HARD FAIL: phantom declarations ---
if [ -n "$phantom" ]; then
  fail=1
  echo "::error::ABI declares %foreign symbols with NO Zig export (phantom surface — gossamer#82):"
  while IFS= read -r s; do
    [ -z "$s" ] && continue
    printf '::error::  phantom: %s (declared in %s, no export fn %s in %s)\n' \
      "$s" "$ABI_DIR" "$s" "$FFI_DIR" >&2
  done <<< "$phantom"
fi

# --- REPORT: coverage of the real surface ---
pct=$(( n_zig > 0 ? covered * 100 / n_zig : 100 ))
echo "  coverage of real FFI surface:            ${covered}/${n_zig} (${pct}%)"
if [ "$n_uncovered" -gt 0 ]; then
  echo "  uncovered Zig exports (no ABI %foreign):  $n_uncovered  [expansion work — gossamer#82]"
fi

# --- ENFORCE: the generated ABI mirror (ForeignGen.idr) is fresh vs the Zig FFI.
# This turns coverage from "reported" into "enforced": add/change/remove a Zig
# `export fn gossamer_*` and the committed ForeignGen.idr goes stale, failing CI
# until `just abi-gen` regenerates it — so the ABI cannot drift from the FFI.
if command -v python3 >/dev/null 2>&1; then
  if ! python3 scripts/gen-abi-foreign.py --check; then
    fail=1
  fi
else
  echo "  (python3 unavailable — skipping ForeignGen freshness check)"
fi

# --- GitHub step summary (when running in Actions) ---
if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "## ABI ↔ FFI cleave (gossamer#82)"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Phantom \`%foreign\` (must be 0) | $(printf '%s' "$phantom" | grep -c . || true) |"
    echo "| ABI coverage of real FFI surface | ${covered}/${n_zig} (${pct}%) |"
    echo "| Uncovered Zig exports (expansion work) | $n_uncovered |"
  } >> "$GITHUB_STEP_SUMMARY"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "ABI/FFI cleave gate: FAILED — the ABI declares symbols the FFI does not export." >&2
  exit 1
fi
echo "ABI/FFI cleave gate: PASSED — every ABI %foreign resolves to a real Zig export."
