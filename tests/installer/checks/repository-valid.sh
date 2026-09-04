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

# Act

check_repository \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Repository structure looks valid"

printf 'PASS: valid repository structure passes\n'
