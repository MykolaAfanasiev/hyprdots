#!/usr/bin/env bash

# These arrays are passed by name and accessed through namerefs.
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

source_packages=(hyprland waybar)
selected_packages=(old-value)

# Act

select_package_group \
  "Optional packages" \
  "Test packages." \
  source_packages \
  selected_packages \
  none \
  <<<$'\n' \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_array_empty selected_packages

printf 'PASS: empty group selection defaults to none when configured\n'
