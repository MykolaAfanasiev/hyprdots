# zoxide should be initialized after compinit and other shell integrations
if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi
