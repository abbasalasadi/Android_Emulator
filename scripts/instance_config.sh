#!/usr/bin/env bash
set -euo pipefail

INSTANCE_RAW="${1:-A}"
INSTANCE="$(printf '%s' "$INSTANCE_RAW" | tr '[:lower:]' '[:upper:]')"

case "$INSTANCE" in
  A)
    INSTANCE_KEY="a"
    DEFAULT_AVD="pixel_api34_a"
    DEFAULT_EMULATOR_PORT="5554"
    DEFAULT_BACKEND_PORT="5001"
    ;;
  B)
    INSTANCE_KEY="b"
    DEFAULT_AVD="pixel_api34_b"
    DEFAULT_EMULATOR_PORT="5556"
    DEFAULT_BACKEND_PORT="5002"
    ;;
  C)
    INSTANCE_KEY="c"
    DEFAULT_AVD="pixel_api34_c"
    DEFAULT_EMULATOR_PORT="5558"
    DEFAULT_BACKEND_PORT="5003"
    ;;
  *)
    echo "Unsupported instance '$INSTANCE_RAW'. Use A, B, or C." >&2
    exit 1
    ;;
 esac

export INSTANCE INSTANCE_KEY DEFAULT_AVD DEFAULT_EMULATOR_PORT DEFAULT_BACKEND_PORT
