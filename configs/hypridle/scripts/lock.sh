#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

HYPRLOCK_LAUNCH="$PROJECT_ROOT/configs/hyprlock/launch.sh"

if pgrep -x hyprlock >/dev/null; then
    exit 0
fi

exec "$HYPRLOCK_LAUNCH"
