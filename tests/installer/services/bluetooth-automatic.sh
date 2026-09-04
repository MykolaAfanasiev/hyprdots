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

select_bluetooth_for_test
create_fake_sudo_for_services
create_fake_systemctl_for_system_services

run_user_service_setup >"$TEST_STATE/output.log" 2>&1

assert_sudo_log_contains \
  "systemctl enable --now bluetooth.service"

assert_systemctl_log_contains \
  "enable --now bluetooth.service"

assert_systemctl_log_contains \
  "is-active --quiet bluetooth.service"

assert_service_output_contains \
  "$TEST_STATE/output.log" \
  "Bluetooth service is enabled and running"

printf 'PASS: selected Bluetooth stack is enabled and started\n'
