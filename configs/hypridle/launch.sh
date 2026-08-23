#!/usr/bin/env bash

set -euo pipefail

HYPRIDLE_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"

BRIGHTNESS_SCRIPT="$HYPRIDLE_DIR/scripts/brightness.sh"

export PATH="$HYPRIDLE_DIR/scripts:$PATH"


check_previous_session() {
    if ! "$BRIGHTNESS_SCRIPT" pending; then
        return 0
    fi

    if "$BRIGHTNESS_SCRIPT" restore; then
        notify-send \
            --urgency=warning \
            "Hyprdots Norexil" \
            "Brightness was not restored before the previous session ended. It has now been restored." \
            || true
    else
        notify-send \
            --urgency=critical \
            "Hyprdots Norexil" \
            "Brightness could not be restored after the previous session." \
            || true
    fi
}


restore_brightness() {
    "$BRIGHTNESS_SCRIPT" restore >/dev/null 2>&1 || true
}


check_previous_session

trap restore_brightness EXIT

hypridle \
    --config "$HYPRIDLE_DIR/hypridle.conf"
