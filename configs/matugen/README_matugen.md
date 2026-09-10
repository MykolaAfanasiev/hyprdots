# Matugen

[Русская версия](README_matugen_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Wallpaper-derived palette generation with automatic light/dark selection.

## Files

- `config.toml`
- `generate.sh`
- `templates/hyprdots.theme`

## Behavior

`generate.sh` reads `configs/theme/settings.conf`, measures wallpaper brightness with ImageMagick when available, chooses `light` or `dark` in automatic mode, and invokes Matugen with the configured scheme/preference. The generated palette is consumed by the theme-switcher render pipeline.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
