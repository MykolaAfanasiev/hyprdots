#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -x /usr/bin/ghostty ]]; then
  printf 'Error: Ghostty is not installed.\n' >&2
  exit 1
fi

GHOSTTY_CONFIG="$GHOSTTY_DIR/config.ghostty"

if generated_config="$("$GHOSTTY_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -r "$generated_config" ]]; then
  GHOSTTY_CONFIG="$generated_config"
fi

exec /usr/bin/ghostty \
  --config-default-files=false \
  --config-file="$GHOSTTY_CONFIG" \
  "$@"
