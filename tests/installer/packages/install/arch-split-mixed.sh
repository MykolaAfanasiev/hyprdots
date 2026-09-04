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

create_fake_pacman \
  0 \
  hyprland \
  kitty

source_packages=(hyprland waybar kitty)
installed_packages=()
missing_packages=()

# Act

split_arch_packages \
  source_packages \
  installed_packages \
  missing_packages

# Assert

assert_array_equals \
  installed_packages \
  hyprland \
  kitty

assert_array_equals \
  missing_packages \
  waybar

printf 'PASS: Arch packages are split into installed and missing groups\n'
