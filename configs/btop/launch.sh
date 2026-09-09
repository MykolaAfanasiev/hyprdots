#!/usr/bin/env bash

set -euo pipefail

BTOP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$BTOP_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  BTOP_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/btop/themes"
else
  BTOP_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/btop/themes"
fi

BTOP_RUNTIME_THEME="$BTOP_RUNTIME_DIR/current.theme"

prepare_btop_theme() {
  local generated=""

  if [[ -x "$THEME_CLI" ]]; then
    generated="$(
      "$THEME_CLI" path btop 2>/dev/null ||
        true
    )"
  fi

  if [[ ! -r "$generated" ]]; then
    return 1
  fi

  mkdir -p -- "$BTOP_RUNTIME_DIR"

  ln -sfn -- \
    "$generated" \
    "$BTOP_RUNTIME_THEME"
}

if prepare_btop_theme; then
  exec btop \
    --config "$BTOP_DIR/btop.conf" \
    --themes-dir "$BTOP_RUNTIME_DIR" \
    "$@"
fi

exec btop \
  --config "$BTOP_DIR/btop.conf" \
  "$@"
