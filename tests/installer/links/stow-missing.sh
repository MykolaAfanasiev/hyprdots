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

# shellcheck source=setup/lib/common.sh
source "$PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/links/config.sh
source "$PROJECT_ROOT/setup/lib/links/config.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

command_exists() {
  local command_name="$1"

  if [[ "$command_name" == "stow" ]]; then
    return 1
  fi

  command -v "$command_name" >/dev/null 2>&1
}

# Act

set +e

(
  set -e
  run_config_link_setup <<<"a"
) >"$TEST_STATE/output.log" 2>&1

status=$?

set -e

# Assert

assert_failure \
  "$status" \
  "automatic configuration deployment should fail when GNU Stow is missing"

if ! grep -Fq -- \
  "GNU Stow is not installed." \
  "$TEST_STATE/output.log"; then
  printf 'FAIL: expected GNU Stow error message was not shown\n' >&2
  exit 1
fi

printf 'PASS: missing GNU Stow causes automatic deployment to fail\n'
