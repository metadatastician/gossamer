#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# package.sh — Build a macOS universal binary and DMG/pkg for Gossamer.
#
# Prerequisites:
#   - Zig 0.14+ (cross-compilation from Linux is supported; native macOS build
#     requires the macOS SDK to be present or a sysroot provided to Zig)
#   - hdiutil (macOS only — produces .dmg)
#   - pkgbuild (macOS only — produces .pkg)
#   - just (the task runner used by the project)
#
# Usage (run from repository root):
#   bash packaging/macos/package.sh
#
# Outputs:
#   dist/macos/gossamer-0.3.0-universal.dmg
#   dist/macos/gossamer-0.3.0.pkg

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────

readonly PACKAGE_NAME="gossamer"
readonly VERSION="0.3.0"
readonly DIST_DIR="dist/macos"
readonly STAGING_DIR="${DIST_DIR}/staging"

# Paths produced by just build-macos-x64 / just build-macos-arm
readonly LIB_X64="src/interface/ffi/zig-out/lib/libgossamer-x86_64-macos.a"
readonly LIB_ARM="src/interface/ffi/zig-out/lib/libgossamer-aarch64-macos.a"
readonly CLI_X64="cli/zig-out/bin/gossamer-x86_64"
readonly CLI_ARM="cli/zig-out/bin/gossamer-aarch64"

# Universal binary output paths
readonly LIB_UNIVERSAL="${DIST_DIR}/libgossamer.dylib"
readonly CLI_UNIVERSAL="${DIST_DIR}/gossamer"

# ── Helpers ────────────────────────────────────────────────────────────────────

log() { printf '[package.sh] %s\n' "$*"; }
die() { printf '[package.sh] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

# ── Preflight ──────────────────────────────────────────────────────────────────

log "Gossamer macOS packaging — v${VERSION}"

require_cmd just
require_cmd zig
require_cmd lipo

# hdiutil and pkgbuild are macOS-only; warn rather than abort so the script can
# be tested for the lipo step on Linux CI.
HAVE_HDIUTIL=false
HAVE_PKGBUILD=false
command -v hdiutil  >/dev/null 2>&1 && HAVE_HDIUTIL=true  || log "hdiutil not found — DMG creation skipped"
command -v pkgbuild >/dev/null 2>&1 && HAVE_PKGBUILD=true || log "pkgbuild not found — PKG creation skipped"

# ── Step 1: Cross-compile for both architectures ───────────────────────────────

log "Building for macOS x86_64..."
just build-macos-x64

log "Building for macOS aarch64 (Apple Silicon)..."
just build-macos-arm

# ── Step 2: Create universal binaries with lipo ────────────────────────────────

mkdir -p "${DIST_DIR}"

log "Creating universal library with lipo..."
lipo -create \
    "${LIB_X64}" \
    "${LIB_ARM}" \
    -output "${LIB_UNIVERSAL}"

log "Creating universal CLI binary with lipo..."
lipo -create \
    "${CLI_X64}" \
    "${CLI_ARM}" \
    -output "${CLI_UNIVERSAL}"

chmod +x "${CLI_UNIVERSAL}"

lipo -info "${LIB_UNIVERSAL}"
lipo -info "${CLI_UNIVERSAL}"

# ── Step 3: Assemble staging tree ─────────────────────────────────────────────

log "Assembling install staging tree at ${STAGING_DIR}..."

mkdir -p "${STAGING_DIR}/usr/local/lib"
mkdir -p "${STAGING_DIR}/usr/local/bin"
mkdir -p "${STAGING_DIR}/usr/local/include/gossamer"

install -m755 "${LIB_UNIVERSAL}"        "${STAGING_DIR}/usr/local/lib/libgossamer.dylib"
install -m755 "${CLI_UNIVERSAL}"        "${STAGING_DIR}/usr/local/bin/gossamer"
install -m644 generated/abi/gossamer.h  "${STAGING_DIR}/usr/local/include/gossamer/gossamer.h"

# ── Step 4: Build .pkg installer (macOS only) ──────────────────────────────────

if "${HAVE_PKGBUILD}"; then
    readonly PKG_OUTPUT="${DIST_DIR}/${PACKAGE_NAME}-${VERSION}.pkg"
    log "Building .pkg installer → ${PKG_OUTPUT}"
    pkgbuild \
        --root "${STAGING_DIR}" \
        --identifier "io.gossamer.Gossamer" \
        --version "${VERSION}" \
        --install-location "/" \
        "${PKG_OUTPUT}"
    log "PKG created: ${PKG_OUTPUT}"
fi

# ── Step 5: Build .dmg (macOS only) ───────────────────────────────────────────

if "${HAVE_HDIUTIL}"; then
    readonly DMG_OUTPUT="${DIST_DIR}/${PACKAGE_NAME}-${VERSION}-universal.dmg"
    readonly DMG_STAGING="${DIST_DIR}/dmg-contents"

    log "Building .dmg → ${DMG_OUTPUT}"

    mkdir -p "${DMG_STAGING}"
    # Copy the universal binaries directly into the DMG for drag-install use.
    cp "${LIB_UNIVERSAL}"        "${DMG_STAGING}/libgossamer.dylib"
    cp "${CLI_UNIVERSAL}"        "${DMG_STAGING}/gossamer"
    cp generated/abi/gossamer.h  "${DMG_STAGING}/gossamer.h"
    cp README.adoc               "${DMG_STAGING}/README.adoc" 2>/dev/null || true
    cp LICENSE                   "${DMG_STAGING}/LICENSE"     2>/dev/null || true

    hdiutil create \
        -volname "Gossamer ${VERSION}" \
        -srcfolder "${DMG_STAGING}" \
        -ov \
        -format UDZO \
        "${DMG_OUTPUT}"

    rm -rf "${DMG_STAGING}"
    log "DMG created: ${DMG_OUTPUT}"
fi

# ── Done ───────────────────────────────────────────────────────────────────────

log "macOS packaging complete."
log "Artefacts in ${DIST_DIR}/:"
ls -lh "${DIST_DIR}/" 2>/dev/null || true
