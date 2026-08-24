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


# Act

configure_hyprsunset_location \
    <<< $'y\nabc\n48.765\nhello\n11.424' \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_file_exists \
    "$destination"

expected_content=$'LATITUDE=48.765\nLONGITUDE=11.424'
actual_content="$(cat "$destination")"

assert_equals \
    "$expected_content" \
    "$actual_content" \
    "valid coordinates should be accepted after invalid input"

if ! grep -Fq -- \
    "Latitude must be a number" \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: invalid latitude warning was not shown\n' >&2
    exit 1
fi

if ! grep -Fq -- \
    "Longitude must be a number" \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: invalid longitude warning was not shown\n' >&2
    exit 1
fi

actual_mode="$(stat -c '%a' -- "$destination")"

assert_equals \
    "600" \
    "$actual_mode" \
    "Hyprsunset location config should have mode 600"


printf 'PASS: invalid coordinates are rejected and retried\n'
