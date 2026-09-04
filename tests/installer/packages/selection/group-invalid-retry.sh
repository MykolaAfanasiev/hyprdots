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

source_packages=(hyprland waybar)
selected_packages=()

# Act

select_package_group \
    "Core packages" \
    "Test packages." \
    source_packages \
    selected_packages \
    all \
    <<< $'invalid\nall\n' \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_array_equals \
    selected_packages \
    hyprland \
    waybar

assert_package_output_contains \
    "$TEST_STATE/output.log" \
    "Choose A, C, or N."

printf 'PASS: invalid group selection is rejected and retried\n'
