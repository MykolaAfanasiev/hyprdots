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

mkdir -p -- "$PROJECT_ROOT"


# Act

ensure_runtime_scripts_executable \
    > "$TEST_STATE/output.log" 2>&1


# Assert

warning_count="$(
    grep -Fc -- \
        "Runtime directory does not exist:" \
        "$TEST_STATE/output.log"
)"

assert_equals \
    "2" \
    "$warning_count" \
    "missing configs and scripts directories should each produce a warning"


printf 'PASS: missing runtime directories are warned about and skipped\n'
