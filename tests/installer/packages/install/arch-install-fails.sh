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

create_fake_pacman 1
create_fake_sudo_passthrough


# Act

run_install_test_captured \
    "$TEST_STATE/output.log" \
    install_arch_packages \
    hyprland


# Assert

assert_failure \
    "$INSTALL_TEST_STATUS" \
    "failed pacman installation should propagate"

assert_log_contains \
    "$TEST_STATE/sudo.log" \
    "pacman -S --needed hyprland"

printf 'PASS: pacman installation failure propagates\n'
