#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
BLUETOOTH_CLI="$SCRIPT_DIR/bluetooth.sh"

ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
BLUETOOTH_LAYOUT="$PROJECT_ROOT/configs/bluetooth/theme.rasi"
BLUETOOTH_FALLBACK_THEME="$PROJECT_ROOT/configs/bluetooth/themes/current.rasi"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots"
else
  RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID"
fi

RUNTIME_THEME="$RUNTIME_DIR/bluetooth.rasi"

prepare_theme() {
  local palette="$BLUETOOTH_FALLBACK_THEME"
  local generated=""

  if [[ -x "$THEME_CLI" ]]; then
    generated="$("$THEME_CLI" path bluetooth 2>/dev/null || true)"
    if [[ -r "$generated" ]]; then
      palette="$generated"
    fi
  fi

  mkdir -p -- "$RUNTIME_DIR"
  {
    printf '@import "%s"\n' "$palette"
    printf '@import "%s"\n' "$BLUETOOTH_LAYOUT"
  } >"$RUNTIME_THEME"
}

prepare_theme

ROFI_COMMON=(
  -theme "$RUNTIME_THEME"
  -kb-row-up "Up,Alt+k"
  -kb-row-down "Down,Alt+j"
  -kb-cancel "Escape,Alt+h"
  -kb-accept-entry "Return,KP_Enter,Alt+l"
)

if [[ -f "$ROFI_CONFIG" ]]; then
  ROFI_COMMON=(-config "$ROFI_CONFIG" "${ROFI_COMMON[@]}")
fi

notify() {
  local message="$1"
  notify-send --app-name="Hyprdots Bluetooth" "Bluetooth" "$message" >/dev/null 2>&1 || true
}

prompt_rename() {
  local old_name="$1"

  printf '' |
    rofi -dmenu -p "󰑕 Rename" -mesg "$old_name" "${ROFI_COMMON[@]}" \
      -theme-str 'window { width: 380px; } listview { enabled: false; }'
}

show_info() {
  local mac="$1"

  "$BLUETOOTH_CLI" info "$mac" |
    rofi -dmenu -no-custom -p "󰋼 Bluetooth info" "${ROFI_COMMON[@]}" \
      -theme-str 'window { width: 520px; } listview { columns: 1; lines: 10; }' \
      >/dev/null || true
}

device_actions() {
  local mac="$1"
  local name="$2"
  local paired="$3"
  local connected="$4"
  local trusted="$5"
  local blocked="$6"
  local -a actions=()
  local action
  local new_name

  if [[ "$blocked" == "yes" ]]; then
    actions+=("󰂲  Unblock")
  else
    [[ "$paired" == "yes" ]] || actions+=("󰂰  Pair")

    if [[ "$connected" == "yes" ]]; then
      actions+=("󰂲  Disconnect")
    elif [[ "$paired" == "yes" ]]; then
      actions+=("󰂱  Connect")
    fi

    if [[ "$trusted" == "yes" ]]; then
      actions+=("󰌾  Untrust")
    else
      actions+=("󰌾  Trust")
    fi

    actions+=("󰍶  Block")
  fi

  actions+=("󰑕  Rename" "󰋼  Info")
  [[ "$paired" == "yes" ]] && actions+=("󰆴  Remove")

  action="$(
    printf '%s\n' "${actions[@]}" |
      rofi -dmenu -p "$name" "${ROFI_COMMON[@]}" \
        -theme-str 'window { width: 340px; } listview { columns: 1; }'
  )" || return 0

  case "$action" in
  "󰂰  Pair") "$BLUETOOTH_CLI" pair "$mac" && notify "Paired with $name" ;;
  "󰂱  Connect") "$BLUETOOTH_CLI" connect "$mac" && notify "Connected to $name" ;;
  "󰂲  Disconnect") "$BLUETOOTH_CLI" disconnect "$mac" && notify "Disconnected from $name" ;;
  "󰌾  Trust") "$BLUETOOTH_CLI" trust "$mac" && notify "Trusted $name" ;;
  "󰌾  Untrust") "$BLUETOOTH_CLI" untrust "$mac" && notify "Untrusted $name" ;;
  "󰍶  Block") "$BLUETOOTH_CLI" block "$mac" && notify "Blocked $name" ;;
  "󰂲  Unblock") "$BLUETOOTH_CLI" unblock "$mac" && notify "Unblocked $name" ;;
  "󰆴  Remove") "$BLUETOOTH_CLI" remove "$mac" && notify "Removed $name" ;;
  "󰑕  Rename")
    new_name="$(prompt_rename "$name")" || return 0
    [[ -n "$new_name" ]] || return 0
    "$BLUETOOTH_CLI" rename "$mac" "$new_name" && notify "Renamed to $new_name"
    ;;
  "󰋼  Info") show_info "$mac" ;;
  esac
}

