#!/usr/bin/env bash

set -euo pipefail

BLUETOOTH_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
BLUETOOTH_THEME="$BLUETOOTH_DIR/theme.rasi"

declare -a ROFI_COMMON=()

if [[ -f "$ROFI_CONFIG" ]]; then
  ROFI_COMMON+=(
    -config "$ROFI_CONFIG"
  )
fi

ROFI_COMMON+=(
  -theme "$BLUETOOTH_THEME"
  -kb-row-up "Up,Alt+k"
  -kb-row-down "Down,Alt+j"
  -kb-cancel "Escape,Alt+h"
  -kb-accept-entry "Return,KP_Enter,Alt+l"
)

notify() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      --app-name="Hyprdots Bluetooth" \
      "Bluetooth" \
      "$message" \
      >/dev/null 2>&1 ||
      true
  else
    printf 'Bluetooth: %s\n' "$message" >&2
  fi
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    exit 127
  fi
}

bluetooth_powered() {
  LC_ALL=C bluetoothctl show 2>/dev/null |
    grep -q 'Powered: yes'
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

  name="$(device_property "$mac" "Alias")"

  if [[ -z "$name" ]]; then
    name="$(device_property "$mac" "Name")"
  fi

  if [[ -z "$name" ]]; then
    name="$mac"
  fi

  printf '%s\n' "$name"
}

device_is_paired() {
  [[ "$(device_property "$1" "Paired")" == "yes" ]]
}

device_is_connected() {
  [[ "$(device_property "$1" "Connected")" == "yes" ]]
}

device_is_trusted() {
  [[ "$(device_property "$1" "Trusted")" == "yes" ]]
}

device_is_blocked() {
  [[ "$(device_property "$1" "Blocked")" == "yes" ]]
}

device_icon() {
  local mac="$1"
  local icon

  icon="$(device_property "$mac" "Icon")"

  case "$icon" in
  audio-card | audio-headset)
    printf '󰋋'
    ;;

  input-mouse)
    printf '󰍽'
    ;;

  input-keyboard)
    printf '󰌌'
    ;;

  phone)
    printf '󰄜'
    ;;

  computer)
    printf '󰍹'
    ;;

  *)
    printf '󰂯'
    ;;
  esac
}

run_bluetoothctl() {
  bluetoothctl --timeout 20 "$@" >/dev/null 2>&1
}

connect_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl connect "$mac"; then
    notify "Connected to $name"
  else
    notify "Could not connect to $name"
    return 1
  fi
}

disconnect_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl disconnect "$mac"; then
    notify "Disconnected from $name"
  else
    notify "Could not disconnect from $name"
    return 1
  fi
}

pair_device() {
  local mac="$1"
  local name="$2"

  if bluetoothctl \
    --agent KeyboardDisplay \
    --timeout 30 \
    pair "$mac" \
    >/dev/null 2>&1; then
    notify "Paired with $name"
  else
    notify "Pairing failed: $name"
    return 1
  fi
}

trust_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl trust "$mac"; then
    notify "Trusted: $name"
  else
    notify "Could not trust $name"
    return 1
  fi
}

untrust_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl untrust "$mac"; then
    notify "Untrusted: $name"
  else
    notify "Could not untrust $name"
    return 1
  fi
}

block_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl block "$mac"; then
    notify "Blocked: $name"
  else
    notify "Could not block $name"
    return 1
  fi
}

unblock_device() {
  local mac="$1"
  local name="$2"

  if run_bluetoothctl unblock "$mac"; then
    notify "Unblocked: $name"
  else
    notify "Could not unblock $name"
    return 1
  fi
}

bluez_device_path() {
  local mac="$1"
  local suffix

  suffix="/dev_${mac//:/_}"

  busctl \
    --system \
    --list \
    tree org.bluez 2>/dev/null |
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
  local old_name="$2"

  if ! command -v busctl >/dev/null 2>&1; then
    notify "busctl is required for Rename"
    return 1
  fi

  local new_name

  new_name="$(
    printf '' |
      rofi \
        -dmenu \
        -p "󰑕 Rename" \
        -mesg "$old_name" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 340px;
            x-offset: 340px;
          }

          listview {
            enabled: false;
          }
        ' ||
      true
  )"

  [[ -n "$new_name" ]] || return 0

  local path
  path="$(bluez_device_path "$mac")"

  if [[ -z "$path" ]]; then
    notify "Could not find BlueZ device"
    return 1
  fi

  if busctl \
    --system \
    set-property \
    org.bluez \
    "$path" \
    org.bluez.Device1 \
    Alias \
    s \
    "$new_name"; then

    notify "Renamed to $new_name"
  else
    notify "Could not rename $old_name"
    return 1
  fi
}

