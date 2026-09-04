#!/usr/bin/env bash

set -u

WALLPAPER_DIR="${HYPRDOTS_WALLPAPER_DIR:-$HOME/.wallpapers}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/wallpaper"
CURRENT_FILE="$CACHE_DIR/current"
CURRENT_LINK="$CACHE_DIR/current-wallpaper"

mkdir -p "$CACHE_DIR"

notify_ok() {
  hyprctl notify 5 2000 "rgb(a6e3a1)" "$1" \
    >/dev/null 2>&1
}

notify_error() {
  hyprctl notify 3 3000 "rgb(f38ba8)" "$1" \
    >/dev/null 2>&1
}

show_wallpapers() {
  local current=""

  if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify_error "Wallpaper directory not found"
    return 1
  fi

  if [[ -f "$CURRENT_FILE" ]]; then
    current="$(<"$CURRENT_FILE")"
  fi

  printf '\0prompt\x1fWallpaper\n'
  printf '\0no-custom\x1ftrue\n'

  while IFS= read -r -d '' wallpaper; do
    local name

    name="$(basename "$wallpaper")"
    name="${name%.*}"

    if [[ "$wallpaper" == "$current" ]]; then
      printf '%s\0icon\x1f%s\x1finfo\x1f%s\x1factive\x1ftrue\n' \
        "$name" \
        "$wallpaper" \
        "$wallpaper"
    else
      printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' \
        "$name" \
        "$wallpaper" \
        "$wallpaper"
    fi
  done < <(
    find "$WALLPAPER_DIR" \
      -type f \
      \( \
      -iname '*.png' \
      -o -iname '*.jpg' \
      -o -iname '*.jpeg' \
      -o -iname '*.webp' \
      \) \
      -print0 |
      sort -z
  )
}

set_wallpaper() {
  local wallpaper="${ROFI_INFO:-}"

  if [[ -z "$wallpaper" || ! -f "$wallpaper" ]]; then
    notify_error "Wallpaper not found"
    return 1
  fi

  if hyprctl hyprpaper wallpaper \
    ", $wallpaper, cover" >/dev/null 2>&1; then
    printf '%s\n' "$wallpaper" >"$CURRENT_FILE"
    ln -sfn "$wallpaper" "$CURRENT_LINK"

    notify_ok "Wallpaper: $(basename "$wallpaper")"
    return 0
  fi

  notify_error "Failed to set wallpaper"
  return 1
}

case "${ROFI_RETV:-0}" in
0)
  show_wallpapers
  ;;

1)
  set_wallpaper
  ;;

*)
  exit 0
  ;;
esac
