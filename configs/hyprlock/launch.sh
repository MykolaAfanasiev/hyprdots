#!/usr/bin/env bash

set -euo pipefail

HYPRLOCK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SESSION_SCRIPT="$HYPRLOCK_DIR/scripts/session.sh"

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

HYPRLOCK_CONFIG="$HYPRLOCK_DIR/hyprlock.conf"

if generated_config="$("$HYPRLOCK_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -r "$generated_config" ]]; then
  HYPRLOCK_CONFIG="$generated_config"
fi

session_active=false

restore_session() {
  if [[ "$session_active" == true ]]; then
    "$SESSION_SCRIPT" unlock || true
    session_active=false
  fi
}

trap restore_session EXIT

"$SESSION_SCRIPT" lock || true
session_active=true

set +e
hyprlock --config "$HYPRLOCK_CONFIG"
status=$?
set -e

restore_session
trap - EXIT

exit "$status"
