#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$HOME/.local/share/applications"
APP_FILE="$APP_DIR/android-emulator-kit.desktop"
DESKTOP_DIR="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
DESKTOP_FILE="$DESKTOP_DIR/android-emulator-kit.desktop"

mkdir -p "$APP_DIR" "$DESKTOP_DIR"

cat > "$APP_FILE" <<EOT
[Desktop Entry]
Type=Application
Name=Android Emulator Kit
Comment=Launch Android emulator instances for audits
Exec=bash -lc 'cd "$ROOT_DIR" && ./scripts/run_with_port.sh'
Terminal=false
Categories=Development;Emulator;
Icon=android
EOT

chmod +x "$APP_FILE"
cp "$APP_FILE" "$DESKTOP_FILE"
chmod +x "$DESKTOP_FILE"

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "Desktop launcher created:"
echo "  $APP_FILE"
echo "Desktop icon created:"
echo "  $DESKTOP_FILE"
