#!/usr/bin/env bash

set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  exit 0
fi

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}"

updated=0
failed=0

while IFS= read -r -d '' socket; do
  # Ignore sockets that no longer belong to a live Neovim instance.
  if ! nvim \
    --server "$socket" \
    --remote-expr '1' \
    >/dev/null 2>&1; then
    continue
  fi

  if nvim \
    --server "$socket" \
    --remote-send '<Cmd>lua require("config.theme").reload()<CR>' \
    >/dev/null 2>&1; then

    printf 'Updated: %s\n' "$socket"
    ((updated += 1))
  else
    printf 'Failed:  %s\n' "$socket" >&2
    ((failed += 1))
  fi
done < <(
  find "$runtime_dir" \
    -maxdepth 2 \
    -type s \
    -name 'nvim.*' \
    -print0 \
    2>/dev/null
)

if ((updated == 0)); then
  printf 'No running Neovim instances found.\n'
else
  printf 'Reloaded %d Neovim instance(s).\n' "$updated"
fi

if ((failed > 0)); then
  exit 1
fi
