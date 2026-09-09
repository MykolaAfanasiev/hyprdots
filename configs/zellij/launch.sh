#!/usr/bin/env bash

set -euo pipefail

ZELLIJ_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -x /usr/bin/zellij ]]; then
  printf 'Error: Zellij is not installed.\n' >&2
  exit 1
fi

ZELLIJ_CONFIG_DIR="$ZELLIJ_DIR"

if runtime_dir="$("$ZELLIJ_DIR/prepare-theme.sh" 2>/dev/null)" &&
  [[ -d "$runtime_dir" ]]; then
  ZELLIJ_CONFIG_DIR="$runtime_dir"
fi

exec env \
  ZELLIJ_CONFIG_DIR="$ZELLIJ_CONFIG_DIR" \
  /usr/bin/zellij "$@"
