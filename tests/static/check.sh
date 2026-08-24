#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

cd -- "$PROJECT_ROOT"


# ------------------------------------------------------------
# Parallelism
# ------------------------------------------------------------

if [[ -n "${HYPRDOTS_STATIC_JOBS:-}" ]]; then
    JOBS="$HYPRDOTS_STATIC_JOBS"
else
    if command -v nproc >/dev/null 2>&1; then
        JOBS="$(nproc)"
    else
        JOBS=4
    fi

    if (( JOBS > 8 )); then
        JOBS=8
    fi
fi

if [[ ! "$JOBS" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Invalid HYPRDOTS_STATIC_JOBS value: %s\n' "$JOBS" >&2
    exit 1
fi


# ------------------------------------------------------------
# Discover shell files
# ------------------------------------------------------------

mapfile -d '' SHELL_FILES < <(
    find "$PROJECT_ROOT" \
        -type f \
        -name '*.sh' \
        -not -path "$PROJECT_ROOT/.git/*" \
        -print0 |
    sort -z
)

if (( ${#SHELL_FILES[@]} == 0 )); then
    printf 'No shell files found.\n' >&2
    exit 1
fi


printf '\n==> ShellCheck version\n\n'

shellcheck --version


printf '\n==> Bash syntax (%s parallel jobs)\n\n' "$JOBS"

for file in "${SHELL_FILES[@]}"; do
    printf 'Checking: %s\n' "${file#"$PROJECT_ROOT/"}"
done

printf '%s\0' "${SHELL_FILES[@]}" |
    xargs \
        -0 \
        -r \
        -n 1 \
        -P "$JOBS" \
        bash -n


printf '\n==> ShellCheck (%s parallel jobs)\n\n' "$JOBS"

for file in "${SHELL_FILES[@]}"; do
    printf 'Checking: %s\n' "${file#"$PROJECT_ROOT/"}"
done

printf '%s\0' "${SHELL_FILES[@]}" |
    xargs \
        -0 \
        -r \
        -n 1 \
        -P "$JOBS" \
        shellcheck -x


printf '\nAll static checks passed.\n'
