#!/bin/bash
# Gossamer Display Test Runner
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Wraps the display integration tests in Xvfb so they can run headlessly
# in CI or on machines without a physical display.
#
# Usage:
#   ./scripts/test-with-display.sh          # Auto-detect display
#   DISPLAY=:0 ./scripts/test-with-display.sh  # Use existing display
#
# Dependencies:
#   - xvfb-run (from xorg-x11-server-Xvfb on Fedora, xvfb on Debian)
#   - zig (build system)
#   - gtk3-devel, webkit2gtk4.1-devel (or equivalent)

set -euo pipefail

# Navigate to the FFI build directory (where build.zig lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FFI_DIR="${SCRIPT_DIR}/../src/interface/ffi"

cd "${FFI_DIR}"

# If a display is already available, run tests directly
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    echo "==> Display detected (DISPLAY=${DISPLAY:-} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-})"
    echo "==> Running display tests directly..."
    zig build test-display 2>&1
    exit $?
fi

# No display — try xvfb-run
if command -v xvfb-run &>/dev/null; then
    echo "==> No display detected, using xvfb-run..."
    xvfb-run -a --server-args="-screen 0 1024x768x24" zig build test-display 2>&1
    exit $?
fi

# Neither display nor xvfb-run available
echo "==> SKIP: No display server and xvfb-run not found."
echo "   Install xvfb-run: sudo dnf install xorg-x11-server-Xvfb  (Fedora)"
echo "                     sudo apt install xvfb                    (Debian/Ubuntu)"
echo "   Or set DISPLAY to an existing X11 server."
exit 0
