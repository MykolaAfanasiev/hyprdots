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

arch_packages=(old)
aur_packages=(old)

# Act

build_package_plan \
  arch_packages \
  aur_packages

# Assert

assert_array_empty arch_packages
assert_array_empty aur_packages

printf 'PASS: empty package selections produce an empty installation plan\n'
