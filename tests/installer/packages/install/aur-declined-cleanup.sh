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

mock_confirm_no

# Act

run_install_test_captured \
    "$TEST_STATE/output.log" \
    install_aur_package \
    wlogout

# Assert

assert_failure \
    "$INSTALL_TEST_STATUS" \
    "declined AUR build should fail installation"

assert_no_aur_build_dirs

assert_file_not_exists \
    "$TEST_STATE/makepkg.log"

assert_install_output_contains \
    "$TEST_STATE/output.log" \
    "AUR package installation cancelled: wlogout"

printf 'PASS: declined AUR build cleans its temporary directory\n'
