#!/usr/bin/env bash

set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1; then
  exit 0
fi

layouts="$(
  hyprctl getoption input.kb_layout 2>/dev/null |
    awk -F': ' '$1 == "str" { print $2; exit }'
)"

layouts="${layouts//[[:space:]]/}"

if [[ -z "$layouts" ]]; then
  exit 0
fi

IFS=',' read -r -a configured_layouts <<<"$layouts"

# There is no useful information to show with only one layout.
if ((${#configured_layouts[@]} <= 1)); then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

active="$(
  hyprctl devices -j 2>/dev/null |
    jq -r '
      .keyboards[]
      | select(.main == true)
      | .active_keymap
    ' |
    head -n1
)"

[[ -n "$active" && "$active" != "null" ]] || exit 0

case "$active" in
English*)
  printf 'EN\n'
  ;;
German*)
  printf 'DE\n'
  ;;
Russian*)
  printf 'RU\n'
  ;;
Ukrainian*)
  printf 'UA\n'
  ;;
French*)
  printf 'FR\n'
  ;;
Polish*)
  printf 'PL\n'
  ;;
Spanish*)
  printf 'ES\n'
  ;;
Italian*)
  printf 'IT\n'
  ;;
Czech*)
  printf 'CZ\n'
  ;;
Turkish*)
  printf 'TR\n'
  ;;
*)
  # Sensible fallback for layouts not listed above.
  printf '%s\n' "${active:0:2}" |
    tr '[:lower:]' '[:upper:]'
  ;;
esac
