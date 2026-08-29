#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Build the RPM from an exact archive of the checked-out commit.
set -euo pipefail

readonly version="0.3.0"
readonly output_dir="dist/linux"
topdir="$(mktemp -d)"
trap 'rm -rf "$topdir"' EXIT
mkdir -p "$topdir"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

git archive --format=tar --prefix="gossamer-${version}/" HEAD \
  | gzip -n > "$topdir/SOURCES/gossamer-${version}.tar.gz"
rpmbuild -bb --nodeps --define "_topdir $topdir" packaging/rpm/gossamer.spec

mkdir -p "$output_dir"
find "$topdir/RPMS" -type f -name '*.rpm' -exec cp {} "$output_dir/" \;
rpm -qpl "$output_dir"/*.rpm >/dev/null
printf 'Built RPM artefacts in %s\n' "$output_dir"
