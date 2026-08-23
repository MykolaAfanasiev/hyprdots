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

# shellcheck source=tests/lib/fake-command.sh
source "$PROJECT_ROOT/tests/lib/fake-command.sh"

# shellcheck source=setup/lib/common.sh
source "$PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/links/config.sh
source "$PROJECT_ROOT/setup/lib/links/config.sh"


# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

create_fake_command stow 0


# Act

run_config_link_setup <<< $'invalid\na' \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_file_exists \
    "$TEST_STATE/stow.log"

expected_args="--restow --dir=$PROJECT_ROOT --target=$HOME/.config configs"
actual_args="$(cat "$TEST_STATE/stow.log")"

assert_equals \
    "$expected_args" \
    "$actual_args" \
    "automatic deployment should run after a valid retry"


if ! grep -Fq -- \
    "Choose A or M." \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: invalid selection warning was not shown\n' >&2
    exit 1
fi


printf 'PASS: invalid selection is rejected and retried\n'
