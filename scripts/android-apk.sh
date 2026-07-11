#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Gradle-free APK assembly for gossamer-android-services (issue #68).
#
# Pipeline (all standard Android SDK build-tools — NO Gradle):
#   javac (android.jar + androidx.annotation) -> d8 -> aapt2 link
#     -> zip in classes.dex + jniLibs -> zipalign -> apksigner
# Produces a debug-signed "smoke" APK from the shim base classes + the sample
# Service/Receiver/Widget subclasses, so the packaging path is exercised without
# an external consumer app. A downstream app supplies its own manifest + concrete
# subclasses and reuses this same pipeline.
#
# Prereqs: ANDROID_HOME (SDK) with build-tools;34.0.0 + platforms;android-34.
# jniLibs are bundled when present (run scripts/android-build.sh or
# `just android-build` first); otherwise the APK is packaged without a native lib
# and the pipeline still validates.
set -euo pipefail

: "${ANDROID_HOME:?set ANDROID_HOME to your Android SDK}"
BUILD_TOOLS="${BUILD_TOOLS:-34.0.0}"
PLATFORM_API="${PLATFORM_API:-34}"
ANDROIDX_ANNOTATION_VER="${ANDROIDX_ANNOTATION_VER:-1.7.1}"

BT="$ANDROID_HOME/build-tools/$BUILD_TOOLS"
PLATFORM="$ANDROID_HOME/platforms/android-$PLATFORM_API/android.jar"
MODULE="android/gossamer-android-services"
MANIFEST="packaging/android/AndroidManifest.template.xml"
OUT="build/android"

for tool in "$BT/aapt2" "$BT/d8" "$BT/zipalign" "$BT/apksigner"; do
  [ -x "$tool" ] || { echo "!! missing $tool — install build-tools;$BUILD_TOOLS" >&2; exit 2; }
done
[ -f "$PLATFORM" ] || { echo "!! missing $PLATFORM — install platforms;android-$PLATFORM_API" >&2; exit 2; }

rm -rf "$OUT"; mkdir -p "$OUT/classes"

# androidx.annotation (LayoutRes, …) is not in android.jar — fetch the JVM jar.
AXA="$OUT/androidx-annotation.jar"
curl -fsSL \
  "https://maven.google.com/androidx/annotation/annotation-jvm/${ANDROIDX_ANNOTATION_VER}/annotation-jvm-${ANDROIDX_ANNOTATION_VER}.jar" \
  -o "$AXA"

echo "==> javac (shim base classes + sample subclasses)"
find "$MODULE/src" -name '*.java' > "$OUT/sources.txt"
javac -Xlint:none -source 17 -target 17 -classpath "$PLATFORM:$AXA" -d "$OUT/classes" @"$OUT/sources.txt"

echo "==> d8 (dex)"
# shellcheck disable=SC2046
"$BT/d8" --min-api 26 --output "$OUT" $(find "$OUT/classes" -name '*.class')

echo "==> aapt2 link (manifest -> base APK)"
"$BT/aapt2" link -o "$OUT/base.apk" -I "$PLATFORM" \
  --manifest "$MANIFEST" --min-sdk-version 26 --target-sdk-version "$PLATFORM_API"

echo "==> add classes.dex + jniLibs"
( cd "$OUT" && zip -qj base.apk classes.dex )
if [ -d "$MODULE/src/main/jniLibs" ] && find "$MODULE/src/main/jniLibs" -name '*.so' | read -r _; then
  rm -rf "$OUT/lib"; cp -r "$MODULE/src/main/jniLibs" "$OUT/lib"
  ( cd "$OUT" && zip -qr base.apk lib )
  echo "   bundled jniLibs: $(cd "$OUT/lib" && ls -d */ | tr -d '/' | tr '\n' ' ')"
else
  echo "   note: no jniLibs — run scripts/android-build.sh first for a runnable APK"
fi

echo "==> zipalign + apksigner (throwaway debug keystore)"
KS="$OUT/debug.keystore"
[ -f "$KS" ] || keytool -genkeypair -keystore "$KS" -alias androiddebugkey \
  -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Gossamer,C=GB" >/dev/null 2>&1
"$BT/zipalign" -f 4 "$OUT/base.apk" "$OUT/gossamer-smoke.apk"
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android "$OUT/gossamer-smoke.apk"
"$BT/apksigner" verify "$OUT/gossamer-smoke.apk"
echo "✔ signed APK: $OUT/gossamer-smoke.apk ($(stat -c%s "$OUT/gossamer-smoke.apk") bytes)"
