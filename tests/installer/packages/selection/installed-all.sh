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

packages=(hyprland waybar kitty)

create_fake_pacman_all_installed


# Act

package_group_installed packages


# Assert

actual_calls="$(wc -l < "$TEST_STATE/pacman.log")"

assert_equals \
    "3" \
    "$actual_calls" \
    "pacman should check every package"


printf 'PASS: package group passes when every package is installed\n'
