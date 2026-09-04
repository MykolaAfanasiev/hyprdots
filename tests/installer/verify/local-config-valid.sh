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

mkdir -p \
    "$PROJECT_ROOT/configs/hypr/modules/vars"

printf '%s\n' '-- local' \
    > "$PROJECT_ROOT/configs/hypr/modules/vars/local.lua"

# Act

verify_hyprland_local_config

# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "existing local config should pass"
assert_equals "0" "$VERIFY_FAIL_COUNT" "existing local config should not fail"

printf 'PASS: existing Hyprland local config passes verification\n'
