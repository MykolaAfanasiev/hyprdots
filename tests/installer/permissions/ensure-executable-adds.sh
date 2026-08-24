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

file="$PROJECT_ROOT/test.sh"

mkdir -p -- "$PROJECT_ROOT"

printf '#!/usr/bin/env bash\n' > "$file"
chmod 0644 -- "$file"


# Act

ensure_executable "$file"


# Assert

assert_executable \
    "$file"

actual_mode="$(stat -c '%a' -- "$file")"

assert_equals \
    "744" \
    "$actual_mode" \
    "ensure_executable should add only the user execute bit"


printf 'PASS: non-executable file receives user execute permission\n'
