#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." &&
    pwd
)"

TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/hyprdots-theme-test.XXXXXX")"
trap 'rm -rf -- "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export XDG_CACHE_HOME="$TEST_ROOT/cache"
export XDG_STATE_HOME="$TEST_ROOT/state"

mkdir -p -- "$HOME"

THEME="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"

mapfile -t themes < <("$THEME" list)

[[ " ${themes[*]} " == *" catppuccin-mocha "* ]]
[[ " ${themes[*]} " == *" tokyo-night "* ]]

[[ "$("$THEME" current)" == "catppuccin-mocha" ]]
[[ "$("$THEME" set tokyo-night)" == "tokyo-night" ]]
[[ "$("$THEME" current)" == "tokyo-night" ]]

active="$XDG_CACHE_HOME/hyprdots/theme/current"

[[ -L "$active" ]]
[[ -f "$active/rofi.rasi" ]]
[[ -f "$active/waybar.css" ]]
[[ -f "$active/hyprland.lua" ]]
[[ -f "$active/ghostty.conf" ]]
[[ -f "$active/btop.theme" ]]
[[ -f "$active/rmpc.ron" ]]
[[ -f "$active/zellij.kdl" ]]

grep -Fq '#1a1b26' "$active/rofi.rasi"
grep -Fq '#7aa2f7' "$active/waybar.css"
grep -Fq '#1a1b26' "$active/btop.theme"

[[ "$("$THEME" path waybar)" == "$active/waybar.css" ]]

printf 'PASS: theme core renders and switches runtime palettes\n'
