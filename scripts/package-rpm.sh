#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Build the RPM from an exact archive of the checked-out commit.
set -euo pipefail

readonly version="0.3.0"
readonly output_dir="dist/linux"
repo_root="$(pwd)"
topdir="$(mktemp -d)"
trap 'rm -rf "$topdir"' EXIT
mkdir -p "$topdir"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

git archive --format=tar --prefix="gossamer-${version}/" HEAD \
  | gzip -n > "$topdir/SOURCES/gossamer-${version}.tar.gz"
rpmbuild -bb --nodeps \
  --define "_topdir $topdir" \
  --define "repo_root $repo_root" \
  --define "debug_package %{nil}" \
  --define "_build_id_links none" \
  --define "__arch_install_post %{nil}" \
  packaging/rpm/gossamer.spec

mkdir -p "$output_dir"
find "$topdir/RPMS" -type f -name '*.rpm' -exec cp {} "$output_dir/" \;
for rpm_file in "$output_dir"/*.rpm; do
  rpm -qpl "$rpm_file" >/dev/null
done
printf 'Built RPM artefacts in %s\n' "$output_dir"
