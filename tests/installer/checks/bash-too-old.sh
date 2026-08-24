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

mock_bash_major_version 3


# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_bash


# Assert

assert_failure \
    "$LAST_STATUS" \
    "Bash older than 4 should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Bash 4 or newer is required."


printf 'PASS: unsupported Bash version is rejected\n'
