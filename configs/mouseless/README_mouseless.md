# Mouseless configuration

[Русская версия](README_mouseless_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Keyboard-pointer mappings plus uinput/udev support files.

## Files

- `99-mouseless.rules`
- `config.yaml`
- `uinput.conf`

## Keyboard layer

The current configuration uses `Q` as a `mod-layer` key. While held, `H/J/K/L` move the pointer, `F/D/S` map to left/right/middle buttons, `P/N` scroll vertically, and `Left Shift`/`Left Alt` change pointer speed.

The installer configures `uinput`, group membership, and the user service. A new login/reboot may be required after group changes.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
