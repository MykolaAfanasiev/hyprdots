#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

SETTINGS_CLI="$SCRIPT_DIR/settings.sh"
THEME_CLI="$SCRIPT_DIR/theme.sh"

ROFI_DIR="$PROJECT_ROOT/configs/rofi"
ROFI_CONFIG="$ROFI_DIR/config.rasi"
ROFI_FALLBACK_THEME="$ROFI_DIR/theme.rasi"

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
    -p "$prompt" \
    -config "$ROFI_CONFIG" \
    -theme "$rofi_theme" \
    -theme-str 'window { width: 620px; } listview { columns: 1; }' \
    "$@"
}

select_value() {
  local prompt="$1"
  local current="$2"
  shift 2

  local value
  local entry
  local -a entries=()

  for value in "$@"; do
    if [[ "$value" == "$current" ]]; then
      entries+=("● $value")
    else
      entries+=("  $value")
    fi
  done

  entry="$(
    printf '%s\n' "${entries[@]}" |
      rofi_menu "$prompt"
  )" || return 1

  printf '%s\n' "${entry#??}"
}

input_number() {
  local prompt="$1"
  local current="$2"
  local result

  result="$(
    printf '%s\n' "$current" |
      rofi_menu "$prompt" \
        -mesg "Enter a value from 0.00 to 1.00"
  )" || return 1

  printf '%s\n' "$result"
}

pretty_scheme() {
  printf '%s' "${1#scheme-}"
}

open_settings_file() {
  local settings_file
  local editor="${EDITOR:-nvim}"

  settings_file="$("$SETTINGS_CLI" path)"

  if command -v ghostty >/dev/null 2>&1; then
    ghostty -e "$editor" "$settings_file" >/dev/null 2>&1 &
    disown
    return 0
  fi

  printf 'Ghostty is not available.\n' >&2
  return 1
}

while true; do
  mode="$("$THEME_CLI" mode)"

  matugen_mode="$("$SETTINGS_CLI" get MATUGEN_MODE)"
  threshold="$("$SETTINGS_CLI" get MATUGEN_LIGHT_THRESHOLD)"
  scheme="$("$SETTINGS_CLI" get MATUGEN_SCHEME)"
  prefer="$("$SETTINGS_CLI" get MATUGEN_PREFER)"
  accent_tint="$("$SETTINGS_CLI" get HYBRID_ACCENT_TINT)"
  neutral_tint="$("$SETTINGS_CLI" get HYBRID_NEUTRAL_TINT)"

  choice="$(
    printf '%s\n' \
      "$(printf '%-28s %s' "Current theme mode" "$mode")" \
      "$(printf '%-28s %s' "Matugen mode" "$matugen_mode")" \
      "$(printf '%-28s %s' "Light threshold" "$threshold")" \
      "$(printf '%-28s %s' "Matugen scheme" "$(pretty_scheme "$scheme")")" \
      "$(printf '%-28s %s' "Source preference" "$prefer")" \
      "$(printf '%-28s %s' "Hybrid accent tint" "$accent_tint")" \
      "$(printf '%-28s %s' "Hybrid neutral tint" "$neutral_tint")" \
      "Apply current theme" \
      "Edit settings file" |
      rofi_menu "Theme Settings"
  )" || exit 0

  case "$choice" in
  Current\ theme\ mode*)
    # Read-only here. Theme mode itself belongs in the normal theme picker.
    continue
    ;;

  Matugen\ mode*)
    value="$(
      select_value \
        "Matugen Mode" \
        "$matugen_mode" \
        auto dark light
    )" || continue

    "$SETTINGS_CLI" set MATUGEN_MODE "$value"
    ;;

  Light\ threshold*)
    value="$(
      input_number \
        "Light Threshold" \
        "$threshold"
    )" || continue

    "$SETTINGS_CLI" set MATUGEN_LIGHT_THRESHOLD "$value" || true
    ;;

  Matugen\ scheme*)
    value="$(
      select_value \
        "Matugen Scheme" \
        "$scheme" \
        scheme-content \
        scheme-tonal-spot \
        scheme-fidelity \
        scheme-expressive \
        scheme-neutral \
        scheme-monochrome \
        scheme-rainbow \
        scheme-fruit-salad
    )" || continue

    "$SETTINGS_CLI" set MATUGEN_SCHEME "$value"
    ;;

  Source\ preference*)
    value="$(
      select_value \
        "Source Preference" \
        "$prefer" \
        saturation \
        less-saturation \
        darkness \
        lightness \
        value \
        closest-to-fallback
    )" || continue

    "$SETTINGS_CLI" set MATUGEN_PREFER "$value"
    ;;

  Hybrid\ accent\ tint*)
    value="$(
      input_number \
        "Hybrid Accent Tint" \
        "$accent_tint"
    )" || continue

    "$SETTINGS_CLI" set HYBRID_ACCENT_TINT "$value" || true
    ;;

  Hybrid\ neutral\ tint*)
    value="$(
      input_number \
        "Hybrid Neutral Tint" \
        "$neutral_tint"
    )" || continue

    "$SETTINGS_CLI" set HYBRID_NEUTRAL_TINT "$value" || true
    ;;

  "Apply current theme")
    "$THEME_CLI" apply
    ;;

  "Edit settings file")
    open_settings_file
    exit 0
    ;;
  esac
done
