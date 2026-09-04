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

directory="$TEST_ROOT/wallpapers"

mkdir -p \
  "$directory"

# Act

verify_runtime_directory \
  "Wallpapers" \
  "$directory"

# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "normal runtime directory should pass"
assert_equals "0" "$VERIFY_FAIL_COUNT" "normal runtime directory should not fail"

printf 'PASS: normal runtime directory passes verification\n'
