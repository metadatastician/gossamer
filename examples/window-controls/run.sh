#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Run the Gossamer Window Controls demo.
#
# Exercises all 8 window control IPC operations:
#   minimize, maximize, restore, show, hide, resize, set_title, close
#
# Must be run from a desktop session (KDE/GNOME/Wayland/X11).
#
# Usage:
#   cd ~/Documents/hyperpolymath-repos/gossamer/examples/window-controls
#   bash run.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GOSSAMER_CLI="${REPO_ROOT}/cli/zig-out/bin/gossamer"

if [[ ! -x "$GOSSAMER_CLI" ]]; then
    echo "ERROR: gossamer CLI not built. Run:"
    echo "  cd ${REPO_ROOT}/cli && zig build"
    exit 1
fi

echo "=== Gossamer Window Controls Demo ==="
echo "CLI:  $GOSSAMER_CLI"
echo ""

cd "$SCRIPT_DIR"
exec "$GOSSAMER_CLI" run
