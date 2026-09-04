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

declined_path="$TEST_ROOT/declined-wallpapers"
fallback_path="$TEST_ROOT/existing-wallpapers"

mkdir -p "$fallback_path"

# Act

configure_runtime_directory \
  "Wallpapers" \
  "$default_path" \
  <<<$'c\n'"$declined_path"$'\nn\n'"$fallback_path"

# Assert

assert_file_not_exists \
  "$declined_path"

assert_directory_exists \
  "$fallback_path"

assert_symlink_to \
  "$default_path" \
  "$fallback_path"

printf 'PASS: declined custom directory creation retries with another path\n'
