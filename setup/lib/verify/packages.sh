#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_PACKAGES_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_VERIFY_PACKAGES_LOADED=1


verify_package_group() {
    local label="$1"
    local array_name="$2"

    local -n packages_ref="$array_name"

    if (( ${#packages_ref[@]} == 0 )); then
        verify_pass "$label: nothing selected"
        return 0
    fi

    local -a missing_packages=()
    local package

    for package in "${packages_ref[@]}"; do
        if ! pacman -Qq "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
        fi
    done

    if (( ${#missing_packages[@]} == 0 )); then
        verify_pass \
            "$label: all ${#packages_ref[@]} selected package(s) are installed"

        return 0
    fi

    verify_fail \
        "$label: ${#missing_packages[@]} package(s) are missing"

    print_package_list missing_packages
}


verify_selected_packages() {
    section "Packages"

    local -a arch_packages=()
    local -a aur_packages=()

    build_package_plan \
        arch_packages \
        aur_packages

    verify_package_group \
        "Official Arch packages" \
        arch_packages

    verify_package_group \
        "AUR packages" \
        aur_packages
}
