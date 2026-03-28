#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
#
# install-desktop.sh — Install Gossamer desktop entry and icon on Linux.
#
# Gossamer is the webview shell itself, so no launcher wrapper is needed.
# This script registers the .desktop file and icon for the application menu.
#
# Usage:
#   ./scripts/install-desktop.sh          # Install
#   ./scripts/install-desktop.sh --remove # Remove
#
# Author: Jonathan D.A. Jewell

set -euo pipefail

APP_NAME="gossamer"
APP_DISPLAY="Gossamer"

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DESKTOP_FILE="$REPO_DIR/${APP_NAME}.desktop"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
APPS_DIR="$HOME/.local/share/applications"

# --- Remove mode ---
if [[ "${1:-}" == "--remove" ]]; then
    echo "Removing ${APP_DISPLAY} desktop entry..."
    rm -f "$APPS_DIR/${APP_NAME}.desktop"
    rm -f "$ICON_DIR/${APP_NAME}.png"
    update-desktop-database "$APPS_DIR" 2>/dev/null || true
    echo "Done. ${APP_DISPLAY} desktop entry removed."
    exit 0
fi

# --- Install mode ---
echo "Installing ${APP_DISPLAY} desktop entry..."

mkdir -p "$APPS_DIR" "$ICON_DIR"

# Copy desktop file
cp "$DESKTOP_FILE" "$APPS_DIR/${APP_NAME}.desktop"
echo "  + Desktop entry -> $APPS_DIR/${APP_NAME}.desktop"

# Copy icon if available
if [[ -f "$REPO_DIR/assets/icon-256.png" ]]; then
    cp "$REPO_DIR/assets/icon-256.png" "$ICON_DIR/${APP_NAME}.png"
    echo "  + Icon -> $ICON_DIR/${APP_NAME}.png"
else
    echo "  ! No icon found (place icon-256.png in assets/)"
fi

# Update desktop database
update-desktop-database "$APPS_DIR" 2>/dev/null || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor/" 2>/dev/null || true

echo ""
echo "Done! ${APP_DISPLAY} is now available in your application menu."
echo "Make sure 'gossamer' is in your PATH."
echo ""
echo "To remove: $0 --remove"
