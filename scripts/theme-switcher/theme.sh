#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/render.sh
source "$SCRIPT_DIR/lib/render.sh"
# shellcheck source=lib/reload.sh
source "$SCRIPT_DIR/lib/reload.sh"

usage() {
  cat <<'EOF_USAGE'
Usage:
  theme.sh list
  theme.sh current
  theme.sh set <theme> [--reload]
  theme.sh apply [--reload]
  theme.sh reload [component]
  theme.sh path [component]
  theme.sh palette [theme]

Stage 2 only prepares runtime theme files. Existing application configs are not
modified or connected automatically.
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

set_theme() {
  local theme_name="$1"
  local should_reload="$2"

  render_theme "$theme_name"
  save_current_theme "$theme_name"

  if [[ "$should_reload" == "true" ]]; then
    reload_all_components
  fi

  printf '%s\n' "$theme_name"
}

apply_theme() {
  local should_reload="$1"
  local theme_name

  theme_name="$(theme_current)"
  render_theme "$theme_name"

  if [[ "$should_reload" == "true" ]]; then
    reload_all_components
  fi

  printf '%s\n' "$theme_name"
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
  waybar | swaync | wlogout)
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
  local theme_name="${1:-$(theme_current)}"
  local variable_name

  theme_load "$theme_name"

  printf 'theme=%s\n' "$THEME_NAME"
  printf 'display_name=%s\n' "$THEME_DISPLAY_NAME"

  for variable_name in "${THEME_COLOR_VARIABLES[@]}"; do
    printf '%s=%s\n' "$variable_name" "${!variable_name}"
  done
}

main() {
  local command_name="${1:-}"
  local theme_name
  local should_reload=false

  case "$command_name" in
  list)
    [[ $# -eq 1 ]] || theme_die "list takes no arguments"
    theme_list
    ;;

  current)
    [[ $# -eq 1 ]] || theme_die "current takes no arguments"
    theme_current
    ;;

  set)
    [[ $# -ge 2 && $# -le 3 ]] || theme_die "usage: theme.sh set <theme> [--reload]"
    theme_name="$2"

    if [[ ${3:-} == "--reload" ]]; then
      should_reload=true
    elif [[ $# -eq 3 ]]; then
      theme_die "unknown option: $3"
    fi

    set_theme "$theme_name" "$should_reload"
    ;;

  apply)
    [[ $# -le 2 ]] || theme_die "usage: theme.sh apply [--reload]"

    if [[ ${2:-} == "--reload" ]]; then
      should_reload=true
    elif [[ $# -eq 2 ]]; then
      theme_die "unknown option: $2"
    fi

    apply_theme "$should_reload"
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
