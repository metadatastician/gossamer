#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-abi-decoupling.sh — structural guard for gossamer#95.
#
# Makes the two root causes behind #95 impossible to reintroduce silently:
#
#   1. Duplication: src/interface/Gossamer/ABI/<M>.idr must be a SYMLINK into
#      the canonical src/interface/abi/<M>.idr — never a materialised copy.
#      (The bug: symlinks were once committed as byte-identical regular files,
#      so the two trees drifted and every edit had to be made twice.)
#
#   2. Conflation: no module in the shell package (gossamer-abi.ipkg) may import
#      a Groove-layer module. Groove is a separate concern and lives in
#      gossamer-groove.ipkg, which DEPENDS ON the shell — never the reverse.
#
# Exit non-zero (with GitHub-Actions ::error annotations) on any violation.
# Pure structure check: no toolchain required, so it runs anywhere.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

NS_DIR="src/interface/Gossamer/ABI"
ABI_DIR="src/interface/abi"
SHELL_IPKG="gossamer-abi.ipkg"
GROOVE_IPKG="gossamer-groove.ipkg"

# The Groove-layer modules (canonical basenames). Everything else under
# $ABI_DIR is shell and must stay groove-agnostic.
GROOVE_MODULES=(Groove GrooveTermination GrooveLinearity GrooveResidue CapabilityAuthenticity)

fail=0
err() { printf '::error::%s\n' "$1" >&2; fail=1; }
note() { printf '  %s\n' "$1"; }

is_groove_module() {
  local name="$1" g
  for g in "${GROOVE_MODULES[@]}"; do
    [ "$name" = "$g" ] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# Check 1: namespace files are symlinks into the canonical abi/ tree.
# ---------------------------------------------------------------------------
echo "== Check 1: ABI namespace files are symlinks (no duplication) =="
while IFS=$'\t' read -r meta path; do
  mode=${meta%% *}
  base=$(basename "$path")
  if [ "$mode" != "120000" ]; then
    err "$path is tracked as mode $mode, expected 120000 (a symlink)."
    note "The ABI namespace copies must be symlinks into $ABI_DIR/, not files."
    continue
  fi
  target=$(git cat-file -p ":$path")
  if [ "$target" != "../../abi/$base" ]; then
    err "$path points to '$target', expected '../../abi/$base'."
  fi
  if [ ! -e "$ABI_DIR/$base" ]; then
    err "canonical source $ABI_DIR/$base is missing (dangling symlink $path)."
  fi
done < <(git ls-files -s -- "$NS_DIR"/*.idr | sed -E 's/^([0-9]+) [0-9a-f]+ [0-9]+\t/\1\t/')
[ "$fail" -eq 0 ] && echo "  OK: all $NS_DIR/*.idr are symlinks into $ABI_DIR/"

# ---------------------------------------------------------------------------
# Check 2: no shell module imports a Groove-layer module.
# ---------------------------------------------------------------------------
echo "== Check 2: shell modules are groove-agnostic (no conflation) =="
groove_import_re='^import[[:space:]]+Gossamer\.ABI\.(Groove|GrooveTermination|GrooveLinearity|CapabilityAuthenticity)([[:space:]]|$)'
for f in "$ABI_DIR"/*.idr; do
  base=$(basename "$f" .idr)
  is_groove_module "$base" && continue
  if grep -nE "$groove_import_re" "$f" >/dev/null; then
    err "shell module '$base' imports a Groove-layer module (re-conflation)."
    grep -nE "$groove_import_re" "$f" | sed 's/^/    /' >&2
  fi
done
[ "$fail" -eq 0 ] && echo "  OK: no shell module imports a groove module"

# ---------------------------------------------------------------------------
# Check 3: the package manifests keep the split.
# ---------------------------------------------------------------------------
echo "== Check 3: package manifests keep shell/groove split =="
if [ ! -f "$GROOVE_IPKG" ]; then
  err "$GROOVE_IPKG is missing — the groove proofs must live in their own package."
fi
for g in "${GROOVE_MODULES[@]}"; do
  if grep -qE "Gossamer\.ABI\.$g([[:space:]]|,|$)" "$SHELL_IPKG"; then
    err "$SHELL_IPKG lists groove module 'Gossamer.ABI.$g' — it belongs in $GROOVE_IPKG."
  fi
  if [ -f "$GROOVE_IPKG" ] && ! grep -qE "Gossamer\.ABI\.$g([[:space:]]|,|$)" "$GROOVE_IPKG"; then
    err "$GROOVE_IPKG does not list groove module 'Gossamer.ABI.$g'."
  fi
done
[ "$fail" -eq 0 ] && echo "  OK: $SHELL_IPKG is groove-free; $GROOVE_IPKG owns the groove modules"

echo
if [ "$fail" -ne 0 ]; then
  echo "ABI decoupling guard: FAILED (see ::error annotations above)." >&2
  exit 1
fi
echo "ABI decoupling guard: PASSED."
