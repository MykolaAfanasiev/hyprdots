#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
        pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$PROJECT_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$PROJECT_ROOT/tests/lib/assertions.sh"

# shellcheck source=tests/lib/fake-command.sh
source "$PROJECT_ROOT/tests/lib/fake-command.sh"

# shellcheck source=setup/lib/common.sh
source "$PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/links/config.sh
source "$PROJECT_ROOT/setup/lib/links/config.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

create_fake_command stow 0

# Act

run_config_link_setup <<< "a"

# Assert

assert_directory_exists \
    "$HOME/.config"

assert_file_exists \
    "$TEST_STATE/stow.log"

expected_args="$(printf '%s\n%s' \
    "--restow --dir=$PROJECT_ROOT --target=$HOME/.config configs" \
    "--restow --dir=$PROJECT_ROOT --target=$HOME home")"

actual_args="$(cat "$TEST_STATE/stow.log")"

assert_equals \
    "$expected_args" \
    "$actual_args" \
    "GNU Stow should be called with the expected arguments"

printf 'PASS: automatic deployment stows config and home packages correctly\n'
