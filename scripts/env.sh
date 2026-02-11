#!/usr/bin/env bash
set -euo pipefail

# Android_Emulator kit paths
export ANDROID_SDK_ROOT="$HOME/Documents/Android_Emulator/sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_AVD_HOME="$HOME/Documents/Android_Emulator/avd"

export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"
