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

check_without_home() {
    unset HOME
    check_home
}

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_without_home

# Assert

assert_failure \
    "$LAST_STATUS" \
    "unset HOME should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "\$HOME is not set."

printf 'PASS: unset HOME is rejected\n'
