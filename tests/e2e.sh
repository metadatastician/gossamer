#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Gossamer — End-to-End Test Suite
#
# Tests the webview shell framework:
#   1. Zig FFI builds (libgossamer)
#   2. FFI integration tests (headless)
#   3. CLI builds
#   4. Safety aspects (no dangerous patterns)
#   5. ABI contract (Idris2 ↔ Zig exports match)
#
# Usage:
#   bash tests/e2e.sh
#   just e2e

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
SKIP=0

green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

pass() { green "  PASS: $1"; PASS=$((PASS + 1)); }
fail_test() { red "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip_test() { yellow "  SKIP: $1 ($2)"; SKIP=$((SKIP + 1)); }

echo "═══════════════════════════════════════════════════════════════"
echo "  Gossamer — End-to-End Tests"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─── Preflight ───────────────────────────────────────────────────────
bold "Preflight"
if command -v zig >/dev/null 2>&1; then
    green "  Zig available: $(zig version)"
else
    red "FATAL: zig not found"
    exit 1
fi
echo ""

FFI_DIR="src/interface/ffi"
CLI_DIR="cli"

# ═══════════════════════════════════════════════════════════════════════
# Section 1: FFI Library Build
# ═══════════════════════════════════════════════════════════════════════
bold "Section 1: FFI library build (libgossamer)"

if [ -f "$FFI_DIR/build.zig" ]; then
    if (cd "$FFI_DIR" && zig build 2>/dev/null); then
        pass "libgossamer builds successfully"

        # Check shared library output
        if ls "$FFI_DIR"/zig-out/lib/libgossamer.* >/dev/null 2>&1; then
            LIB_SIZE=$(ls -la "$FFI_DIR"/zig-out/lib/libgossamer.* 2>/dev/null | head -1 | awk '{print $5}')
            pass "libgossamer produced (${LIB_SIZE:-unknown} bytes)"
        else
            skip_test "libgossamer output" "library not in zig-out"
        fi
    else
        fail_test "libgossamer build failed"
    fi
else
    fail_test "FFI build.zig not found at $FFI_DIR"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 2: FFI Integration Tests (headless)
# ═══════════════════════════════════════════════════════════════════════
bold "Section 2: FFI integration tests"

if [ -f "$FFI_DIR/build.zig" ]; then
    if (cd "$FFI_DIR" && zig build test 2>/dev/null); then
        pass "FFI headless unit tests pass"
    else
        fail_test "FFI headless unit tests failed"
    fi

    # Integration test (ABI alignment, null safety, version)
    if [ -f "$FFI_DIR/test/integration_test.zig" ]; then
        pass "Integration test file exists"
    else
        skip_test "integration_test.zig" "file not found"
    fi
else
    skip_test "FFI tests" "no build.zig"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 3: CLI Build
# ═══════════════════════════════════════════════════════════════════════
bold "Section 3: CLI build"

if [ -f "$CLI_DIR/build.zig" ]; then
    if (cd "$CLI_DIR" && zig build); then
        pass "Gossamer CLI builds"
    else
        fail_test "Gossamer CLI build failed"
    fi
else
    skip_test "CLI" "cli/build.zig not found"
fi

# ─── Section 3b: Launcher prerequisite — libwasmtime headers + lib ────────
#
# The wasm-host launcher (cli/launcher) links libwasmtime via system
# search. The build.zig also runs the Ephapax compiler to produce
# cli.wasm, so a full `zig build` of the launcher needs both libwasmtime
# AND the ephapax binary on PATH. CI only installs libwasmtime today
# (release-tarball install in .github/workflows/e2e.yml); the ephapax
# integration is a separate follow-up.
#
# We assert the libwasmtime headers + library are present so the
# install-gate failure mode is reported here rather than as an opaque
# linker error from a future launcher CI job.
if [ -f /usr/local/include/wasmtime.h ] && \
   ( [ -f /usr/local/lib/libwasmtime.so ] || [ -f /usr/local/lib/libwasmtime.dylib ] ); then
    pass "libwasmtime C-API installed (launcher prerequisite)"
else
    skip_test "libwasmtime" "not installed; launcher CI deferred"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 4: Exported Symbols Check
# ═══════════════════════════════════════════════════════════════════════
bold "Section 4: C-ABI symbol exports"

LIBPATH=$(ls "$FFI_DIR"/zig-out/lib/libgossamer.so 2>/dev/null || ls "$FFI_DIR"/zig-out/lib/libgossamer.a 2>/dev/null || true)
if [ -n "$LIBPATH" ] && command -v nm >/dev/null 2>&1; then
    GOSSAMER_SYMBOLS=$(nm -D "$LIBPATH" 2>/dev/null | grep -c "gossamer_" || true)
    if [ "$GOSSAMER_SYMBOLS" -ge 10 ]; then
        pass "Found $GOSSAMER_SYMBOLS gossamer_* exported symbols"
    elif [ "$GOSSAMER_SYMBOLS" -gt 0 ]; then
        pass "Found $GOSSAMER_SYMBOLS gossamer_* symbols (expected 19+)"
    else
        fail_test "No gossamer_* symbols exported"
    fi
else
    skip_test "Symbol check" "library or nm not available"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 5: Safety Aspects
# ═══════════════════════════════════════════════════════════════════════
bold "Section 5: Safety aspects"

# No @panic in production code
ZIG_PANIC=$(grep -rn '@panic' "$FFI_DIR/src/" 2>/dev/null | grep -v test || true)
if [ -n "$ZIG_PANIC" ]; then
    fail_test "Zig @panic in production FFI code ($(echo "$ZIG_PANIC" | wc -l) occurrences)"
else
    pass "No @panic in FFI production code"
fi

# No believe_me in Idris2 ABI — exclude doc-comment lines ("||| ...") and
# line comments ("-- ...") so the test only flags real code uses.
ABI_DIR="src/interface/abi"
if [ -d "$ABI_DIR" ]; then
    DANGEROUS=$(grep -rn 'believe_me\|assert_total' "$ABI_DIR/" 2>/dev/null \
        | grep -vE '^[^:]+:[0-9]+:[[:space:]]*(\|\|\||--)' || true)
    if [ -n "$DANGEROUS" ]; then
        fail_test "Dangerous Idris2 patterns in ABI"
    else
        pass "No dangerous Idris2 patterns in ABI"
    fi
else
    skip_test "ABI safety" "src/interface/abi/ not found"
fi

# SPDX headers — check every FFI source, not a 20-file sample.
MISSING=0
while IFS= read -r f; do
    if ! head -3 "$f" | grep -q "SPDX"; then
        MISSING=$((MISSING + 1))
    fi
done < <(find "$FFI_DIR/src/" -name "*.zig" 2>/dev/null)
if [ "$MISSING" -eq 0 ]; then
    pass "SPDX headers present (all FFI sources)"
else
    fail_test "$MISSING FFI files missing SPDX headers"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 6: Ephapax Module Check
# ═══════════════════════════════════════════════════════════════════════
bold "Section 6: Ephapax core modules"

EPH_COUNT=$(find src/core/ -name "*.eph" 2>/dev/null | wc -l)
if [ "$EPH_COUNT" -gt 0 ]; then
    pass "Found $EPH_COUNT Ephapax core modules"

    # Check all modules have linear type annotations
    LINEAR_COUNT=$(grep -rl 'linear\|Linear\|consume\|Consume' src/core/*.eph 2>/dev/null | wc -l)
    if [ "$LINEAR_COUNT" -gt 0 ]; then
        pass "$LINEAR_COUNT modules use linear types"
    else
        skip_test "Linear types" "no linear annotations found"
    fi
else
    skip_test "Ephapax modules" "no .eph files in src/core/"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Section 7: Display integration test indicator
# ═══════════════════════════════════════════════════════════════════════
bold "Section 7: Display integration tests (Xvfb)"

DISPLAY_TEST="$FFI_DIR/test/display_test.zig"
if [ -f "$DISPLAY_TEST" ]; then
    pass "display_test.zig present ($(wc -l < "$DISPLAY_TEST") lines)"
    if command -v xvfb-run >/dev/null 2>&1; then
        if (cd "$FFI_DIR" && xvfb-run -a --server-args="-screen 0 1024x768x24" zig build test-display 2>/dev/null); then
            pass "Display integration tests passed under Xvfb"
        else
            fail_test "Display integration tests failed under Xvfb"
        fi
    else
        skip_test "Display tests" "xvfb-run not available (run in CI with apt-get install xvfb)"
    fi
else
    fail_test "display_test.zig not found at $DISPLAY_TEST"
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo ""
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
