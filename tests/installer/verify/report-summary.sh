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

VERIFY_PASS_COUNT=4
VERIFY_WARN_COUNT=2
VERIFY_FAIL_COUNT=1


# Act

print_verification_summary \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_verify_output_contains "$TEST_STATE/output.log" "PASS: 4"
assert_verify_output_contains "$TEST_STATE/output.log" "WARN: 2"
assert_verify_output_contains "$TEST_STATE/output.log" "FAIL: 1"

printf 'PASS: verification summary displays all result counters\n'
