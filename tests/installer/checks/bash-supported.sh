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

mock_bash_major_version 5

# Act

check_bash \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Bash $BASH_VERSION"

printf 'PASS: supported Bash version passes\n'
