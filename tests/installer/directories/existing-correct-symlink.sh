#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$PROJECT_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$PROJECT_ROOT/tests/lib/assertions.sh"

# shellcheck source=setup/lib/common.sh
source "$PROJECT_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/filesystem.sh
source "$PROJECT_ROOT/setup/lib/filesystem.sh"

# shellcheck source=setup/lib/directories/runtime.sh
source "$PROJECT_ROOT/setup/lib/directories/runtime.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

default_path="$HOME/.wallpapers"
custom_path="$TEST_ROOT/custom-wallpapers"

mkdir -p "$custom_path"

ln -s \
  "$custom_path" \
  "$default_path"

before_inode="$(stat -c '%i' -- "$default_path")"

# Act

configure_runtime_directory \
  "Wallpapers" \
  "$default_path" \
  <<<$'c\n'"$custom_path" \
  >"$TEST_STATE/output.log" 2>&1

assert_symlink_to \
  "$default_path" \
  "$custom_path"

after_inode="$(stat -c '%i' -- "$default_path")"

assert_equals \
  "$before_inode" \
  "$after_inode" \
  "correct runtime directory symlink should be left unchanged"

if grep -Fq -- \
  "default path already exists" \
  "$TEST_STATE/output.log"; then
  printf 'FAIL: correct symlink was treated as a conflict\n' >&2
  exit 1
fi

if ! grep -Fq -- \
  "Wallpapers is already linked to: $custom_path" \
  "$TEST_STATE/output.log"; then
  printf 'FAIL: existing correct symlink was not detected\n' >&2
  exit 1
fi

printf 'PASS: existing correct runtime directory symlink is detected and left unchanged\n'
