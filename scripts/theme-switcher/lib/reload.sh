#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_THEME_RELOAD_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_THEME_RELOAD_LOADED=1

THEME_RELOAD_LIB_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"
THEME_RELOAD_PROJECT_ROOT="$(
  cd -- "$THEME_RELOAD_LIB_DIR/../../.." &&
    pwd
)"

theme_process_running() {
  pgrep -x "$1" >/dev/null 2>&1
}

theme_run_hook() {
  local hook="$1"
  shift

  if [[ -x "$hook" ]]; then
    "$hook" "$@" >/dev/null 2>&1 || true
  fi
}

reload_starship() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/starship/prepare-theme.zsh"
}

reload_zellij() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/zellij/prepare-theme.sh"
}

reload_waybar() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/waybar/prepare-theme.sh"

  if theme_process_running waybar; then
    pkill -SIGUSR2 -x waybar >/dev/null 2>&1 || true
  fi
}

reload_swaync() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/swaync/prepare-theme.sh"

  if ! theme_process_running swaync; then
    return 0
  fi

  local control="$THEME_RELOAD_PROJECT_ROOT/configs/swaync/scripts/control.sh"

  if [[ -x "$control" ]]; then
    "$control" reload >/dev/null 2>&1 || true
  elif command -v swaync-client >/dev/null 2>&1; then
    swaync-client -R >/dev/null 2>&1 || true
    swaync-client -rs >/dev/null 2>&1 || true
  fi
}

reload_tmux() {
  local tmux_config="$THEME_RELOAD_PROJECT_ROOT/configs/tmux/tmux.conf"

  command -v tmux >/dev/null 2>&1 || return 0

  if tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$tmux_config" >/dev/null 2>&1 || true
  fi
}

reload_ghostty() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/ghostty/prepare-theme.sh"

  if ! theme_process_running ghostty; then
    return 0
  fi

  if command -v systemctl >/dev/null 2>&1 &&
    systemctl --user is-active --quiet \
      app-com.mitchellh.ghostty.service 2>/dev/null; then

    systemctl --user reload \
      app-com.mitchellh.ghostty.service >/dev/null 2>&1 || true
  else
    pkill -SIGUSR2 -x ghostty >/dev/null 2>&1 || true
  fi
}

reload_nvim() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/nvim/reload-theme.sh"
}

reload_btop() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/btop/reload-theme.sh"
}

reload_yazi() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/yazi/reload-theme.sh"
}

reload_obsidian() {
  theme_run_hook \
    "$THEME_RELOAD_PROJECT_ROOT/configs/obsidian/apply-theme.sh"
}

reload_hyprland() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
}

reload_component() {
  local component="$1"

  case "$component" in
  starship)
    reload_starship
    ;;
  zellij)
    reload_zellij
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
  ghostty)
    reload_ghostty
    ;;
  nvim)
    reload_nvim
    ;;
  btop)
    reload_btop
    ;;
  yazi)
    reload_yazi
    ;;
  obsidian)
    reload_obsidian
    ;;
  hyprland)
    reload_hyprland
    ;;

  # Transient applications or applications that consume the generated theme
  # on their next launch.
  hyprlock | rofi | networkmanager | bluetooth | wlogout | rmpc)
    ;;

  *)
    printf 'theme: unknown reload component: %s\n' "$component" >&2
    return 1
    ;;
  esac
}

reload_all_components() {
  # Prepare and reload applications first. Hyprland is intentionally last.
  reload_starship
  reload_zellij
  reload_waybar
  reload_swaync
  reload_tmux
  reload_ghostty

  # Terminal applications.
  reload_nvim
  reload_btop
  reload_yazi

  reload_obsidian

  # Hyprland is intentionally reloaded last.
  reload_hyprland
}
