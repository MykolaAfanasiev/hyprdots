ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_USE_ASYNC=1

ZSH_HIGHLIGHT_HIGHLIGHTERS=(
  main
  brackets
)

if (($+commands[sheldon])); then
  eval "$(sheldon source)"
else
  print -u2 -- "Warning: Sheldon is not installed"
fi
