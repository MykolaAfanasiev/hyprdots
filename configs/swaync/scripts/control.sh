#!/usr/bin/env bash

notify() {
    hyprctl notify 5 2500 "rgb(cba6f7)" "$1" > /dev/null 2>&1
}

case "${1:-}" in
    toggle)
        swaync-client -t
        ;;

    dnd)
        state="$(swaync-client -d)"

        if [[ "$state" == "true" ]]; then
            notify "Do Not Disturb: ON"
        else
            notify "Do Not Disturb: OFF"
        fi
        ;;

    reload)
        if swaync-client -R && swaync-client -rs; then
            notify "SwayNC reloaded"
        else
            hyprctl notify 3 3500 "rgb(f38ba8)" "SwayNC reload failed" > /dev/null 2>&1
            exit 1
        fi
        ;;

    *)
        echo "Usage: $0 {toggle|dnd|reload}" >&2
        exit 1
        ;;
esac
