# Control Center

[English version](README_control_center.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

Control Center собирает настройки и status operations, но не дублирует логику компонентов. `control-center.sh` — CLI-backend, `rofi.sh` — frontend.

## Задачи backend

- делегировать theme и theme-settings команды;
- делегировать NetworkManager, Bluetooth, Mouseless и wallpaper actions;
- показывать status Waybar/services и перезапускать desktop components;
- управлять SwayNC и Hyprpaper helpers;
- отдавать Hyprland reload/config errors;
- сопоставлять понятные имена конфигураций с файлами репозитория.

## Примеры CLI

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

Rofi frontend умеет открываться сразу в `appearance`, `connectivity`, `input`, `desktop`, `config` и `system`. Hyprland открывает основной Control Center через `SUPER + CTRL + SHIFT + M`.
