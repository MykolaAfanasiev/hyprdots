#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/system-checks.sh
source "$REPO_ROOT/tests/lib/system-checks.sh"

# Arrange

setup_system_checks_test
trap destroy_test_sandbox EXIT

create_fake_sudo 1 0

# Act

check_sudo \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_output_contains \
  "$TEST_STATE/output.log" \
  "sudo authentication successful"

expected_log="$(
  printf '%s\n%s' \
    '-n true' \
    '-v'
)"

actual_log="$(cat "$TEST_STATE/sudo.log")"

assert_equals \
  "$expected_log" \
  "$actual_log" \
  "sudo should fall back to authentication"

printf 'PASS: sudo password authentication fallback succeeds\n'
