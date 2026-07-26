#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Per-ABI cross-compile of libgossamer.so for Android (issue #67).
#
# Produces the jniLibs tree the consuming app bundles. build.zig routes
# *-linux-android / *-androideabi targets through the JNI WebView backend and
# the Service/Receiver/Widget native host, and wires the NDK sysroot
# (liblog/libandroid) via -Dndk. Requires ANDROID_NDK_HOME (r26+).
set -euo pipefail
: "${ANDROID_NDK_HOME:?set ANDROID_NDK_HOME to your NDK (r26+)}"
ZIG="${ZIG:-zig}"
MODULE="android/gossamer-android-services"

declare -A ABI=( [aarch64-linux-android]=arm64-v8a
                 [x86_64-linux-android]=x86_64
                 [arm-linux-androideabi]=armeabi-v7a )
for tgt in "${!ABI[@]}"; do
  echo "==> $tgt (${ABI[$tgt]})"
  ( cd src/interface/ffi && "$ZIG" build -Dtarget="$tgt" -Doptimize=ReleaseSafe -Dndk="$ANDROID_NDK_HOME" )
  dst="$MODULE/src/main/jniLibs/${ABI[$tgt]}"
  mkdir -p "$dst"
  cp "src/interface/ffi/zig-out/lib/libgossamer.so" "$dst/"
done
echo "jniLibs built for: $(cd "$MODULE/src/main/jniLibs" && ls -d */ 2>/dev/null | tr -d '/' | tr '\n' ' ')"
