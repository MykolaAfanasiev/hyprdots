#!/usr/bin/env bash

# Package test arrays and overrides are consumed through namerefs or
# indirectly by sourced package functions.
# shellcheck disable=SC2034,SC2317,SC2329

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../.." &&
    pwd
)"

# shellcheck source=tests/lib/package-installation.sh
source "$REPO_ROOT/tests/lib/package-installation.sh"

# Arrange

setup_package_installation_test
trap destroy_test_sandbox EXIT

PACKAGE_INSTALLATION_NEEDED=1

SELECTED_ARCH_REQUIRED=(hyprland)
SELECTED_AUR_REQUIRED=(wlogout)

mock_confirm_no

install_arch_packages() {
  touch "$TEST_STATE/arch-install-called"
}

install_aur_packages() {
  touch "$TEST_STATE/aur-install-called"
}

# Act

run_install_test_captured \
  "$TEST_STATE/output.log" \
  run_package_installation

# Assert

assert_failure \
  "$INSTALL_TEST_STATUS" \
  "cancelled package installation should fail"

assert_file_not_exists \
  "$TEST_STATE/arch-install-called"

assert_file_not_exists \
  "$TEST_STATE/aur-install-called"

assert_install_output_contains \
  "$TEST_STATE/output.log" \
  "Package installation cancelled."

printf 'PASS: cancelling installation prevents package installers from running\n'
