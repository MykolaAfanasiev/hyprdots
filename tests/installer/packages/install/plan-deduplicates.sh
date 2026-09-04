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

SELECTED_ARCH_REQUIRED=(hyprland waybar)
SELECTED_ARCH_RECOMMENDED=(waybar wireplumber)
SELECTED_ARCH_DEFAULT_APPS=(kitty hyprland)
SELECTED_AUR_REQUIRED=(wlogout wlogout)

arch_packages=()
aur_packages=()

# Act

build_package_plan \
  arch_packages \
  aur_packages

# Assert

assert_array_equals \
  arch_packages \
  hyprland \
  waybar \
  wireplumber \
  kitty

assert_array_equals \
  aur_packages \
  wlogout

printf 'PASS: installation plan removes duplicate packages\n'
