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
  hyprland

create_fake_sudo_passthrough

# Act

install_arch_packages \
  hyprland \
  waybar \
  kitty \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_log_contains \
  "$TEST_STATE/sudo.log" \
  "pacman -S --needed waybar kitty"

assert_install_output_contains \
  "$TEST_STATE/output.log" \
  "Official Arch packages installed"

printf 'PASS: only missing Arch packages are installed\n'
