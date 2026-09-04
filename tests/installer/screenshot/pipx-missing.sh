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

command_exists() {
  local command_name="$1"

  if [[ "$command_name" == "pipx" ]]; then
    return 1
  fi

  command -v "$command_name" >/dev/null 2>&1
}

# Act

run_screenshot_tool_setup

# Assert

assert_file_not_exists \
  "$TEST_BIN/screenshot-tool"

printf 'PASS: missing pipx skips screenshot-tool installation\n'
