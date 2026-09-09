#!/usr/bin/env zsh

emulate -L zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

typeset starship_dir project_root
typeset theme_cli builder
typeset fallback_config generated_theme
typeset runtime_dir runtime_config

starship_dir="${0:A:h}"
project_root="${starship_dir:h:h}"

theme_cli="$project_root/scripts/theme-switcher/theme.sh"
builder="$starship_dir/build.zsh"

fallback_config="$starship_dir/starship.toml"
generated_theme=""

if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  runtime_dir="$XDG_RUNTIME_DIR/hyprdots/starship"
else
  runtime_dir="${TMPDIR:-/tmp}/hyprdots-$UID/starship"
fi

runtime_config="$runtime_dir/starship.toml"

if [[ -x "$theme_cli" ]]; then
  generated_theme="$(
    "$theme_cli" path starship 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated_theme" || ! -r "$generated_theme" ]]; then
  print -r -- "$fallback_config"
  exit 0
fi

command mkdir -p -- "$runtime_dir"

if STARSHIP_THEME_FILE="$generated_theme" \
  STARSHIP_OUTPUT="$runtime_config" \
  command zsh "$builder" >/dev/null 2>&1; then

  print -r -- "$runtime_config"
else
  print -r -- "$fallback_config"
fi
