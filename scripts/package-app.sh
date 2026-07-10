#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/outputs/SubtitleOverlay.app"
CONTENTS_DIR="$APP_DIR/Contents"

cd "$ROOT_DIR"
swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"
cp "$ROOT_DIR/.build/arm64-apple-macosx/release/SubtitleOverlay" "$CONTENTS_DIR/MacOS/SubtitleOverlay"
cp "$ROOT_DIR/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"
chmod +x "$CONTENTS_DIR/MacOS/SubtitleOverlay"

if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$APP_DIR" >/dev/null
fi

echo "Packaged $APP_DIR"
