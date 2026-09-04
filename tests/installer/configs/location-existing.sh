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

# shellcheck source=setup/lib/configs/local.sh
source "$REAL_PROJECT_ROOT/setup/lib/configs/local.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

PROJECT_ROOT="$TEST_ROOT/project"

destination="$PROJECT_ROOT/configs/hyprsunset/location.conf"

mkdir -p "$(dirname -- "$destination")"

printf '%s\n' \
    'LATITUDE=10.123' \
    'LONGITUDE=20.456' \
    > "$destination"

before_content="$(cat "$destination")"
before_inode="$(stat -c '%i' -- "$destination")"

# Act

configure_hyprsunset_location

# Assert

after_content="$(cat "$destination")"
after_inode="$(stat -c '%i' -- "$destination")"

assert_equals \
    "$before_content" \
    "$after_content" \
    "existing Hyprsunset location should not be overwritten"

assert_equals \
    "$before_inode" \
    "$after_inode" \
    "existing Hyprsunset location should not be recreated"

printf 'PASS: existing Hyprsunset location config is left unchanged\n'
