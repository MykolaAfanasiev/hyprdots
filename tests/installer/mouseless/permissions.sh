#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$REPO_ROOT/tests/lib/sandbox.sh"
# shellcheck source=tests/lib/assertions.sh
source "$REPO_ROOT/tests/lib/assertions.sh"
# shellcheck source=setup/lib/common.sh
source "$REPO_ROOT/setup/lib/common.sh"
# shellcheck source=setup/lib/integrations/mouseless.sh
source "$REPO_ROOT/setup/lib/integrations/mouseless.sh"

create_test_sandbox
trap destroy_test_sandbox EXIT

PROJECT_ROOT="$TEST_ROOT/project"
mkdir -p "$PROJECT_ROOT/configs/mouseless"
printf '%s\n' 'rule' >"$PROJECT_ROOT/configs/mouseless/99-mouseless.rules"
printf '%s\n' 'uinput' >"$PROJECT_ROOT/configs/mouseless/uinput.conf"
printf '%s\n' 'layers:' >"$PROJECT_ROOT/configs/mouseless/config.yaml"

cat >"$TEST_BIN/getent" <<'EOF_GETENT'
#!/usr/bin/env bash
exit 1
EOF_GETENT
chmod +x "$TEST_BIN/getent"

cat >"$TEST_BIN/id" <<'EOF_ID'
#!/usr/bin/env bash
if [[ "${1:-}" == "-nG" ]]; then
  printf '%s\n' 'users'
  exit 0
fi
if [[ "${1:-}" == "-un" ]]; then
  printf '%s\n' 'tester'
  exit 0
fi
exec /usr/bin/id "$@"
EOF_ID
chmod +x "$TEST_BIN/id"

cat >"$TEST_BIN/sudo" <<'EOF_SUDO'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_STATE/sudo.log"
exit 0
EOF_SUDO
chmod +x "$TEST_BIN/sudo"

USER=tester setup_mouseless_permissions >"$TEST_STATE/output.log" 2>&1

grep -Fq -- 'groupadd --system input' "$TEST_STATE/sudo.log"
grep -Fq -- 'groupadd --system uinput' "$TEST_STATE/sudo.log"
grep -Fq -- 'usermod -aG input,uinput tester' "$TEST_STATE/sudo.log"
grep -Fq -- 'modprobe uinput' "$TEST_STATE/sudo.log"
grep -Fq -- 'udevadm control --reload-rules' "$TEST_STATE/sudo.log"
grep -Fq -- 'udevadm trigger' "$TEST_STATE/sudo.log"

assert_equals \
  '1' \
  "$MOUSELESS_RELOGIN_REQUIRED" \
  'new group membership should require a new login'

printf 'PASS: Mouseless device permissions are configured\n'
