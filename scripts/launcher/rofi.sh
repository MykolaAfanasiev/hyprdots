#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

LAUNCHER_CLI="$SCRIPT_DIR/launcher.sh"

ROFI_DIR="$PROJECT_ROOT/configs/rofi"
ROFI_CONFIG="$ROFI_DIR/config.rasi"
ROFI_FALLBACK_THEME="$ROFI_DIR/theme.rasi"
ROFI_CLIPBOARD="$ROFI_DIR/clipboard.sh"

CONTROL_CENTER_FRONTEND="$PROJECT_ROOT/scripts/control-center/rofi.sh"
THEME_FRONTEND="$PROJECT_ROOT/scripts/theme-switcher/rofi.sh"
WALLPAPER_FRONTEND="$PROJECT_ROOT/scripts/wallpaper-switcher/launch.sh"
NETWORK_FRONTEND="$PROJECT_ROOT/scripts/networkmanager/rofi.sh"
BLUETOOTH_FRONTEND="$PROJECT_ROOT/scripts/bluetooth/rofi.sh"

if ! command -v rofi >/dev/null 2>&1; then
  printf 'Error: Rofi is not installed.\n' >&2
  exit 1
fi

rofi_theme="$ROFI_FALLBACK_THEME"

if [[ -x "$ROFI_DIR/prepare-theme.sh" ]]; then
  if generated_theme="$("${ROFI_DIR}/prepare-theme.sh" 2>/dev/null)" &&
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
    -theme-str 'window { width: 720px; } listview { columns: 1; lines: 13; }' \
    -kb-row-up "Up,Alt+k" \
    -kb-row-down "Down,Alt+j" \
    "$@"
}

choose() {
  local prompt="$1"
  shift

  printf '%s\n' "$@" | menu "$prompt"
}

input_value() {
  local prompt="$1"
  local message="${2:-}"

  printf '' |
    menu "$prompt" \
      -mesg "$message"
}

notify_error() {
  local message="$1"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      --app-name="Hyprdots Launcher" \
      "Launcher" \
      "$message" \
      >/dev/null 2>&1 || true
  fi
}

run_backend() {
  if ! "$LAUNCHER_CLI" "$@"; then
    notify_error "Command failed: $*"
    return 1
  fi
}

show_rofi_mode() {
  local mode="$1"
  local prompt="$2"
  local display_option=""

  case "$mode" in
  drun)
    display_option="-display-drun"
    ;;
  window)
    display_option="-display-window"
    ;;
  run)
    display_option="-display-run"
    ;;
  *)
    notify_error "Unsupported Rofi mode: $mode"
    return 2
    ;;
  esac

  rofi \
    -config "$ROFI_CONFIG" \
    -theme "$rofi_theme" \
    -modi "$mode" \
    -show "$mode" \
    "$display_option" "$prompt"
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
      -theme-str 'window { width: 720px; } listview { columns: 1; lines: 8; }'
}

mouseless_menu() {
  local choice
  local status
  local enabled

  while true; do
    status="$($LAUNCHER_CLI mouseless status 2>/dev/null || printf 'unavailable')"
    enabled="$($LAUNCHER_CLI mouseless enabled 2>/dev/null || printf 'unavailable')"

    choice="$(
      choose \
        "Mouseless" \
        "󰍽  Toggle                        $status" \
        "󰐥  Autostart                     $enabled" \
        "󰑐  Restart" \
        "←  Back"
    )" || return 0

    case "$choice" in
    "󰍽  Toggle"*)
      run_backend mouseless toggle || true
      ;;
    "󰐥  Autostart"*)
      if [[ "$enabled" == "enabled" ]]; then
        run_backend mouseless disable || true
      else
        run_backend mouseless enable || true
      fi
      ;;
    "󰑐  Restart")
      run_backend mouseless restart || true
      ;;
    "←  Back" | "")
      return 0
      ;;
    esac
  done
}

screenshot_menu() {
  local choice

  choice="$(
    choose \
      "Screenshot" \
      "󰹑  Fullscreen · copy + save" \
      "󰩭  Area · copy + save" \
      "󰏫  Fullscreen · edit" \
      "󰏫  Area · edit" \
      "󰅌  Fullscreen · clipboard only" \
      "󰅌  Area · clipboard only" \
      "󰆏  Fullscreen · save only" \
      "󰆏  Area · save only" \
      "←  Back"
  )" || return 0

  case "$choice" in
  "󰹑  Fullscreen · copy + save")
    run_backend screenshot full || true
    ;;
  "󰩭  Area · copy + save")
    run_backend screenshot area || true
    ;;
  "󰏫  Fullscreen · edit")
    run_backend screenshot full-edit || true
    ;;
  "󰏫  Area · edit")
    run_backend screenshot area-edit || true
    ;;
  "󰅌  Fullscreen · clipboard only")
    run_backend screenshot full-copy || true
    ;;
  "󰅌  Area · clipboard only")
    run_backend screenshot area-copy || true
    ;;
  "󰆏  Fullscreen · save only")
    run_backend screenshot full-save || true
    ;;
  "󰆏  Area · save only")
    run_backend screenshot area-save || true
    ;;
  esac
}

confirm_power_action() {
  local action="$1"
  local label="$2"
  local choice

  choice="$(
    choose \
      "$label?" \
      "Yes · $label" \
      "Cancel"
  )" || return 1

  [[ "$choice" == "Yes · $label" ]] || return 1

  run_backend power "$action"
}

