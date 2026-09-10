# Theme palettes

[Русская версия](README_theme_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Static theme definitions and shared Dynamic/Hybrid settings.

## Files

- `default`
- `settings.conf`
- `themes/catppuccin-frappe.theme`
- `themes/catppuccin-latte.theme`
- `themes/catppuccin-macchiato.theme`
- `themes/catppuccin-mocha.theme`
- `themes/dracula.theme`
- `themes/dynamic.theme`
- `themes/everforest-dark.theme`
- `themes/gruvbox-dark.theme`
- `themes/hybrid.theme`
- `themes/kanagawa-dragon.theme`
- `themes/kanagawa-wave.theme`
- `themes/nord.theme`
- `themes/one-dark.theme`
- `themes/rose-pine-dawn.theme`
- `themes/rose-pine-moon.theme`
- `themes/rose-pine.theme`
- `themes/solarized-dark.theme`
- `themes/solarized-light.theme`
- `themes/tokyo-night.theme`

## Palettes

Static palettes are shell-style `.theme` files with semantic `COLOR_*` and ANSI roles. Current static themes: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`. `dynamic.theme` and `hybrid.theme` are providers used by the theme engine rather than ordinary static choices.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
