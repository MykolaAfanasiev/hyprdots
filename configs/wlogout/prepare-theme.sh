#!/usr/bin/env bash

set -euo pipefail

WLOGOUT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$WLOGOUT_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

WLOGOUT_LAYOUT="$WLOGOUT_DIR/style.css"
WLOGOUT_FALLBACK_THEME="$WLOGOUT_DIR/themes/current.css"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  WLOGOUT_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/wlogout"
else
  WLOGOUT_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/wlogout"
fi

WLOGOUT_RUNTIME_STYLE="$WLOGOUT_RUNTIME_DIR/style.css"

palette="$WLOGOUT_FALLBACK_THEME"
generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path wlogout 2>/dev/null ||
      true
  )"

  if [[ -r "$generated" ]]; then
    palette="$generated"
  fi
fi

if [[ ! -r "$palette" || ! -r "$WLOGOUT_LAYOUT" ]]; then
  printf '%s\n' "$WLOGOUT_LAYOUT"
  exit 0
fi

mkdir -p -- "$WLOGOUT_RUNTIME_DIR"

temporary_style=""

cleanup() {
  if [[ -n "${temporary_style:-}" ]]; then
    rm -f -- "$temporary_style"
  fi
}

trap cleanup EXIT

temporary_style="$(
  mktemp "$WLOGOUT_RUNTIME_DIR/.style.XXXXXX"
)"

{
  printf '@import url("%s");\n' "$palette"
  printf '@import url("%s");\n' "$WLOGOUT_LAYOUT"
} >"$temporary_style"

mv -f -- \
  "$temporary_style" \
  "$WLOGOUT_RUNTIME_STYLE"

temporary_style=""

printf '%s\n' "$WLOGOUT_RUNTIME_STYLE"
