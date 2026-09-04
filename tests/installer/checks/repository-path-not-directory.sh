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

mkdir -p -- \
    "$PROJECT_ROOT" \
    "$PROJECT_ROOT/scripts" \
    "$SETUP_DIR/packages"

touch "$PROJECT_ROOT/configs"

# Act

run_captured \
    "$TEST_STATE/output.log" \
    check_repository

# Assert

assert_failure \
    "$LAST_STATUS" \
    "repository paths should be directories"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Required repository path is missing: $PROJECT_ROOT/configs"

printf 'PASS: repository path that is not a directory is rejected\n'
