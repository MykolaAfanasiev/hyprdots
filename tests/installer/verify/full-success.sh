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

create_valid_verification_environment
# No installed packages are needed for this scenario.
# shellcheck disable=SC2119
create_fake_pacman_installed

# Act

run_post_install_verification \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_equals "13" "$VERIFY_PASS_COUNT" "fully valid installation should produce 13 passes"
assert_equals "0" "$VERIFY_WARN_COUNT" "fully valid installation should have no warnings"
assert_equals "0" "$VERIFY_FAIL_COUNT" "fully valid installation should have no failures"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "Post-install verification passed"

printf 'PASS: fully valid installation passes post-install verification\n'
