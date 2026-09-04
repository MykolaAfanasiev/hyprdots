#!/usr/bin/env bash

set -euo pipefail

HYPRSUNSET_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
        pwd
)"

LOCATION="$HYPRSUNSET_DIR/location.conf"
SCHEDULER="$HYPRSUNSET_DIR/scripts/schedule.py"

if [[ ! -f "$LOCATION" ]]; then
    echo "Missing location config:" >&2
    echo "  $LOCATION" >&2
    echo >&2
    echo "Copy location.conf.example and configure it." >&2
    exit 1
fi

# Start without changing colors.
hyprsunset --identity &
hyprsunset_pid=$!

cleanup() {
    if [[ -n "${scheduler_pid:-}" ]]; then
        kill "$scheduler_pid" 2> /dev/null || true
    fi

    kill "$hyprsunset_pid" 2> /dev/null || true
}

trap cleanup EXIT INT TERM

# Wait until IPC is ready.
ready=false

for _ in {1..50}; do
    if hyprctl hyprsunset identity > /dev/null 2>&1; then
        ready=true
        break
    fi

    if ! kill -0 "$hyprsunset_pid" 2> /dev/null; then
        wait "$hyprsunset_pid"
        exit $?
    fi

    sleep 0.1
done

if [[ "$ready" != true ]]; then
    echo "Hyprsunset IPC is not available" >&2
    exit 1
fi

python3 "$SCHEDULER" &
scheduler_pid=$!

wait -n \
    "$hyprsunset_pid" \
    "$scheduler_pid"
