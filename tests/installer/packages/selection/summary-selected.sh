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

SELECTED_ARCH_REQUIRED=(hyprland waybar)
SELECTED_ARCH_RECOMMENDED=(wireplumber)
SELECTED_ARCH_DEFAULT_APPS=(kitty)
SELECTED_AUR_REQUIRED=(wlogout)

# Act

print_package_selection_summary \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_package_output_contains \
  "$TEST_STATE/output.log" \
  "Required Arch packages:"

assert_package_output_contains \
  "$TEST_STATE/output.log" \
  "Recommended Arch packages:"

assert_package_output_contains \
  "$TEST_STATE/output.log" \
  "Default applications:"

assert_package_output_contains \
  "$TEST_STATE/output.log" \
  "AUR packages:"

for package in \
  hyprland \
  waybar \
  wireplumber \
  kitty \
  wlogout; do
  assert_package_output_contains \
    "$TEST_STATE/output.log" \
    "  - $package"
done

printf 'PASS: package selection summary displays selected packages\n'
