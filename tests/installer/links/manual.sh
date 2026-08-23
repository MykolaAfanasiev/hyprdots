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

run_config_link_setup <<< "m" \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_file_not_exists \
    "$TEST_STATE/stow.log"

assert_file_not_exists \
    "$HOME/.config/hypr"


expected_command="stow --restow --dir=\"$PROJECT_ROOT\" --target=\"$HOME/.config\" configs"

if ! grep -Fq -- \
    "$expected_command" \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: manual Stow command was not shown correctly\n' >&2
    printf '  expected: %s\n' "$expected_command" >&2
    exit 1
fi


printf 'PASS: manual deployment leaves configs unchanged and shows Stow command\n'
