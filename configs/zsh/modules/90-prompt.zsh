if (($+commands[starship])); then
  export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
  eval "$(starship init zsh)"
else
  print -u2 -- "Warning: Starship is not installed"
fi
