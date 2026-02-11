#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$APP_DIR/android-emulator-kit.desktop"

mkdir -p "$APP_DIR"

# Use bash -lc so PATH/env behaves like a login shell
cat > "$DESKTOP_FILE" <<EOT
[Desktop Entry]
Type=Application
Name=Android Emulator Kit
Comment=Launch Android emulator for audits
Exec=bash -lc '$ROOT_DIR/scripts/launch_emulator.sh pixel_api34'
Terminal=false
Categories=Development;Emulator;
Icon=android
EOT

chmod +x "$DESKTOP_FILE"

# Optional refresh (doesn't exist on all distros, so don't fail if missing)
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true

echo "Desktop launcher created:"
echo "  $DESKTOP_FILE"
