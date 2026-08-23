#!/usr/bin/env bash

set -euo pipefail


PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

TEST_DIR="$PROJECT_ROOT/tests/installer/"


printf '\n==> Installer tests\n\n'

while IFS= read -r -d '' test; do
    printf 'Running: %s\n' "${test#"$PROJECT_ROOT/"}"

    bash "$test"

    printf '\n'
done < <(
    find "$TEST_DIR" \
        -type f \
        -name '*.sh' \
        ! -name 'run.sh' \
        -print0
)


printf 'All installer tests passed.\n'
