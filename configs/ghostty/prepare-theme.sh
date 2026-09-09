#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$GHOSTTY_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

GHOSTTY_LAYOUT="$GHOSTTY_DIR/layout.conf"
GHOSTTY_KEYBINDINGS="$GHOSTTY_DIR/keybindings.conf"
GHOSTTY_FALLBACK_CONFIG="$GHOSTTY_DIR/config.ghostty"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  GHOSTTY_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/ghostty"
else
  GHOSTTY_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/ghostty"
fi

GHOSTTY_RUNTIME_CONFIG="$GHOSTTY_RUNTIME_DIR/config.ghostty"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path ghostty 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated" ||
  ! -r "$generated" ||
  ! -r "$GHOSTTY_LAYOUT" ||
  ! -r "$GHOSTTY_KEYBINDINGS" ]]; then

  printf '%s\n' "$GHOSTTY_FALLBACK_CONFIG"
  exit 0
fi

mkdir -p -- "$GHOSTTY_RUNTIME_DIR"

temporary_config=""

cleanup() {
  if [[ -n "${temporary_config:-}" ]]; then
    rm -f -- "$temporary_config"
  fi
}

trap cleanup EXIT

temporary_config="$(
  mktemp "$GHOSTTY_RUNTIME_DIR/.config.XXXXXX"
)"

{
  printf 'config-file = %s\n' "$generated"
  printf 'config-file = %s\n' "$GHOSTTY_LAYOUT"
  printf 'config-file = %s\n' "$GHOSTTY_KEYBINDINGS"
} >"$temporary_config"

mv -f -- \
  "$temporary_config" \
  "$GHOSTTY_RUNTIME_CONFIG"

temporary_config=""

printf '%s\n' "$GHOSTTY_RUNTIME_CONFIG"
