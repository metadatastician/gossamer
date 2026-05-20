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
    {{ephapax}} check src/core/Shell.eph src/core/Bridge.eph src/core/Capabilities.eph src/core/SSG.eph src/core/Platform.eph --mode linear -v

# Type-check in affine mode (more permissive)
check-affine:
    {{ephapax}} check src/core/Shell.eph src/core/Bridge.eph src/core/Capabilities.eph --mode affine -v

# Type-check an example
check-example name:
    {{ephapax}} check examples/{{name}}/main.eph --mode linear -v

# Type-check the formal ABI proof package (idris2 0.8.0). This is a
# REQUIRED gate, not optional: the ABI modules silently bit-rot otherwise.
abi-check:
    idris2 --typecheck gossamer-abi.ipkg

# Build the Gossamer CLI (links libgossamer)
build-cli: build-ffi
    cd cli && zig build

# Build the Gossamer CLI in release mode
build-cli-release: build-ffi-release
    cd cli && zig build -Doptimize=ReleaseSafe

# Build everything (FFI + CLI + check)
build: build-ffi build-cli check

# ═══════════════════════════════════════════════════════════════
# Static Site Generator
# ═══════════════════════════════════════════════════════════════

# Build the Gossamer project site from site/src/ into site/dist/
build-site: build-ffi
    #!/usr/bin/env bash
    set -euo pipefail
    GOSSAMER_ROOT="$(pwd)"
    CONTENT_DIR="${GOSSAMER_ROOT}/site/src/content"
    TEMPLATE_FILE="${GOSSAMER_ROOT}/site/src/templates/default.html"
    OUT_DIR="${GOSSAMER_ROOT}/site/dist"
    AWK_MD="${GOSSAMER_ROOT}/scripts/md-to-html.awk"
    AWK_TMPL="${GOSSAMER_ROOT}/scripts/template-sub.awk"

    echo "=== Gossamer SSG Build ==="

    # Clean previous output.
    rm -rf "${OUT_DIR}"
    mkdir -p "${OUT_DIR}"

    # Process each .md file in the content directory.
    for md_file in "${CONTENT_DIR}"/*.md; do
        [ -f "${md_file}" ] || continue
        BASENAME=$(basename "${md_file}" .md)

        # Extract front matter metadata.
        TITLE="Untitled"
        DATE=""
        if head -1 "${md_file}" | grep -q "^---$"; then
            TITLE=$(sed -n '/^---$/,/^---$/{ /^title:/s/^title: *//p }' "${md_file}" | tr -d '"' | tr -d "'")
            DATE=$(sed -n '/^---$/,/^---$/{ /^date:/s/^date: *//p }' "${md_file}" | tr -d '"' | tr -d "'")
        fi
        [ -z "${TITLE}" ] && TITLE="Untitled"

        # Convert Markdown body to HTML (writes to temp file to avoid
        # awk argument length limits and special character escaping).
        BODY_TMP=$(mktemp)
        trap "rm -f ${BODY_TMP}" EXIT
        awk -f "${AWK_MD}" "${md_file}" > "${BODY_TMP}"

        # Apply template substitution, reading body from temp file.
        awk -v title="${TITLE}" -v date="${DATE}" \
            -v content_file="${BODY_TMP}" \
            -f "${AWK_TMPL}" "${TEMPLATE_FILE}" > "${OUT_DIR}/${BASENAME}.html"

        rm -f "${BODY_TMP}"
        echo "  Built: ${BASENAME}.html"
    done

    # Copy static assets.
    if [ -d "${GOSSAMER_ROOT}/site/src/assets" ]; then
        cp -r "${GOSSAMER_ROOT}/site/src/assets/"* "${OUT_DIR}/" 2>/dev/null || true
        echo "  Copied assets"
    fi

    echo "=== Site built to site/dist/ ==="
    ls -la "${OUT_DIR}/"

