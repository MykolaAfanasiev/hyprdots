# Hyprland

[Русская версия](README_hyprland_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Lua-based Hyprland configuration and the central desktop keybinding/path integration.

## Files

- `.luarc.json`
- `hyprland.lua`
- `modules/animations.lua`
- `modules/autostart.lua`
- `modules/decoration.lua`
- `modules/input.lua`
- `modules/misc.lua`
- `modules/monitor.lua`
- `modules/special_workspaces.lua`
- `modules/theme.lua`
- `modules/windowsrules.lua`

## Integration

`hyprland.lua` loads the desktop modules. `modules/vars/paths.lua` resolves repository paths for Launcher, Control Center, Rofi, networking, wallpaper, lock/power actions, and other helpers. The main keybindings are defined in `modules/submaps/submaps.lua`.

The current visual frontends are opened directly rather than through invisible configuration/screenshot submaps.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
