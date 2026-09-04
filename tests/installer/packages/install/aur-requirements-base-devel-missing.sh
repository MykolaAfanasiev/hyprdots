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

mock_available_commands \
  git \
  makepkg

create_fake_pacman 0

# Act

run_install_test_captured \
  "$TEST_STATE/output.log" \
  check_aur_requirements

# Assert

assert_failure \
  "$INSTALL_TEST_STATUS" \
  "missing base-devel should fail AUR requirements"

assert_install_output_contains \
  "$TEST_STATE/output.log" \
  "base-devel is required to build AUR packages."

printf 'PASS: missing base-devel is rejected for AUR installation\n'
