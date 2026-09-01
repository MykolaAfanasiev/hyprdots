bindkey -e

autoload -Uz \
    up-line-or-beginning-search \
    down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Prefix-aware history search
bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

# Terminal-specific navigation keys
zmodload zsh/terminfo

[[ -n "${terminfo[kcuu1]}" ]] &&
    bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search

[[ -n "${terminfo[kcud1]}" ]] &&
    bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

[[ -n "${terminfo[khome]}" ]] &&
    bindkey "${terminfo[khome]}" beginning-of-line

[[ -n "${terminfo[kend]}" ]] &&
    bindkey "${terminfo[kend]}" end-of-line

[[ -n "${terminfo[kdch1]}" ]] &&
    bindkey "${terminfo[kdch1]}" delete-char

# Ctrl+Left and Ctrl+Right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Shift+Tab
bindkey '^[[Z' reverse-menu-complete
