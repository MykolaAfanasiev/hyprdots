#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_PACKAGE_PLAN_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_PACKAGE_PLAN_LOADED=1


deduplicate_packages() {
    local source_name="$1"
    local destination_name="$2"

    local -n source="$source_name"
    local -n destination="$destination_name"

    local -A seen=()
    local package

    destination=()

    for package in "${source[@]}"; do
        if [[ -n "${seen[$package]+x}" ]]; then
            continue
        fi

        seen["$package"]=1
        destination+=("$package")
    done
}


build_package_plan() {
    local arch_destination_name="$1"
    local aur_destination_name="$2"

    local -a arch_candidates=(
        "${SELECTED_ARCH_REQUIRED[@]}"
        "${SELECTED_ARCH_RECOMMENDED[@]}"
        "${SELECTED_ARCH_DEFAULT_APPS[@]}"
    )

    local -a aur_candidates=(
        "${SELECTED_AUR_REQUIRED[@]}"
    )

    deduplicate_packages \
        arch_candidates \
        "$arch_destination_name"

    deduplicate_packages \
        aur_candidates \
        "$aur_destination_name"
}
