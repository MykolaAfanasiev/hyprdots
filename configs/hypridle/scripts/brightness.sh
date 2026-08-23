#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp/hyprdots-$UID}/hyprdots"
STATE_FILE="$STATE_DIR/brightness-before-idle"
LOCK_FILE="$STATE_DIR/brightness.lock"

mkdir -p -- "$STATE_DIR"


get_brightness() {
    brightnessctl get
}


get_max_brightness() {
    brightnessctl max
}


save_brightness_once() {
    if [[ -s "$STATE_FILE" ]]; then
        return 0
    fi

    local current
    current="$(get_brightness)"

    printf '%s\n' "$current" > "$STATE_FILE"
}


smooth_set_raw() {
    local target="$1"

    local current
    current="$(get_brightness)"

    local steps=20
    local step
    local value

    for (( step = 1; step <= steps; step++ )); do
        value=$(( current + (target - current) * step / steps ))

        brightnessctl set "$value" >/dev/null
        sleep 0.02
    done

    brightnessctl set "$target" >/dev/null
}

set_percent() {
    local percent="$1"

    save_brightness_once

    local maximum
    maximum="$(get_max_brightness)"

    local target=$(( maximum * percent / 100 ))

    if (( target < 1 )); then
        target=1
    fi

    smooth_set_raw "$target"
}


restore_brightness() {
    if [[ ! -s "$STATE_FILE" ]]; then
        return 0
    fi

    local target
    target="$(<"$STATE_FILE")"

    if [[ ! "$target" =~ ^[0-9]+$ ]]; then
        rm -f -- "$STATE_FILE"
        return 1
    fi

    local maximum
    maximum="$(get_max_brightness)"

    if (( target > maximum )); then
        target="$maximum"
    fi

    smooth_set_raw "$target"

    rm -f -- "$STATE_FILE"
}


main() {
    local action="${1:-}"

    (
        flock -x 9

        case "$action" in
            restore)
                restore_brightness
                ;;

            pending)
                [[ -s "$STATE_FILE" ]]
                ;;

            ''|*[!0-9]*)
                printf 'Usage: %s <0-100|restore|pending>\n' "$0" >&2
                return 1
                ;;

            *)
                if (( action < 0 || action > 100 )); then
                    printf 'Brightness percentage must be between 0 and 100.\n' >&2
                    return 1
                fi

                set_percent "$action"
                ;;
        esac
    ) 9>"$LOCK_FILE"
}
