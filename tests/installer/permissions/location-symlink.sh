#!/usr/bin/env bash

set -euo pipefail


REAL_PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"


# shellcheck source=tests/lib/sandbox.sh
source "$REAL_PROJECT_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$REAL_PROJECT_ROOT/tests/lib/assertions.sh"

# shellcheck source=setup/lib/common.sh
source "$REAL_PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/permissions/runtime.sh
source "$REAL_PROJECT_ROOT/setup/lib/permissions/runtime.sh"


# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

PROJECT_ROOT="$TEST_ROOT/project"

location_file="$PROJECT_ROOT/configs/hyprsunset/location.conf"
target_file="$TEST_ROOT/external-location.conf"

mkdir -p -- "$(dirname -- "$location_file")"

printf '%s\n' \
    'LATITUDE=48.765' \
    'LONGITUDE=11.424' \
    > "$target_file"

chmod 0644 -- "$target_file"

ln -s \
    "$target_file" \
    "$location_file"


# Act

secure_hyprsunset_location \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_symlink_to \
    "$location_file" \
    "$target_file"

target_mode="$(stat -c '%a' -- "$target_file")"

assert_equals \
    "644" \
    "$target_mode" \
    "Hyprsunset symlink target permissions should not be changed"

if ! grep -Fq -- \
    "Hyprsunset location.conf is a symlink; permissions were not changed" \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: Hyprsunset symlink warning was not shown\n' >&2
    exit 1
fi


printf 'PASS: Hyprsunset location symlink is detected and left unchanged\n'
