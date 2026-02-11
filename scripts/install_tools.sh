#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

# Base deps
sudo apt-get update
sudo apt-get install -y curl unzip openjdk-17-jdk libc6 libstdc++6 zlib1g libncurses6

# Create cmdline-tools "latest" layout
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

# Official command line tools (Linux) — stable link
# If Google changes the filename, you can swap it here.
URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

echo "Downloading Android command-line tools..."
curl -L "$URL" -o cmdline-tools.zip

unzip -q cmdline-tools.zip

# The zip contains a top-level folder named "cmdline-tools"
rm -rf "$ANDROID_SDK_ROOT/cmdline-tools/latest"
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools/latest"
cp -a cmdline-tools/* "$ANDROID_SDK_ROOT/cmdline-tools/latest/"

# Install core SDK components
yes | sdkmanager --licenses >/dev/null || true
sdkmanager "platform-tools" "emulator" "cmdline-tools;latest"

echo
echo "Installed tools into: $ANDROID_SDK_ROOT"
echo "AVD home: $ANDROID_AVD_HOME"
