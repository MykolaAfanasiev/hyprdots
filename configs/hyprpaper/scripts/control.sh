#!/usr/bin/env bash

HYPRPAPER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
    restart)
        pkill -x hyprpaper
        sleep 0.2

        "$HYPRPAPER_DIR/launch.sh" &

        hyprctl notify 5 2000 "rgb(a6e3a1)" "Hyprpaper restarted" >/dev/null 2>&1
        ;;

    *)
        echo "Usage: $0 {restart}" >&2
        exit 1
        ;;
esac
