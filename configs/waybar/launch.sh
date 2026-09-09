#!/usr/bin/env bash

set -euo pipefail

WAYBAR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export WAYBAR_CONFIG_DIR="$WAYBAR_DIR"

WAYBAR_STYLE="$("$WAYBAR_DIR/prepare-theme.sh")"

exec waybar \
  -c "$WAYBAR_DIR/config.jsonc" \
  -s "$WAYBAR_STYLE"
