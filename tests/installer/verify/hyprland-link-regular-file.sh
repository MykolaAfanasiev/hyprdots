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
    "$PROJECT_ROOT/configs/hypr" \
    "$HOME/.config/hypr"

printf '%s\n' '-- source' \
    > "$PROJECT_ROOT/configs/hypr/hyprland.lua"

printf '%s\n' '-- local unmanaged config' \
    > "$HOME/.config/hypr/hyprland.lua"

# Act

verify_hyprland_link

# Assert

assert_equals "1" "$VERIFY_WARN_COUNT" "regular destination file should warn"
assert_equals "0" "$VERIFY_FAIL_COUNT" "regular destination file should not hard fail"

printf 'PASS: unmanaged Hyprland config file produces a warning\n'
