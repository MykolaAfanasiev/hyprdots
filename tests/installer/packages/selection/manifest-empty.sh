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

manifest="$TEST_STATE/packages.txt"

printf '\n# comment\n   \n\t\n' > "$manifest"

packages=(old-value)

# Act

load_package_manifest \
    "$manifest" \
    packages

# Assert

assert_array_empty packages

printf 'PASS: empty and comment-only manifest produces an empty array\n'
