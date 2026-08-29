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
MODULE="${GOSSAMER_ANDROID_MODULE:-android/gossamer-android-services}"

declare -A ABI=( [aarch64-linux-android]=arm64-v8a
                 [x86_64-linux-android]=x86_64
                 [arm-linux-androideabi]=armeabi-v7a )
libc_file=""
trap 'rm -f "${libc_file:-}"' EXIT
for tgt in "${!ABI[@]}"; do
  echo "==> $tgt (${ABI[$tgt]})"
  sysroot="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
  crt_dir="$sysroot/usr/lib/$tgt/26"
  libc_file="$(mktemp)"
  printf '%s\n' \
    "include_dir=$sysroot/usr/include" \
    "sys_include_dir=$sysroot/usr/include" \
    "crt_dir=$crt_dir" \
    'msvc_lib_dir=' \
    'kernel32_lib_dir=' \
    'gcc_dir=' > "$libc_file"
  # Zig does not bundle Android's Bionic libc. Supply the NDK installation
  # explicitly; -Dndk additionally locates liblog and libandroid.
  ( cd src/interface/ffi && "$ZIG" build --libc "$libc_file" -Dtarget="$tgt" -Doptimize=ReleaseSafe -Dndk="$ANDROID_NDK_HOME" )
  rm -f "$libc_file"
  libc_file=""
  dst="$MODULE/src/main/jniLibs/${ABI[$tgt]}"
  mkdir -p "$dst"
  cp "src/interface/ffi/zig-out/lib/libgossamer.so" "$dst/"
done
built_abis="$(find "$MODULE/src/main/jniLibs" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tr '\n' ' ')"
echo "jniLibs built for: $built_abis"
