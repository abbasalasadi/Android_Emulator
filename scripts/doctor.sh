#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

echo "ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo "ANDROID_AVD_HOME=$ANDROID_AVD_HOME"
echo

command -v sdkmanager && sdkmanager --version
command -v adb && adb version | head -n 2
command -v emulator && emulator -version | head -n 3
echo
avdmanager list avd || true
echo
emulator -list-avds || true
