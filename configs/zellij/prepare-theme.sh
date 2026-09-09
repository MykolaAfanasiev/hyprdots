#!/usr/bin/env bash

set -euo pipefail

ZELLIJ_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$ZELLIJ_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
FALLBACK_THEME="$ZELLIJ_DIR/themes/current.kdl"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/zellij"
else
  RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/zellij"
fi

RUNTIME_THEMES="$RUNTIME_DIR/themes"
RUNTIME_THEME="$RUNTIME_THEMES/current.kdl"

mkdir -p -- "$RUNTIME_THEMES"

ln -sfn -- \
  "$ZELLIJ_DIR/config.kdl" \
  "$RUNTIME_DIR/config.kdl"

generated_theme=""

if [[ -x "$THEME_CLI" ]]; then
  generated_theme="$(
    "$THEME_CLI" path zellij 2>/dev/null ||
      true
  )"
fi

source_theme="$FALLBACK_THEME"

if [[ -n "$generated_theme" && -r "$generated_theme" ]]; then
  source_theme="$generated_theme"
fi

if [[ ! -r "$source_theme" ]]; then
  printf 'Cannot read Zellij theme: %s\n' "$source_theme" >&2
  exit 1
fi

# Write in place so a running Zellij session can detect the theme change.
cat -- "$source_theme" >"$RUNTIME_THEME"

printf '%s\n' "$RUNTIME_DIR"
