# Unified Launcher

[Русская версия](README_launcher_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

The Launcher is the main action/search entry point. `launcher.sh` is the UI-independent CLI backend and `rofi.sh` is the current frontend.

## Architecture

```text
Rofi frontend -> launcher.sh -> Control Center/component backends
```

The backend opens Ghostty, Yazi, btop and RMPC, evaluates a restricted calculator expression, opens web searches with `xdg-open`, dispatches screenshot modes, and delegates theme, wallpaper, network, Bluetooth, Mouseless, and power actions.

## CLI examples

```bash
./scripts/launcher/launcher.sh status
./scripts/launcher/launcher.sh terminal
./scripts/launcher/launcher.sh files "$HOME"
./scripts/launcher/launcher.sh calc '25 * 4 + sqrt(144)'
./scripts/launcher/launcher.sh search 'Arch Linux Hyprland'
./scripts/launcher/launcher.sh screenshot area-edit
./scripts/launcher/launcher.sh power lock
./scripts/launcher/launcher.sh network status
```

## Frontend

```bash
./scripts/launcher/rofi.sh
./scripts/launcher/rofi.sh screenshot
./scripts/launcher/rofi.sh power
./scripts/launcher/rofi.sh mouseless
```

Hyprland opens the main frontend with `SUPER + Space`.
