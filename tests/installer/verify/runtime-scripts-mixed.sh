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

mkdir -p \
  "$PROJECT_ROOT/configs/example" \
  "$PROJECT_ROOT/scripts/example"

printf '#!/usr/bin/env bash\n' \
  >"$PROJECT_ROOT/configs/example/good.sh"

printf '#!/usr/bin/env bash\n' \
  >"$PROJECT_ROOT/scripts/example/bad.sh"

chmod +x \
  "$PROJECT_ROOT/configs/example/good.sh"

chmod -x \
  "$PROJECT_ROOT/scripts/example/bad.sh"

# Act

verify_runtime_script_permissions \
  >"$TEST_STATE/output.log" 2>&1

# Assert

assert_equals "0" "$VERIFY_PASS_COUNT" "mixed script permissions should not pass"
assert_equals "1" "$VERIFY_FAIL_COUNT" "non-executable runtime script should fail"

assert_verify_output_contains \
  "$TEST_STATE/output.log" \
  "1 runtime shell script(s) are not executable"

assert_verify_output_contains \
  "$TEST_STATE/output.log" \
  "scripts/example/bad.sh"

printf 'PASS: non-executable runtime scripts are reported\n'
