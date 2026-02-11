#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

AVD_NAME="${1:-pixel_api34}"
GPU="${2:-swiftshader_indirect}"

exec emulator -avd "$AVD_NAME" -gpu "$GPU"
