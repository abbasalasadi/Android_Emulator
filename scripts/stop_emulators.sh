#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/env.sh"

mapfile -t EMUS < <(adb devices | awk 'NR>1 && $1 ~ /^emulator-/ {print $1}')

if (( ${#EMUS[@]} == 0 )); then
  echo "No running emulators."
  exit 0
fi

for id in "${EMUS[@]}"; do
  echo "Stopping $id ..."
  adb -s "$id" emu kill || true
done
