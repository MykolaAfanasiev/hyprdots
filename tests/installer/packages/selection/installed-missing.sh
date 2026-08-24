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

packages=(hyprland missing-package waybar)

create_fake_pacman_with_missing \
    missing-package


# Act

set +e
package_group_installed packages
status=$?
set -e


# Assert

assert_failure \
    "$status" \
    "package group with a missing package should fail"


printf 'PASS: package group fails when a package is missing\n'
