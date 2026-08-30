#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Build a Debian binary package from the already-verified release artefacts.
set -euo pipefail

readonly version="0.3.0"
arch="$(dpkg --print-architecture)"
readonly arch
readonly output_dir="dist/linux"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

install -d "$stage/DEBIAN" "$stage/usr/bin" "$stage/usr/lib" \
  "$stage/usr/share/gossamer" "$stage/usr/include/gossamer"
sed "s/^Architecture:.*/Architecture: $arch/" packaging/debian/control \
  > "$stage/DEBIAN/control"
install -m 0755 cli/launcher/zig-out/bin/gossamer-launcher \
  "$stage/usr/bin/gossamer"
install -m 0755 src/interface/ffi/zig-out/lib/libgossamer.so \
  "$stage/usr/lib/libgossamer.so"
install -m 0644 src/interface/ffi/zig-out/lib/libgossamer.a \
  "$stage/usr/lib/libgossamer.a"
install -m 0644 cli/launcher/zig-out/share/gossamer/cli.wasm \
  "$stage/usr/share/gossamer/cli.wasm"
install -m 0644 generated/abi/gossamer.h \
  "$stage/usr/include/gossamer/gossamer.h"

mkdir -p "$output_dir"
output="$output_dir/gossamer_${version}_${arch}.deb"
dpkg-deb --build --root-owner-group "$stage" "$output"
dpkg-deb --info "$output" >/dev/null
dpkg-deb --contents "$output" >/dev/null
printf 'Built %s\n' "$output"
