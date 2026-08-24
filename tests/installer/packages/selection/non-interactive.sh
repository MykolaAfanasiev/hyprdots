#!/usr/bin/env bash

# Package arrays are passed by name or consumed indirectly through sourced functions.
# shellcheck disable=SC2034

set -euo pipefail

REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." &&
    pwd
)"

# shellcheck source=tests/lib/package-selection.sh
source "$REPO_ROOT/tests/lib/package-selection.sh"


# Arrange

setup_package_selection_test
trap destroy_test_sandbox EXIT

mock_terminal 0


# Act

run_package_test_captured \
    "$TEST_STATE/output.log" \
    run_package_selection


# Assert

assert_failure \
    "$PACKAGE_TEST_STATUS" \
    "non-interactive package selection should fail"

assert_package_output_contains \
    "$TEST_STATE/output.log" \
    "Interactive package selection requires a terminal."


printf 'PASS: package selection rejects non-interactive stdin\n'
