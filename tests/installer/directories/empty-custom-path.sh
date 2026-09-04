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

mkdir -p -- "$custom_path"

# Act

configure_runtime_directory \
    "Wallpapers" \
    "$default_path" \
    <<< $'c\n\n'"$custom_path" \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_symlink_to \
    "$default_path" \
    "$custom_path"

if ! grep -Fq -- \
    "Directory path cannot be empty." \
    "$TEST_STATE/output.log"; then
    printf 'FAIL: empty directory path warning was not shown\n' >&2
    exit 1
fi

printf 'PASS: empty custom directory path is rejected and retried\n'
