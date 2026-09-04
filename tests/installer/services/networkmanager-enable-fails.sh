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

select_networkmanager_for_test
create_fake_sudo_for_services
create_fake_systemctl_for_system_services \
  "enable --now NetworkManager.service"

run_service_test_captured \
  "$TEST_STATE/output.log" \
  run_user_service_setup

assert_failure \
  "$SERVICE_TEST_STATUS" \
  "service stage should fail when NetworkManager cannot be enabled"

assert_service_output_contains \
  "$TEST_STATE/output.log" \
  "Failed to enable and start NetworkManager.service."

printf 'PASS: NetworkManager activation failure stops the service stage\n'
