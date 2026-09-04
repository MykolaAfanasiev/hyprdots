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

create_valid_repository

rm -rf -- "$SETUP_DIR/packages"

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_repository

# Assert

assert_failure \
    "$LAST_STATUS" \
    "missing setup packages directory should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Required repository path is missing: $SETUP_DIR/packages"

printf 'PASS: missing setup packages directory is rejected\n'
