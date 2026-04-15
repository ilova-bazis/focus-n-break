#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_NAME="FocusBreak"
BUNDLE_DIR="$BUILD_DIR/${APP_NAME}.app"

swift build --product focus-n-break

mkdir -p "$BUNDLE_DIR/Contents/MacOS" "$BUNDLE_DIR/Contents/Resources"
cp "$ROOT_DIR/.build/debug/focus-n-break" "$BUNDLE_DIR/Contents/MacOS/focus-n-break"
cp "$ROOT_DIR/AppBundle/Info.plist" "$BUNDLE_DIR/Contents/Info.plist"

chmod +x "$BUNDLE_DIR/Contents/MacOS/focus-n-break"

echo "Built ${BUNDLE_DIR}"
