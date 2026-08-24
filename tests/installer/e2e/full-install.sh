#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/e2e.sh
source "$REPO_ROOT/tests/lib/e2e.sh"


# Arrange

setup_e2e_test
trap destroy_test_sandbox EXIT

prepare_e2e_environment 0

# Stage 8 should repair this before Stage 9 verifies it.
chmod -x -- \
    "$E2E_PROJECT/configs/hypridle/launch.sh"

# Enough default answers for the remaining interactive stages.
E2E_INPUT=$'\n\n\n\n\n\n\n\n\n\n'


# Act

run_e2e_installer \
    "$E2E_INPUT" \
    "$TEST_STATE/output.log"


if (( E2E_STATUS != 0 )); then
    printf '\n--- E2E installer output ---\n' >&2
    cat -- "$TEST_STATE/output.log" >&2
    printf '%s\n' '----------------------------' >&2
fi

# Assert

assert_equals \
    "0" \
    "$E2E_STATUS" \
    "full installer should exit successfully"

for stage in {1..9}; do
    assert_e2e_output_contains \
        "$TEST_STATE/output.log" \
        "[$stage/10]"
done

assert_file_exists \
    "$E2E_PROJECT/configs/hypr/modules/vars/local.lua"

assert_directory_exists \
    "$HOME/.wallpapers"

assert_directory_exists \
    "$HOME/Screenshots"

assert_executable \
    "$E2E_PROJECT/configs/hypridle/launch.sh"

assert_symlink_to \
    "$HOME/.config/hypr/hyprland.lua" \
    "$E2E_PROJECT/configs/hypr/hyprland.lua"

location_permissions="$(
    stat -c '%a' -- \
        "$E2E_PROJECT/configs/hyprsunset/location.conf"
)"

assert_equals \
    "600" \
    "$location_permissions" \
    "Hyprsunset location permissions should be secure"

assert_e2e_output_contains \
    "$TEST_STATE/stow.log" \
    "--restow"

assert_e2e_output_contains \
    "$TEST_STATE/output.log" \
    "Post-install verification passed"

printf 'PASS: complete installer pipeline succeeds end to end\n'
