#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

# Always load kit environment (ANDROID_SDK_ROOT / ANDROID_AVD_HOME etc.)
source "$SCRIPT_DIR/env.sh"

AVD="${1:-${AVD:-pixel_api34}}"
GPU="${2:-${GPU:-swiftshader_indirect}}"

CFG="$ANDROID_AVD_HOME/${AVD}.avd/config.ini"

if [[ ! -f "$CFG" ]]; then
  echo "ERROR: AVD config not found: $CFG"
  echo "Tip: run: emulator -list-avds"
  exit 1
fi

# ---- Permanent keyboard fixes ----
# Enable hardware keyboard
if grep -q '^hw.keyboard=' "$CFG"; then
  sed -i 's/^hw.keyboard=.*/hw.keyboard=yes/' "$CFG"
else
  echo 'hw.keyboard=yes' >> "$CFG"
fi

# Optional: stable qwerty map (harmless)
if ! grep -q '^hw.keyboard.charmap=' "$CFG"; then
  echo 'hw.keyboard.charmap=qwerty2' >> "$CFG"
fi

# Optional: show navigation keys
if grep -q '^hw.mainKeys=' "$CFG"; then
  sed -i 's/^hw.mainKeys=.*/hw.mainKeys=no/' "$CFG"
else
  echo 'hw.mainKeys=no' >> "$CFG"
fi

echo "AVD keyboard settings ensured in: $CFG"
grep -nE '^(hw.keyboard|hw.keyboard.charmap|hw.mainKeys)=' "$CFG" || true

# ---- Launch emulator ----
# Avoid snapshot-related regressions (common source of keyboard issues)
exec emulator -avd "$AVD" -gpu "$GPU" -no-snapshot -no-snapshot-save
