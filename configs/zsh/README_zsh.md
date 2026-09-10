# Zsh

[Русская версия](README_zsh_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Modular shell environment using Sheldon, Starship, aliases, tools, and terminal integrations.

## Files

- `.zshrc`
- `modules/00-environment.zsh`
- `modules/05-ghostty-integration.zsh`
- `modules/10-options.zsh`
- `modules/20-completion.zsh`
- `modules/30-history.zsh`
- `modules/40-keybindings.zsh`
- `modules/50-aliases.zsh`
- `modules/60-functions.zsh`
- `modules/70-tools.zsh`
- `modules/80-plugins.zsh`
- `modules/90-prompt.zsh`
- `modules/95-tmux.zsh`
- `modules/99-integrations.zsh`
- `plugins.toml`



## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
