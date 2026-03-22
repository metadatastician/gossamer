# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Containerfile for Gossamer
# Build: podman build -t gossamer:latest -f Containerfile .
# Run:   podman run --rm -it gossamer:latest
# Seal:  selur seal gossamer:latest

# --- Build stage ---
FROM cgr.dev/chainguard/wolfi-base:latest AS build

RUN apk add --no-cache zig

WORKDIR /build
COPY . .

RUN cd src/interface/ffi && zig build -Doptimize=ReleaseSafe

# --- Runtime stage ---
FROM cgr.dev/chainguard/static:latest

# Copy built library from build stage
COPY --from=build /build/src/interface/ffi/zig-out/lib/libgossamer.so /usr/local/lib/
COPY --from=build /build/src/interface/ffi/zig-out/lib/libgossamer.a /usr/local/lib/

# Non-root user (chainguard images default to nonroot)
USER nonroot
