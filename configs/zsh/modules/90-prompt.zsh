if (($+commands[starship])); then
  typeset starship_config prepare_starship generated_config

  starship_config="$XDG_CONFIG_HOME/starship/starship.toml"
  prepare_starship="$HYPRDOTS_ROOT/configs/starship/prepare-theme.zsh"

  if [[ -x "$prepare_starship" ]]; then
    generated_config="$(
      "$prepare_starship" 2>/dev/null ||
        true
    )"

    if [[ -r "$generated_config" ]]; then
      starship_config="$generated_config"
    fi
  fi

  export STARSHIP_CONFIG="$starship_config"

  eval "$(starship init zsh)"
else
  print -u2 -- "Warning: Starship is not installed"
fi
