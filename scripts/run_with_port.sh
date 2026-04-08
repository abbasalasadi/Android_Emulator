#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

source "$HERE/env.sh"

INSTANCE="${INSTANCE:-A}"
source "$HERE/instance_config.sh" "$INSTANCE"

AVD_NAME="${AVD:-$DEFAULT_AVD}"
EMULATOR_PORT="${EMULATOR_PORT:-$DEFAULT_EMULATOR_PORT}"
DEFAULT_PORT="${DEFAULT_PORT:-$DEFAULT_BACKEND_PORT}"
GPU="${GPU:-swiftshader_indirect}"

VAR_DIR="$ROOT/var"
LOG_DIR="$VAR_DIR/logs"
LEGACY_LAST_PORT_FILE="$ROOT/last_port"
LEGACY_AUDIT_ENV_FILE="$ROOT/audit_env.sh"

mkdir -p "$VAR_DIR" "$LOG_DIR"

validate_port() {
  local p="$1"
  [[ "$p" =~ ^[0-9]+$ ]] || return 1
  (( p >= 1 && p <= 65535 )) || return 1
  return 0
}

is_emulator_running_for_port() {
  local serial="emulator-$1"
  adb devices | awk 'NR>1 {print $1}' | grep -qx "$serial"
}

port_file_for_instance() {
  local key="$1"
  printf '%s/instances/%s/last_port' "$VAR_DIR" "$key"
}

read_saved_port_for_instance() {
  local instance="$1"
  source "$HERE/instance_config.sh" "$instance"
  local file
  file="$(port_file_for_instance "$INSTANCE_KEY")"
  if [[ -f "$file" ]]; then
    cat "$file"
  else
    printf '%s\n' "$DEFAULT_BACKEND_PORT"
  fi
}

show_error() {
  local title="$1"
  local msg="$2"
  if command -v zenity >/dev/null 2>&1; then
    zenity --error --title="$title" --text="$msg" --width=520
  else
    echo -e "$title: $msg" >&2
  fi
}

selected_instances=()

default_a_port="$(read_saved_port_for_instance A)"
default_b_port="$(read_saved_port_for_instance B)"
default_c_port="$(read_saved_port_for_instance C)"

prompt_instances() {
  if command -v zenity >/dev/null 2>&1; then
    local selected_raw
    selected_raw="$(zenity --list \
      --title="Android Emulator Launcher" \
      --text="Select one or more emulator instances to launch. Saved backend ports shown below will be used as-is." \
      --checklist \
      --column="Select" --column="Instance" --column="Default AVD" --column="Emulator Port" --column="Saved Backend Port" \
      TRUE "A" "pixel_api34_a" "5554" "$default_a_port" \
      FALSE "B" "pixel_api34_b" "5556" "$default_b_port" \
      FALSE "C" "pixel_api34_c" "5558" "$default_c_port" \
      --separator='|' \
      --height=320 --width=760 \
      --ok-label="Launch" --cancel-label="Cancel")" || exit 0

    [[ -n "$selected_raw" ]] || exit 0
    IFS='|' read -r -a selected_instances <<< "$selected_raw"
  else
    local selected_input
    printf 'Choose instance(s) to launch [A,B,C] comma-separated (default A): ' >&2
    read -r selected_input
    selected_input="${selected_input:-A}"
    selected_input="$(printf '%s' "$selected_input" | tr '[:lower:]' '[:upper:]' | tr ',' ' ')"
    read -r -a selected_instances <<< "$selected_input"
  fi
}

prompt_instances

if [[ ${#selected_instances[@]} -eq 0 ]]; then
  exit 0
fi

declare -A seen_instances=()
summary_lines=()
launched_any=0

for selected_instance in "${selected_instances[@]}"; do
  selected_instance="$(printf '%s' "$selected_instance" | tr '[:lower:]' '[:upper:]')"
  [[ -n "$selected_instance" ]] || continue

  if [[ -n "${seen_instances[$selected_instance]:-}" ]]; then
    continue
  fi
  seen_instances[$selected_instance]=1

  source "$HERE/instance_config.sh" "$selected_instance"

  AVD_NAME="${AVD:-$DEFAULT_AVD}"
  EMULATOR_PORT="${EMULATOR_PORT:-$DEFAULT_EMULATOR_PORT}"
  PORT="$(read_saved_port_for_instance "$selected_instance")"

  if ! validate_port "$PORT"; then
    show_error "Invalid port" "Instance $selected_instance has invalid backend port '$PORT'. Port must be a number between 1 and 65535."
    exit 1
  fi

  INSTANCE_DIR="$VAR_DIR/instances/$INSTANCE_KEY"
  LAST_PORT_FILE="$INSTANCE_DIR/last_port"
  LAST_LAUNCH_FILE="$INSTANCE_DIR/last_launch.env"
  AUDIT_ENV_FILE="$ROOT/audit_env_instance_${INSTANCE_KEY}.sh"
  LOG_FILE="$LOG_DIR/emulator-${INSTANCE_KEY}.log"
  WINDOW_TITLE="Android Emulator ${selected_instance}"

  mkdir -p "$INSTANCE_DIR" "$LOG_DIR"

  printf '%s\n' "$PORT" > "$LAST_PORT_FILE"

  cat > "$AUDIT_ENV_FILE" <<EOF2
# Source this before running the audited mobile app for instance $selected_instance.
export AUDIT_INSTANCE="$selected_instance"
export AUDIT_EMULATOR_PORT="$EMULATOR_PORT"
export AUDIT_BACKEND_PORT="$PORT"
export AUDIT_BACKEND_URL="http://10.0.2.2:$PORT"
EOF2

  cat > "$LAST_LAUNCH_FILE" <<EOF2
INSTANCE=$selected_instance
AVD_NAME=$AVD_NAME
EMULATOR_PORT=$EMULATOR_PORT
AUDIT_BACKEND_PORT=$PORT
AUDIT_BACKEND_URL=http://10.0.2.2:$PORT
LOG_FILE=$LOG_FILE
EOF2

  if [[ "$selected_instance" == "A" ]]; then
    printf '%s\n' "$PORT" > "$LEGACY_LAST_PORT_FILE"
    cp "$AUDIT_ENV_FILE" "$LEGACY_AUDIT_ENV_FILE"
  fi

  if ! emulator -list-avds | grep -qx "$AVD_NAME"; then
    show_error "AVD not found" "AVD '$AVD_NAME' not found.\nCreate or rename the instance AVD first.\n\nExpected AVD for instance $selected_instance: $AVD_NAME"
    exit 1
  fi

  if ! is_emulator_running_for_port "$EMULATOR_PORT"; then
    nohup "$HERE/launch_emulator.sh" "$AVD_NAME" "$GPU" "$EMULATOR_PORT" "$WINDOW_TITLE" >"$LOG_FILE" 2>&1 &
    launched_any=1
  fi

  summary_lines+=("Instance: $selected_instance\nAVD: $AVD_NAME\nEmulator port: $EMULATOR_PORT\nBackend URL (from emulator): http://10.0.2.2:$PORT\nSaved port file: $LAST_PORT_FILE\nEnv file: $AUDIT_ENV_FILE\nLog: $LOG_FILE")
done

summary="$(printf '%b\n\n' "${summary_lines[@]}")"

if command -v zenity >/dev/null 2>&1; then
  zenity --info --title="Emulator launch summary" --text="$summary" --width=620
else
  printf '%b\n' "$summary"
fi