show_disabled() {
  local choice

  choice="$(
    printf '%s\n' "󰂯  Enable Bluetooth" "󰜺  Cancel" |
      rofi -dmenu -p "󰂲 Bluetooth disabled" "${ROFI_COMMON[@]}" \
        -theme-str 'window { width: 380px; } listview { lines: 2; columns: 1; }'
  )" || return 0

  if [[ "$choice" == "󰂯  Enable Bluetooth" ]]; then
    "$BLUETOOTH_CLI" on
  fi
}

show_devices() {
  local mac
  local name
  local paired
  local connected
  local trusted
  local blocked
  local icon
  local status_text
  local entry
  local selection
  local selected_mac
  local -a entries=()
  declare -A mac_by_entry=()
  declare -A name_by_entry=()
  declare -A paired_by_entry=()
  declare -A connected_by_entry=()
  declare -A trusted_by_entry=()
  declare -A blocked_by_entry=()

  while IFS=$'\t' read -r mac name paired connected trusted blocked icon; do
    [[ -n "$mac" ]] || continue

    status_text=""
    if [[ "$connected" == "yes" ]]; then
      status_text="● Connected"
    elif [[ "$paired" == "yes" ]]; then
      status_text="Paired"
    fi

    entry="$(printf '%s  %-30s  %s' "$icon" "${name:0:30}" "$status_text")"
    entries+=("$entry")
    mac_by_entry["$entry"]="$mac"
    name_by_entry["$entry"]="$name"
    paired_by_entry["$entry"]="$paired"
    connected_by_entry["$entry"]="$connected"
    trusted_by_entry["$entry"]="$trusted"
    blocked_by_entry["$entry"]="$blocked"
  done < <("$BLUETOOTH_CLI" list)

  entries+=("󰑓  Scan devices" "󰂲  Disable Bluetooth")

  selection="$(
    printf '%s\n' "${entries[@]}" |
      rofi -dmenu -i -p "󰂯 Bluetooth" "${ROFI_COMMON[@]}"
  )" || return 0

  case "$selection" in
  "󰑓  Scan devices")
    notify "Scanning for Bluetooth devices..."
    "$BLUETOOTH_CLI" scan 5
    ;;
  "󰂲  Disable Bluetooth")
    "$BLUETOOTH_CLI" off
    notify "Bluetooth disabled"
    ;;
  "")
    ;;
  *)
    selected_mac="${mac_by_entry[$selection]:-}"
    [[ -n "$selected_mac" ]] || return 0
    device_actions \
      "$selected_mac" \
      "${name_by_entry[$selection]}" \
      "${paired_by_entry[$selection]}" \
      "${connected_by_entry[$selection]}" \
      "${trusted_by_entry[$selection]}" \
      "${blocked_by_entry[$selection]}"
    ;;
  esac
}

main() {
  command -v rofi >/dev/null 2>&1 || {
    printf 'Rofi is not installed.\n' >&2
    return 127
  }

  if [[ "$("$BLUETOOTH_CLI" status)" != "enabled" ]]; then
    show_disabled
    return 0
  fi

  show_devices
}

main "$@"
