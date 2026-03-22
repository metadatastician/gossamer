#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Run the Gossamer Hello World example.
#
# This opens a real GTK window with WebKitGTK rendering HTML.
# Must be run from a desktop session (KDE/GNOME/Wayland/X11).
#
# Usage:
#   cd ~/Documents/hyperpolymath-repos/gossamer
#   bash examples/hello/run.sh

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

echo "=== Gossamer Hello World ==="
echo "Compiler: $EPHAPAX"
echo "FFI lib:  $LIBGOSSAMER"
echo ""

# Run the hello example with native FFI
"$EPHAPAX" run "${REPO_ROOT}/examples/hello/run.eph" \
    -L "$LIBGOSSAMER" \
    -v
