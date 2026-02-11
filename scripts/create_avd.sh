#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

NAME="${1:-pixel_api34}"

# Ensure AVD home exists
mkdir -p "$ANDROID_AVD_HOME"

# Create (uses our ANDROID_AVD_HOME automatically)
avdmanager create avd -n "$NAME" -k "system-images;android-34;google_apis;x86_64" --device "pixel"

echo "Created AVD: $NAME"
echo "List:"
avdmanager list avd
