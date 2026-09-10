#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
NETWORK_CLI="$SCRIPT_DIR/network.sh"

ROFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/config.rasi"
THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
NETWORK_LAYOUT="$PROJECT_ROOT/configs/networkmanager/theme.rasi"
NETWORK_FALLBACK_THEME="$PROJECT_ROOT/configs/networkmanager/themes/current.rasi"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots"
else
  RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID"
fi

RUNTIME_THEME="$RUNTIME_DIR/networkmanager.rasi"

prepare_theme() {
  local palette="$NETWORK_FALLBACK_THEME"
  local generated=""

  if [[ -x "$THEME_CLI" ]]; then
    generated="$("$THEME_CLI" path networkmanager 2>/dev/null || true)"
    if [[ -r "$generated" ]]; then
      palette="$generated"
    fi
  fi

  mkdir -p -- "$RUNTIME_DIR"
  {
    printf '@import "%s"\n' "$palette"
    printf '@import "%s"\n' "$NETWORK_LAYOUT"
  } >"$RUNTIME_THEME"
}

prepare_theme

ROFI_COMMON=(
  -theme "$RUNTIME_THEME"
  -kb-row-up "Up,Alt+k"
  -kb-row-down "Down,Alt+j"
)

if [[ -f "$ROFI_CONFIG" ]]; then
  ROFI_COMMON=(-config "$ROFI_CONFIG" "${ROFI_COMMON[@]}")
fi

notify() {
  local message="$1"
  notify-send --app-name="Hyprdots Network" "Network" "$message" >/dev/null 2>&1 || true
}

signal_icon() {
  local signal="${1:-0}"

  if ((signal >= 80)); then
    printf '󰤨'
  elif ((signal >= 60)); then
    printf '󰤥'
  elif ((signal >= 40)); then
    printf '󰤢'
  elif ((signal >= 20)); then
    printf '󰤟'
  else
    printf '󰤯'
  fi
}

password_prompt() {
  local ssid="$1"

  printf '' |
    rofi \
      -dmenu \
      -password \
      -p " Password" \
      -mesg "$ssid" \
      "${ROFI_COMMON[@]}" \
      -theme-str 'window { width: 360px; } listview { enabled: false; }'
}

show_info() {
  local ssid="$1"
  local signal="$2"
  local security="$3"
  local raw

  raw="$("$NETWORK_CLI" info "$ssid" "$signal" "$security")"

  printf '%s\n' "$raw" |
    sed 's/^/  /' |
    rofi \
      -dmenu \
      -no-custom \
      -p "󰋼 Network info" \
      "${ROFI_COMMON[@]}" \
      -theme-str 'window { width: 520px; } listview { lines: 10; columns: 1; }' \
      >/dev/null || true
}

network_actions() {
  local ssid="$1"
  local signal="$2"
  local security="$3"
  local active="$4"
  local saved="$5"
  local -a actions=()
  local action
  local password

  if [[ "$active" == "*" ]]; then
    actions+=("󰌊  Disconnect")
  else
    actions+=("󰖩  Connect")
  fi

  actions+=("󰋼  Info" "󰆏  Copy SSID")

  if [[ "$saved" == "true" ]]; then
    actions+=("󰆴  Forget")
  fi

  action="$(
    printf '%s\n' "${actions[@]}" |
      rofi -dmenu -p "$ssid" "${ROFI_COMMON[@]}" \
        -theme-str 'window { width: 340px; } listview { columns: 1; }'
  )" || return 0

  case "$action" in
  "󰖩  Connect")
    if "$NETWORK_CLI" connect "$ssid"; then
      notify "Connected to $ssid"
      return 0
    fi

    if [[ -n "$security" && "$security" != "--" ]]; then
      password="$(password_prompt "$ssid")" || return 0
      [[ -n "$password" ]] || return 0

      if printf '%s\n' "$password" |
        "$NETWORK_CLI" connect "$ssid" --password-stdin; then
        notify "Connected to $ssid"
      else
        notify "Could not connect to $ssid"
      fi
    else
      notify "Could not connect to $ssid"
    fi
    ;;
  "󰌊  Disconnect")
    if "$NETWORK_CLI" disconnect "$ssid"; then
      notify "Disconnected from $ssid"
    else
      notify "Could not disconnect from $ssid"
    fi
    ;;
  "󰋼  Info")
    show_info "$ssid" "$signal" "$security"
    ;;
  "󰆏  Copy SSID")
    if command -v wl-copy >/dev/null 2>&1; then
      printf '%s' "$ssid" | wl-copy
      notify "SSID copied"
    fi
    ;;
  "󰆴  Forget")
    if "$NETWORK_CLI" forget "$ssid"; then
      notify "Forgot $ssid"
    else
      notify "No saved profile for $ssid"
    fi
    ;;
  esac
}

