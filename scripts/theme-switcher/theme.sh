#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"

# shellcheck source=lib/common.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/render.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/render.sh"
# shellcheck source=lib/reload.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/reload.sh"

THEME_MODE_FILE="$THEME_STATE_ROOT/mode"
THEME_DYNAMIC_NAME="dynamic"
THEME_DEFAULT_STATIC="catppuccin-mocha"

usage() {
  cat <<'EOF_USAGE'
Usage:
  theme.sh list
  theme.sh current
  theme.sh mode
  theme.sh mode fixed [--no-reload]
  theme.sh mode dynamic [--no-reload]
  theme.sh set <theme> [--no-reload]
  theme.sh apply [--no-reload]
  theme.sh wallpaper
  theme.sh reload [component]
  theme.sh path [component]
  theme.sh palette [theme]
EOF_USAGE
}

save_current_theme() {
  local theme_name="$1"
  local temporary

  theme_prepare_runtime
  temporary="$(mktemp "$THEME_STATE_ROOT/.current.XXXXXX")"

  printf '%s\n' "$theme_name" >"$temporary"
  mv -f -- "$temporary" "$THEME_CURRENT_FILE"
}

save_theme_mode() {
  local mode="$1"
  local temporary

  theme_prepare_runtime
  temporary="$(mktemp "$THEME_STATE_ROOT/.mode.XXXXXX")"

  printf '%s\n' "$mode" >"$temporary"
  mv -f -- "$temporary" "$THEME_MODE_FILE"
}

theme_mode() {
  local mode

  if [[ ! -r "$THEME_MODE_FILE" ]]; then
    printf 'fixed\n'
    return 0
  fi

  mode="$(<"$THEME_MODE_FILE")"

  case "$mode" in
  fixed | dynamic)
    printf '%s\n' "$mode"
    ;;
  *)
    printf 'fixed\n'
    ;;
  esac
}

static_theme_list() {
  local theme_name

  while IFS= read -r theme_name; do
    [[ -n "$theme_name" ]] || continue
    [[ "$theme_name" == "$THEME_DYNAMIC_NAME" ]] && continue

    printf '%s\n' "$theme_name"
  done < <(theme_list)
}

static_theme_exists() {
  local requested="$1"
  local theme_name

  while IFS= read -r theme_name; do
    if [[ "$theme_name" == "$requested" ]]; then
      return 0
    fi
  done < <(static_theme_list)

  return 1
}

ensure_theme_state() {
  local legacy_current

  theme_prepare_runtime

  if [[ -r "$THEME_MODE_FILE" ]]; then
    return 0
  fi

  legacy_current="$(theme_current 2>/dev/null || true)"

  # Migration from the temporary implementation where "dynamic"
  # was stored as if it were a normal theme.
  if [[ "$legacy_current" == "$THEME_DYNAMIC_NAME" ]]; then
    save_current_theme "$THEME_DEFAULT_STATIC"
    save_theme_mode dynamic
    return 0
  fi

  if [[ -z "$legacy_current" ]]; then
    save_current_theme "$THEME_DEFAULT_STATIC"
  fi

  save_theme_mode fixed
}

active_theme_name() {
  case "$(theme_mode)" in
  dynamic)
    printf '%s\n' "$THEME_DYNAMIC_NAME"
    ;;
  fixed)
    theme_current
    ;;
  esac
}

set_fixed_theme() {
  local theme_name="$1"
  local should_reload="$2"

  if ! static_theme_exists "$theme_name"; then
    theme_die "unknown static theme: $theme_name"
  fi

  # Render first. State is changed only after a successful render.
  render_theme "$theme_name"

  save_current_theme "$theme_name"
  save_theme_mode fixed

  if [[ "$should_reload" == "true" ]]; then
    reload_all_components
  fi

  printf '%s\n' "$theme_name"
}

set_mode() {
  local mode="$1"
  local should_reload="$2"
  local theme_name

  case "$mode" in
  fixed)
    theme_name="$(theme_current)"

    if ! static_theme_exists "$theme_name"; then
      theme_name="$THEME_DEFAULT_STATIC"
    fi

    render_theme "$theme_name"
    save_current_theme "$theme_name"
    save_theme_mode fixed
    ;;

  dynamic)
    # dynamic.theme is an internal provider backed by Matugen.
    render_theme "$THEME_DYNAMIC_NAME"
    save_theme_mode dynamic
    theme_name="$THEME_DYNAMIC_NAME"
    ;;

  *)
    theme_die "unknown mode: $mode"
    ;;
  esac

  if [[ "$should_reload" == "true" ]]; then
    reload_all_components
  fi

  printf '%s\n' "$mode"
}

apply_theme() {
  local should_reload="$1"
  local theme_name

  theme_name="$(active_theme_name)"
  render_theme "$theme_name"

  if [[ "$should_reload" == "true" ]]; then
    reload_all_components
  fi

  printf '%s\n' "$theme_name"
}

