#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# notarize.sh — Code sign, notarize, and staple Gossamer macOS artefacts.
#
# This script is intended to run AFTER package.sh has produced the universal
# binary and the .pkg / .dmg artefacts in dist/macos/.
#
# Prerequisites:
#   - macOS with Xcode command-line tools
#   - A valid Apple Developer ID certificate in the keychain
#   - An app-specific password for notarytool
#
# Required environment variables:
#   GOSSAMER_CODESIGN_IDENTITY — Developer ID identity for codesign
#       e.g. "Developer ID Application: Your Name (TEAMID)"
#   GOSSAMER_APPLE_ID          — Apple ID email for notarization
#   GOSSAMER_APPLE_PASSWORD    — App-specific password (NOT your Apple ID password)
#   GOSSAMER_APPLE_TEAM_ID     — 10-character Apple Developer Team ID
#
# Optional environment variables:
#   GOSSAMER_KEYCHAIN_PROFILE  — Stored notarytool credential profile name
#       If set, overrides APPLE_ID/APPLE_PASSWORD/APPLE_TEAM_ID and uses
#       `xcrun notarytool submit --keychain-profile $PROFILE` instead.
#
# Usage (run from repository root):
#   bash packaging/macos/notarize.sh [--dry-run]
#
# Flags:
#   --dry-run    Validate configuration and print commands without executing
#                signing, notarization, or stapling. Useful for CI validation.
#
# Outputs:
#   Signed and stapled versions of:
#     dist/macos/gossamer              (universal CLI binary)
#     dist/macos/libgossamer.dylib     (universal library)
#     dist/macos/gossamer-0.3.0.pkg    (installer package)
#     dist/macos/gossamer-0.3.0-universal.dmg  (disk image)

set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────────

readonly VERSION="0.3.0"
readonly DIST_DIR="dist/macos"
readonly CLI_BINARY="${DIST_DIR}/gossamer"
readonly LIB_BINARY="${DIST_DIR}/libgossamer.dylib"
readonly PKG_FILE="${DIST_DIR}/gossamer-${VERSION}.pkg"
readonly DMG_FILE="${DIST_DIR}/gossamer-${VERSION}-universal.dmg"

DRY_RUN=false

# ── Argument Parsing ──────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --help|-h)
            head -44 "$0" | tail -40
            exit 0
            ;;
        *)
            printf '[notarize.sh] ERROR: Unknown argument: %s\n' "$arg" >&2
            exit 1
            ;;
    esac
done

# ── Helpers ───────────────────────────────────────────────────────────────────

