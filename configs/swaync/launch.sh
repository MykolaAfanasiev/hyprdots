#!/usr/bin/env bash

SWAYNC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec swaync \
  -c "$SWAYNC_DIR/config.json" \
  -s "$SWAYNC_DIR/style.css"
