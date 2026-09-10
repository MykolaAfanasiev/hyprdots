#!/usr/bin/env bash

set -euo pipefail

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    return 127
  fi
}

powered() {
  LC_ALL=C bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'
}

status() {
  require_command bluetoothctl

  if powered; then
    printf 'enabled\n'
  else
    printf 'disabled\n'
  fi
}

set_power() {
  local state="$1"
  require_command bluetoothctl
  bluetoothctl power "$state" >/dev/null
}

toggle() {
  if [[ "$(status)" == "enabled" ]]; then
    set_power off
  else
    set_power on
  fi
}

device_property() {
  local mac="$1"
  local property="$2"

  LC_ALL=C bluetoothctl info "$mac" 2>/dev/null |
    awk -F': ' -v property="$property" '
      {
        key = $1
        sub(/^[[:space:]]+/, "", key)
        if (key == property) {
          print $2
          exit
        }
      }
    '
}

device_name() {
  local mac="$1"
  local name

  name="$(device_property "$mac" Alias)"
  [[ -n "$name" ]] || name="$(device_property "$mac" Name)"
  [[ -n "$name" ]] || name="$mac"
  printf '%s\n' "$name"
}

device_icon() {
  case "$(device_property "$1" Icon)" in
  audio-card | audio-headset) printf '󰋋' ;;
  input-mouse) printf '󰍽' ;;
  input-keyboard) printf '󰌌' ;;
  phone) printf '󰄜' ;;
  computer) printf '󰍹' ;;
  *) printf '󰂯' ;;
  esac
}

list_devices() {
  require_command bluetoothctl

  local prefix
  local mac
  local ignored
  local name
  local paired
  local connected
  local trusted
  local blocked
  local icon
  local -A seen=()

  while read -r prefix mac ignored; do
    [[ "$prefix" == "Device" ]] || continue
    [[ -n "$mac" ]] || continue
    [[ -z "${seen[$mac]:-}" ]] || continue
    seen["$mac"]=1

    name="$(device_name "$mac")"
    paired="$(device_property "$mac" Paired)"
    connected="$(device_property "$mac" Connected)"
    trusted="$(device_property "$mac" Trusted)"
    blocked="$(device_property "$mac" Blocked)"
    icon="$(device_icon "$mac")"

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$mac" "$name" "$paired" "$connected" "$trusted" "$blocked" "$icon"
  done < <(LC_ALL=C bluetoothctl devices 2>/dev/null)
}

run() {
  require_command bluetoothctl
  bluetoothctl --timeout 20 "$@" >/dev/null
}

pair() {
  require_command bluetoothctl
  bluetoothctl --agent KeyboardDisplay --timeout 30 pair "$1" >/dev/null
}

scan() {
  require_command bluetoothctl
  timeout "${1:-5}s" bluetoothctl scan on >/dev/null 2>&1 || true
  bluetoothctl scan off >/dev/null 2>&1 || true
}

bluez_device_path() {
  local mac="$1"
  local suffix="/dev_${mac//:/_}"

  require_command busctl

  busctl --system --list tree org.bluez 2>/dev/null |
    awk -v suffix="$suffix" '
      index($0, suffix) &&
      substr($0, length($0) - length(suffix) + 1) == suffix {
        print
        exit
      }
    '
}

rename_device() {
  local mac="$1"
  local name="$2"
  local path

  path="$(bluez_device_path "$mac")"
  [[ -n "$path" ]] || return 1

  busctl set-property \
    org.bluez \
    "$path" \
    org.bluez.Device1 \
    Alias \
    s \
    "$name"
}

info() {
  local mac="$1"

  require_command bluetoothctl

  printf 'mac=%s\n' "$mac"
  printf 'name=%s\n' "$(device_name "$mac")"
  printf 'paired=%s\n' "$(device_property "$mac" Paired)"
  printf 'connected=%s\n' "$(device_property "$mac" Connected)"
  printf 'trusted=%s\n' "$(device_property "$mac" Trusted)"
  printf 'blocked=%s\n' "$(device_property "$mac" Blocked)"
  printf 'battery=%s\n' "$(device_property "$mac" 'Battery Percentage')"
}

usage() {
  cat <<'EOF_USAGE'
Usage:
  bluetooth.sh status
  bluetooth.sh on
  bluetooth.sh off
  bluetooth.sh toggle
  bluetooth.sh list
  bluetooth.sh scan [seconds]
  bluetooth.sh info <mac>
  bluetooth.sh pair <mac>
  bluetooth.sh connect <mac>
  bluetooth.sh disconnect <mac>
  bluetooth.sh trust <mac>
  bluetooth.sh untrust <mac>
  bluetooth.sh block <mac>
  bluetooth.sh unblock <mac>
  bluetooth.sh remove <mac>
  bluetooth.sh rename <mac> <name>
EOF_USAGE
}

main() {
  local command_name="${1:-}"

  case "$command_name" in
  status) status ;;
  on) set_power on ;;
  off) set_power off ;;
  toggle) toggle ;;
  list) list_devices ;;
  scan) scan "${2:-5}" ;;
  info)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    info "$2"
    ;;
  pair)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    pair "$2"
    ;;
  connect | disconnect | trust | untrust | block | unblock | remove)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    run "$command_name" "$2"
    ;;
  rename)
    [[ $# -eq 3 ]] || {
      usage >&2
      return 2
    }
    rename_device "$2" "$3"
    ;;
  help | -h | --help) usage ;;
  *)
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
