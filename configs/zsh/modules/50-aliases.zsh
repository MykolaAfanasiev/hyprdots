# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# General
alias cls='clear'
alias v='nvim'
alias grep='grep --color=auto'

# Git
alias g='git'
alias gs='git status --short --branch'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'

# File listing
if (( $+commands[eza] )); then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -lah --icons=auto --group-directories-first --git'
    alias la='eza -a --icons=auto --group-directories-first'
    alias lt='eza --tree --level=2 --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -lah --color=auto'
    alias la='ls -A --color=auto'
fi
