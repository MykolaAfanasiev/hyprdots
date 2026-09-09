#!/usr/bin/env bash

set -euo pipefail

SWAYNC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SWAYNC_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

SWAYNC_LAYOUT="$SWAYNC_DIR/layout.css"
SWAYNC_FALLBACK_STYLE="$SWAYNC_DIR/style.css"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  SWAYNC_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/swaync"
else
  SWAYNC_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/swaync"
fi

SWAYNC_RUNTIME_STYLE="$SWAYNC_RUNTIME_DIR/style.css"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path swaync 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated" || ! -r "$generated" || ! -r "$SWAYNC_LAYOUT" ]]; then
  printf '%s\n' "$SWAYNC_FALLBACK_STYLE"
  exit 0
fi

mkdir -p -- "$SWAYNC_RUNTIME_DIR"

temporary_style=""

cleanup() {
  if [[ -n "${temporary_style:-}" ]]; then
    rm -f -- "$temporary_style"
  fi
}

trap cleanup EXIT

temporary_style="$(
  mktemp "$SWAYNC_RUNTIME_DIR/.style.XXXXXX"
)"

{
  printf '@import url("%s");\n' "$generated"
  printf '@import url("%s");\n' "$SWAYNC_LAYOUT"
} >"$temporary_style"

mv -f -- \
  "$temporary_style" \
  "$SWAYNC_RUNTIME_STYLE"

temporary_style=""

printf '%s\n' "$SWAYNC_RUNTIME_STYLE"
