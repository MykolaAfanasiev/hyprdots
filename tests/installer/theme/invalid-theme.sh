#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/hyprdots-theme-test.XXXXXX")"
trap 'rm -rf -- "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export XDG_CACHE_HOME="$TEST_ROOT/cache"
export XDG_STATE_HOME="$TEST_ROOT/state"

mkdir -p -- "$HOME"

THEME="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

if "$THEME" set definitely-not-a-theme >/dev/null 2>&1; then
  printf 'FAIL: invalid theme was accepted\n' >&2
  exit 1
fi

[[ ! -e "$XDG_STATE_HOME/hyprdots/theme/current" ]]

printf 'PASS: unknown theme is rejected without changing state\n'
