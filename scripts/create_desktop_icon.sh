#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root (…/Android_Emulator)
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

APP_DIR="${HOME}/.local/share/applications"
DESKTOP_DIR="${HOME}/Desktop"

LAUNCHER_NAME="Android Emulator Audit"
DESKTOP_FILE_NAME="android-emulator-audit.desktop"

APP_LAUNCHER_PATH="${APP_DIR}/${DESKTOP_FILE_NAME}"
DESKTOP_LAUNCHER_PATH="${DESKTOP_DIR}/${DESKTOP_FILE_NAME}"

mkdir -p "$APP_DIR"
mkdir -p "$DESKTOP_DIR"

# Prefer a real icon if available; fallback to "android"
ICON_PATH=""
for p in \
  "/usr/share/icons/hicolor/128x128/apps/android-studio.png" \
  "/usr/share/pixmaps/android.png" \
  "/usr/share/icons/hicolor/128x128/apps/android.png" \
  "/usr/share/icons/hicolor/256x256/apps/android.png"
do
  if [[ -f "$p" ]]; then
    ICON_PATH="$p"
    break
  fi
done

ICON_VALUE="${ICON_PATH:-android}"

# Important: Exec should run in a login shell so it can find make/bash tools consistently.
# We explicitly cd into the kit root and run "make run".
EXEC_CMD="bash -lc 'cd \"${ROOT}\" && make run'"

cat > "$APP_LAUNCHER_PATH" <<EOF
[Desktop Entry]
Type=Application
Name=${LAUNCHER_NAME}
Comment=Start Android emulator for audits (prompts for backend port)
Exec=${EXEC_CMD}
Terminal=false
Categories=Development;
Icon=${ICON_VALUE}
StartupNotify=true
EOF

chmod +x "$APP_LAUNCHER_PATH"

# Copy to Desktop (icon)
cp -f "$APP_LAUNCHER_PATH" "$DESKTOP_LAUNCHER_PATH"
chmod +x "$DESKTOP_LAUNCHER_PATH"

# Try to mark it "trusted" (works on many Mint/Nemo setups)
if command -v gio >/dev/null 2>&1; then
  gio set "$DESKTOP_LAUNCHER_PATH" metadata::trusted true >/dev/null 2>&1 || true
fi

echo "Created launcher:"
echo "  Menu:    $APP_LAUNCHER_PATH"
echo "  Desktop: $DESKTOP_LAUNCHER_PATH"
echo
echo "If Mint blocks launching, right-click the Desktop icon and choose 'Allow Launching'."
