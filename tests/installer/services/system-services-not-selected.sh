#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/system-services.sh
source "$REPO_ROOT/tests/lib/system-services.sh"

setup_user_service_test
trap destroy_test_sandbox EXIT

create_fake_sudo_for_services
create_fake_systemctl_for_system_services

run_user_service_setup >"$TEST_STATE/output.log" 2>&1

assert_file_not_exists "$TEST_STATE/sudo.log"
assert_file_not_exists "$TEST_STATE/systemctl.log"

assert_service_output_contains \
  "$TEST_STATE/output.log" \
  "NetworkManager was not selected"

assert_service_output_contains \
  "$TEST_STATE/output.log" \
  "Bluetooth was not selected"

printf 'PASS: unselected system services are not activated\n'
