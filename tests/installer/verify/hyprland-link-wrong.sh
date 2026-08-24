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

source_file="$PROJECT_ROOT/configs/hypr/hyprland.lua"
wrong_file="$TEST_STATE/wrong.lua"
destination="$HOME/.config/hypr/hyprland.lua"

printf '%s\n' '-- source' > "$source_file"
printf '%s\n' '-- wrong' > "$wrong_file"

ln -s \
    "$wrong_file" \
    "$destination"


# Act

verify_hyprland_link


# Assert

assert_equals "1" "$VERIFY_WARN_COUNT" "wrong Hyprland symlink should warn"
assert_equals "0" "$VERIFY_FAIL_COUNT" "wrong Hyprland symlink should not hard fail"

printf 'PASS: incorrect Hyprland configuration symlink produces a warning\n'
