#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_CLI="$SCRIPT_DIR/wallpaper.sh"

notify_ok() {
  hyprctl notify 5 2000 "rgb(a6e3a1)" "$1" >/dev/null 2>&1 || true
}

notify_error() {
  hyprctl notify 3 3000 "rgb(f38ba8)" "$1" >/dev/null 2>&1 || true
}

show_wallpapers() {
  local current=""
  local wallpaper
  local name

  current="$("$WALLPAPER_CLI" current 2>/dev/null || true)"

  printf '\0prompt\x1fWallpaper\n'
  printf '\0no-custom\x1ftrue\n'

  while IFS= read -r wallpaper; do
    [[ -n "$wallpaper" ]] || continue

    name="$(basename "$wallpaper")"
    name="${name%.*}"

    if [[ "$wallpaper" == "$current" ]]; then
      printf '%s\0icon\x1f%s\x1finfo\x1f%s\x1factive\x1ftrue\n' \
        "$name" "$wallpaper" "$wallpaper"
    else
      printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' \
        "$name" "$wallpaper" "$wallpaper"
    fi
  done < <("$WALLPAPER_CLI" list)
}

select_wallpaper() {
  local wallpaper="${ROFI_INFO:-}"

  if [[ -z "$wallpaper" ]]; then
    notify_error "Wallpaper not found"
    return 1
  fi

  if "$WALLPAPER_CLI" set "$wallpaper" >/dev/null; then
    notify_ok "Wallpaper: $(basename "$wallpaper")"
  else
    notify_error "Failed to set wallpaper"
    return 1
  fi
}

case "${ROFI_RETV:-0}" in
0) show_wallpapers ;;
1) select_wallpaper ;;
*) exit 0 ;;
esac
