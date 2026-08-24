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

verify_screenshot_command


# Assert

assert_equals "1" "$VERIFY_WARN_COUNT" "missing screenshot-tool should warn"
assert_equals "0" "$VERIFY_FAIL_COUNT" "missing screenshot-tool should not hard fail"

printf 'PASS: missing screenshot-tool produces a warning\n'
