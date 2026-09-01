typeset -g ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
typeset -g ZSH_COMPLETION_CACHE="$XDG_CACHE_HOME/zsh/completion"

command mkdir -p -- \
    "${ZSH_COMPDUMP:h}" \
    "$ZSH_COMPLETION_CACHE"

autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP"

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_COMPLETION_CACHE"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format 'No matches found'
zstyle ':completion:*' menu no

if [[ -n "$LS_COLORS" ]]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

zstyle ':fzf-tab:complete:cd:*' \
    fzf-preview 'command ls --color=always -- "$realpath"'