log() { printf '[notarize.sh] %s\n' "$*"; }
die() { printf '[notarize.sh] ERROR: %s\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

# Execute a command, or print it if --dry-run is active.
run_cmd() {
    if "${DRY_RUN}"; then
        log "[DRY RUN] $*"
    else
        "$@"
    fi
}

# ── Preflight Checks ─────────────────────────────────────────────────────────

log "Gossamer macOS notarization — v${VERSION}"

if "${DRY_RUN}"; then
    log "Running in DRY RUN mode — no signing or notarization will be performed."
fi

# Require macOS tools
require_cmd codesign
require_cmd xcrun

# Validate signing identity
if [ -z "${GOSSAMER_CODESIGN_IDENTITY:-}" ]; then
    die "GOSSAMER_CODESIGN_IDENTITY is not set.
    Set it to your Developer ID identity, e.g.:
      export GOSSAMER_CODESIGN_IDENTITY=\"Developer ID Application: Your Name (TEAMID)\"
    List available identities with:
      security find-identity -v -p codesigning"
fi

# Validate notarization credentials
if [ -z "${GOSSAMER_KEYCHAIN_PROFILE:-}" ]; then
    # Using explicit credentials — validate all three
    if [ -z "${GOSSAMER_APPLE_ID:-}" ]; then
        die "GOSSAMER_APPLE_ID is not set.
    Set it to your Apple ID email:
      export GOSSAMER_APPLE_ID=\"you@example.com\"
    Alternatively, store credentials with:
      xcrun notarytool store-credentials \"gossamer-notary\" \\
        --apple-id \"\$APPLE_ID\" --password \"\$APP_PASSWORD\" --team-id \"\$TEAM_ID\"
    Then set:
      export GOSSAMER_KEYCHAIN_PROFILE=\"gossamer-notary\""
    fi
    if [ -z "${GOSSAMER_APPLE_PASSWORD:-}" ]; then
        die "GOSSAMER_APPLE_PASSWORD is not set.
    Generate an app-specific password at https://appleid.apple.com/account/manage
    Then:
      export GOSSAMER_APPLE_PASSWORD=\"xxxx-xxxx-xxxx-xxxx\"
    Do NOT use your real Apple ID password."
    fi
    if [ -z "${GOSSAMER_APPLE_TEAM_ID:-}" ]; then
        die "GOSSAMER_APPLE_TEAM_ID is not set.
    Find your 10-character Team ID at https://developer.apple.com/account
    Then:
      export GOSSAMER_APPLE_TEAM_ID=\"ABCDE12345\""
    fi
    log "Using explicit Apple ID credentials for notarization."
    NOTARY_AUTH=(--apple-id "${GOSSAMER_APPLE_ID}" --password "${GOSSAMER_APPLE_PASSWORD}" --team-id "${GOSSAMER_APPLE_TEAM_ID}")
else
    log "Using keychain profile '${GOSSAMER_KEYCHAIN_PROFILE}' for notarization."
    NOTARY_AUTH=(--keychain-profile "${GOSSAMER_KEYCHAIN_PROFILE}")
fi

# Verify artefacts exist
for f in "${CLI_BINARY}" "${LIB_BINARY}"; do
    [ -f "$f" ] || die "Artefact not found: $f — run packaging/macos/package.sh first."
done

# Verify universal binary architecture
log "Verifying universal binary architectures..."
lipo -info "${CLI_BINARY}"
lipo -info "${LIB_BINARY}"

# ── Step 1: Code Signing ─────────────────────────────────────────────────────

log "Step 1: Code signing binaries..."

sign_binary() {
    local binary="$1"
    local opts=(
        --force
        --options runtime
        --timestamp
        --sign "${GOSSAMER_CODESIGN_IDENTITY}"
    )
    log "  Signing ${binary}..."
    run_cmd codesign "${opts[@]}" "${binary}"
}

# Sign the library first, then the CLI binary
sign_binary "${LIB_BINARY}"
sign_binary "${CLI_BINARY}"

# Verify signatures
if ! "${DRY_RUN}"; then
    log "  Verifying code signatures..."
    codesign --verify --deep --strict "${LIB_BINARY}" && log "  libgossamer.dylib: signature OK"
    codesign --verify --deep --strict "${CLI_BINARY}" && log "  gossamer: signature OK"
fi

# ── Step 2: Sign and Notarize .pkg ───────────────────────────────────────────

if [ -f "${PKG_FILE}" ]; then
    log "Step 2a: Signing .pkg installer..."

    # .pkg files use "Developer ID Installer" identity (not "Application")
    INSTALLER_IDENTITY="${GOSSAMER_CODESIGN_IDENTITY/Application/Installer}"
    run_cmd productsign \
        --sign "${INSTALLER_IDENTITY}" \
        "${PKG_FILE}" \
        "${PKG_FILE}.signed"

    if ! "${DRY_RUN}"; then
        mv "${PKG_FILE}.signed" "${PKG_FILE}"
    fi

    log "Step 2b: Notarizing .pkg..."
    run_cmd xcrun notarytool submit "${PKG_FILE}" \
        "${NOTARY_AUTH[@]}" \
        --wait

    log "Step 2c: Stapling .pkg..."
    run_cmd xcrun stapler staple "${PKG_FILE}"
else
    log "Step 2: Skipping .pkg (not found at ${PKG_FILE})"
fi

# ── Step 3: Sign and Notarize .dmg ───────────────────────────────────────────

if [ -f "${DMG_FILE}" ]; then
    log "Step 3a: Signing .dmg..."
    run_cmd codesign \
        --force \
        --timestamp \
        --sign "${GOSSAMER_CODESIGN_IDENTITY}" \
        "${DMG_FILE}"

    log "Step 3b: Notarizing .dmg..."
    run_cmd xcrun notarytool submit "${DMG_FILE}" \
        "${NOTARY_AUTH[@]}" \
        --wait

    log "Step 3c: Stapling .dmg..."
    run_cmd xcrun stapler staple "${DMG_FILE}"
else
    log "Step 3: Skipping .dmg (not found at ${DMG_FILE})"
fi

# ── Step 4: Final Verification ───────────────────────────────────────────────

if ! "${DRY_RUN}"; then
    log "Step 4: Final verification..."

    log "  Binary signatures:"
    codesign -dvv "${CLI_BINARY}" 2>&1 | grep -E "^(Authority|TeamIdentifier|Timestamp)" || true
    codesign -dvv "${LIB_BINARY}" 2>&1 | grep -E "^(Authority|TeamIdentifier|Timestamp)" || true

    if [ -f "${PKG_FILE}" ]; then
        log "  PKG staple check:"
        xcrun stapler validate "${PKG_FILE}" && log "    Staple: OK" || log "    Staple: MISSING"
    fi

    if [ -f "${DMG_FILE}" ]; then
        log "  DMG staple check:"
        xcrun stapler validate "${DMG_FILE}" && log "    Staple: OK" || log "    Staple: MISSING"
    fi
else
    log "Step 4: [DRY RUN] Skipping final verification."
fi

# ── Done ──────────────────────────────────────────────────────────────────────

log ""
log "Notarization complete."
log "Signed artefacts in ${DIST_DIR}/:"
ls -lh "${DIST_DIR}/" 2>/dev/null || true
