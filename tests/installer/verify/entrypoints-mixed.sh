#!/usr/bin/env bash

# Test variables are consumed indirectly by sourced verification functions.
# shellcheck disable=SC2034

set -euo pipefail

REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

# shellcheck source=tests/lib/verification.sh
source "$REPO_ROOT/tests/lib/verification.sh"

# Arrange

setup_verification_test
trap destroy_test_sandbox EXIT

printf '#!/usr/bin/env bash\n' \
  >"$PROJECT_ROOT/install.sh"

printf '#!/usr/bin/env bash\n' \
  >"$SETUP_DIR/install.sh"

chmod +x \
  "$PROJECT_ROOT/install.sh"

chmod -x \
  "$SETUP_DIR/install.sh"

# Act

verify_installer_entrypoints

# Assert

assert_equals "1" "$VERIFY_PASS_COUNT" "one executable entrypoint should pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "one non-executable entrypoint should fail"

printf 'PASS: installer entrypoint permissions are verified independently\n'
