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

VERIFY_PASS_COUNT=9
VERIFY_WARN_COUNT=8
VERIFY_FAIL_COUNT=7

# Act

reset_verification_report

# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "pass counter should reset"
assert_equals "0" "$VERIFY_WARN_COUNT" "warn counter should reset"
assert_equals "0" "$VERIFY_FAIL_COUNT" "fail counter should reset"

printf 'PASS: verification report counters reset to zero\n'