remove_device() {
  local mac="$1"
  local name="$2"

  local choice

  choice="$(
    printf '%s\n' \
      "󰆴  Remove device" \
      "󰜺  Cancel" |
      rofi \
        -dmenu \
        -p "$name" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 300px;
            x-offset: 340px;
          }

          listview {
            lines: 2;
          }
        ' ||
      true
  )"

  [[ "$choice" == "󰆴  Remove device" ]] || return 0

  if run_bluetoothctl remove "$mac"; then
    notify "Removed: $name"
  else
    notify "Could not remove $name"
    return 1
  fi
}

show_info() {
  local mac="$1"
  local name="$2"

  local paired
  local bonded
  local trusted
  local blocked
  local connected
  local icon
  local rssi

  paired="$(device_property "$mac" "Paired")"
  bonded="$(device_property "$mac" "Bonded")"
  trusted="$(device_property "$mac" "Trusted")"
  blocked="$(device_property "$mac" "Blocked")"
  connected="$(device_property "$mac" "Connected")"
  icon="$(device_property "$mac" "Icon")"
  rssi="$(device_property "$mac" "RSSI")"

  {
    printf 'Name       %s\n' "$name"
    printf 'Address    %s\n' "$mac"
    printf 'Connected  %s\n' "${connected:-no}"
    printf 'Paired     %s\n' "${paired:-no}"
    printf 'Bonded     %s\n' "${bonded:-no}"
    printf 'Trusted    %s\n' "${trusted:-no}"
    printf 'Blocked    %s\n' "${blocked:-no}"
    printf 'Type       %s\n' "${icon:---}"

    if [[ -n "$rssi" ]]; then
      printf 'RSSI       %s\n' "$rssi"
    fi
  } |
    rofi \
      -dmenu \
      -no-custom \
      -p "󰋼 Device info" \
      "${ROFI_COMMON[@]}" \
      -theme-str '
        window {
          width: 440px;
          x-offset: 400px;
        }

        listview {
          lines: 10;
        }
      ' \
      >/dev/null ||
    true
}

device_actions() {
  local mac="$1"

  local name
  name="$(device_name "$mac")"

  local paired=false
  local connected=false
  local trusted=false
  local blocked=false

  device_is_paired "$mac" && paired=true
  device_is_connected "$mac" && connected=true
  device_is_trusted "$mac" && trusted=true
  device_is_blocked "$mac" && blocked=true

  local -a actions=()

  if [[ "$blocked" == "true" ]]; then
    actions+=("󰂲  Unblock")
  else
    if [[ "$paired" != "true" ]]; then
      actions+=("󰂰  Pair")
    fi

    if [[ "$connected" == "true" ]]; then
      actions+=("󰂲  Disconnect")
    elif [[ "$paired" == "true" ]]; then
      actions+=("󰂱  Connect")
    fi

    if [[ "$trusted" == "true" ]]; then
      actions+=("󰌾  Untrust")
    else
      actions+=("󰌾  Trust")
    fi

    actions+=("󰍶  Block")
  fi

  actions+=(
    "󰑕  Rename"
    "󰋼  Info"
  )

  if [[ "$paired" == "true" ]]; then
    actions+=("󰆴  Remove")
  fi

  local action

  action="$(
    printf '%s\n' "${actions[@]}" |
      rofi \
        -dmenu \
        -p "$name" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 310px;
            x-offset: 340px;
          }

          listview {
            lines: 9;
          }
        ' ||
      true
  )"

  case "$action" in
  "󰂰  Pair")
    pair_device "$mac" "$name" || true
    ;;

  "󰂱  Connect")
    connect_device "$mac" "$name" || true
    ;;

  "󰂲  Disconnect")
    disconnect_device "$mac" "$name" || true
    ;;

  "󰌾  Trust")
    trust_device "$mac" "$name" || true
    ;;

  "󰌾  Untrust")
    untrust_device "$mac" "$name" || true
    ;;

  "󰍶  Block")
    block_device "$mac" "$name" || true
    ;;

  "󰂲  Unblock")
    unblock_device "$mac" "$name" || true
    ;;

  "󰑕  Rename")
    rename_device "$mac" "$name" || true
    ;;

  "󰋼  Info")
    show_info "$mac" "$name"
    ;;

  "󰆴  Remove")
    remove_device "$mac" "$name" || true
    ;;

  "")
    ;;

  *)
    notify "Unknown action"
    ;;
  esac
}

