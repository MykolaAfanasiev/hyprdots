#!/usr/bin/env bash

# Package test arrays and overrides are consumed through namerefs or
# indirectly by sourced package functions.
# shellcheck disable=SC2034,SC2317,SC2329

set -euo pipefail

REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." &&
    pwd
)"

# shellcheck source=tests/lib/package-installation.sh
source "$REPO_ROOT/tests/lib/package-installation.sh"

# Arrange

setup_package_installation_test
trap destroy_test_sandbox EXIT

mock_available_commands \
    git \
    makepkg

create_fake_pacman \
    0 \
    base-devel


# Act

check_aur_requirements


# Assert

assert_log_contains \
    "$TEST_STATE/pacman.log" \
    "-Qq base-devel"

printf 'PASS: valid AUR build requirements are accepted\n'
