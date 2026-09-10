#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

CONTROL_CLI="$PROJECT_ROOT/scripts/control-center/control-center.sh"

ROFI_DIR="$PROJECT_ROOT/configs/rofi"
ROFI_CONFIG="$ROFI_DIR/config.rasi"
ROFI_FALLBACK_THEME="$ROFI_DIR/theme.rasi"

THEME_FRONTEND="$PROJECT_ROOT/scripts/theme-switcher/rofi.sh"
THEME_SETTINGS_FRONTEND="$PROJECT_ROOT/scripts/theme-switcher/settings-rofi.sh"
WALLPAPER_FRONTEND="$PROJECT_ROOT/scripts/wallpaper-switcher/launch.sh"
NETWORK_FRONTEND="$PROJECT_ROOT/configs/networkmanager/network.sh"
BLUETOOTH_FRONTEND="$PROJECT_ROOT/configs/bluetooth/bluetooth.sh"
GHOSTTY_LAUNCH="$PROJECT_ROOT/configs/ghostty/launch.sh"

if ! command -v rofi >/dev/null 2>&1; then
  printf 'Error: Rofi is not installed.\n' >&2
  exit 1
fi

rofi_theme="$ROFI_FALLBACK_THEME"

if [[ -x "$ROFI_DIR/prepare-theme.sh" ]]; then
  if generated_theme="$("$ROFI_DIR/prepare-theme.sh" 2>/dev/null)" &&
    [[ -r "$generated_theme" ]]; then
    rofi_theme="$generated_theme"
  fi
fi

menu() {
  local prompt="$1"
  shift

  rofi \
    -dmenu \
    -i \
    -p "$prompt" \
    -config "$ROFI_CONFIG" \
    -theme "$rofi_theme" \
    -theme-str 'window { width: 660px; } listview { columns: 1; lines: 10; }' \
    -kb-row-up "Up,Alt+k" \
    -kb-row-down "Down,Alt+j" \
    "$@"
}

choose() {
  local prompt="$1"
  shift

  printf '%s\n' "$@" | menu "$prompt"
}

notify_error() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      --app-name="Hyprdots Control Center" \
      "Control Center" \
      "$message" \
      >/dev/null 2>&1 || true
  fi
}

run_backend() {
  if ! "$CONTROL_CLI" "$@"; then
    notify_error "Command failed: $*"
    return 1
  fi
}

open_config() {
  local config_name="$1"
  local config_path
  local editor="${EDITOR:-nvim}"

  config_path="$("$CONTROL_CLI" config path "$config_name")" || return 1

  if [[ ! -e "$config_path" ]]; then
    notify_error "Config not found: $config_path"
    return 1
  fi

  "$GHOSTTY_LAUNCH" -e "$editor" "$config_path" >/dev/null 2>&1 &
}

show_text() {
  local title="$1"
  local text="$2"

  printf '%s\n' "$text" |
    rofi \
      -dmenu \
      -p "$title" \
      -config "$ROFI_CONFIG" \
      -theme "$rofi_theme" \
      -theme-str 'window { width: 760px; } listview { columns: 1; lines: 12; }'
}

appearance_menu() {
  local choice
  local mode
  local theme

  while true; do
    mode="$("$CONTROL_CLI" theme mode)"
    theme="$("$CONTROL_CLI" theme current)"

    choice="$(
      choose \
        "Appearance" \
        "󰔎  Theme                         $theme ($mode)" \
        "󰸉  Wallpaper" \
        "󰒓  Theme settings" \
        "󰑐  Apply current theme" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰔎  Theme"*)
      "$THEME_FRONTEND" || true
      ;;
    "󰸉  Wallpaper")
      "$WALLPAPER_FRONTEND" || true
      ;;
    "󰒓  Theme settings")
      "$THEME_SETTINGS_FRONTEND" || true
      ;;
    "󰑐  Apply current theme")
      run_backend theme apply || true
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

connectivity_menu() {
  local choice
  local wifi
  local bluetooth

  while true; do
    wifi="$("$CONTROL_CLI" network status 2>/dev/null || printf 'unavailable')"
    bluetooth="$("$CONTROL_CLI" bluetooth status 2>/dev/null || printf 'unavailable')"

    choice="$(
      choose \
        "Connectivity" \
        "󰖩  Network                       $wifi" \
        "󰂯  Bluetooth                     $bluetooth" \
        "󰖪  Toggle Wi-Fi" \
        "󰂲  Toggle Bluetooth" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰖩  Network"*)
      "$NETWORK_FRONTEND" || true
      ;;
    "󰂯  Bluetooth"*)
      "$BLUETOOTH_FRONTEND" || true
      ;;
    "󰖪  Toggle Wi-Fi")
      run_backend network toggle || true
      ;;
    "󰂲  Toggle Bluetooth")
      run_backend bluetooth toggle || true
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

