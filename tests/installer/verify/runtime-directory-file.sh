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

path="$TEST_ROOT/wallpapers"

printf '%s\n' 'not a directory' \
  >"$path"

# Act

verify_runtime_directory \
  "Wallpapers" \
  "$path"

# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "runtime file should not pass as directory"
assert_equals "1" "$VERIFY_FAIL_COUNT" "runtime file should fail directory verification"

printf 'PASS: runtime path that is a file fails verification\n'
