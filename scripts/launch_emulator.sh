#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/env.sh"

AVD="${1:-${AVD:-pixel_api34}}"
GPU="${2:-${GPU:-swiftshader_indirect}}"
EMULATOR_PORT="${3:-${EMULATOR_PORT:-5554}}"
WINDOW_TITLE="${4:-${WINDOW_TITLE:-Android Emulator}}"

CFG="$ANDROID_AVD_HOME/${AVD}.avd/config.ini"

if [[ ! -f "$CFG" ]]; then
  echo "ERROR: AVD config not found: $CFG"
  echo "Tip: run: emulator -list-avds"
  exit 1
fi

if grep -q '^hw.keyboard=' "$CFG"; then
  sed -i 's/^hw.keyboard=.*/hw.keyboard=yes/' "$CFG"
else
  echo 'hw.keyboard=yes' >> "$CFG"
fi

if ! grep -q '^hw.keyboard.charmap=' "$CFG"; then
  echo 'hw.keyboard.charmap=qwerty2' >> "$CFG"
fi

if grep -q '^hw.mainKeys=' "$CFG"; then
  sed -i 's/^hw.mainKeys=.*/hw.mainKeys=no/' "$CFG"
else
  echo 'hw.mainKeys=no' >> "$CFG"
fi

EMULATOR_ARGS=(
  -avd "$AVD"
  -gpu "$GPU"
  -port "$EMULATOR_PORT"
  -no-snapshot
  -no-snapshot-save
)

if emulator -help-all 2>/dev/null | grep -q -- '-qt-window-title'; then
  EMULATOR_ARGS+=( -qt-window-title "$WINDOW_TITLE" )
fi

exec emulator "${EMULATOR_ARGS[@]}"
