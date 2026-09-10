#!/usr/bin/env bash

set -euo pipefail

MATUGEN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
MATUGEN_CONFIG="$MATUGEN_DIR/config.toml"

DEFAULT_WALLPAPER="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/wallpaper/current-wallpaper"
OUTPUT="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/theme/matugen-generated.theme"

wallpaper="${1:-$DEFAULT_WALLPAPER}"

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
# Adaptive dark-surface brightness
#
# Very dark wallpapers need brighter surfaces so the desktop does not
# collapse into almost-black colors. Bright wallpapers keep darker
# surfaces for contrast.
#
# brightness:
#   0.0 = black
#   1.0 = white
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

dark_lightness="$(
  awk -v brightness="$brightness" '
    BEGIN {
      if (brightness >= 0.68)
        print "0.04"
      else if (brightness >= 0.50)
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

printf 'Wallpaper brightness: %.3f\n' "$brightness" >&2
printf 'Dark lightness:      %s\n' "$dark_lightness" >&2

(
  cd -- "$MATUGEN_DIR"

  matugen \
    -c "$MATUGEN_CONFIG" \
    image "$wallpaper" \
    -m dark \
    --lightness-dark "$dark_lightness" \
    -t scheme-content \
    --prefer saturation \
    --base16-backend wal
)

if [[ ! -r "$OUTPUT" ]]; then
  printf 'Error: Matugen did not generate: %s\n' "$OUTPUT" >&2
  exit 1
fi

printf '%s\n' "$OUTPUT"
