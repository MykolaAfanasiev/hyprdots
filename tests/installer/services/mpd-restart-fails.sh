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

select_mpd_for_test
create_deployed_mpd_files
create_fake_systemctl_for_services restart

run_service_test_captured \
    "$TEST_STATE/output.log" \
    run_user_service_setup

assert_failure \
    "$SERVICE_TEST_STATUS" \
    "service stage should fail when MPD cannot start"

assert_service_output_contains \
    "$TEST_STATE/output.log" \
    "Failed to start mpd.service."

printf 'PASS: MPD startup failure stops the service stage\n'
