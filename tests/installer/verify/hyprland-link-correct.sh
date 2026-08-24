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
destination="$HOME/.config/hypr/hyprland.lua"

printf '%s\n' '-- hyprland' > "$source_file"

ln -s \
    "$source_file" \
    "$destination"


# Act

verify_hyprland_link


# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "correct Hyprland symlink should pass"
assert_equals "0" "$VERIFY_WARN_COUNT" "correct Hyprland symlink should not warn"

printf 'PASS: correct Hyprland configuration symlink passes verification\n'
