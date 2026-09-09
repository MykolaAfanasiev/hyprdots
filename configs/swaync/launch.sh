#!/usr/bin/env bash

set -euo pipefail

SWAYNC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

SWAYNC_STYLE="$SWAYNC_DIR/style.css"

if generated_style="$("$SWAYNC_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -r "$generated_style" ]]; then
  SWAYNC_STYLE="$generated_style"
fi

exec swaync \
  -c "$SWAYNC_DIR/config.json" \
  -s "$SWAYNC_STYLE"
