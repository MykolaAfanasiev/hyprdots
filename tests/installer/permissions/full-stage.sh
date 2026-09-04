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

root_installer="$PROJECT_ROOT/install.sh"
setup_installer="$SETUP_DIR/install.sh"
config_script="$PROJECT_ROOT/configs/example/run.sh"
runtime_script="$PROJECT_ROOT/scripts/example/tool.sh"
location_file="$PROJECT_ROOT/configs/hyprsunset/location.conf"

mkdir -p \
    "$SETUP_DIR" \
    "$(dirname -- "$config_script")" \
    "$(dirname -- "$runtime_script")" \
    "$(dirname -- "$location_file")"

printf '#!/usr/bin/env bash\n' > "$root_installer"
printf '#!/usr/bin/env bash\n' > "$setup_installer"
printf '#!/usr/bin/env bash\n' > "$config_script"
printf '#!/usr/bin/env bash\n' > "$runtime_script"

printf '%s\n' \
    'LATITUDE=48.765' \
    'LONGITUDE=11.424' \
    > "$location_file"

chmod 0644 \
    "$root_installer" \
    "$setup_installer" \
    "$config_script" \
    "$runtime_script" \
    "$location_file"

# Act

run_permission_setup

# Assert

assert_executable \
    "$root_installer"

assert_executable \
    "$setup_installer"

assert_executable \
    "$config_script"

assert_executable \
    "$runtime_script"

location_mode="$(stat -c '%a' -- "$location_file")"

assert_equals \
    "600" \
    "$location_mode" \
    "full permissions stage should secure Hyprsunset location.conf"

printf 'PASS: full permissions stage configures all required permissions\n'