mouseless_menu() {
  local choice
  local status
  local autostart

  while true; do
    status="$("$CONTROL_CLI" mouseless status 2>/dev/null || printf 'unavailable')"
    autostart="$("$CONTROL_CLI" mouseless enabled 2>/dev/null || printf 'unavailable')"

    choice="$(
      choose \
        "Mouseless" \
        "󰍽  Status                        $status" \
        "󰐥  Autostart                     $autostart" \
        "󰑐  Restart" \
        "󰒓  Edit configuration" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰍽  Status"*)
      run_backend mouseless toggle || true
      ;;
    "󰐥  Autostart"*)
      if [[ "$autostart" == "enabled" ]]; then
        run_backend mouseless disable || true
      else
        run_backend mouseless enable || true
      fi
      ;;
    "󰑐  Restart")
      run_backend mouseless restart || true
      ;;
    "󰒓  Edit configuration")
      open_config mouseless || true
      return 0
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

input_menu() {
  local choice

  while true; do
    choice="$(
      choose \
        "Input" \
        "󰍽  Mouseless" \
        "󰌌  Hyprland input configuration" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰍽  Mouseless")
      mouseless_menu
      ;;
    "󰌌  Hyprland input configuration")
      open_config hyprland || true
      return 0
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

desktop_menu() {
  local choice
  local waybar

  while true; do
    waybar="$("$CONTROL_CLI" waybar status)"

    choice="$(
      choose \
        "Desktop" \
        "󰍜  Restart Waybar                $waybar" \
        "󰥔  Toggle Waybar clock" \
        "󰂚  Toggle notifications" \
        "󰂛  Toggle Do Not Disturb" \
        "󰑐  Reload SwayNC" \
        "󰸉  Restart Hyprpaper" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰍜  Restart Waybar"*)
      run_backend waybar restart || true
      ;;
    "󰥔  Toggle Waybar clock")
      run_backend waybar clock-toggle || true
      ;;
    "󰂚  Toggle notifications")
      run_backend notifications toggle || true
      ;;
    "󰂛  Toggle Do Not Disturb")
      run_backend notifications dnd || true
      ;;
    "󰑐  Reload SwayNC")
      run_backend notifications reload || true
      ;;
    "󰸉  Restart Hyprpaper")
      run_backend hyprpaper restart || true
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

system_menu() {
  local choice
  local errors

  while true; do
    choice="$(
      choose \
        "System" \
        "󰑓  Reload Hyprland" \
        "󰑐  Reload themed applications" \
        "󰅚  Hyprland config errors" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰑓  Reload Hyprland")
      run_backend hyprland reload || true
      ;;
    "󰑐  Reload themed applications")
      run_backend reload || true
      ;;
    "󰅚  Hyprland config errors")
      errors="$("$CONTROL_CLI" hyprland errors 2>&1 || true)"
      [[ -n "$errors" ]] || errors="No Hyprland configuration errors."
      show_text "Hyprland errors" "$errors" >/dev/null || true
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

configuration_menu() {
  local selection
  local name
  local label
  local -a entries=()
  local -a names=()

  while IFS=$'\t' read -r name label; do
    [[ -n "$name" ]] || continue
    entries+=("󰒓  $label")
    names+=("$name")
  done < <("$CONTROL_CLI" config list)

  entries+=("←  Back")

  while true; do
    selection="$(
      printf '%s\n' "${entries[@]}" |
        menu "Edit Configuration"
    )" || return 0

    [[ "$selection" != "←  Back" && -n "$selection" ]] || return 0

    local index
    for ((index = 0; index < ${#names[@]}; index++)); do
      if [[ "$selection" == "${entries[index]}" ]]; then
        open_config "${names[index]}" || true
        return 0
      fi
    done
  done
}

main_menu() {
  local choice
  local theme_mode
  local wifi
  local bluetooth
  local mouseless

  while true; do
    theme_mode="$("$CONTROL_CLI" theme mode 2>/dev/null || printf '?')"
    wifi="$("$CONTROL_CLI" network status 2>/dev/null || printf '?')"
    bluetooth="$("$CONTROL_CLI" bluetooth status 2>/dev/null || printf '?')"
    mouseless="$("$CONTROL_CLI" mouseless status 2>/dev/null || printf '?')"

    choice="$(
      choose \
        "Hyprdots" \
        "󰔎  Appearance                    $theme_mode" \
        "󰖩  Connectivity                  Wi-Fi $wifi · BT $bluetooth" \
        "󰌌  Input                         Mouseless $mouseless" \
        "󰧨  Desktop" \
        "󰒓  Edit Configuration" \
        "󰒋  System" \
        "󰅖  Close"
    )" || exit 0

    case "$choice" in
    "󰔎  Appearance"*)
      appearance_menu
      ;;
    "󰖩  Connectivity"*)
      connectivity_menu
      ;;
    "󰌌  Input"*)
      input_menu
      ;;
    "󰧨  Desktop")
      desktop_menu
      ;;
    "󰒓  Edit Configuration")
      configuration_menu
      ;;
    "󰒋  System")
      system_menu
      ;;
    "󰅖  Close" | "")
      exit 0
      ;;
    esac
  done
}

main_menu
