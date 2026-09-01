# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Keep PATH ordered and free of duplicates
typeset -U path PATH

path=(
    "$HOME/.local/bin"
    "${path[@]}"
)

export PATH

# Default applications
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export SUDO_EDITOR="${SUDO_EDITOR:-$EDITOR}"
export PAGER="${PAGER:-less}"
export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$XDG_CONFIG_HOME/starship/starship.toml}"
export YAZI_CONFIG_HOME="$HOME/.config/yazi"

# Sheldon uses configs/zsh/plugins.toml
export SHELDON_CONFIG_DIR="$ZSH_CONFIG_DIR"
