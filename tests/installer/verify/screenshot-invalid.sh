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

create_fake_command \
    screenshot-tool \
    0

mock_screenshot_tool_status 1

# Act

verify_screenshot_command

# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "invalid screenshot-tool should not pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "invalid screenshot-tool should fail"

printf 'PASS: broken screenshot-tool fails verification\n'
