typeset -g ZSH_CONFIG_DIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

for module in "$ZSH_CONFIG_DIR"/modules/*.zsh(N); do
  source "$module"
done

unset module
