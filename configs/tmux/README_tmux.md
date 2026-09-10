# tmux

[Русская версия](README_tmux_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Server-oriented tmux configuration split into modules with runtime theme overrides.

## Files

- `modules/00-options.conf`
- `modules/10-keybindings.conf`
- `modules/20-plugins.conf`
- `themes/catppuccin-mocha.conf`
- `themes/current.conf`
- `tmux.conf`



## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
