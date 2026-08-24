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

prepare_e2e_environment 1


# Act

run_e2e_installer \
    $'\n\n\n' \
    "$TEST_STATE/output.log"

if (( E2E_STATUS == 0 )) ||
    ! grep -Fq -- "[1/10]" "$TEST_STATE/output.log"
then
    print_e2e_output "$TEST_STATE/output.log"
fi


# Assert

assert_failure \
    "$E2E_STATUS" \
    "installer should fail when sudo authentication is unavailable"

assert_e2e_output_contains \
    "$TEST_STATE/output.log" \
    "[1/10]"

assert_e2e_output_not_contains \
    "$TEST_STATE/output.log" \
    "[2/10]"

assert_file_not_exists \
    "$E2E_PROJECT/configs/hypr/modules/vars/local.lua"

printf 'PASS: preflight failure stops the complete installer pipeline\n'
