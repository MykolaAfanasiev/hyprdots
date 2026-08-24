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

file="$PROJECT_ROOT/missing.sh"


# Act

ensure_executable "$file" \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_file_not_exists \
    "$file"

if ! grep -Fq -- \
    "Cannot set executable permission; file does not exist:" \
    "$TEST_STATE/output.log"
then
    printf 'FAIL: missing executable warning was not shown\n' >&2
    exit 1
fi


printf 'PASS: missing executable file is warned about and skipped\n'
