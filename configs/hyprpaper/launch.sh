#!/usr/bin/env bash

HYPRPAPER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

hyprpaper --config "$HYPRPAPER_DIR/hyprpaper.conf" &

sleep 0.5

wallpaper="$(
    find "$WALLPAPER_DIR" \
        -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) |
        shuf -n 1
)"

[[ -n "$wallpaper" ]] &&
    hyprctl hyprpaper wallpaper ", $wallpaper, cover"

wait
