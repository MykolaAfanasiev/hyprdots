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

write_test_os_release \
  ubuntu \
  "debian" \
  "Ubuntu"

use_test_os_release

# Act

run_captured \
  "$TEST_STATE/output.log" \
  check_arch_linux

# Assert

assert_failure \
  "$LAST_STATUS" \
  "unsupported distribution should be rejected"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Unsupported distribution: Ubuntu. Arch Linux is required."

printf 'PASS: unsupported distribution is rejected\n'
