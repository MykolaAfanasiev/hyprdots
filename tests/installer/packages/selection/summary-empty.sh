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

# Act

print_package_selection_summary \
  >"$TEST_STATE/output.log" 2>&1

# Assert

none_count="$(
  grep -Fc -- "  (none)" "$TEST_STATE/output.log"
)"

assert_equals \
  "4" \
  "$none_count" \
  "every empty package group should be displayed as none"

printf 'PASS: empty package selection summary shows all groups as none\n'
