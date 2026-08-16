#!/usr/bin/env bash

set -euo pipefail

WLOGOUT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$WLOGOUT_DIR/scripts:$PATH"

exec wlogout \
    --layout "$WLOGOUT_DIR/layout" \
    --css "$WLOGOUT_DIR/style.css" \
    --buttons-per-row 3 \
    --column-spacing 16 \
    --row-spacing 16
