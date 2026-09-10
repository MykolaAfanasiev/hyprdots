#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

WALLPAPER_DIR="${HYPRDOTS_WALLPAPER_DIR:-$HOME/.wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/wallpaper"
CURRENT_FILE="$CACHE_DIR/current"
CURRENT_LINK="$CACHE_DIR/current-wallpaper"

current() {
  if [[ -L "$CURRENT_LINK" ]]; then
    readlink -f -- "$CURRENT_LINK"
    return 0
  fi

  if [[ -r "$CURRENT_FILE" ]]; then
    cat -- "$CURRENT_FILE"
    return 0
  fi

  return 1
}

list_wallpapers() {
  [[ -d "$WALLPAPER_DIR" ]] || {
    printf 'Wallpaper directory not found: %s\n' "$WALLPAPER_DIR" >&2
    return 1
  }

  find "$WALLPAPER_DIR" \
    -type f \
    \( \
    -iname '*.png' \
    -o -iname '*.jpg' \
    -o -iname '*.jpeg' \
    -o -iname '*.webp' \
    \) \
    -print0 |
    sort -z |
    tr '\0' '\n'
}

set_wallpaper() {
  local wallpaper="$1"

  command -v hyprctl >/dev/null 2>&1 || {
    printf 'Required command is not installed: hyprctl\n' >&2
    return 127
  }

  [[ -f "$wallpaper" ]] || {
    printf 'Wallpaper not found: %s\n' "$wallpaper" >&2
    return 1
  }

  wallpaper="$(readlink -f -- "$wallpaper")"

  hyprctl hyprpaper wallpaper ", $wallpaper, cover" >/dev/null

  mkdir -p -- "$CACHE_DIR"
  printf '%s\n' "$wallpaper" >"$CURRENT_FILE"
  ln -sfn -- "$wallpaper" "$CURRENT_LINK"

  if [[ -x "$THEME_CLI" ]]; then
    "$THEME_CLI" wallpaper
  fi

  printf '%s\n' "$wallpaper"
}

usage() {
  cat <<'EOF_USAGE'
Usage:
  wallpaper.sh current
  wallpaper.sh list
  wallpaper.sh set <file>
  wallpaper.sh dir
EOF_USAGE
}

main() {
  case "${1:-}" in
  current)
    current
    ;;
  list)
    list_wallpapers
    ;;
  set)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    set_wallpaper "$2"
    ;;
  dir)
    printf '%s\n' "$WALLPAPER_DIR"
    ;;
  help | -h | --help)
    usage
    ;;
  *)
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
