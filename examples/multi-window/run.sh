#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Run the Gossamer Multi-Window example.
#
# This opens two real GTK windows with WebKitGTK rendering HTML.
# Must be run from a desktop session (KDE/GNOME/Wayland/X11).
#
# Demonstrates:
# - Creating multiple webview windows
# - Window registry management
# - Window grouping
# - Multi-window lifecycle
#
# Usage:
#   cd ~/Documents/hyperpolymath-repos/gossamer
#   bash examples/multi-window/run.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
EPHAPAX="${REPO_ROOT}/../ephapax/target/debug/ephapax"
LIBGOSSAMER="${REPO_ROOT}/src/interface/ffi/zig-out/lib/libgossamer.so"

# Check prerequisites
if [[ ! -x "$EPHAPAX" ]]; then
    echo "ERROR: Ephapax CLI not built. Run:"
    echo "  cd ~/Documents/hyperpolymath-repos/ephapax && cargo build -p ephapax-cli"
    exit 1
fi

if [[ ! -f "$LIBGOSSAMER" ]]; then
    echo "ERROR: libgossamer.so not built. Run:"
    echo "  cd ~/Documents/hyperpolymath-repos/gossamer/src/interface/ffi && zig build"
    exit 1
fi

echo "=== Gossamer Multi-Window Example ==="
echo "Compiler: $EPHAPAX"
echo "FFI lib:  $LIBGOSSAMER"
echo ""
echo "Starting two windows..."
echo "  - Main Window (1024x768)"
echo "  - Sidebar Window (400x768)"
echo ""
echo "Note: Windows will appear one at a time due to single-threaded event loop."
echo "Close each window to continue to the next one."
echo ""

# Run the multi-window example with native FFI
"$EPHAPAX" run "${REPO_ROOT}/examples/multi-window/run.eph" \
    -L "$LIBGOSSAMER" \
    -v
