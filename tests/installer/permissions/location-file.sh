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

mkdir -p -- "$(dirname -- "$location_file")"

printf '%s\n' \
    'LATITUDE=48.765' \
    'LONGITUDE=11.424' \
    > "$location_file"

chmod 0644 -- "$location_file"

# Act

secure_hyprsunset_location

# Assert

actual_mode="$(stat -c '%a' -- "$location_file")"

assert_equals \
    "600" \
    "$actual_mode" \
    "Hyprsunset location.conf should be restricted to mode 600"

printf 'PASS: Hyprsunset location file is secured to mode 600\n'
