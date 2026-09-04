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

packages=()

# Act

deduplicate_packages \
  packages \
  zeta \
  alpha \
  zeta \
  beta \
  alpha \
  gamma

# Assert

assert_array_equals \
  packages \
  zeta \
  alpha \
  beta \
  gamma

printf 'PASS: package deduplication preserves first-seen order\n'
