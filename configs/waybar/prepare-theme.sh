#!/usr/bin/env bash

set -euo pipefail

WAYBAR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$WAYBAR_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

WAYBAR_LAYOUT="$WAYBAR_DIR/style.css"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  WAYBAR_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/waybar"
else
  WAYBAR_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/waybar"
fi

WAYBAR_RUNTIME_STYLE="$WAYBAR_RUNTIME_DIR/style.css"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path waybar 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated" || ! -r "$generated" ]]; then
  printf '%s\n' "$WAYBAR_LAYOUT"
  exit 0
fi

mkdir -p -- "$WAYBAR_RUNTIME_DIR"

temporary_style=""

cleanup() {
  if [[ -n "${temporary_style:-}" ]]; then
    rm -f -- "$temporary_style"
  fi
}

trap cleanup EXIT

temporary_style="$(
  mktemp "$WAYBAR_RUNTIME_DIR/.style.XXXXXX"
)"

{
  printf '@import url("%s");\n' "$generated"
  printf '@import url("%s");\n' "$WAYBAR_LAYOUT"
} >"$temporary_style"

mv -f -- "$temporary_style" "$WAYBAR_RUNTIME_STYLE"
temporary_style=""

printf '%s\n' "$WAYBAR_RUNTIME_STYLE"
