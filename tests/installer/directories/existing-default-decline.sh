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

mkdir -p \
    "$default_path" \
    "$custom_path"

printf 'keep me\n' > "$default_path/original.txt"

before_inode="$(stat -c '%i' -- "$default_path")"

# Act

configure_runtime_directory \
    "Wallpapers" \
    "$default_path" \
    <<< $'c\n'"$custom_path"$'\nn'

# Assert

assert_directory_exists \
    "$default_path"

assert_file_exists \
    "$default_path/original.txt"

after_inode="$(stat -c '%i' -- "$default_path")"

assert_equals \
    "$before_inode" \
    "$after_inode" \
    "declined replacement should leave default directory unchanged"

if [[ -L "$default_path" ]]; then
    printf 'FAIL: declined replacement should not create a symlink\n' >&2
    exit 1
fi

printf 'PASS: existing default directory is preserved when replacement is declined\n'
