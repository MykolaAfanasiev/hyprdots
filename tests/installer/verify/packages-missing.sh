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
    hyprland


# Act

verify_package_group \
    "Official Arch packages" \
    hyprland \
    waybar \
    kitty \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "missing package group should not pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "missing package group should fail once"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "2 package(s) are missing"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "waybar"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "kitty"

printf 'PASS: missing packages are reported by verification\n'
