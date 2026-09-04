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

# shellcheck source=setup/lib/tools/screenshot.sh
source "$PROJECT_ROOT/setup/lib/tools/screenshot.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

create_fake_command python 0

cat > "$TEST_BIN/pipx" << 'EOF'
#!/usr/bin/env bash

printf '%s\n' "$*" >> "$TEST_STATE/pipx.log"

if [[ "$*" == "environment --value PIPX_BIN_DIR" ]]; then
    printf '%s\n' "$TEST_BIN"
    exit 0
fi

if [[ "$1" == "install" ]]; then
    exit 1
fi

exit 1
EOF

chmod +x -- "$TEST_BIN/pipx"

# Act

set +e

(
    set -e
    run_screenshot_tool_setup
) > "$TEST_STATE/output.log" 2>&1

status=$?

set -e

# Assert

assert_failure \
    "$status" \
    "screenshot setup should fail when pipx installation fails"

assert_file_exists \
    "$TEST_STATE/pipx.log"

assert_file_not_exists \
    "$TEST_BIN/screenshot-tool"

printf 'PASS: pipx installation failure propagates correctly\n'
