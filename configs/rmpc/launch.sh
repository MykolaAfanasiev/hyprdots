#!/usr/bin/env bash

set -euo pipefail

RMPC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$RMPC_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
RMPC_FALLBACK_THEME="$RMPC_DIR/themes/current.ron"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  RMPC_RUNTIME_ROOT="$XDG_RUNTIME_DIR/hyprdots/rmpc"
else
  RMPC_RUNTIME_ROOT="${TMPDIR:-/tmp}/hyprdots-$UID/rmpc"
fi

RMPC_RUNTIME_XDG="$RMPC_RUNTIME_ROOT/config"
RMPC_RUNTIME_CONFIG="$RMPC_RUNTIME_XDG/rmpc"
RMPC_RUNTIME_THEMES="$RMPC_RUNTIME_CONFIG/themes"

prepare_rmpc_config() {
  local theme="$RMPC_FALLBACK_THEME"
  local generated=""

  if [[ -x "$THEME_CLI" ]]; then
    generated="$(
      "$THEME_CLI" path rmpc 2>/dev/null ||
        true
    )"

    if [[ -r "$generated" ]]; then
      theme="$generated"
    fi
  fi

  mkdir -p -- "$RMPC_RUNTIME_THEMES"

  ln -sfn -- \
    "$RMPC_DIR/config.ron" \
    "$RMPC_RUNTIME_CONFIG/config.ron"

  ln -sfn -- \
    "$theme" \
    "$RMPC_RUNTIME_THEMES/current.ron"
}

prepare_rmpc_config

exec env \
  XDG_CONFIG_HOME="$RMPC_RUNTIME_XDG" \
  /usr/bin/rmpc \
  "$@"
