#!/usr/bin/env bash

set -euo pipefail

HYPRLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$HYPRLOCK_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

HYPRLOCK_LAYOUT="$HYPRLOCK_DIR/layout.conf"
HYPRLOCK_FALLBACK_CONFIG="$HYPRLOCK_DIR/hyprlock.conf"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  HYPRLOCK_RUNTIME_DIR="$XDG_RUNTIME_DIR/hyprdots/hyprlock"
else
  HYPRLOCK_RUNTIME_DIR="${TMPDIR:-/tmp}/hyprdots-$UID/hyprlock"
fi

HYPRLOCK_RUNTIME_CONFIG="$HYPRLOCK_RUNTIME_DIR/hyprlock.conf"

generated=""

if [[ -x "$THEME_CLI" ]]; then
  generated="$(
    "$THEME_CLI" path hyprlock 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated" || ! -r "$generated" || ! -r "$HYPRLOCK_LAYOUT" ]]; then
  printf '%s\n' "$HYPRLOCK_FALLBACK_CONFIG"
  exit 0
fi

mkdir -p -- "$HYPRLOCK_RUNTIME_DIR"

temporary_config=""

cleanup() {
  if [[ -n "${temporary_config:-}" ]]; then
    rm -f -- "$temporary_config"
  fi
}

trap cleanup EXIT

temporary_config="$(
  mktemp "$HYPRLOCK_RUNTIME_DIR/.hyprlock.XXXXXX"
)"

{
  printf 'source = %s\n' "$generated"
  printf 'source = %s\n' "$HYPRLOCK_LAYOUT"
} >"$temporary_config"

mv -f -- \
  "$temporary_config" \
  "$HYPRLOCK_RUNTIME_CONFIG"

temporary_config=""

printf '%s\n' "$HYPRLOCK_RUNTIME_CONFIG"
