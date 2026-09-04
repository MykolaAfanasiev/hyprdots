#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
        pwd
)"

BRIGHTNESS_SCRIPT="$SCRIPT_DIR/brightness.sh"

exec hyprshutdown \
    --top-label "Shutting down..." \
    --post-cmd "\"$BRIGHTNESS_SCRIPT\" restore || true; shutdown -P 0"