show_disabled() {
  local choice

  choice="$(
    printf '%s\n' "󰖩  Enable Wi-Fi" "󰜺  Cancel" |
      rofi -dmenu -p "󰖪 Wi-Fi disabled" "${ROFI_COMMON[@]}" \
        -theme-str 'window { width: 360px; } listview { lines: 2; columns: 1; }'
  )" || return 0

  if [[ "$choice" == "󰖩  Enable Wi-Fi" ]]; then
    "$NETWORK_CLI" on
  fi
}

show_networks() {
  local line
  local active
  local signal
  local security
  local saved
  local ssid
  local marker
  local lock
  local entry
  local selection
  local -a entries=()
  declare -A active_by_entry=()
  declare -A signal_by_entry=()
  declare -A security_by_entry=()
  declare -A saved_by_entry=()
  declare -A ssid_by_entry=()

  while IFS=$'\t' read -r active signal security saved ssid; do
    [[ -n "$ssid" ]] || continue

    marker=" "
    [[ "$active" == "*" ]] && marker="󰄬"

    lock=""
    [[ -n "$security" && "$security" != "--" ]] && lock=""

    entry="$(printf '%s  %s  %-28s  %3s%%  %s' \
      "$marker" "$(signal_icon "$signal")" "${ssid:0:28}" "$signal" "$lock")"

    entries+=("$entry")
    active_by_entry["$entry"]="$active"
    signal_by_entry["$entry"]="$signal"
    security_by_entry["$entry"]="$security"
    saved_by_entry["$entry"]="$saved"
    ssid_by_entry["$entry"]="$ssid"
  done < <("$NETWORK_CLI" list)

  entries+=("󰑓  Rescan" "󰖪  Disable Wi-Fi")

  selection="$(
    printf '%s\n' "${entries[@]}" |
      rofi -dmenu -i -p "󰖩 Network" "${ROFI_COMMON[@]}"
  )" || return 0

  case "$selection" in
  "󰑓  Rescan")
    "$NETWORK_CLI" rescan || notify "Wi-Fi scan failed"
    ;;
  "󰖪  Disable Wi-Fi")
    "$NETWORK_CLI" off
    notify "Wi-Fi disabled"
    ;;
  "")
    ;;
  *)
    ssid="${ssid_by_entry[$selection]:-}"
    [[ -n "$ssid" ]] || return 0
    network_actions \
      "$ssid" \
      "${signal_by_entry[$selection]}" \
      "${security_by_entry[$selection]}" \
      "${active_by_entry[$selection]}" \
      "${saved_by_entry[$selection]}"
    ;;
  esac
}

main() {
  command -v rofi >/dev/null 2>&1 || {
    printf 'Rofi is not installed.\n' >&2
    return 127
  }

  if [[ "$("$NETWORK_CLI" status)" != "enabled" ]]; then
    show_disabled
    return 0
  fi

  while true; do
    show_networks
    return 0
  done
}

main "$@"
