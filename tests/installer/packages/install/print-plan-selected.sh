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

arch_packages=(hyprland waybar)
aur_packages=(wlogout)


# Act

print_install_plan \
    arch_packages \
    aur_packages \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_install_output_contains \
    "$TEST_STATE/output.log" \
    "Official Arch packages:"

assert_install_output_contains \
    "$TEST_STATE/output.log" \
    "AUR packages:"

for package in \
    hyprland \
    waybar \
    wlogout
do
    assert_install_output_contains \
        "$TEST_STATE/output.log" \
        "  - $package"
done

printf 'PASS: installation plan displays selected packages\n'
