# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Gossamer — A linearly-typed webview shell
# https://just.systems/man/en/

set shell := ["bash", "-uc"]
set dotenv-load := true
set positional-arguments := true

import? "contractile.just"

# Ephapax compiler location (must be built first)
ephapax := "~/Documents/hyperpolymath-repos/ephapax/target/debug/ephapax"

# Show all recipes
default:
    @just --list

# ═══════════════════════════════════════════════════════════════
# Build
# ═══════════════════════════════════════════════════════════════

# Build the Zig FFI library (libgossamer.so + libgossamer.a)
build-ffi:
    cd src/interface/ffi && zig build

# Build the Zig FFI in release mode
build-ffi-release:
    cd src/interface/ffi && zig build -Doptimize=ReleaseSafe

# Type-check all Gossamer core modules
check:
    {{ephapax}} check src/core/Shell.eph src/core/Bridge.eph src/core/Capabilities.eph --mode linear -v

# Type-check in affine mode (more permissive)
check-affine:
    {{ephapax}} check src/core/Shell.eph src/core/Bridge.eph src/core/Capabilities.eph --mode affine -v

# Type-check an example
check-example name:
    {{ephapax}} check examples/{{name}}/main.eph --mode linear -v

# Build the Gossamer CLI (links libgossamer)
build-cli: build-ffi
    cd cli && zig build

# Build the Gossamer CLI in release mode
build-cli-release: build-ffi-release
    cd cli && zig build -Doptimize=ReleaseSafe

# Build everything (FFI + CLI + check)
build: build-ffi build-cli check

# ═══════════════════════════════════════════════════════════════
# Run
# ═══════════════════════════════════════════════════════════════

# Run an example (requires display)
run-example name:
    {{ephapax}} run examples/{{name}}/main.eph

# Run the hello example
hello: build-ffi
    {{ephapax}} run examples/hello/main.eph

# ═══════════════════════════════════════════════════════════════
# Test
# ═══════════════════════════════════════════════════════════════

# Run Zig FFI unit tests
test-ffi:
    cd src/interface/ffi && zig build test

# Type-check all conformance tests (valid should pass, invalid should fail)
test-conformance:
    #!/usr/bin/env bash
    set -e
    echo "=== Valid tests (should pass) ==="
    for f in conformance/valid/*.eph; do
        if {{ephapax}} check "$f" --mode linear 2>/dev/null; then
            echo "  ✓ $f"
        else
            echo "  ✗ $f (UNEXPECTED FAILURE)"
            exit 1
        fi
    done
    echo "=== Invalid tests (should fail) ==="
    for f in conformance/invalid/*.eph; do
        if {{ephapax}} check "$f" --mode linear 2>/dev/null; then
            echo "  ✗ $f (UNEXPECTED PASS)"
            exit 1
        else
            echo "  ✓ $f (correctly rejected)"
        fi
    done
    echo "All conformance tests passed."

# Run Zig FFI integration tests
test-integration:
    cd src/interface/ffi && zig test test/integration_test.zig

# Run all tests
test: test-ffi test-integration test-conformance

# ═══════════════════════════════════════════════════════════════
# Clean
# ═══════════════════════════════════════════════════════════════

# Clean Zig build artifacts
clean:
    rm -rf src/interface/ffi/zig-out src/interface/ffi/.zig-cache

# ═══════════════════════════════════════════════════════════════
# Development
# ═══════════════════════════════════════════════════════════════

# Install the gossamer CLI to ~/.local/bin
install: build-cli
    mkdir -p ~/.local/bin
    cp cli/zig-out/bin/gossamer ~/.local/bin/gossamer
    @echo "  ✓ Installed gossamer to ~/.local/bin/gossamer"

# Show exported FFI symbols
symbols:
    nm -D src/interface/ffi/zig-out/lib/libgossamer.so | grep "T gossamer_"

# Count exported symbols
symbol-count:
    @nm -D src/interface/ffi/zig-out/lib/libgossamer.so | grep -c "T gossamer_"

# Check system dependencies
deps:
    @echo "Checking dependencies..."
    @pkg-config --exists gtk+-3.0 && echo "  ✓ gtk3" || echo "  ✗ gtk3 (install gtk3-devel)"
    @pkg-config --exists webkit2gtk-4.1 && echo "  ✓ webkit2gtk-4.1" || echo "  ✗ webkit2gtk-4.1 (install webkit2gtk4.1-devel)"
    @which zig >/dev/null && echo "  ✓ zig ($(zig version))" || echo "  ✗ zig (install via asdf)"
    @test -x {{ephapax}} && echo "  ✓ ephapax" || echo "  ✗ ephapax (build: cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli)"
