#!/usr/bin/env bash

WAYBAR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export WAYBAR_CONFIG_DIR="$WAYBAR_DIR"

exec waybar \
  -c "$WAYBAR_DIR/config.jsonc" \
  -s "$WAYBAR_DIR/style.css"
