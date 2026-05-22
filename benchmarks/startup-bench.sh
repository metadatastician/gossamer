#!/usr/bin/env bash
# Gossamer Startup Benchmark
# Measures time-to-first-paint for the Gossamer webview shell.
#
# Usage: ./benchmarks/startup-bench.sh [path-to-binary] [iterations]
#
# SPDX-License-Identifier: MPL-2.0

set -euo pipefail

BINARY="${1:-zig-out/bin/gossamer}"
ITERATIONS="${2:-10}"
TIMEOUT_SEC=5

if [ ! -x "$BINARY" ]; then
    echo "ERROR: Binary not found or not executable: $BINARY"
    echo "Build first: cd src/interface/ffi && zig build"
    exit 1
fi

echo "# Gossamer Startup Benchmark"
echo "# Binary: $BINARY"
echo "# Iterations: $ITERATIONS"
echo "# Timeout: ${TIMEOUT_SEC}s"
echo "#"

results=()

for i in $(seq 1 "$ITERATIONS"); do
    # Measure wall-clock time to launch and exit
    start_ns=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')
    timeout "$TIMEOUT_SEC" "$BINARY" --headless --eval "window.close()" 2>/dev/null || true
    end_ns=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))')

    elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
    results+=("$elapsed_ms")
    echo "run_${i}_ms=$elapsed_ms"
done

# Compute median
IFS=$'\n' sorted=($(sort -n <<<"${results[*]}")); unset IFS
mid=$(( ITERATIONS / 2 ))
median="${sorted[$mid]}"

echo "#"
echo "# Results"
echo "median_ms=$median"
echo "iterations=$ITERATIONS"
echo "binary=$BINARY"
