#!/usr/bin/env bash

set -euo pipefail

HYPRLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if pgrep -x hyprlock > /dev/null; then
    exit 0
fi

exec hyprlock \
    --config "$HYPRLOCK_DIR/hyprlock.conf"