# ═══════════════════════════════════════════════════════════════
# Cross-Platform Builds (v0.3.0+)
# ═══════════════════════════════════════════════════════════════

# Cross-compile for macOS Intel
build-macos-x64:
    cd src/interface/ffi && zig build -Dtarget=x86_64-macos

# Cross-compile for macOS Apple Silicon
build-macos-arm:
    cd src/interface/ffi && zig build -Dtarget=aarch64-macos

# Cross-compile for Windows x64
build-windows:
    cd src/interface/ffi && zig build -Dtarget=x86_64-windows

# Cross-compile for Linux ARM64 (Raspberry Pi, etc.)
build-linux-arm:
    cd src/interface/ffi && zig build -Dtarget=aarch64-linux

# Cross-compile for Linux RISC-V 64
build-linux-riscv:
    cd src/interface/ffi && zig build -Dtarget=riscv64-linux

# Cross-compile for FreeBSD x64
build-freebsd:
    cd src/interface/ffi && zig build -Dtarget=x86_64-freebsd

# Build for all desktop platforms (cross-compilation)
build-all-platforms: build-ffi build-macos-x64 build-macos-arm build-windows build-linux-arm build-linux-riscv
    @echo "Built for: linux-x64, macos-x64, macos-arm64, windows-x64, linux-arm64, linux-riscv64"

# Show supported platform targets
platforms:
    @echo "=== Gossamer Supported Platforms ==="
    @echo ""
    @echo "Desktop (Phase 2 — v0.3.0):"
    @echo "  linux-x64      WebKitGTK         zig build (native)"
    @echo "  linux-arm64    WebKitGTK         zig build -Dtarget=aarch64-linux"
    @echo "  linux-riscv64  WebKitGTK         zig build -Dtarget=riscv64-linux"
    @echo "  macos-x64      WKWebView/Cocoa   zig build -Dtarget=x86_64-macos"
    @echo "  macos-arm64    WKWebView/Cocoa   zig build -Dtarget=aarch64-macos"
    @echo "  windows-x64    WebView2/COM      zig build -Dtarget=x86_64-windows"
    @echo "  freebsd-x64    WebKitGTK         zig build -Dtarget=x86_64-freebsd"
    @echo "  openbsd-x64    WebKitGTK         zig build -Dtarget=x86_64-openbsd"
    @echo "  netbsd-x64     WebKitGTK         zig build -Dtarget=x86_64-netbsd"
    @echo ""
    @echo "Mobile (Phase 3 — v0.4.0+):"
    @echo "  ios-arm64      WKWebView/UIKit   planned"
    @echo "  android-arm64  Android WebView   planned"

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

# Run Idris2 ABI tests (installs the library locally, builds and runs the test executable)
test-abi:
    #!/usr/bin/env bash
    set -e
    # idris2 on this host has a stale baked-in prefix; locate the real libdir via the binary
    export IDRIS2_PREFIX="$(dirname "$(dirname "$(command -v idris2)")")"
    idris2 --install gossamer-abi.ipkg
    idris2 --build   gossamer-abi-tests.ipkg
    ./build/exec/gossamer-abi-tests

# Run all tests
test: test-ffi test-integration test-conformance test-abi

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

# Run panic-attacker pre-commit scan
assail:
    @command -v panic-attack >/dev/null 2>&1 && panic-attack assail . || echo "panic-attack not found — install from https://github.com/hyperpolymath/panic-attacker"

# ── Onboarding ────────────────────────────────────────────────────────────

