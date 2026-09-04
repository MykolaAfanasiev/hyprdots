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

PACKAGE_INSTALLATION_NEEDED=1

SELECTED_ARCH_REQUIRED=(hyprland waybar)
SELECTED_ARCH_RECOMMENDED=(waybar)
SELECTED_ARCH_DEFAULT_APPS=(kitty)
SELECTED_AUR_REQUIRED=(wlogout)

mock_available_commands \
    git \
    makepkg

create_fake_pacman \
    0 \
    base-devel \
    hyprland

create_fake_sudo_passthrough
create_fake_git_clone 0
create_fake_makepkg 0

mock_confirm_yes

# Act

run_package_installation \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_log_contains \
    "$TEST_STATE/sudo.log" \
    "pacman -S --needed waybar kitty"

assert_log_contains \
    "$TEST_STATE/git.log" \
    "https://aur.archlinux.org/wlogout.git"

assert_log_contains \
    "$TEST_STATE/makepkg.log" \
    "-si --needed"

assert_no_aur_build_dirs

assert_install_output_contains \
    "$TEST_STATE/output.log" \
    "Package installation complete"

printf 'PASS: full package installation stage installs Arch and AUR packages\n'
