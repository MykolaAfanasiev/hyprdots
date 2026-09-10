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
printf '%s\n' 'layers:' >"$PROJECT_ROOT/configs/mouseless/config.yaml"

cat >"$TEST_BIN/go" <<'EOF_GO'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TEST_STATE/go.log"
mkdir -p -- "$GOBIN"
printf '#!/usr/bin/env bash\nexit 0\n' >"$GOBIN/mouseless"
chmod +x -- "$GOBIN/mouseless"
EOF_GO
chmod +x "$TEST_BIN/go"

install_mouseless_binary

assert_executable "$HOME/.local/bin/mouseless"
grep -Fq -- \
  'install github.com/jbensmann/mouseless@v0.3.0' \
  "$TEST_STATE/go.log"

printf 'PASS: Mouseless is installed from the pinned Go module\n'
