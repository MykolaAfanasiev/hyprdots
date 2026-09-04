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

arch_packages=()
aur_packages=()

# Act

print_install_plan \
  arch_packages \
  aur_packages \
  >"$TEST_STATE/output.log" 2>&1

# Assert

none_count="$(
  grep -Fc -- "  (none)" "$TEST_STATE/output.log"
)"

assert_equals \
  "2" \
  "$none_count" \
  "both empty installation groups should be displayed as none"

printf 'PASS: empty installation plan displays both groups as none\n'
