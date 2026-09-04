#!/usr/bin/env bash

# Test state and dynamic command overrides are consumed by service-stage tests.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_USER_SERVICES_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_USER_SERVICES_LOADED=1

HYPRDOTS_TEST_REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/assertions.sh"

# shellcheck source=setup/lib/common.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/packages/select.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/select.sh"

# shellcheck source=setup/lib/services/user.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/services/user.sh"

setup_user_service_test() {
  create_test_sandbox

  PROJECT_ROOT="$TEST_ROOT/project"
  SETUP_DIR="$PROJECT_ROOT/setup"

  SELECTED_ARCH_REQUIRED=()
  SELECTED_ARCH_RECOMMENDED=()
  SELECTED_ARCH_DEFAULT_APPS=()
  SELECTED_AUR_REQUIRED=()

  CONFIG_DEPLOYMENT_MODE="automatic"

  mkdir -p -- \
    "$PROJECT_ROOT" \
    "$HOME/.config/mpd" \
    "$HOME/.config/systemd/user/mpd.service.d"

  export PROJECT_ROOT
  export SETUP_DIR
}

select_mpd_for_test() {
  SELECTED_ARCH_DEFAULT_APPS=(mpd mpc rmpc)
}

create_deployed_mpd_files() {
  printf '%s\n' 'music_directory "~/Music/music"' \
    >"$HOME/.config/mpd/mpd.conf"

  printf '%s\n' '[Service]' 'RuntimeDirectory=mpd' \
    >"$HOME/.config/systemd/user/mpd.service.d/10-hyprdots.conf"
}

create_fake_systemctl_for_services() {
  local fail_command="${1:-}"

  cat >"$TEST_BIN/systemctl" <<EOF_SYSTEMCTL
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/systemctl.log"

if [[ -n "$fail_command" && "\${2:-}" == "$fail_command" ]]; then
    exit 1
fi

exit 0
EOF_SYSTEMCTL

  chmod +x -- "$TEST_BIN/systemctl"
}

run_service_test_captured() {
  local output_file="$1"
  shift

  set +e

  (
    set -e
    "$@"
  ) >"$output_file" 2>&1

  SERVICE_TEST_STATUS=$?

  set -e
}

assert_service_output_contains() {
  local output_file="$1"
  local expected="$2"

  if grep -Fq -- "$expected" "$output_file"; then
    return 0
  fi

  printf 'FAIL: expected service-stage output was not found\n' >&2
  printf '  expected: %s\n' "$expected" >&2
  return 1
}

assert_systemctl_log_contains() {
  local expected="$1"

  if [[ -f "$TEST_STATE/systemctl.log" ]] &&
    grep -Fq -- "$expected" "$TEST_STATE/systemctl.log"; then
    return 0
  fi

  printf 'FAIL: expected systemctl invocation was not logged\n' >&2
  printf '  expected: %s\n' "$expected" >&2
  return 1
}
