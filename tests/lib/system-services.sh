#!/usr/bin/env bash

# Shared helpers for NetworkManager and Bluetooth service-stage tests.
# shellcheck disable=SC2034

if [[ -n "${HYPRDOTS_TEST_SYSTEM_SERVICES_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_SYSTEM_SERVICES_LOADED=1

SYSTEM_SERVICES_TEST_REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/user-services.sh
source "$SYSTEM_SERVICES_TEST_REPO_ROOT/tests/lib/user-services.sh"

select_networkmanager_for_test() {
  SELECTED_ARCH_RECOMMENDED=(networkmanager)
}

select_bluetooth_for_test() {
  SELECTED_ARCH_RECOMMENDED=(bluez bluez-utils)
}

create_fake_sudo_for_services() {
  cat >"$TEST_BIN/sudo" <<'EOF_SUDO'
#!/usr/bin/env bash

printf '%s\n' "$*" >>"$TEST_STATE/sudo.log"
exec "$@"
EOF_SUDO

  chmod +x -- "$TEST_BIN/sudo"
}

create_fake_systemctl_for_system_services() {
  local fail_invocation="${1:-}"

  cat >"$TEST_BIN/systemctl" <<EOF_SYSTEMCTL
#!/usr/bin/env bash

printf '%s\n' "\$*" >>"$TEST_STATE/systemctl.log"

if [[ -n "$fail_invocation" && "\$*" == "$fail_invocation" ]]; then
  exit 1
fi

exit 0
EOF_SYSTEMCTL

  chmod +x -- "$TEST_BIN/systemctl"
}

assert_sudo_log_contains() {
  local expected="$1"

  if [[ -f "$TEST_STATE/sudo.log" ]] &&
    grep -Fq -- "$expected" "$TEST_STATE/sudo.log"; then
    return 0
  fi

  printf 'FAIL: expected sudo invocation was not logged\n' >&2
  printf '  expected: %s\n' "$expected" >&2
  return 1
}
