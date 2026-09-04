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

mock_effective_uid 0

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_not_root

# Assert

assert_failure \
    "$LAST_STATUS" \
    "root user should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Do not run the installer as root."

printf 'PASS: root user is rejected\n'
