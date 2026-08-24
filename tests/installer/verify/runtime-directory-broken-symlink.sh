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

link="$TEST_ROOT/wallpapers"

ln -s \
    "$TEST_ROOT/missing-directory" \
    "$link"


# Act

verify_runtime_directory \
    "Wallpapers" \
    "$link"


# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "broken runtime symlink should not pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "broken runtime symlink should fail"

printf 'PASS: broken runtime directory symlink fails verification\n'
