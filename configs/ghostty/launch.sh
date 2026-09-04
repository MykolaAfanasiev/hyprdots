#!/usr/bin/env bash

set -euo pipefail

if ! command -v ghostty > /dev/null 2>&1; then
    printf 'Error: Ghostty is not installed.\n' >&2
    exit 1
fi

exec ghostty "$@"
