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

select_packages_individually \
    source_packages \
    selected_packages \
    yes \
    <<< $'\n\n'

# Assert

assert_array_equals \
    selected_packages \
    hyprland \
    waybar

printf 'PASS: empty individual answers select packages when default is yes\n'
