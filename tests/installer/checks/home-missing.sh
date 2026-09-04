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

HOME="$TEST_ROOT/missing-home"
export HOME

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_home

# Assert

assert_failure \
    "$LAST_STATUS" \
    "missing home directory should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Home directory does not exist: $HOME"

printf 'PASS: missing home directory is rejected\n'
