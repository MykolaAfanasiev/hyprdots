#!/usr/bin/env bash

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/waybar-clock-expanded"

toggle() {
    if [[ -f "$STATE_FILE" ]]; then
        rm -f "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
}

render() {
    if [[ -f "$STATE_FILE" ]]; then
        LC_TIME=C date '+%A, %B %-d, %Y %H:%M:%S'
    else
        date '+%H:%M'
    fi
}

case "${1:-watch}" in
    toggle)
        toggle
        ;;

    watch)
        while true; do
            render
            sleep 1
        done
        ;;

    *)
        echo "Usage: $0 {watch|toggle}" >&2
        exit 1
        ;;
esac
