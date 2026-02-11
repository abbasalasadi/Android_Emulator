#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

# Load env vars for SDK + AVD home
source "$HERE/env.sh"

AVD_NAME="${AVD:-pixel_api34}"
DEFAULT_PORT="${DEFAULT_PORT:-5001}"
GPU="${GPU:-swiftshader_indirect}"

prompt_port() {
  local port=""
  if command -v zenity >/dev/null 2>&1; then
    port="$(zenity --entry \
      --title="Android Emulator Audit" \
      --text="Enter backend PORT for this audit.\n\nEmulator will reach your host backend via:\nhttp://10.0.2.2:PORT" \
      --entry-text="${DEFAULT_PORT}" \
      --ok-label="Run" \
      --cancel-label="Cancel" \
      --width=520 )" || exit 0
  else
    read -r -p "Enter backend PORT (default ${DEFAULT_PORT}): " port
    port="${port:-$DEFAULT_PORT}"
  fi
  echo "$port"
}

validate_port() {
  local p="$1"
  [[ "$p" =~ ^[0-9]+$ ]] || return 1
  (( p >= 1 && p <= 65535 )) || return 1
  return 0
}

PORT="$(prompt_port)"
if ! validate_port "$PORT"; then
  if command -v zenity >/dev/null 2>&1; then
    zenity --error --title="Invalid port" --text="Port must be a number between 1 and 65535." --width=380
  else
    echo "Invalid port: $PORT (must be 1..65535)" >&2
  fi
  exit 1
fi

# Save last port (for future)
echo "$PORT" > "$ROOT/last_port"

# Save env snippet for other terminals/projects
cat > "$ROOT/audit_env.sh" <<EOF
# Source this in any terminal before running an audited mobile app:
export AUDIT_BACKEND_PORT="$PORT"
export AUDIT_BACKEND_URL="http://10.0.2.2:$PORT"
EOF

# If an emulator device already exists, don't start another.
if adb devices | awk 'NR>1 {print $1}' | grep -q '^emulator-'; then
  :
else
  # Ensure the AVD exists
  if ! emulator -list-avds | grep -qx "$AVD_NAME"; then
    msg="AVD '$AVD_NAME' not found.\nRun: make list-avds\nThen: make start AVD=<name>"
    if command -v zenity >/dev/null 2>&1; then
      zenity --error --title="AVD not found" --text="$msg" --width=420
    else
      echo -e "$msg" >&2
    fi
    exit 1
  fi

  # Start emulator detached so Make doesn't stay blocked
  LOG="$ROOT/emulator.log"
  nohup emulator -avd "$AVD_NAME" -gpu "$GPU" >"$LOG" 2>&1 &
fi

# Show info
INFO="Emulator: $AVD_NAME
Backend URL (from emulator): http://10.0.2.2:$PORT

Saved:
- $ROOT/last_port
- $ROOT/audit_env.sh (source this in other terminals)

Tip: On Android emulator, host localhost is 10.0.2.2"
if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Emulator started" --text="$INFO" --width=520
else
  echo "$INFO"
fi
