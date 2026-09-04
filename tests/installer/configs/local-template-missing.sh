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

template="$PROJECT_ROOT/configs/hypr/modules/vars/local.lua.example"
destination="$PROJECT_ROOT/configs/hypr/modules/vars/local.lua"

mkdir -p "$(dirname -- "$destination")"

# Act

set +e

(
    set -e

    create_local_config \
        "$template" \
        "$destination" \
        "Hyprland local config"
) > "$TEST_STATE/output.log" 2>&1

status=$?

set -e

# Assert

assert_failure \
    "$status" \
    "missing local config template should cause failure"

assert_file_not_exists \
    "$destination"

if ! grep -Fq -- \
    "Local config template is not readable:" \
    "$TEST_STATE/output.log"; then
    printf 'FAIL: missing template error was not shown\n' >&2
    exit 1
fi

printf 'PASS: missing local config template causes failure\n'
