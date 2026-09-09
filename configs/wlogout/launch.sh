#!/usr/bin/env bash

set -euo pipefail

# Toggle an already running wlogout instance.
if pgrep -x wlogout >/dev/null 2>&1; then
  pkill -x wlogout
  exit 0
fi

WLOGOUT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$WLOGOUT_DIR/scripts:$PATH"

WLOGOUT_STYLE="$WLOGOUT_DIR/style.css"

if generated_style="$("$WLOGOUT_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -r "$generated_style" ]]; then
  WLOGOUT_STYLE="$generated_style"
fi

exec wlogout \
  --layout "$WLOGOUT_DIR/layout" \
  --css "$WLOGOUT_STYLE" \
  --buttons-per-row 3 \
  --column-spacing 16 \
  --row-spacing 16
