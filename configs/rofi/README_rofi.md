# Rofi

[Русская версия](README_rofi_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Shared Rofi behavior/layout, themed palette preparation, app/window launcher, and clipboard picker.

## Files

- `clipboard.sh`
- `config.rasi`
- `launch.sh`
- `layout.rasi`
- `prepare-theme.sh`
- `theme.rasi`
- `themes/catppuccin-mocha.rasi`
- `themes/current.rasi`
- `themes/wallpaper.rasi`

## Role

This directory contains shared Rofi layout and theme infrastructure plus the simple app/window and clipboard interfaces. The unified Launcher and Control Center frontends live under `scripts/launcher` and `scripts/control-center`.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
