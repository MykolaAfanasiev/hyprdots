#!/usr/bin/env bash

HYPRIDLE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$HYPRIDLE_DIR/scripts:$PATH"

exec hypridle \
    --config "$HYPRIDLE_DIR/hypridle.conf"
