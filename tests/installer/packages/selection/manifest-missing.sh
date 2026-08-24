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

manifest="$TEST_STATE/missing.txt"

packages=()


# Act

run_package_test_captured \
    "$TEST_STATE/output.log" \
    load_package_manifest \
    "$manifest" \
    packages


# Assert

assert_failure \
    "$PACKAGE_TEST_STATUS" \
    "missing manifest should be rejected"

assert_package_output_contains \
    "$TEST_STATE/output.log" \
    "Package manifest is not readable: $manifest"


printf 'PASS: missing package manifest is rejected\n'
