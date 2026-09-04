#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/system-checks.sh
source "$REPO_ROOT/tests/lib/system-checks.sh"

# Arrange

setup_system_checks_test
trap destroy_test_sandbox EXIT

mock_effective_uid 1000
mock_bash_major_version 5
mock_home_writable 1

write_test_os_release \
  arch \
  "" \
  "Arch Linux"

use_test_os_release

create_fake_command pacman 0
create_fake_sudo 0 1

create_valid_repository

# Act

run_system_checks \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_output_contains \
  "$TEST_STATE/output.log" \
  "[1/11] System check"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Running as user: test-user"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Operating system: Arch Linux"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "Repository structure looks valid"

assert_output_contains \
  "$TEST_STATE/output.log" \
  "System check passed"

printf 'PASS: full system check stage succeeds in a valid environment\n'
