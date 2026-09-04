#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

TEST_DIR="$PROJECT_ROOT/tests/installer"

if [[ -n "${HYPRDOTS_TEST_JOBS:-}" ]]; then
  JOBS="$HYPRDOTS_TEST_JOBS"
else
  if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
  else
    JOBS=4
  fi

  # More than 8 parallel shell tests normally gives little benefit
  # while creating unnecessary CPU and filesystem contention.
  if ((JOBS > 8)); then
    JOBS=8
  fi
fi

if [[ ! "$JOBS" =~ ^[1-9][0-9]*$ ]]; then
  printf 'Invalid HYPRDOTS_TEST_JOBS value: %s\n' "$JOBS" >&2
  exit 1
fi

mapfile -d '' TESTS < <(
  find "$TEST_DIR" \
    -type f \
    -name '*.sh' \
    ! -name 'run.sh' \
    -print0 |
    sort -z
)

if ((${#TESTS[@]} == 0)); then
  printf 'No installer tests found.\n' >&2
  exit 1
fi

TEST_RUN_ROOT="$(
  mktemp -d \
    "${TMPDIR:-/tmp}/hyprdots-test-run.XXXXXX"
)"

cleanup_test_runner() {
  rm -rf -- "$TEST_RUN_ROOT"
}

trap cleanup_test_runner EXIT

run_one_test() {
  local index="$1"
  local test="$2"

  local log_file="$TEST_RUN_ROOT/$index.log"
  local status_file="$TEST_RUN_ROOT/$index.status"
  local status

  if bash "$test" >"$log_file" 2>&1; then
    status=0
  else
    status=$?
  fi

  printf '%s\n' "$status" >"$status_file"
}

export TEST_RUN_ROOT
export -f run_one_test

declare -a TASK_ARGUMENTS=()

for index in "${!TESTS[@]}"; do
  TASK_ARGUMENTS+=(
    "$index"
    "${TESTS[$index]}"
  )
done

printf '\n==> Installer tests (%s parallel jobs)\n\n' "$JOBS"
# $1 and $2 are intentionally expanded by the child bash process.
# shellcheck disable=SC2016
printf '%s\0' "${TASK_ARGUMENTS[@]}" |
  xargs \
    -0 \
    -r \
    -n 2 \
    -P "$JOBS" \
    bash -c 'run_one_test "$1" "$2"' _

failed=0

for index in "${!TESTS[@]}"; do
  test="${TESTS[$index]}"
  log_file="$TEST_RUN_ROOT/$index.log"
  status_file="$TEST_RUN_ROOT/$index.status"

  printf 'Running: %s\n' "${test#"$PROJECT_ROOT/"}"

  if [[ -f "$log_file" ]]; then
    cat -- "$log_file"
  fi

  if [[ ! -f "$status_file" ]]; then
    printf 'FAIL: test did not produce an exit status\n'
    failed=1
    printf '\n'
    continue
  fi

  status="$(<"$status_file")"

  if ((status != 0)); then
    printf 'FAIL: test exited with status %s\n' "$status"

    FAILED_TESTS+=(
      "${test#"$PROJECT_ROOT/"}"
    )

    failed=1
  fi
  printf '\n'
done

if ((failed != 0)); then
  printf '\nFailed tests:\n' >&2

  for test in "${FAILED_TESTS[@]}"; do
    printf '  - %s\n' "$test" >&2
  done

  printf '\nInstaller tests failed.\n' >&2
  exit 1
fi

printf 'All installer tests passed.\n'
