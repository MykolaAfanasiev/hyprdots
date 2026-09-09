#!/usr/bin/env bash

set -euo pipefail

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

ROFI_THEME="$ROFI_DIR/theme.rasi"

if generated_theme="$("$ROFI_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -r "$generated_theme" ]]; then
  ROFI_THEME="$generated_theme"
fi

exec rofi \
  -config "$ROFI_DIR/config.rasi" \
  -theme "$ROFI_THEME" \
  -show combi
