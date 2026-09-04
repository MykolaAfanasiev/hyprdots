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

config_script="$PROJECT_ROOT/configs/example/scripts/run.sh"
runtime_script="$PROJECT_ROOT/scripts/example/tool.sh"
non_shell_file="$PROJECT_ROOT/configs/example/config.lua"

mkdir -p \
    "$(dirname -- "$config_script")" \
    "$(dirname -- "$runtime_script")"

printf '#!/usr/bin/env bash\n' > "$config_script"
printf '#!/usr/bin/env bash\n' > "$runtime_script"
printf 'return {}\n' > "$non_shell_file"

chmod 0644 \
    "$config_script" \
    "$runtime_script" \
    "$non_shell_file"

# Act

ensure_runtime_scripts_executable

# Assert

assert_executable \
    "$config_script"

assert_executable \
    "$runtime_script"

non_shell_mode="$(stat -c '%a' -- "$non_shell_file")"

assert_equals \
    "644" \
    "$non_shell_mode" \
    "non-shell runtime files should not have permissions changed"

printf 'PASS: runtime shell scripts are executable and non-shell files are untouched\n'
