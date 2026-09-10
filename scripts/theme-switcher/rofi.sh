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

rofi_theme="$ROFI_FALLBACK_THEME"

if [[ -x "$ROFI_DIR/prepare-theme.sh" ]]; then
  if generated_theme="$("$ROFI_DIR/prepare-theme.sh" 2>/dev/null)" &&
    [[ -r "$generated_theme" ]]; then
    rofi_theme="$generated_theme"
  fi
fi

rofi_menu() {
  local prompt="$1"
  shift

  rofi \
    -dmenu \
    -i \
    -markup-rows \
    -p "$prompt" \
    -config "$ROFI_CONFIG" \
    -theme "$rofi_theme" \
    "$@"
}

theme_display_name() {
  local slug="$1"
  local theme_file="$THEMES_DIR/$slug.theme"
  local display=""

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

  printf '%s\n' "$display"
}

theme_metadata() {
  local slug="$1"
  local theme_file="$THEMES_DIR/$slug.theme"
  local variant=""
  local accent=""

  if [[ -r "$theme_file" ]]; then
    variant="$(
      sed -nE \
        's/^THEME_VARIANT="(.*)"$/\1/p' \
        "$theme_file" |
        head -n 1
    )"

    accent="$(
      sed -nE \
        's/^COLOR_BLUE="(#[0-9A-Fa-f]{6})"$/\1/p' \
        "$theme_file" |
        head -n 1
    )"
  fi

  case "$variant" in
  light)
    variant="Light"
    ;;
  dark)
    variant="Dark"
    ;;
  *)
    variant="Unknown"
    ;;
  esac

  printf '%s\t%s\n' "$variant" "$accent"
}

choose_static_theme() {
  local prompt="$1"
  local action="$2"

  local selected
  local slug
  local display
  local metadata
  local variant
  local accent
  local choice
  local index

  local -a entries=()
  local -a slugs=()

  selected="$("$THEME_CLI" selected 2>/dev/null || true)"

  while IFS= read -r slug; do
    [[ -n "$slug" ]] || continue

    display="$(theme_display_name "$slug")"

    metadata="$(theme_metadata "$slug")"
    IFS=$'\t' read -r variant accent <<<"$metadata"

    local swatch
    swatch="<span foreground=\"$accent\">●</span>"

    if [[ "$slug" == "$selected" ]]; then
      entries+=("$(printf '● %-26s %-7s %s  %s' "$display" "$variant" "$swatch" "$accent")")
    else
      entries+=("$(printf '  %-26s %-7s %s  %s' "$display" "$variant" "$swatch" "$accent")")
    fi

    slugs+=("$slug")
  done < <("$THEME_CLI" list)

  if ((${#entries[@]} == 0)); then
    printf 'Error: no static themes found.\n' >&2
    return 1
  fi

  choice="$(
    printf '%s\n' "${entries[@]}" |
      rofi_menu "$prompt" \
        -theme-str 'listview { columns: 1; }'
  )" || return 0

  for ((index = 0; index < ${#entries[@]}; index++)); do
    if [[ "${entries[index]}" != "$choice" ]]; then
      continue
    fi

    case "$action" in
    fixed)
      "$THEME_CLI" set "${slugs[index]}"
      ;;
    hybrid)
      "$THEME_CLI" hybrid "${slugs[index]}"
      ;;
    *)
      printf 'Error: unknown theme action: %s\n' "$action" >&2
      return 1
      ;;
    esac

    return 0
  done
}

choose_mode() {
  local current_mode
  local choice

  current_mode="$("$THEME_CLI" mode)"

  local fixed="  Fixed"
  local dynamic="  Dynamic"
  local hybrid="  Hybrid"

  case "$current_mode" in
  fixed)
    fixed="● Fixed"
    ;;
  dynamic)
    dynamic="● Dynamic"
    ;;
  hybrid)
    hybrid="● Hybrid"
    ;;
  esac

  choice="$(
    printf '%s\n' \
      "$fixed" \
      "$dynamic" \
      "$hybrid" |
      rofi_menu "Theme Mode"
  )" || return 0

  case "$choice" in
  "● Fixed" | "  Fixed")
    choose_static_theme "Fixed Theme" fixed
    ;;

  "● Dynamic" | "  Dynamic")
    "$THEME_CLI" mode dynamic
    ;;

  "● Hybrid" | "  Hybrid")
    choose_static_theme "Hybrid Tint" hybrid
    ;;
  esac
}

choose_mode
