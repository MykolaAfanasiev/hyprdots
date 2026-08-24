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

write_test_os_release \
    endeavouros \
    "arch" \
    "EndeavourOS"

use_test_os_release


# Act

check_arch_linux \
    > "$TEST_STATE/output.log" 2>&1


# Assert

assert_output_contains \
    "$TEST_STATE/output.log" \
    "Arch-based distribution detected: EndeavourOS"

assert_output_contains \
    "$TEST_STATE/output.log" \
    "The installer is primarily tested on Arch Linux."


printf 'PASS: Arch-based distribution is accepted with warning\n'
