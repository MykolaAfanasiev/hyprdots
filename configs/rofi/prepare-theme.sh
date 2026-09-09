#!/usr/bin/env bash

set -euo pipefail

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$ROFI_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

ROFI_LAYOUT="$ROFI_DIR/layout.rasi"
ROFI_FALLBACK_THEME="$ROFI_DIR/theme.rasi"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  ROFI_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots"
else
  ROFI_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID"
fi

ROFI_RUNTIME_THEME="$ROFI_RUNTIME_DIR/rofi.rasi"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path rofi 2>/dev/null ||
      true
  )"
fi

# If the theme manager is unavailable or hasn't generated
# a Rofi palette yet, use the repository fallback theme.
if [[ -z "$generated" || ! -r "$generated" ]]; then
  printf '%s\n' "$ROFI_FALLBACK_THEME"
  exit 0
fi

if [[ ! -r "$ROFI_LAYOUT" ]]; then
  printf '%s\n' "$ROFI_FALLBACK_THEME"
  exit 0
fi

mkdir -p -- "$ROFI_RUNTIME_DIR"

temporary_theme=""

cleanup() {
  if [[ -n "${temporary_theme:-}" ]]; then
    rm -f -- "$temporary_theme"
  fi
}

trap cleanup EXIT

temporary_theme="$(
  mktemp "$ROFI_RUNTIME_DIR/.rofi.XXXXXX"
)"

{
  printf '@import "%s"\n' "$generated"
  printf '@import "%s"\n' "$ROFI_LAYOUT"
} >"$temporary_theme"

mv -f -- \
  "$temporary_theme" \
  "$ROFI_RUNTIME_THEME"

temporary_theme=""

printf '%s\n' "$ROFI_RUNTIME_THEME"
