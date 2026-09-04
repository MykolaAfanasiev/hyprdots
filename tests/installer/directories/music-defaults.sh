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

create_test_sandbox
trap destroy_test_sandbox EXIT

ensure_music_directories >"$TEST_STATE/output.log" 2>&1

assert_directory_exists "$HOME/Music/music"
assert_directory_exists "$HOME/Music/playlists"
assert_directory_exists "$XDG_DATA_HOME/mpd"
assert_directory_exists "$XDG_STATE_HOME/mpd"

printf 'PASS: MPD music and state directories are created\n'
