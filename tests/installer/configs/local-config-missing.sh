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

mkdir -p "$(dirname -- "$template")"

printf '%s\n' \
    'return {' \
    '    test = true,' \
    '}' \
    > "$template"


# Act

create_local_config \
    "$template" \
    "$destination" \
    "Hyprland local config"


# Assert

assert_file_exists \
    "$destination"

expected_content="$(cat "$template")"
actual_content="$(cat "$destination")"

assert_equals \
    "$expected_content" \
    "$actual_content" \
    "local.lua should be copied from the example template"


printf 'PASS: missing Hyprland local config is created from template\n'
