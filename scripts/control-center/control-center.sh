#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
THEME_SETTINGS_CLI="$PROJECT_ROOT/scripts/theme-switcher/settings.sh"
MOUSELESS_CLI="$PROJECT_ROOT/scripts/mouseless/mouseless.sh"
NETWORK_CLI="$PROJECT_ROOT/scripts/networkmanager/network.sh"
BLUETOOTH_CLI="$PROJECT_ROOT/scripts/bluetooth/bluetooth.sh"
WALLPAPER_CLI="$PROJECT_ROOT/scripts/wallpaper-switcher/wallpaper.sh"

WAYBAR_LAUNCH="$PROJECT_ROOT/configs/waybar/launch.sh"
WAYBAR_CLOCK="$PROJECT_ROOT/configs/waybar/scripts/clock.sh"
SWAYNC_CONTROL="$PROJECT_ROOT/configs/swaync/scripts/control.sh"
HYPRPAPER_CONTROL="$PROJECT_ROOT/configs/hyprpaper/scripts/control.sh"

usage() {
  cat <<'EOF_USAGE'
Usage:
  control-center.sh status

  control-center.sh theme <theme.sh arguments...>
  control-center.sh theme-settings <settings.sh arguments...>
  control-center.sh mouseless <mouseless.sh arguments...>

  control-center.sh network <status|on|off|toggle>
  control-center.sh bluetooth <status|on|off|toggle>
  control-center.sh waybar <status|restart|clock-toggle>
  control-center.sh notifications <toggle|dnd|reload>
  control-center.sh hyprpaper restart
  control-center.sh hyprland <reload|errors>

  control-center.sh wallpaper current
  control-center.sh wallpaper set <file>

  control-center.sh config list
  control-center.sh config path <name>

  control-center.sh reload
  control-center.sh help
EOF_USAGE
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    return 127
  fi
}

waybar_status() {
  if pgrep -x waybar >/dev/null 2>&1; then
    printf 'running\n'
  else
    printf 'stopped\n'
  fi
}

waybar_restart() {
  pkill -x waybar >/dev/null 2>&1 || true
  sleep 0.2

  "$WAYBAR_LAUNCH" >/dev/null 2>&1 &
}

config_list() {
  cat <<'EOF_CONFIGS'
hyprland	Hyprland
appearance	Appearance / theme settings
waybar	Waybar
rofi	Rofi
ghostty	Ghostty
mouseless	Mouseless
swaync	SwayNC
hypridle	Hypridle
hyprlock	Hyprlock
hyprpaper	Hyprpaper
zellij	Zellij
tmux	tmux
nvim	Neovim
yazi	Yazi
zsh	Zsh
rmpc	RMPC
mpd	MPD
EOF_CONFIGS
}

config_path() {
  case "$1" in
  hyprland)
    printf '%s\n' "$PROJECT_ROOT/configs/hypr/hyprland.lua"
    ;;
  appearance)
    printf '%s\n' "$PROJECT_ROOT/configs/theme/settings.conf"
    ;;
  waybar)
    printf '%s\n' "$PROJECT_ROOT/configs/waybar/config.jsonc"
    ;;
  rofi)
    printf '%s\n' "$PROJECT_ROOT/configs/rofi/config.rasi"
    ;;
  ghostty)
    printf '%s\n' "$PROJECT_ROOT/configs/ghostty/config.ghostty"
    ;;
  mouseless)
    printf '%s\n' "$PROJECT_ROOT/configs/mouseless/config.yaml"
    ;;
  swaync)
    printf '%s\n' "$PROJECT_ROOT/configs/swaync/config.json"
    ;;
  hypridle)
    printf '%s\n' "$PROJECT_ROOT/configs/hypridle/hypridle.conf"
    ;;
  hyprlock)
    printf '%s\n' "$PROJECT_ROOT/configs/hyprlock/hyprlock.conf"
    ;;
  hyprpaper)
    printf '%s\n' "$PROJECT_ROOT/configs/hyprpaper/hyprpaper.conf"
    ;;
  zellij)
    printf '%s\n' "$PROJECT_ROOT/configs/zellij/config.kdl"
    ;;
  tmux)
    printf '%s\n' "$PROJECT_ROOT/configs/tmux/tmux.conf"
    ;;
  nvim)
    printf '%s\n' "$PROJECT_ROOT/configs/nvim/init.lua"
    ;;
  yazi)
    printf '%s\n' "$PROJECT_ROOT/configs/yazi/yazi.toml"
    ;;
  zsh)
    printf '%s\n' "$PROJECT_ROOT/configs/zsh/.zshrc"
    ;;
  rmpc)
    printf '%s\n' "$PROJECT_ROOT/configs/rmpc/config.ron"
    ;;
  mpd)
    printf '%s\n' "$PROJECT_ROOT/configs/mpd/mpd.conf"
    ;;
  *)
    printf 'Unknown configuration: %s\n' "$1" >&2
    return 1
    ;;
  esac
}

