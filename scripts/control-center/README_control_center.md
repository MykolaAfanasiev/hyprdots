# Control Center

[Русская версия](README_control_center_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

The Control Center aggregates configuration/status operations without owning component logic. `control-center.sh` is the CLI backend; `rofi.sh` is the frontend.

## Backend responsibilities

- delegate theme and theme-setting commands;
- delegate NetworkManager, Bluetooth, Mouseless, and wallpaper actions;
- report Waybar/service status and restart selected desktop components;
- control SwayNC and Hyprpaper helpers;
- expose Hyprland reload/config errors;
- map friendly configuration names to repository files.

## CLI examples

```bash
./scripts/control-center/control-center.sh status
./scripts/control-center/control-center.sh theme mode
./scripts/control-center/control-center.sh theme-settings show
./scripts/control-center/control-center.sh network toggle
./scripts/control-center/control-center.sh bluetooth status
./scripts/control-center/control-center.sh mouseless status
./scripts/control-center/control-center.sh config list
./scripts/control-center/control-center.sh config path nvim
```

The Rofi frontend can open directly in sections such as `appearance`, `connectivity`, `input`, `desktop`, `config`, and `system`. Hyprland opens the main Control Center with `SUPER + CTRL + SHIFT + M`.
