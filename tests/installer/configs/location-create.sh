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

configure_hyprsunset_location <<< $'y\n48.765\n11.424'


# Assert

assert_file_exists \
    "$destination"

expected_content=$'LATITUDE=48.765\nLONGITUDE=11.424'
actual_content="$(cat "$destination")"

assert_equals \
    "$expected_content" \
    "$actual_content" \
    "Hyprsunset coordinates were written incorrectly"

actual_mode="$(stat -c '%a' -- "$destination")"

assert_equals \
    "600" \
    "$actual_mode" \
    "Hyprsunset location config should have mode 600"


printf 'PASS: Hyprsunset location config is created correctly\n'
