#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

selection="$(
    cliphist list |
        rofi \
            -dmenu \
            -display-columns 2 \
            -config "$ROFI_DIR/config.rasi" \
            -theme "$ROFI_DIR/rofi/theme.rasi"
)"

[[ -z "$selection" ]] && exit 0

printf '%s\n' "$selection" |
    cliphist decode |
    wl-copy
