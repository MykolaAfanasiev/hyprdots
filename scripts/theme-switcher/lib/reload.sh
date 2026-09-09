#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_THEME_RELOAD_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_THEME_RELOAD_LOADED=1

# Reload hooks are deliberately best-effort. A program that is not running is
# not an error, and apps without a reliable hot reload simply use the new theme
# on their next launch.

theme_process_running() {
  pgrep -x "$1" >/dev/null 2>&1
}

reload_hyprland() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
}

reload_waybar() {
  if theme_process_running waybar; then
    pkill -SIGUSR2 -x waybar >/dev/null 2>&1 || true
  fi
}

reload_swaync() {
  if command -v swaync-client >/dev/null 2>&1 && theme_process_running swaync; then
    swaync-client --reload-css >/dev/null 2>&1 || true
    swaync-client --reload-config >/dev/null 2>&1 || true
  fi
}

reload_tmux() {
  local tmux_config="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

  if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$tmux_config" >/dev/null 2>&1 || true
  fi
}

reload_component() {
  local component="$1"

  case "$component" in
  hyprland)
    reload_hyprland
    ;;
  waybar)
    reload_waybar
    ;;
  swaync)
    reload_swaync
    ;;
  tmux)
    reload_tmux
    ;;
  ghostty | hyprlock | rofi | networkmanager | bluetooth | wlogout | starship | btop | rmpc | zellij | yazi | nvim)
    # These currently pick up the generated theme on the next launch or will
    # receive dedicated hot-reload integration in Stage 3.
    ;;
  *)
    printf 'theme: unknown reload component: %s\n' "$component" >&2
    return 1
    ;;
  esac
}

reload_all_components() {
  local component

  for component in \
    hyprland \
    waybar \
    swaync \
    tmux \
    ghostty \
    hyprlock \
    rofi \
    networkmanager \
    bluetooth \
    wlogout \
    starship \
    btop \
    rmpc \
    zellij \
    yazi \
    nvim; do
    reload_component "$component"
  done
}
