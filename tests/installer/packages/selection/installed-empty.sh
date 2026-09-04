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

packages=()

# Act

package_group_installed packages

# Assert

assert_file_not_exists \
    "$TEST_STATE/pacman.log"

printf 'PASS: empty package group is already satisfied without pacman calls\n'
