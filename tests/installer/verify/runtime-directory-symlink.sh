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

target="$TEST_ROOT/custom-wallpapers"
link="$TEST_ROOT/wallpapers"

mkdir -p \
    "$target"

ln -s \
    "$target" \
    "$link"


# Act

verify_runtime_directory \
    "Wallpapers" \
    "$link"


# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "valid runtime symlink should pass"
assert_equals "0" "$VERIFY_FAIL_COUNT" "valid runtime symlink should not fail"

printf 'PASS: runtime directory symlink passes verification\n'