# Check all required tools are installed
doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    ok=0; fail=0
    check() {
        if "$@" >/dev/null 2>&1; then
            echo "  [ok] $1"
            ((ok++))
        else
            echo "  [MISSING] $1 — $2"
            ((fail++))
        fi
    }
    echo "=== Gossamer Doctor ==="
    echo "--- Core (required) ---"
    check zig version "asdf install zig 0.14.0"
    check pkg-config --version "sudo dnf install pkg-config"
    check just --version "cargo install just"
    if pkg-config --exists gtk+-3.0 2>/dev/null; then
        echo "  [ok] gtk3 (pkg-config)"
        ((ok++))
    else
        echo "  [MISSING] gtk3-devel — sudo dnf install gtk3-devel"
        ((fail++))
    fi
    if pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
        echo "  [ok] webkit2gtk-4.1 (pkg-config)"
        ((ok++))
    else
        echo "  [MISSING] webkit2gtk4.1-devel — sudo dnf install webkit2gtk4.1-devel"
        ((fail++))
    fi
    echo ""
    echo "--- Ephapax (for .eph type checking) ---"
    if [ -x "$(eval echo {{ephapax}})" ]; then
        echo "  [ok] ephapax compiler"
        ((ok++))
    else
        echo "  [MISSING] ephapax — cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli"
        ((fail++))
    fi
    echo ""
    echo "--- Optional ---"
    if command -v idris2 >/dev/null 2>&1; then
        echo "  [ok] idris2 (ABI definitions)"
        ((ok++))
    else
        echo "  [info] idris2 not found (optional — for ABI layer)"
    fi
    echo ""
    echo "Result: $ok passed, $fail failed"
    if [ "$fail" -gt 0 ]; then
        echo "Fix the MISSING items above, then re-run: just doctor"
        exit 1
    else
        echo "All prerequisites satisfied."
    fi

# Auto-install missing tools where possible
heal:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Gossamer Heal ==="
    if ! command -v zig &>/dev/null; then
        echo "Installing Zig via asdf..."
        asdf install zig 0.14.0 || echo "Try: asdf plugin add zig && asdf install zig 0.14.0"
    fi
    if ! command -v just &>/dev/null; then
        echo "Installing just..."
        cargo install just
    fi
    if ! pkg-config --exists gtk+-3.0 2>/dev/null; then
        echo "GTK3 missing — run: sudo dnf install gtk3-devel"
    fi
    if ! pkg-config --exists webkit2gtk-4.1 2>/dev/null; then
        echo "WebKit2GTK missing — run: sudo dnf install webkit2gtk4.1-devel"
    fi
    if ! [ -x "$(eval echo {{ephapax}})" ]; then
        echo "Ephapax missing — build it:"
        echo "  cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli"
    fi
    echo ""
    echo "Re-run 'just doctor' to verify."

# Guided tour of the codebase
tour:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Gossamer Tour ==="
    echo ""
    echo "1. WHAT IS GOSSAMER?"
    echo "   A linearly-typed webview shell. Think Electron/Tauri but with"
    echo "   linear types guaranteeing no resource leaks."
    echo ""
    echo "2. ARCHITECTURE"
    echo "   src/interface/abi/*.idr   Idris2 ABI (formal spec)"
    echo "   src/interface/ffi/        Zig FFI (C-ABI implementation)"
    echo "   src/core/*.eph            Ephapax application modules"
    echo "   cli/                      Gossamer CLI binary"
    echo "   examples/                 Example applications"
    echo ""
    echo "3. BUILD & RUN"
    echo "   just build-ffi   Build libgossamer.so/.a"
    echo "   just build-cli   Build gossamer CLI"
    echo "   just hello       Run the hello example"
    echo ""
    echo "4. LINEAR TYPES"
    echo "   WebviewHandle, Channel, Cap are linear."
    echo "   Borrow = returns handle. Consume = destroys it."
    echo "   MkCap is NOT exported (framework-only)."
    echo ""
    echo "5. TESTING"
    echo "   just test-ffi           Zig unit tests"
    echo "   just test-conformance   Linear type conformance"
    echo "   just test-integration   Integration tests"
    echo ""
    echo "6. FFI SYMBOLS"
    echo "   just symbols      List exported gossamer_* functions"
    echo "   just symbol-count Count them (19+ expected)"
    echo ""
    echo "7. KEY FILES"
    echo "   0-AI-MANIFEST.a2ml     Project manifest"
    echo "   conformance/           Linear type test suite"
    echo "   src/interface/ffi/     The real implementation"
    echo ""
    echo "Run 'just' to see all available recipes."

