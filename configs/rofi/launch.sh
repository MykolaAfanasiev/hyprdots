#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec rofi \
    -config "$ROFI_DIR/config.rasi" \
    -show drun
