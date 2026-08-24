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

create_fake_git_clone 0
create_fake_makepkg 0

mock_confirm_yes


# Act

install_aur_packages \
    wlogout \
    example-aur \
    > "$TEST_STATE/output.log" 2>&1


# Assert

makepkg_calls="$(
    awk 'END { print NR }' "$TEST_STATE/makepkg.log"
)"

assert_equals \
    "2" \
    "$makepkg_calls" \
    "makepkg should run once for each missing AUR package"

assert_no_aur_build_dirs

printf 'PASS: multiple AUR packages are installed sequentially\n'