power_menu() {
  local choice

  choice="$(
    choose \
      "Power" \
      "󰌾  Lock" \
      "󰤄  Suspend" \
      "󰒲  Hibernate" \
      "󰗼  Logout" \
      "󰜉  Reboot" \
      "󰐥  Shutdown" \
      "←  Back"
  )" || return 0

  case "$choice" in
  "󰌾  Lock")
    run_backend power lock || true
    ;;
  "󰤄  Suspend")
    run_backend power suspend || true
    ;;
  "󰒲  Hibernate")
    run_backend power hibernate || true
    ;;
  "󰗼  Logout")
    confirm_power_action logout "Logout" || true
    ;;
  "󰜉  Reboot")
    confirm_power_action reboot "Reboot" || true
    ;;
  "󰐥  Shutdown")
    confirm_power_action shutdown "Shutdown" || true
    ;;
  esac
}

calculator() {
  local expression
  local result

  expression="$(
    input_value \
      "Calculator" \
      "Examples: (12 + 5) * 3, sqrt(144), sin(pi / 2)"
  )" || return 0

  [[ -n "$expression" ]] || return 0

  if ! result="$($LAUNCHER_CLI calc "$expression" 2>&1)"; then
    show_text "Calculator error" "$result" >/dev/null || true
    return 0
  fi

  if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$result" | wl-copy
  fi

  local message
  printf -v message \
    '%s = %s\n\nResult copied to clipboard.' \
    "$expression" \
    "$result"

  show_text \
    "Calculator" \
    "$message" \
    >/dev/null || true
}

emoji_picker() {
  local selection=""

  if command -v rofimoji >/dev/null 2>&1; then
    rofimoji --selector rofi >/dev/null 2>&1 || true
    return 0
  fi

  if [[ -r /usr/share/unicode/emoji/emoji-test.txt ]]; then
    selection="$(
      awk '
        /; fully-qualified/ {
          line = $0
          sub(/^.*# /, "", line)
          print line
        }
      ' /usr/share/unicode/emoji/emoji-test.txt |
        menu "Emoji"
    )" || return 0

    [[ -n "$selection" ]] || return 0

    printf '%s' "${selection%% *}" | wl-copy
    return 0
  fi

  notify_error "Emoji picker is not installed yet"
}

web_search() {
  local query

  query="$(
    input_value \
      "Web Search" \
      "Search with the system default browser"
  )" || return 0

  [[ -n "$query" ]] || return 0

  run_backend search "$query" || true
}

main_menu() {
  local choice
  local theme_mode
  local wifi
  local bluetooth
  local mouseless

  while true; do
    theme_mode="$($LAUNCHER_CLI theme mode 2>/dev/null || printf '?')"
    wifi="$($LAUNCHER_CLI network status 2>/dev/null || printf '?')"
    bluetooth="$($LAUNCHER_CLI bluetooth status 2>/dev/null || printf '?')"
    mouseless="$($LAUNCHER_CLI mouseless status 2>/dev/null || printf '?')"

    choice="$(
      choose \
        "Hyprdots Launcher" \
        "󰀻  Applications" \
        "󰖲  Windows" \
        "󰘳  Commands" \
        "󰅌  Clipboard" \
        "󰆍  Terminal" \
        "󰉋  Files" \
        "󰨇  System Monitor" \
        "󰎆  Music" \
        "󰒓  Control Center" \
        "󰔎  Theme                         $theme_mode" \
        "󰸉  Wallpaper" \
        "󰖩  Network                       $wifi" \
        "󰂯  Bluetooth                     $bluetooth" \
        "󰍽  Mouseless                     $mouseless" \
        "󰹑  Screenshot" \
        "󰐥  Power" \
        "󰪚  Calculator" \
        "󰞅  Emoji" \
        "󰍉  Web Search" \
        "󰅖  Close"
    )" || exit 0

    case "$choice" in
    "󰀻  Applications")
      show_rofi_mode drun "Applications" || true
      exit 0
      ;;
    "󰖲  Windows")
      show_rofi_mode window "Windows" || true
      exit 0
      ;;
    "󰘳  Commands")
      show_rofi_mode run "Commands" || true
      exit 0
      ;;
    "󰅌  Clipboard")
      "$ROFI_CLIPBOARD" || true
      exit 0
      ;;
    "󰆍  Terminal")
      run_backend terminal || true
      exit 0
      ;;
    "󰉋  Files")
      run_backend files || true
      exit 0
      ;;
    "󰨇  System Monitor")
      run_backend monitor || true
      exit 0
      ;;
    "󰎆  Music")
      run_backend music || true
      exit 0
      ;;
    "󰒓  Control Center")
      "$CONTROL_CENTER_FRONTEND" || true
      exit 0
      ;;
    "󰔎  Theme"*)
      "$THEME_FRONTEND" || true
      exit 0
      ;;
    "󰸉  Wallpaper")
      "$WALLPAPER_FRONTEND" || true
      exit 0
      ;;
    "󰖩  Network"*)
      "$NETWORK_FRONTEND" || true
      exit 0
      ;;
    "󰂯  Bluetooth"*)
      "$BLUETOOTH_FRONTEND" || true
      exit 0
      ;;
    "󰍽  Mouseless"*)
      mouseless_menu
      ;;
    "󰹑  Screenshot")
      screenshot_menu
      exit 0
      ;;
    "󰐥  Power")
      power_menu
      exit 0
      ;;
    "󰪚  Calculator")
      calculator
      ;;
    "󰞅  Emoji")
      emoji_picker
      exit 0
      ;;
    "󰍉  Web Search")
      web_search
      exit 0
      ;;
    "󰅖  Close" | "")
      exit 0
      ;;
    esac
  done
}

main() {
  case "${1:-main}" in
  main)
    main_menu
    ;;
  screenshot)
    screenshot_menu
    ;;
  power)
    power_menu
    ;;
  mouseless)
    mouseless_menu
    ;;
  *)
    printf 'Unknown launcher frontend: %s
' "$1" >&2
    return 2
    ;;
  esac
}

main "$@"
