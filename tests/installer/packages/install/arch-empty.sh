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

# Act

install_arch_packages \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_install_output_contains \
  "$TEST_STATE/output.log" \
  "No official Arch packages selected"

assert_file_not_exists \
  "$TEST_STATE/sudo.log"

printf 'PASS: empty Arch package list skips installation\n'
