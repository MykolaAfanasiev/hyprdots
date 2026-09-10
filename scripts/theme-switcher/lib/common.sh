#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_THEME_COMMON_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_THEME_COMMON_LOADED=1

THEME_SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &&
    pwd
)"

THEME_PROJECT_ROOT="${HYPRDOTS_PROJECT_ROOT:-$(
  cd -- "$THEME_SCRIPT_DIR/../.." &&
    pwd
)}"

THEME_CONFIG_ROOT="$THEME_PROJECT_ROOT/configs/theme"
THEME_DEFINITIONS_DIR="$THEME_CONFIG_ROOT/themes"
THEME_DEFAULT_FILE="$THEME_CONFIG_ROOT/default"

THEME_STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/hyprdots/theme"
THEME_CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/theme"

# Used by scripts that source this library.
# shellcheck disable=SC2034
THEME_ACTIVE_LINK="$THEME_CACHE_ROOT/current"

THEME_RENDER_ROOT="$THEME_CACHE_ROOT/rendered"
THEME_CURRENT_FILE="$THEME_STATE_ROOT/current"

THEME_NAME=""

readonly -a THEME_COLOR_VARIABLES=(
  COLOR_ROSEWATER
  COLOR_FLAMINGO
  COLOR_PINK
  COLOR_MAUVE
  COLOR_RED
  COLOR_MAROON
  COLOR_PEACH
  COLOR_YELLOW
  COLOR_GREEN
  COLOR_TEAL
  COLOR_SKY
  COLOR_SAPPHIRE
  COLOR_BLUE
  COLOR_LAVENDER
  COLOR_TEXT
  COLOR_SUBTEXT1
  COLOR_SUBTEXT0
  COLOR_OVERLAY2
  COLOR_OVERLAY1
  COLOR_OVERLAY0
  COLOR_SURFACE2
  COLOR_SURFACE1
  COLOR_SURFACE0
  COLOR_BASE
  COLOR_MANTLE
  COLOR_CRUST
  ANSI_BLACK
  ANSI_RED
  ANSI_GREEN
  ANSI_YELLOW
  ANSI_BLUE
  ANSI_MAGENTA
  ANSI_CYAN
  ANSI_WHITE
  ANSI_BRIGHT_BLACK
  ANSI_BRIGHT_RED
  ANSI_BRIGHT_GREEN
  ANSI_BRIGHT_YELLOW
  ANSI_BRIGHT_BLUE
  ANSI_BRIGHT_MAGENTA
  ANSI_BRIGHT_CYAN
  ANSI_BRIGHT_WHITE
)

theme_die() {
  printf 'theme: %s\n' "$*" >&2
  exit 1
}

theme_info() {
  printf 'theme: %s\n' "$*" >&2
}

theme_definition_path() {
  local theme_name="$1"

  printf '%s/%s.theme\n' "$THEME_DEFINITIONS_DIR" "$theme_name"
}

theme_exists() {
  local theme_name="$1"

  [[ -r "$(theme_definition_path "$theme_name")" ]]
}

theme_default() {
  local theme_name

  [[ -r "$THEME_DEFAULT_FILE" ]] || theme_die "default theme file is missing: $THEME_DEFAULT_FILE"

  IFS= read -r theme_name <"$THEME_DEFAULT_FILE"

  [[ -n "$theme_name" ]] || theme_die "default theme is empty"
  theme_exists "$theme_name" || theme_die "default theme does not exist: $theme_name"

  printf '%s\n' "$theme_name"
}

theme_current() {
  local theme_name=""

  if [[ -r "$THEME_CURRENT_FILE" ]]; then
    IFS= read -r theme_name <"$THEME_CURRENT_FILE"
  fi

  if [[ -n "$theme_name" ]] && theme_exists "$theme_name"; then
    printf '%s\n' "$theme_name"
    return 0
  fi

  theme_default
}

theme_list() {
  local file

  for file in "$THEME_DEFINITIONS_DIR"/*.theme; do
    [[ -e "$file" ]] || continue
    basename -- "$file" .theme
  done | sort
}

theme_validate_hex() {
  local variable_name="$1"
  local value="${!variable_name:-}"

  if [[ ! "$value" =~ ^#[[:xdigit:]]{6}$ ]]; then
    theme_die "invalid color in $THEME_NAME: $variable_name=${value:-<unset>}"
  fi
}

theme_load() {
  local theme_name="$1"
  local definition
  local variable_name

  theme_exists "$theme_name" || theme_die "unknown theme: $theme_name"

  definition="$(theme_definition_path "$theme_name")"

  for variable_name in "${THEME_COLOR_VARIABLES[@]}"; do
    unset "$variable_name"
  done

  unset THEME_DISPLAY_NAME

  # Theme definitions are trusted files from this repository. Keeping them as
  # shell assignments lets the core stay dependency-free and easy to generate
  # later from Matugen.
  # shellcheck disable=SC1090
  source "$definition"

  THEME_NAME="$theme_name"

  [[ -n "${THEME_DISPLAY_NAME:-}" ]] || theme_die "THEME_DISPLAY_NAME is missing in $theme_name"

  for variable_name in "${THEME_COLOR_VARIABLES[@]}"; do
    theme_validate_hex "$variable_name"
  done
}

theme_hex() {
  printf '%s' "${1#\#}"
}

theme_rgb_csv() {
  local color="${1#\#}"

  printf '%d, %d, %d' \
    "$((16#${color:0:2}))" \
    "$((16#${color:2:2}))" \
    "$((16#${color:4:2}))"
}

theme_prepare_runtime() {
  mkdir -p -- "$THEME_STATE_ROOT" "$THEME_RENDER_ROOT"
}
