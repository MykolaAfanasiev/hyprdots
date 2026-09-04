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

mkdir -p \
  "$PROJECT_ROOT/configs/hyprsunset"

printf '%s\n' 'LATITUDE=48.7' \
  >"$PROJECT_ROOT/configs/hyprsunset/location.conf"

chmod 644 \
  "$PROJECT_ROOT/configs/hyprsunset/location.conf"

# Act

verify_hyprsunset_location \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "configured location itself should pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "wrong permissions should fail"

assert_verify_output_contains \
  "$TEST_STATE/output.log" \
  "permissions are 644; expected 600"

printf 'PASS: unsafe Hyprsunset permissions fail verification\n'