scan_devices() {
  notify "Scanning for Bluetooth devices..."

  timeout 5s \
    bluetoothctl \
    scan on \
    >/dev/null 2>&1 ||
    true

  bluetoothctl scan off >/dev/null 2>&1 || true
}

show_power_disabled() {
  local choice

  choice="$(
    printf '%s\n' \
      "󰂯  Enable Bluetooth" \
      "󰜺  Cancel" |
      rofi \
        -dmenu \
        -p "󰂲 Bluetooth disabled" \
        "${ROFI_COMMON[@]}" \
        -theme-str '
          window {
            width: 370px;
          }

          listview {
            lines: 2;
          }
        ' ||
      true
  )"

  if [[ "$choice" == "󰂯  Enable Bluetooth" ]]; then
    bluetoothctl power on >/dev/null

    sleep 0.5

    exec "$0"
  fi
}

show_devices() {
  declare -A connected_devices=()
  declare -A paired_devices=()
  declare -A mac_by_entry=()
  declare -A seen=()

  local prefix
  local mac
  local name

  while read -r prefix mac name; do
    [[ "$prefix" == "Device" ]] || continue
    [[ -n "$mac" ]] || continue

    connected_devices["$mac"]=1
  done < <(
    LC_ALL=C bluetoothctl devices Connected 2>/dev/null
  )

  while read -r prefix mac name; do
    [[ "$prefix" == "Device" ]] || continue
    [[ -n "$mac" ]] || continue

    paired_devices["$mac"]=1
  done < <(
    LC_ALL=C bluetoothctl devices Paired 2>/dev/null
  )

  local -a entries=()

  while read -r prefix mac name; do
    [[ "$prefix" == "Device" ]] || continue
    [[ -n "$mac" ]] || continue
    [[ -n "${seen[$mac]:-}" ]] && continue

    seen["$mac"]=1

    name="$(device_name "$mac")"

    local icon
    local status
    local entry

    icon="$(device_icon "$mac")"
    status=""

    if [[ -n "${connected_devices[$mac]:-}" ]]; then
      status="● Connected"
    elif [[ -n "${paired_devices[$mac]:-}" ]]; then
      status="Paired"
    fi

    entry="$(
      printf '%s  %-30s  %s' \
        "$icon" \
        "${name:0:30}" \
        "$status"
    )"

    entries+=("$entry")
    mac_by_entry["$entry"]="$mac"
  done < <(
    LC_ALL=C bluetoothctl devices 2>/dev/null
  )

  entries+=(
    "󰑓  Scan devices"
    "󰂲  Disable Bluetooth"
  )

  local selection

  selection="$(
    printf '%s\n' "${entries[@]}" |
      rofi \
        -dmenu \
        -i \
        -p "󰂯 Bluetooth" \
        "${ROFI_COMMON[@]}" ||
      true
  )"

  case "$selection" in
  "")
    return 0
    ;;

  "󰑓  Scan devices")
    scan_devices
    exec "$0"
    ;;

  "󰂲  Disable Bluetooth")
    bluetoothctl power off >/dev/null
    notify "Bluetooth disabled"
    ;;

  *)
    local selected_mac="${mac_by_entry[$selection]:-}"

    [[ -n "$selected_mac" ]] || return 0

    device_actions "$selected_mac"

    exec "$0"
    ;;
  esac
}

main() {
  require_command bluetoothctl
  require_command rofi

  if ! bluetooth_powered; then
    show_power_disabled
    return
  fi

  show_devices
}

main "$@"
