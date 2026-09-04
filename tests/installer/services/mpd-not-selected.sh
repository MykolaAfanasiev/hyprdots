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

run_user_service_setup > "$TEST_STATE/output.log" 2>&1

assert_file_not_exists "$TEST_STATE/systemctl.log"
assert_service_output_contains \
    "$TEST_STATE/output.log" \
    "MPD was not selected"

printf 'PASS: unselected MPD is not activated\n'
