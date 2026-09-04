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

mock_home_writable 0

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_home

# Assert

assert_failure \
    "$LAST_STATUS" \
    "non-writable home directory should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Home directory is not writable: $HOME"

printf 'PASS: non-writable home directory is rejected\n'
