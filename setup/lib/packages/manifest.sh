#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_PACKAGE_MANIFEST_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_PACKAGE_MANIFEST_LOADED=1

load_package_manifest() {
    local manifest="$1"
    local destination_name="$2"

    if [[ ! -r "$manifest" ]]; then
        die "Package manifest is not readable: $manifest"
    fi

    local -n destination="$destination_name"
    destination=()

    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove leading/trailing whitespace.
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Ignore empty lines and comments.
        [[ -z "$line" ]] && continue
        [[ "$line" == \#* ]] && continue

        destination+=("$line")
    done < "$manifest"
}
