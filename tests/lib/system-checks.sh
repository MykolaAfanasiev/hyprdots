#!/usr/bin/env bash

# This file provides test helpers and dynamically overrides functions from
# setup/lib/checks.sh. The overridden functions and shared test state are
# shellcheck disable=SC2034,SC2329

if [[ -n "${HYPRDOTS_TEST_SYSTEM_CHECKS_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_SYSTEM_CHECKS_LOADED=1

HYPRDOTS_TEST_REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/assertions.sh"

# shellcheck source=tests/lib/fake-command.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/fake-command.sh"

# shellcheck source=setup/lib/common.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/checks.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/checks.sh"

setup_system_checks_test() {
  create_test_sandbox

  PROJECT_ROOT="$TEST_ROOT/project"
  SETUP_DIR="$PROJECT_ROOT/setup"

  TEST_OS_RELEASE="$TEST_STATE/os-release"

  USER="test-user"

  export PROJECT_ROOT
  export SETUP_DIR
  export TEST_OS_RELEASE
  export USER
}

create_valid_repository() {
  mkdir -p -- \
    "$PROJECT_ROOT/configs" \
    "$PROJECT_ROOT/home" \
    "$PROJECT_ROOT/scripts" \
    "$SETUP_DIR/packages"
}

write_test_os_release() {
  local id="$1"
  local id_like="${2:-}"
  local pretty_name="${3:-Test Linux}"

  cat >"$TEST_OS_RELEASE" <<EOF_OS
ID=$id
ID_LIKE="$id_like"
PRETTY_NAME="$pretty_name"
EOF_OS
}

use_test_os_release() {
  get_os_release_path() {
    printf '%s\n' "$TEST_OS_RELEASE"
  }
}

mock_effective_uid() {
  TEST_EFFECTIVE_UID="$1"

  get_effective_uid() {
    printf '%s\n' "$TEST_EFFECTIVE_UID"
  }
}

mock_bash_major_version() {
  TEST_BASH_MAJOR="$1"

  get_bash_major_version() {
    printf '%s\n' "$TEST_BASH_MAJOR"
  }
}

mock_home_writable() {
  TEST_HOME_WRITABLE="$1"

  is_directory_writable() {
    ((TEST_HOME_WRITABLE != 0))
  }
}

create_fake_sudo() {
  local noninteractive_status="$1"
  local authentication_status="$2"

  cat >"$TEST_BIN/sudo" <<EOF_SUDO
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/sudo.log"

if [[ "\${1:-}" == "-n" && "\${2:-}" == "true" ]]; then
    exit $noninteractive_status
fi

if [[ "\${1:-}" == "-v" ]]; then
    exit $authentication_status
fi

exit 1
EOF_SUDO

  chmod +x -- "$TEST_BIN/sudo"
}

run_captured() {
  local output_file="$1"
  shift

  set +e

  (
    set -e
    "$@"
  ) >"$output_file" 2>&1

  LAST_STATUS=$?

  set -e
}

assert_output_contains() {
  local output_file="$1"
  local expected="$2"
  local message="${3:-Expected output was not found}"

  if grep -Fq -- "$expected" "$output_file"; then
    return 0
  fi

  printf 'FAIL: %s\n' "$message" >&2
  printf '  expected output: %s\n' "$expected" >&2

  return 1
}
