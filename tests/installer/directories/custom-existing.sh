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

# shellcheck source=setup/lib/common.sh
source "$PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/filesystem.sh
source "$PROJECT_ROOT/setup/lib/filesystem.sh"

# shellcheck source=setup/lib/directories/runtime.sh
source "$PROJECT_ROOT/setup/lib/directories/runtime.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

default_path="$HOME/.wallpapers"
custom_path="$TEST_ROOT/custom-wallpapers"

mkdir -p "$custom_path"

# Act

configure_runtime_directory \
    "Wallpapers" \
    "$default_path" \
    <<< $'c\n'"$custom_path"

# Assert

assert_directory_exists \
    "$custom_path"

assert_symlink_to \
    "$default_path" \
    "$custom_path"

printf 'PASS: existing custom runtime directory is linked correctly\n'
