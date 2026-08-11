#!/usr/bin/env bash

case "${1:-}" in
    toggle)
        swaync-client -t
        ;;

    dnd)
        swaync-client -d
        ;;

    reload)
        swaync-client -R
        swaync-client -rs
        ;;

    *)
        echo "Usage: $0 {toggle|dnd|reload}" >&2
        exit 1
        ;;
esac
