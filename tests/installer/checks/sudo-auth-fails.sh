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

create_fake_sudo 1 1

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_sudo

# Assert

assert_failure \
    "$LAST_STATUS" \
    "failed sudo authentication should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Unable to authenticate with sudo."

expected_log="$(
    printf '%s\n%s' \
        '-n true' \
        '-v'
)"

actual_log="$(cat "$TEST_STATE/sudo.log")"

assert_equals \
    "$expected_log" \
    "$actual_log" \
    "both sudo authentication paths should be attempted"

printf 'PASS: failed sudo authentication is rejected\n'
