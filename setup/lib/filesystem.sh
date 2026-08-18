#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_FILESYSTEM_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_FILESYSTEM_LOADED=1


backup_path() {
    local path="$1"

    local timestamp
    timestamp="$(date '+%Y%m%d-%H%M%S')"

    local backup="${path}.backup.${timestamp}"

    mv -- \
        "$path" \
        "$backup"

    printf '%s\n' "$backup"
}
