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

printf 'important data\n' \
    > "$default_path/original.txt"


# Act

configure_runtime_directory \
    "Wallpapers" \
    "$default_path" \
    <<< $'c\n'"$custom_path"$'\ny'


# Assert

assert_symlink_to \
    "$default_path" \
    "$custom_path"


shopt -s nullglob
backups=("$default_path".backup.*)
shopt -u nullglob


assert_equals \
    "1" \
    "${#backups[@]}" \
    "exactly one backup should be created"


backup_path="${backups[0]}"

assert_directory_exists \
    "$backup_path"

assert_file_exists \
    "$backup_path/original.txt"

actual_content="$(cat "$backup_path/original.txt")"

assert_equals \
    "important data" \
    "$actual_content" \
    "backup should preserve existing user data"


printf 'PASS: existing default directory is backed up and replaced with symlink\n'
