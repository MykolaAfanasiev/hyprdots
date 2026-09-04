#!/usr/bin/env bash

# Package arrays are passed by name or consumed indirectly through sourced functions.
# shellcheck disable=SC2034

set -euo pipefail

REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." &&
        pwd
)"

# shellcheck source=tests/lib/package-selection.sh
source "$REPO_ROOT/tests/lib/package-selection.sh"

# Arrange

setup_package_selection_test
trap destroy_test_sandbox EXIT

mock_terminal 1
create_default_manifests
create_fake_pacman_all_missing

# Act

run_package_selection \
    <<< $'\n\n\n\n' \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_array_equals \
    SELECTED_ARCH_REQUIRED \
    hyprland \
    waybar

assert_array_equals \
    SELECTED_ARCH_RECOMMENDED \
    xdg-desktop-portal-hyprland \
    wireplumber

assert_array_equals \
    SELECTED_ARCH_DEFAULT_APPS \
    kitty \
    btop

assert_array_equals \
    SELECTED_AUR_REQUIRED \
    wlogout

assert_equals \
    "1" \
    "$PACKAGE_INSTALLATION_NEEDED" \
    "selected packages should require the installation stage"

assert_package_output_contains \
    "$TEST_STATE/output.log" \
    "Package selection complete"

printf 'PASS: full package-selection stage selects all default packages\n'
