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

rm -rf -- "$PROJECT_ROOT/scripts"

# Act

run_captured \
  "$TEST_STATE/output.log" \
  check_repository

# Assert

assert_failure \
  "$LAST_STATUS" \
  "missing scripts directory should be rejected"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Required repository path is missing: $PROJECT_ROOT/scripts"

printf 'PASS: missing scripts directory is rejected\n'