# ═══════════════════════════════════════════════════════════════
# Packaging
# ═══════════════════════════════════════════════════════════════

# Build .deb package for Debian/Ubuntu
package-deb: build-ffi-release build-cli-release
    dpkg-buildpackage -b --no-sign --build-dir=packaging/debian

# Build .rpm package for Fedora/RHEL
package-rpm: build-ffi-release build-cli-release
    rpmbuild -bb packaging/rpm/gossamer.spec

# Build Flatpak bundle
package-flatpak:
    flatpak-builder --repo=packaging/flatpak/repo packaging/flatpak/build packaging/flatpak/io.gossamer.Gossamer.json
    flatpak build-bundle packaging/flatpak/repo gossamer.flatpak io.gossamer.Gossamer

# Build macOS DMG/pkg (requires macOS or cross-compilation sysroot)
package-macos: build-macos-x64 build-macos-arm
    bash packaging/macos/package.sh

# Build Windows MSI installer (requires WiX 4 and zig cross-compilation)
package-windows: build-windows
    powershell -File packaging/windows/build-installer.ps1

# Build all packages (Linux targets only — suitable for CI)
package-all: package-deb package-rpm package-flatpak

# What to do when things go wrong
help-me:
    #!/usr/bin/env bash
    echo "=== Gossamer Help ==="
    echo ""
    echo "BUILD FAILS:"
    echo "  'gtk+-3.0 not found'       -> sudo dnf install gtk3-devel"
    echo "  'webkit2gtk-4.1 not found' -> sudo dnf install webkit2gtk4.1-devel"
    echo "  Zig errors                 -> Check version: zig version (need 0.14+)"
    echo "  Ephapax not found          -> Build it: cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli"
    echo ""
    echo "RUNTIME ISSUES:"
    echo "  'no display'         -> Gossamer needs X11/Wayland (headless won't work)"
    echo "  Segfault on start    -> Check libgossamer.so is built: just build-ffi"
    echo "  WebView blank        -> Check CSP settings in gossamer.conf.json"
    echo ""
    echo "TYPE CHECKING:"
    echo "  'linear resource leaked'  -> Ensure every handle creation has a consumer"
    echo "  'affine mode' needed      -> Use: just check-affine (more permissive)"
    echo "  Conformance test fails    -> Check conformance/valid/ and conformance/invalid/"
    echo ""
    echo "STILL STUCK?"
    echo "  1. just doctor    (check prerequisites)"
    echo "  2. just heal      (auto-install)"
    echo "  3. just clean && just build  (fresh build)"
    echo "  4. Read 0-AI-MANIFEST.a2ml for full context"


# Print the current CRG grade (reads from READINESS.md '**Current Grade:** X' line)
crg-grade:
    @grade=$$(grep -oP '(?<=\*\*Current Grade:\*\* )[A-FX]' READINESS.md 2>/dev/null | head -1); \
    [ -z "$$grade" ] && grade="X"; \
    echo "$$grade"

# Generate a shields.io badge markdown for the current CRG grade
# Looks for '**Current Grade:** X' in READINESS.md; falls back to X
crg-badge:
    @grade=$$(grep -oP '(?<=\*\*Current Grade:\*\* )[A-FX]' READINESS.md 2>/dev/null | head -1); \
    [ -z "$$grade" ] && grade="X"; \
    case "$$grade" in \
      A) color="brightgreen" ;; B) color="green" ;; C) color="yellow" ;; \
      D) color="orange" ;; E) color="red" ;; F) color="critical" ;; \
      *) color="lightgrey" ;; esac; \
    echo "[![CRG $$grade](https://img.shields.io/badge/CRG-$$grade-$$color?style=flat-square)](https://github.com/hyperpolymath/standards/tree/main/component-readiness-grades)"
