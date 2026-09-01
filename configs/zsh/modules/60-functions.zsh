mkcd() {
    if (( $# != 1 )); then
        print -u2 -- "Usage: mkcd <directory>"
        return 2
    fi

    command mkdir -p -- "$1" &&
        builtin cd -- "$1"
}

croot() {
    local root

    root="$(command git rev-parse --show-toplevel 2>/dev/null)" || {
        print -u2 -- "Not inside a Git repository"
        return 1
    }

    builtin cd -- "$root"
}

extract() {
    if (( $# != 1 )); then
        print -u2 -- "Usage: extract <archive>"
        return 2
    fi

    if [[ ! -f "$1" ]]; then
        print -u2 -- "File not found: $1"
        return 1
    fi

    if (( $+commands[bsdtar] )); then
        command bsdtar -xf "$1"
    else
        print -u2 -- "bsdtar is not installed"
        return 127
    fi
}

rzsh() {
    exec zsh
}

rstarship() {
    local builder="$XDG_CONFIG_HOME/starship/build.zsh"

    if [[ ! -r "$builder" ]]; then
        print -u2 -- "Starship builder not found: $builder"
        return 1
    fi

    command zsh "$builder"
}

scrollback() {
    if (( $# != 1 )); then
        print -u2 -- "Usage: scrollback <file>"
        return 2
    fi

    local scrollback_file="$1"

    if [[ ! -r "$scrollback_file" ]]; then
        print -u2 -- "Cannot read scrollback file: $scrollback_file"
        return 1
    fi

    command nvim --clean -n -R \
        '+set clipboard=unnamedplus' \
        '+setlocal nowrap nonumber norelativenumber signcolumn=no noswapfile' \
        '+syntax off' \
        '+nnoremap <buffer> q <Cmd>quit!<CR>' \
        '+normal! G' \
        -- "$scrollback_file"
}

y() {
    local tmp cwd

    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return 1

    command yazi "$@" --cwd-file="$tmp"

    IFS= read -r -d '' cwd < "$tmp"

    if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
        builtin cd -- "$cwd"
    fi

    command rm -f -- "$tmp"
}
# Function vim for nvim
function vim {
    XDG_CONFIG_HOME="$HOME/.config/.dotfiles/configs" command nvim "$@"
}

# ncmpcpp
function ncmpcpp() {
  XDG_CONFIG_HOME="$HOME/.config/.dotfiles/configs/music/" command ncmpcpp "$@"
}

function mpd() {
  command mpd "$HOME/.config/.dotfiles/configs/music/mpd/mpd.conf" "$@"
}

# # Tmux function
# function tmux {
#   if [[ "$1" == "attach" ]]; then
#     command tmux -f "$HOME/.config/.dotfiles/configs/tmux/.tmux.conf" attach "${@:2}"
#   else
#     command tmux -f "$HOME/.config/.dotfiles/configs/tmux/.tmux.conf" "$@"
#   fi
# }