show_status() {
  local theme_mode
  local current_theme
  local wifi="unavailable"
  local bluetooth="unavailable"
  local mouseless="unavailable"
  local mouseless_autostart="unavailable"
  local waybar

  theme_mode="$($THEME_CLI mode)"
  current_theme="$($THEME_CLI current)"

  if command -v nmcli >/dev/null 2>&1; then
    wifi="$("$NETWORK_CLI" status)"
  fi

  if command -v bluetoothctl >/dev/null 2>&1; then
    bluetooth="$("$BLUETOOTH_CLI" status)"
  fi

  if command -v systemctl >/dev/null 2>&1; then
    mouseless="$($MOUSELESS_CLI status)"
    mouseless_autostart="$($MOUSELESS_CLI enabled)"
  fi

  waybar="$(waybar_status)"

  printf 'theme_mode=%s\n' "$theme_mode"
  printf 'theme=%s\n' "$current_theme"
  printf 'wifi=%s\n' "$wifi"
  printf 'bluetooth=%s\n' "$bluetooth"
  printf 'mouseless=%s\n' "$mouseless"
  printf 'mouseless_autostart=%s\n' "$mouseless_autostart"
  printf 'waybar=%s\n' "$waybar"
}

main() {
  local command_name="${1:-}"
  local action="${2:-}"

  case "$command_name" in
  status)
    [[ $# -eq 1 ]] || {
      usage >&2
      return 2
    }
    show_status
    ;;

  theme)
    shift
    exec "$THEME_CLI" "$@"
    ;;

  theme-settings)
    shift
    exec "$THEME_SETTINGS_CLI" "$@"
    ;;

  mouseless)
    shift
    exec "$MOUSELESS_CLI" "$@"
    ;;

  network)
    shift
    exec "$NETWORK_CLI" "$@"
    ;;

  bluetooth)
    shift
    exec "$BLUETOOTH_CLI" "$@"
    ;;

  waybar)
    case "$action" in
    status)
      waybar_status
      ;;
    restart)
      waybar_restart
      ;;
    clock-toggle)
      "$WAYBAR_CLOCK" toggle
      ;;
    *)
      usage >&2
      return 2
      ;;
    esac
    ;;

  notifications)
    case "$action" in
    toggle | dnd | reload)
      "$SWAYNC_CONTROL" "$action"
      ;;
    *)
      usage >&2
      return 2
      ;;
    esac
    ;;

  hyprpaper)
    [[ "$action" == "restart" ]] || {
      usage >&2
      return 2
    }
    "$HYPRPAPER_CONTROL" restart
    ;;

  hyprland)
    require_command hyprctl

    case "$action" in
    reload)
      hyprctl reload
      ;;
    errors)
      hyprctl configerrors
      ;;
    *)
      usage >&2
      return 2
      ;;
    esac
    ;;

  wallpaper)
    shift
    exec "$WALLPAPER_CLI" "$@"
    ;;

  config)
    case "$action" in
    list)
      config_list
      ;;
    path)
      [[ $# -eq 3 ]] || {
        usage >&2
        return 2
      }
      config_path "$3"
      ;;
    *)
      usage >&2
      return 2
      ;;
    esac
    ;;

  reload)
    "$THEME_CLI" reload
    ;;

  help | -h | --help)
    usage
    ;;

  "")
    usage >&2
    return 2
    ;;

  *)
    printf 'Unknown command: %s\n\n' "$command_name" >&2
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
