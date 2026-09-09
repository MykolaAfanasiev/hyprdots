#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROFI_THEME="$("$ROFI_DIR/prepare-theme.sh")"

selection="$(
  cliphist list |
    rofi \
      -dmenu \
      -display-columns 2 \
      -config "$ROFI_DIR/config.rasi" \
      -theme "$ROFI_THEME"
)"

[[ -z "$selection" ]] && exit 0

printf '%s\n' "$selection" |
  cliphist decode |
  wl-copy
