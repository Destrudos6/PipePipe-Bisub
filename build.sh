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

CLIENT_URL="https://codeberg.org/NullPointerException/PipePipeClient.git"
EXTRACTOR_URL="https://codeberg.org/NullPointerException/PipePipeExtractor.git"
DEFAULT_CLIENT_REF="b91f008fb4d25b470c4383dcf42e31ee7696d272"
DEFAULT_EXTRACTOR_REF="1a09d20e68dbd0892995bc58ffa539049a656690"

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
# core.autocrlf=false: `git am` matches upstream context lines byte-for-byte and
# needs them to stay LF. On Windows the default autocrlf=true checks the tree out
# as CRLF, so every context-bearing hunk fails with "does not match index".
git -c core.autocrlf=false clone "$CLIENT_URL" "$SRC_DIR/PipePipeClient"
cd "$SRC_DIR/PipePipeClient"
git config core.autocrlf false
git checkout "$CLIENT_REF"

echo "==> Cloning upstream PipePipeExtractor ($EXTRACTOR_REF)"
git -c core.autocrlf=false clone "$EXTRACTOR_URL" "$SRC_DIR/PipePipeExtractor"
cd "$SRC_DIR/PipePipeExtractor"
git config core.autocrlf false
git checkout "$EXTRACTOR_REF"

echo "==> Applying bisub patches"
cd "$SRC_DIR/PipePipeClient"
# `git am` creates commits: a fresh machine without a global git identity would
# otherwise abort with "Please tell me who you are".
git config user.name "bisub-build"
git config user.email "bisub-build@localhost"
git am "$PATCH_DIR"/*.patch
echo "    Patches applied cleanly."

echo "==> Installing the fixed debug keystore"
# The committed keystore keeps the APK signature identical across builds (and
# equal to the CI releases), so a local APK can be installed over a release and
# vice versa. Without it every build gets a fresh random debug key and Android
# refuses to update the installed app. Same behaviour as the CI workflow.
mkdir -p "$HOME/.android"
cp "$WORKDIR/debug.keystore" "$HOME/.android/debug.keystore"

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