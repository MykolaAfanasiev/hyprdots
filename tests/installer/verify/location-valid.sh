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

chmod 600 \
  "$PROJECT_ROOT/configs/hyprsunset/location.conf"

# Act

verify_hyprsunset_location

# Assert

assert_equals "2" "$VERIFY_PASS_COUNT" "valid location should produce two passes"
assert_equals "0" "$VERIFY_FAIL_COUNT" "valid location should not fail"

printf 'PASS: valid Hyprsunset location and permissions pass verification\n'
