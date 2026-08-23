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

symlink_points_to() {
    local link="$1"
    local expected_target="$2"

    [[ -L "$link" ]] || return 1

    local actual_target

    actual_target="$(readlink -f -- "$link")" || return 1

    [[ "$actual_target" == "$expected_target" ]]
}
