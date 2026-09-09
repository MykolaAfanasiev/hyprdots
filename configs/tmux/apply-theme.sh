#!/usr/bin/env bash

set -euo pipefail

TMUX_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$TMUX_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path tmux 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated" || ! -r "$generated" ]]; then
  exit 0
fi

tmux source-file "$generated"
