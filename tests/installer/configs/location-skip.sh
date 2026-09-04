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

configure_hyprsunset_location <<< "" \
    > "$TEST_STATE/output.log" 2>&1

# Assert

assert_file_not_exists \
    "$destination"

if ! grep -Fq -- \
    "Skipping Hyprsunset location configuration" \
    "$TEST_STATE/output.log"; then
    printf 'FAIL: location skip message was not shown\n' >&2
    exit 1
fi

printf 'PASS: Hyprsunset location configuration can be skipped\n'
