#!/usr/bin/env bash
#
# Build a PipePipe APK with the bisub (bilingual subtitle) patches applied.
#
# Usage:
#   ./build.sh                                # default pinned refs
#   ./build.sh <client_ref> [extractor_ref]   # e.g. ./build.sh dev main
#   ./build.sh dev main --keep-source         # keep the cloned source directory
#
# Requirements: git, JDK 25, Android SDK (ANDROID_HOME or local.properties).
#
# NOTE: PipePipeClient's settings.gradle has includeBuild('../PipePipeExtractor'),
# so both repos are cloned side by side under src/ with their original names.

set -euo pipefail

CLIENT_URL="https://github.com/InfinityLoop1309/PipePipeClient.git"
EXTRACTOR_URL="https://github.com/InfinityLoop1309/PipePipeExtractor.git"
DEFAULT_CLIENT_REF="v5.5.0-beta3"
DEFAULT_EXTRACTOR_REF="73442076c671ae09bd5c0f9635932a5a67bdd609"

CLIENT_REF="${1:-$DEFAULT_CLIENT_REF}"
EXTRACTOR_REF="${2:-$DEFAULT_EXTRACTOR_REF}"
KEEP_SOURCE="${3:-}"

WORKDIR="$(pwd)"
SRC_DIR="$WORKDIR/src"
PATCH_DIR="$WORKDIR/patches"

echo "==> Cleaning previous source"
rm -rf "$SRC_DIR"
mkdir -p "$SRC_DIR"

echo "==> Cloning upstream PipePipeClient ($CLIENT_REF)"
git clone "$CLIENT_URL" "$SRC_DIR/PipePipeClient"
cd "$SRC_DIR/PipePipeClient"
git checkout "$CLIENT_REF"

echo "==> Cloning upstream PipePipeExtractor ($EXTRACTOR_REF)"
git clone "$EXTRACTOR_URL" "$SRC_DIR/PipePipeExtractor"
cd "$SRC_DIR/PipePipeExtractor"
git checkout "$EXTRACTOR_REF"

echo "==> Applying bisub patches"
cd "$SRC_DIR/PipePipeClient"
git am "$PATCH_DIR"/*.patch
echo "    Patches applied cleanly."

echo "==> Building debug APK"
./gradlew assembleDebug --stacktrace -DskipFormatKtlint

echo ""
echo "==> Done. APK location:"
find "$SRC_DIR/PipePipeClient/app/build/outputs" -name "*.apk" -exec ls -lh {} \;

if [ "$KEEP_SOURCE" != "--keep-source" ]; then
    echo "==> Cleaning up source directory"
    cd "$WORKDIR"
    rm -rf "$SRC_DIR"
fi