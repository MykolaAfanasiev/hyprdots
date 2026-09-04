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

use_test_os_release

# Act

run_captured \
  "$TEST_STATE/output.log" \
  check_arch_linux

# Assert

assert_failure \
  "$LAST_STATUS" \
  "missing os-release should be rejected"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Cannot read $TEST_OS_RELEASE."

printf 'PASS: missing os-release file is rejected\n'
