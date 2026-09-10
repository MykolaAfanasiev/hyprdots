# systemd user units

[Русская версия](README_systemd_ru.md) · [Configurations](../README_configs.md) · [Project](../../README.md)

## Purpose

Repository-managed user units and drop-ins for desktop services.

## Files

- `user/mouseless.service`

## Managed units

`mouseless.service` starts the keyboard-pointer daemon. `mpd.service.d/10-hyprdots.conf` supplies repository-specific user-unit behavior for MPD. The installer reloads the user systemd manager after Stow deployment.

## Development

Source configuration is repository-managed and deployed by the installer/Stow workflow. Generated or mutable runtime state should stay outside the tracked source files whenever possible.
