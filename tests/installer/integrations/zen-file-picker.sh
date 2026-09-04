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

# shellcheck source=setup/lib/integrations/desktop.sh
source "$REPO_ROOT/setup/lib/integrations/desktop.sh"

# Arrange

create_test_sandbox
trap destroy_test_sandbox EXIT

# Consumed indirectly by the sourced integration module.
# shellcheck disable=SC2034
PROJECT_ROOT="$TEST_ROOT/project"
export PROJECT_ROOT

native_profile="$HOME/.zen/profile.default"
flatpak_profile="$HOME/.var/app/app.zen_browser.zen/.zen/profile.flatpak"

mkdir -p -- \
  "$native_profile" \
  "$flatpak_profile"

cat >"$HOME/.zen/profiles.ini" <<'EOF_NATIVE'
[Profile0]
Name=Default
IsRelative=1
Path=profile.default
Default=1
EOF_NATIVE

cat >"$HOME/.var/app/app.zen_browser.zen/.zen/profiles.ini" <<EOF_FLATPAK
[Profile0]
Name=Default
IsRelative=0
Path=$flatpak_profile
Default=1
EOF_FLATPAK

cat >"$native_profile/user.js" <<'EOF_USER_JS'
user_pref("browser.tabs.warnOnClose", false);
user_pref("widget.use-xdg-desktop-portal.file-picker", 0);
EOF_USER_JS

# Act: a second call must update in place without duplicating the preference.

configure_zen_file_picker >"$TEST_STATE/first.log" 2>&1
configure_zen_file_picker >"$TEST_STATE/second.log" 2>&1

# Assert

preference='user_pref("widget.use-xdg-desktop-portal.file-picker", 1);'

assert_equals \
  1 \
  "$(grep -Fxc -- "$preference" "$native_profile/user.js")" \
  "native Zen profile should contain one portal preference"

assert_equals \
  1 \
  "$(grep -Fxc -- "$preference" "$flatpak_profile/user.js")" \
  "Flatpak Zen profile should contain one portal preference"

assert_equals \
  1 \
  "$(grep -Fxc -- 'user_pref("browser.tabs.warnOnClose", false);' "$native_profile/user.js")" \
  "unrelated Zen preferences should be preserved"

grep -Fq -- \
  'Zen uses the XDG portal file picker in 2 profile(s)' \
  "$TEST_STATE/second.log"

printf 'PASS: Zen portal preference is configured idempotently\n'
