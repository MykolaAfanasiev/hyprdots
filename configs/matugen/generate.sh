#!/usr/bin/env bash

set -euo pipefail

MATUGEN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MATUGEN_CONFIG="$MATUGEN_DIR/config.toml"

DEFAULT_WALLPAPER="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/wallpaper/current-wallpaper"
OUTPUT="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/theme/matugen-generated.theme"

wallpaper="${1:-$DEFAULT_WALLPAPER}"

# auto | dark | light
requested_mode="${HYPRDOTS_MATUGEN_MODE:-auto}"

# Wallpapers at or above this average brightness become light themes.
light_threshold="${HYPRDOTS_MATUGEN_LIGHT_THRESHOLD:-0.56}"

if ! command -v matugen >/dev/null 2>&1; then
  printf 'Error: Matugen is not installed.\n' >&2
  exit 1
fi

if [[ ! -e "$wallpaper" ]]; then
  printf 'Error: wallpaper not found: %s\n' "$wallpaper" >&2
  exit 1
fi

wallpaper="$(readlink -f -- "$wallpaper")"

mkdir -p -- "$(dirname -- "$OUTPUT")"

# -------------------------------------------------------------------
# Wallpaper brightness
#
# 0.0 = black
# 1.0 = white
# -------------------------------------------------------------------

brightness="0.50"

if command -v magick >/dev/null 2>&1; then
  measured="$(
    magick "$wallpaper" \
      -resize '64x64!' \
      -colorspace Gray \
      -format '%[fx:mean]' \
      info: 2>/dev/null ||
      true
  )"

  if [[ "$measured" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    brightness="$measured"
  fi
fi

# -------------------------------------------------------------------
# Automatic light / dark mode
# -------------------------------------------------------------------

case "$requested_mode" in
auto)
  if awk \
    -v brightness="$brightness" \
    -v threshold="$light_threshold" \
    'BEGIN { exit !(brightness >= threshold) }'; then
    matugen_mode="light"
  else
    matugen_mode="dark"
  fi
  ;;

dark | light)
  matugen_mode="$requested_mode"
  ;;

*)
  printf \
    'Error: HYPRDOTS_MATUGEN_MODE must be auto, dark or light.\n' \
    >&2
  exit 1
  ;;
esac

printf 'Wallpaper brightness: %.3f\n' "$brightness" >&2
printf 'Matugen mode:        %s\n' "$matugen_mode" >&2

# -------------------------------------------------------------------
# Matugen arguments
# -------------------------------------------------------------------

matugen_args=(
  -c "$MATUGEN_CONFIG"
  image "$wallpaper"
  -m "$matugen_mode"
  -t scheme-content
  --prefer saturation
  --base16-backend wal
)

# Very dark wallpapers need brighter dark surfaces.
# Light mode already has suitable Material surfaces, so this compensation
# is only applied in dark mode.
if [[ "$matugen_mode" == "dark" ]]; then
  dark_lightness="$(
    awk -v brightness="$brightness" '
      BEGIN {
        if (brightness >= 0.50)
          print "0.07"
        else if (brightness >= 0.35)
          print "0.10"
        else if (brightness >= 0.22)
          print "0.14"
        else
          print "0.18"
      }
    '
  )"

  printf 'Dark lightness:      %s\n' "$dark_lightness" >&2

  matugen_args+=(--lightness-dark "$dark_lightness")
fi

(
  cd -- "$MATUGEN_DIR"
  matugen "${matugen_args[@]}"
)

if [[ ! -r "$OUTPUT" ]]; then
  printf 'Error: Matugen did not generate: %s\n' "$OUTPUT" >&2
  exit 1
fi

# Store the detected variant alongside the generated palette.
temporary_output=""

cleanup() {
  if [[ -n "${temporary_output:-}" ]]; then
    rm -f -- "$temporary_output"
  fi
}

trap cleanup EXIT

temporary_output="$(
  mktemp "$(dirname -- "$OUTPUT")/.matugen-theme.XXXXXX"
)"

{
  printf 'THEME_VARIANT="%s"\n' "$matugen_mode"
  grep -v '^THEME_VARIANT=' "$OUTPUT"
} >"$temporary_output"

mv -f -- "$temporary_output" "$OUTPUT"
temporary_output=""

trap - EXIT

printf '%s\n' "$OUTPUT"
