#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

THEME_CLI="$SCRIPT_DIR/theme.sh"

ROFI_DIR="$PROJECT_ROOT/configs/rofi"
ROFI_CONFIG="$ROFI_DIR/config.rasi"
ROFI_FALLBACK_THEME="$ROFI_DIR/theme.rasi"

THEMES_DIR="$PROJECT_ROOT/configs/theme/themes"

if ! command -v rofi >/dev/null 2>&1; then
  printf 'Error: Rofi is not installed.\n' >&2
  exit 1
fi

current="$("$THEME_CLI" current 2>/dev/null || true)"

declare -a entries=()
declare -a slugs=()

while IFS= read -r slug; do
  [[ -n "$slug" ]] || continue

  theme_file="$THEMES_DIR/$slug.theme"
  display=""

  if [[ -r "$theme_file" ]]; then
    display="$(
      sed -nE \
        's/^THEME_DISPLAY_NAME="(.*)"$/\1/p' \
        "$theme_file" |
        head -n 1
    )"
  fi

  if [[ -z "$display" ]]; then
    display="${slug//-/ }"
  fi

  if [[ "$slug" == "$current" ]]; then
    entries+=("● $display")
  else
    entries+=("  $display")
  fi

  slugs+=("$slug")
done < <("$THEME_CLI" list)

if ((${#entries[@]} == 0)); then
  printf 'Error: no themes found.\n' >&2
  exit 1
fi

rofi_theme="$ROFI_FALLBACK_THEME"

if [[ -x "$ROFI_DIR/prepare-theme.sh" ]]; then
  if generated_theme="$("$ROFI_DIR/prepare-theme.sh" 2>/dev/null)" &&
    [[ -r "$generated_theme" ]]; then
    rofi_theme="$generated_theme"
  fi
fi

choice="$(
  printf '%s\n' "${entries[@]}" |
    rofi \
      -dmenu \
      -i \
      -p "Theme" \
      -config "$ROFI_CONFIG" \
      -theme "$rofi_theme"
)" || exit 0

for ((i = 0; i < ${#entries[@]}; i++)); do
  if [[ "${entries[i]}" == "$choice" ]]; then
    "$THEME_CLI" set "${slugs[i]}"
    exit 0
  fi
done

exit 0
