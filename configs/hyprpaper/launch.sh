#!/usr/bin/env bash

set -euo pipefail

HYPRPAPER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_DIR="${HYPRDOTS_WALLPAPER_DIR:-$HOME/.wallpapers}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/wallpaper"
CURRENT_FILE="$CACHE_DIR/current"
CURRENT_LINK="$CACHE_DIR/current-wallpaper"

mkdir -p "$CACHE_DIR"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Wallpaper directory not found: $WALLPAPER_DIR" >&2
    exit 1
fi

hyprpaper --config "$HYPRPAPER_DIR/hyprpaper.conf" &
hyprpaper_pid=$!

cleanup() {
    kill "$hyprpaper_pid" 2> /dev/null || true
}

trap cleanup EXIT INT TERM

ready=false
for _ in {1..50}; do
    if hyprctl hyprpaper listactive > /dev/null 2>&1; then
        ready=true
        break
    fi

    if ! kill -0 "$hyprpaper_pid" 2> /dev/null; then
        wait "$hyprpaper_pid"
        exit $?
    fi

    sleep 0.1
done

if [[ "$ready" != true ]]; then
    echo "Hyprpaper IPC is not available" >&2
    exit 1
fi

wallpaper=""
IFS= read -r -d '' wallpaper < <(
    find "$WALLPAPER_DIR" \
        -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
        -print0 |
        shuf -z -n 1
) || true

if [[ -z "$wallpaper" ]]; then
    echo "No supported wallpapers found in: $WALLPAPER_DIR" >&2
    exit 1
fi

if hyprctl hyprpaper wallpaper ", $wallpaper, cover" > /dev/null 2>&1; then
    printf '%s\n' "$wallpaper" > "$CURRENT_FILE"
    ln -sfn "$wallpaper" "$CURRENT_LINK"
else
    echo "Failed to set wallpaper: $wallpaper" >&2
    exit 1
fi

wait "$hyprpaper_pid"
