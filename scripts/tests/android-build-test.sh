#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/bin" "$WORK/ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include"

cat > "$WORK/bin/fake-zig" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail

libc_file=""
target=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --libc) libc_file="$2"; shift 2 ;;
    -Dtarget=*) target="${1#-Dtarget=}"; shift ;;
    *) shift ;;
  esac
done

[ -n "$libc_file" ] && [ -f "$libc_file" ]
[ -n "$target" ]
sysroot="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
grep -Fxq "include_dir=$sysroot/usr/include" "$libc_file"
grep -Fxq "sys_include_dir=$sysroot/usr/include" "$libc_file"
grep -Fxq "crt_dir=$sysroot/usr/lib/$target/26" "$libc_file"
grep -Fxq 'msvc_lib_dir=' "$libc_file"
grep -Fxq 'kernel32_lib_dir=' "$libc_file"
grep -Fxq 'gcc_dir=' "$libc_file"

printf '%s\n' "$target" >> "$FAKE_ZIG_LOG"
mkdir -p zig-out/lib
: > zig-out/lib/libgossamer.so
FAKE
chmod +x "$WORK/bin/fake-zig"

cd "$ROOT"
ANDROID_NDK_HOME="$WORK/ndk" \
GOSSAMER_ANDROID_MODULE="$WORK/module" \
FAKE_ZIG_LOG="$WORK/targets" \
ZIG="$WORK/bin/fake-zig" \
  bash scripts/android-build.sh >/dev/null

sort "$WORK/targets" > "$WORK/actual"
printf '%s\n' \
  aarch64-linux-android \
  arm-linux-androideabi \
  x86_64-linux-android > "$WORK/expected"
cmp "$WORK/expected" "$WORK/actual"

for abi in arm64-v8a armeabi-v7a x86_64; do
  test -f "$WORK/module/src/main/jniLibs/$abi/libgossamer.so"
done

echo "PASS: Android builds receive per-ABI NDK libc configuration and emit every jniLib"
