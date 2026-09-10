# Starship

[Русская версия](README_starship_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Prompt modules, build pipeline, and runtime theme preparation.

## Files

- `build.zsh`
- `current.toml`
- `modules/10-os.toml`
- `modules/20-directory.toml`
- `modules/30-characters.toml`
- `modules/40-git-branch.toml`
- `modules/41-git-status.toml`
- `modules/50-cmd-duration.toml`
- `prepare-theme.zsh`
- `prompt.toml`
- `starship.toml`
- `themes/catppuccin-mocha.toml`



## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
