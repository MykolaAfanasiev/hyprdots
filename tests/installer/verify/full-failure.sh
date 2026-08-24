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

chmod -x \
    "$SETUP_DIR/install.sh"


# Act

run_verification_test_captured \
    "$TEST_STATE/output.log" \
    run_post_install_verification


# Assert

assert_failure \
    "$VERIFICATION_TEST_STATUS" \
    "verification with a failed requirement should fail"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "FAIL: 1"

assert_verify_output_contains \
    "$TEST_STATE/output.log" \
    "Post-install verification failed."

printf 'PASS: failed verification causes Stage 9 to fail\n'