wallpaper_changed() {
  case "$(theme_mode)" in
  fixed)
    # Wallpaper does not affect a fixed theme.
    return 0
    ;;

  dynamic)
    # Re-run Matugen against current-wallpaper and reload everything.
    apply_theme true >/dev/null
    ;;
  esac
}

show_current() {
  active_theme_name
}

show_path() {
  local component="${1:-}"

  if [[ -z "$component" ]]; then
    printf '%s\n' "$THEME_ACTIVE_LINK"
    return 0
  fi

  case "$component" in
  palette)
    printf '%s/palette.env\n' "$THEME_ACTIVE_LINK"
    ;;
  rofi | networkmanager | bluetooth)
    printf '%s/%s.rasi\n' "$THEME_ACTIVE_LINK" "$component"
    ;;
  waybar | swaync | wlogout | obsidian)
    printf '%s/%s.css\n' "$THEME_ACTIVE_LINK" "$component"
    ;;
  hyprlock | ghostty)
    printf '%s/%s.conf\n' "$THEME_ACTIVE_LINK" "$component"
    ;;
  hyprland | nvim)
    printf '%s/%s.lua\n' "$THEME_ACTIVE_LINK" "$component"
    ;;
  starship)
    printf '%s/starship.toml\n' "$THEME_ACTIVE_LINK"
    ;;
  btop)
    printf '%s/btop.theme\n' "$THEME_ACTIVE_LINK"
    ;;
  rmpc)
    printf '%s/rmpc.ron\n' "$THEME_ACTIVE_LINK"
    ;;
  tmux)
    printf '%s/tmux.conf\n' "$THEME_ACTIVE_LINK"
    ;;
  zellij)
    printf '%s/zellij.kdl\n' "$THEME_ACTIVE_LINK"
    ;;
  yazi)
    printf '%s/yazi.yazi\n' "$THEME_ACTIVE_LINK"
    ;;
  *)
    theme_die "no generated path for component: $component"
    ;;
  esac
}

show_palette() {
  local theme_name="${1:-$(active_theme_name)}"
  local variable_name

  theme_load "$theme_name"

  # THEME_NAME and THEME_DISPLAY_NAME are populated by theme_load.
  # shellcheck disable=SC2153
  printf 'theme=%s\n' "$THEME_NAME"
  printf 'display_name=%s\n' "$THEME_DISPLAY_NAME"

  for variable_name in "${THEME_COLOR_VARIABLES[@]}"; do
    printf '%s=%s\n' "$variable_name" "${!variable_name}"
  done
}

main() {
  local command_name="${1:-}"
  local theme_name
  local should_reload=true

  ensure_theme_state

  case "$command_name" in
  list)
    [[ $# -eq 1 ]] || theme_die "list takes no arguments"
    static_theme_list
    ;;

  current)
    [[ $# -eq 1 ]] || theme_die "current takes no arguments"
    show_current
    ;;

  mode)
    if [[ $# -eq 1 ]]; then
      theme_mode
      exit 0
    fi

    [[ $# -le 3 ]] ||
      theme_die "usage: theme.sh mode <fixed|dynamic> [--no-reload]"

    if [[ ${3:-} == "--no-reload" ]]; then
      should_reload=false
    elif [[ ${3:-} == "--reload" ]]; then
      should_reload=true
    elif [[ $# -eq 3 ]]; then
      theme_die "unknown option: $3"
    fi

    set_mode "$2" "$should_reload"
    ;;

  set)
    [[ $# -ge 2 && $# -le 3 ]] ||
      theme_die "usage: theme.sh set <theme> [--no-reload]"

    theme_name="$2"

    if [[ ${3:-} == "--no-reload" ]]; then
      should_reload=false
    elif [[ ${3:-} == "--reload" ]]; then
      should_reload=true
    elif [[ $# -eq 3 ]]; then
      theme_die "unknown option: $3"
    fi

    set_fixed_theme "$theme_name" "$should_reload"
    ;;

  apply)
    [[ $# -le 2 ]] ||
      theme_die "usage: theme.sh apply [--no-reload]"

    if [[ ${2:-} == "--no-reload" ]]; then
      should_reload=false
    elif [[ ${2:-} == "--reload" ]]; then
      should_reload=true
    elif [[ $# -eq 2 ]]; then
      theme_die "unknown option: $2"
    fi

    apply_theme "$should_reload"
    ;;

  wallpaper)
    [[ $# -eq 1 ]] || theme_die "wallpaper takes no arguments"
    wallpaper_changed
    ;;

  reload)
    [[ $# -le 2 ]] || theme_die "usage: theme.sh reload [component]"

    if [[ -n "${2:-}" ]]; then
      reload_component "$2"
    else
      reload_all_components
    fi
    ;;

  path)
    [[ $# -le 2 ]] || theme_die "usage: theme.sh path [component]"
    show_path "${2:-}"
    ;;

  palette)
    [[ $# -le 2 ]] || theme_die "usage: theme.sh palette [theme]"
    show_palette "${2:-}"
    ;;

  -h | --help | help)
    usage
    ;;

  "")
    usage >&2
    exit 2
    ;;

  *)
    theme_die "unknown command: $command_name"
    ;;
  esac
}

main "$@"
