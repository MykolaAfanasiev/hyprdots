#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/user-services.sh
source "$REPO_ROOT/tests/lib/user-services.sh"

setup_user_service_test
trap destroy_test_sandbox EXIT

create_deployed_mouseless_files
create_fake_systemctl_for_services

run_user_service_setup >"$TEST_STATE/output.log" 2>&1

assert_systemctl_log_contains "--user enable mouseless.service"
assert_systemctl_log_contains "--user restart mouseless.service"
assert_systemctl_log_contains "--user is-active --quiet mouseless.service"

assert_service_output_contains \
  "$TEST_STATE/output.log" \
  "Mouseless user service is enabled and running"

printf 'PASS: automatic deployment enables and starts Mouseless\n'
