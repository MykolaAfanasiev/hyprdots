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
SETUP_DIR="$PROJECT_ROOT/setup"

mkdir -p -- "$SETUP_DIR"

printf '#!/usr/bin/env bash\n' > "$PROJECT_ROOT/install.sh"
printf '#!/usr/bin/env bash\n' > "$SETUP_DIR/install.sh"

chmod 0644 \
    "$PROJECT_ROOT/install.sh" \
    "$SETUP_DIR/install.sh"


# Act

ensure_installer_entrypoints_executable


# Assert

assert_executable \
    "$PROJECT_ROOT/install.sh"

assert_executable \
    "$SETUP_DIR/install.sh"


printf 'PASS: installer entrypoints are made executable\n'
