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


cat > "$TEST_BIN/pipx" <<'EOF'
#!/usr/bin/env bash

printf '%s\n' "$*" >> "$TEST_STATE/pipx.log"


if [[ "$1" == "environment" ]]; then
    printf '%s\n' "$TEST_BIN"
    exit 0
fi


if [[ "$1" == "install" ]]; then
    cat > "$TEST_BIN/screenshot-tool" <<'INNER_EOF'
#!/usr/bin/env bash

printf '%s\n' "$*" >> "$TEST_STATE/screenshot-tool.log"

exit 0
INNER_EOF

    chmod +x -- "$TEST_BIN/screenshot-tool"

    exit 0
fi


exit 1
EOF

chmod +x -- "$TEST_BIN/pipx"


# Act

run_screenshot_tool_setup


# Assert

assert_file_exists \
    "$TEST_STATE/pipx.log"

assert_file_exists \
    "$TEST_BIN/screenshot-tool"

assert_executable \
    "$TEST_BIN/screenshot-tool"

assert_file_exists \
    "$TEST_STATE/screenshot-tool.log"

assert_equals \
    "--help" \
    "$(cat "$TEST_STATE/screenshot-tool.log")" \
    "installed screenshot-tool should be verified with --help"

expected_pipx_log="$(
    printf '%s\n%s\n' \
        "environment --value PIPX_BIN_DIR" \
        "install --editable $PROJECT_ROOT/scripts/screenshot"
)"

actual_pipx_log="$(cat "$TEST_STATE/pipx.log")"


assert_equals \
    "$expected_pipx_log" \
    "$actual_pipx_log" \
    "pipx should query its bin directory and install screenshot-tool in editable mode"

printf 'PASS: missing screenshot-tool is installed with pipx\n'
