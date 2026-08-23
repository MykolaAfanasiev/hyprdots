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

PIPX_BIN_DIR="$TEST_ROOT/pipx-bin"
mkdir -p "$PIPX_BIN_DIR"


cat > "$PIPX_BIN_DIR/screenshot-tool" <<'EOF'
#!/usr/bin/env bash

exit 0
EOF

chmod +x -- "$PIPX_BIN_DIR/screenshot-tool"


cat > "$TEST_BIN/pipx" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/pipx.log"

if [[ "\$*" == "environment --value PIPX_BIN_DIR" ]]; then
    printf '%s\n' "$PIPX_BIN_DIR"
    exit 0
fi

exit 1
EOF

chmod +x -- "$TEST_BIN/pipx"


# Act

run_screenshot_tool_setup


# Assert

assert_file_exists \
    "$PIPX_BIN_DIR/screenshot-tool"

assert_executable \
    "$PIPX_BIN_DIR/screenshot-tool"

assert_file_exists \
    "$TEST_STATE/pipx.log"

assert_equals \
    "environment --value PIPX_BIN_DIR" \
    "$(cat "$TEST_STATE/pipx.log")" \
    "pipx install should not run when screenshot-tool already exists in PIPX_BIN_DIR"


printf 'PASS: screenshot-tool in PIPX_BIN_DIR skips reinstall\n'
