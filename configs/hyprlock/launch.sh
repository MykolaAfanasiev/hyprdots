#!/usr/bin/env bash

HYPRLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec hyprlock \
    --config "$HYPRLOCK_DIR/hyprlock.conf"
