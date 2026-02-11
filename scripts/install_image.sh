#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

sdkmanager "platforms;android-34" "system-images;android-34;google_apis;x86_64"
