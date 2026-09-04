# GNU file colors
if (($+commands[dircolors])); then
  eval "$(command dircolors -b)"
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# bat
if (($+commands[bat])); then
  export BAT_PAGER="${BAT_PAGER:-less -RF}"
fi

# fzf
if (($+commands[fzf])); then
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height=40% --layout=reverse --border --info=inline --cycle}"

  source <(fzf --zsh)
fi
