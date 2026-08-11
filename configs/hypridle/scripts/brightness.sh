#!/usr/bin/env bash

set -u

TARGET="${1:-}"
DURATION_MS="${2:-500}"

BRIGHTNESS_ARGS=(-c backlight)

if [[ -n "${BRIGHTNESS_DEVICE:-}" ]]; then
    BRIGHTNESS_ARGS=(-d "$BRIGHTNESS_DEVICE")
fi

case "$TARGET" in
    max)
        TARGET=100
        ;;
    ''|*[!0-9]*)
        echo "Usage: $0 {0..100|max} [duration_ms]" >&2
        exit 1
        ;;
esac

if (( TARGET < 1 || TARGET > 100 )); then
    echo "Brightness must be between 1 and 100" >&2
    exit 1
fi

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/hyprdots-brightness.lock"

exec 9>"$LOCK_FILE"
flock 9

CURRENT_RAW="$(
    brightnessctl "${BRIGHTNESS_ARGS[@]}" get 2>/dev/null
)" || exit 1

MAX_RAW="$(
    brightnessctl "${BRIGHTNESS_ARGS[@]}" max 2>/dev/null
)" || exit 1

if (( MAX_RAW <= 0 )); then
    exit 1
fi

CURRENT=$(( (CURRENT_RAW * 100 + MAX_RAW / 2) / MAX_RAW ))

# Уже нужная яркость.
if (( CURRENT == TARGET )); then
    exit 0
fi

DELTA=$(( TARGET - CURRENT ))

if (( DELTA < 0 )); then
    ABS_DELTA=$(( -DELTA ))
else
    ABS_DELTA=$DELTA
fi

STEPS=20

if (( ABS_DELTA < STEPS )); then
    STEPS=$ABS_DELTA
fi

DELAY_MS=$(( DURATION_MS / STEPS ))

printf -v DELAY "%d.%03d" \
    $(( DELAY_MS / 1000 )) \
    $(( DELAY_MS % 1000 ))

for (( i = 1; i <= STEPS; i++ )); do
    VALUE=$(( CURRENT + DELTA * i / STEPS ))

    brightnessctl \
        -q \
        "${BRIGHTNESS_ARGS[@]}" \
        set "${VALUE}%"

    if (( i < STEPS )); then
        sleep "$DELAY"
    fi
done
