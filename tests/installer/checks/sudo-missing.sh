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


command_exists() {
    if [[ "$1" == "sudo" ]]; then
        return 1
    fi

    command -v "$1" >/dev/null 2>&1
}


# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_sudo


# Assert

assert_failure \
    "$LAST_STATUS" \
    "missing sudo should be rejected"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "sudo was not found."


printf 'PASS: missing sudo is rejected\n'
