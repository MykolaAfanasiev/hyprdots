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

create_fake_sudo 0 1


# Act

check_sudo \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_output_contains \
    "$TEST_STATE/output.log" \
    "sudo access available"

actual_log="$(cat "$TEST_STATE/sudo.log")"

assert_equals \
    "-n true" \
    "$actual_log" \
    "sudo -v should not run when non-interactive access works"


printf 'PASS: existing non-interactive sudo access is accepted\n'
