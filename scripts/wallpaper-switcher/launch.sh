#!/usr/bin/env bash

SWITCHER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SWITCHER_DIR/../.." && pwd)"

ROFI_DIR="$PROJECT_ROOT/configs/rofi"

exec rofi \
    -show wallpaper \
    -modes "wallpaper:$SWITCHER_DIR/wallpaper.sh" \
    -config "$ROFI_DIR/config.rasi" \
    -theme "$ROFI_DIR/themes/wallpaper.rasi" \
    -show-icons \
    -kb-row-left "Control+Page_Up,Alt+h" \
    -kb-row-right "Control+Page_Down,Alt+l" \
