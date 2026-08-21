#!/usr/bin/env bash

set -euo pipefail


PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"


printf '\n==> Bash syntax\n\n'

while IFS= read -r -d '' file; do
    printf 'Checking: %s\n' "${file#"$PROJECT_ROOT/"}"

    bash -n "$file"
done < <(
    find "$PROJECT_ROOT" \
        -type f \
        -name '*.sh' \
        -not -path "$PROJECT_ROOT/.git/*" \
        -print0
)


printf '\n==> ShellCheck\n\n'

while IFS= read -r -d '' file; do
    printf 'Checking: %s\n' "${file#"$PROJECT_ROOT/"}"

    shellcheck "$file"
done < <(
    find "$PROJECT_ROOT" \
        -type f \
        -name '*.sh' \
        -not -path "$PROJECT_ROOT/.git/*" \
        -print0
)


printf '\nAll static checks passed.\n'
