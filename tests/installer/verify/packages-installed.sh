#!/usr/bin/env bash

# Test variables are consumed indirectly by sourced verification functions.
# shellcheck disable=SC2034

set -euo pipefail

REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/verification.sh
source "$REPO_ROOT/tests/lib/verification.sh"

# Arrange

setup_verification_test
trap destroy_test_sandbox EXIT

create_fake_pacman_installed \
    hyprland \
    waybar


# Act

verify_package_group \
    "Official Arch packages" \
    hyprland \
    waybar


# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "installed package group should pass"
assert_equals "0" "$VERIFY_FAIL_COUNT" "installed package group should not fail"

printf 'PASS: installed package group passes verification\n'
