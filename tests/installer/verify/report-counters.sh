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


# Act

verify_pass "first pass"
verify_pass "second pass"
verify_warn "one warning"
verify_fail "one failure"


# Assert

assert_equals "2" "$VERIFY_PASS_COUNT" "pass counter should increment"
assert_equals "1" "$VERIFY_WARN_COUNT" "warn counter should increment"
assert_equals "1" "$VERIFY_FAIL_COUNT" "fail counter should increment"

printf 'PASS: verification result functions update their counters\n'
