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
create_fake_systemctl_for_services

run_user_service_setup > "$TEST_STATE/output.log" 2>&1

assert_systemctl_log_contains "--user daemon-reload"
assert_systemctl_log_contains "--user enable mpd.service"
assert_systemctl_log_contains "--user restart mpd.service"
assert_systemctl_log_contains "--user is-active --quiet mpd.service"

assert_service_output_contains \
    "$TEST_STATE/output.log" \
    "MPD user service is enabled and running"

printf 'PASS: automatic deployment enables and starts MPD\n'
