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

mkdir -p -- "$default_path"

before_inode="$(stat -c '%i' -- "$default_path")"

# Act

configure_runtime_directory \
    "Wallpapers" \
    "$default_path" \
    <<< $'c\n'"$default_path" \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_directory_exists \
    "$default_path"

if [[ -L "$default_path" ]]; then
    printf 'FAIL: default runtime directory should not link to itself\n' >&2
    exit 1
fi

after_inode="$(stat -c '%i' -- "$default_path")"

assert_equals \
    "$before_inode" \
    "$after_inode" \
    "custom path equal to default should leave default directory unchanged"

if ! grep -Fq -- \
    "Wallpapers directory: $default_path" \
    "$TEST_STATE/output.log"; then
    printf 'FAIL: custom path equal to default was not recognized\n' >&2
    exit 1
fi

printf 'PASS: custom path equal to default uses the normal default directory\n'
