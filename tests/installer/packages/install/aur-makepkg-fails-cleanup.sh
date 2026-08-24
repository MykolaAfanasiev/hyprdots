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

create_fake_pacman 0
create_fake_git_clone 0
create_fake_makepkg 1

mock_confirm_yes


# Act

run_install_test_captured \
    "$TEST_STATE/output.log" \
    install_aur_package \
    wlogout


# Assert

assert_failure \
    "$INSTALL_TEST_STATUS" \
    "failed makepkg should fail AUR installation"

assert_no_aur_build_dirs

assert_log_contains \
    "$TEST_STATE/makepkg.log" \
    "-si --needed"

assert_install_output_contains \
    "$TEST_STATE/output.log" \
    "Failed to build or install AUR package: wlogout"

printf 'PASS: failed makepkg cleans its temporary build directory\n'
