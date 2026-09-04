#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_TEST_ASSERTIONS_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_ASSERTIONS_LOADED=1

assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-Values are not equal}"

  if [[ "$expected" == "$actual" ]]; then
    return 0
  fi

  printf 'FAIL: %s\n' "$message" >&2
  printf '  expected: %s\n' "$expected" >&2
  printf '  actual:   %s\n' "$actual" >&2

  return 1
}

assert_file_exists() {
  local path="$1"

  if [[ -f "$path" ]]; then
    return 0
  fi

  printf 'FAIL: expected file does not exist:\n' >&2
  printf '  %s\n' "$path" >&2

  return 1
}

assert_file_not_exists() {
  local path="$1"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    return 0
  fi

  printf 'FAIL: path should not exist:\n' >&2
  printf '  %s\n' "$path" >&2

  return 1
}

assert_directory_exists() {
  local path="$1"

  if [[ -d "$path" ]]; then
    return 0
  fi

  printf 'FAIL: expected directory does not exist:\n' >&2
  printf '  %s\n' "$path" >&2

  return 1
}

assert_symlink_to() {
  local link="$1"
  local expected_target="$2"

  if [[ ! -L "$link" ]]; then
    printf 'FAIL: expected symlink does not exist:\n' >&2
    printf '  %s\n' "$link" >&2
    return 1
  fi

  local actual_target
  local resolved_expected

  actual_target="$(readlink -f -- "$link")"
  resolved_expected="$(readlink -f -- "$expected_target")"

  if [[ "$actual_target" == "$resolved_expected" ]]; then
    return 0
  fi

  printf 'FAIL: symlink points to the wrong target:\n' >&2
  printf '  link:     %s\n' "$link" >&2
  printf '  expected: %s\n' "$resolved_expected" >&2
  printf '  actual:   %s\n' "$actual_target" >&2

  return 1
}

assert_executable() {
  local path="$1"

  if [[ -x "$path" ]]; then
    return 0
  fi

  printf 'FAIL: expected executable:\n' >&2
  printf '  %s\n' "$path" >&2

  return 1
}

assert_failure() {
  local status="$1"
  local message="${2:-Expected command to fail}"

  if ((status != 0)); then
    return 0
  fi

  printf 'FAIL: %s\n' "$message" >&2
  printf '  exit status: %s\n' "$status" >&2

  return 1
}
