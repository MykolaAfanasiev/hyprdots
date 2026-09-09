#!/usr/bin/env bash

set -euo pipefail

YAZI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$YAZI_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

YAZI_FALLBACK_FLAVOR="$YAZI_DIR/flavors/current.yazi"

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  YAZI_RUNTIME_CONFIG="$XDG_RUNTIME_DIR/hyprdots/yazi"
else
  YAZI_RUNTIME_CONFIG="${TMPDIR:-/tmp}/hyprdots-$UID/yazi"
fi

YAZI_RUNTIME_FLAVORS="$YAZI_RUNTIME_CONFIG/flavors"

runtime_link() {
  local source="$1"
  local destination="$2"

  ln -sfnT -- "$source" "$destination"
}

prepare_yazi_config() {
  local generated=""
  local current_flavor="$YAZI_FALLBACK_FLAVOR"

  if [[ -x "$THEME_CLI" ]]; then
    generated="$(
      "$THEME_CLI" path yazi 2>/dev/null ||
        true
    )"

    if [[ -d "$generated" && -r "$generated/flavor.toml" ]]; then
      current_flavor="$generated"
    fi
  fi

  mkdir -p -- "$YAZI_RUNTIME_FLAVORS"

  local config_name

  for config_name in \
    yazi.toml \
    keymap.toml \
    theme.toml \
    package.toml \
    init.lua \
    vfs.toml; do

    if [[ -e "$YAZI_DIR/$config_name" ]]; then
      runtime_link \
        "$YAZI_DIR/$config_name" \
        "$YAZI_RUNTIME_CONFIG/$config_name"
    fi
  done

  if [[ -d "$YAZI_DIR/plugins" ]]; then
    runtime_link \
      "$YAZI_DIR/plugins" \
      "$YAZI_RUNTIME_CONFIG/plugins"
  fi

  if [[ -d "$YAZI_DIR/flavors" ]]; then
    local flavor
    local flavor_name

    shopt -s nullglob

    for flavor in "$YAZI_DIR"/flavors/*.yazi; do
      flavor_name="$(basename -- "$flavor")"

      [[ "$flavor_name" == "current.yazi" ]] && continue

      runtime_link \
        "$flavor" \
        "$YAZI_RUNTIME_FLAVORS/$flavor_name"
    done

    shopt -u nullglob
  fi

  if [[ -d "$current_flavor" ]]; then
    runtime_link \
      "$current_flavor" \
      "$YAZI_RUNTIME_FLAVORS/current.yazi"
  fi
}

prepare_yazi_config

exec env \
  YAZI_CONFIG_HOME="$YAZI_RUNTIME_CONFIG" \
  /usr/bin/yazi \
  "$@"
