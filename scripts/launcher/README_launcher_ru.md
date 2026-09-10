# Единый Launcher

[English version](README_launcher.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

Launcher — главная точка для запуска действий и поиска. `launcher.sh` является независимым от UI CLI-backend, а `rofi.sh` — текущим frontend.

## Архитектура

```text
Rofi frontend -> launcher.sh -> Control Center/backend компонентов
```

Backend открывает Ghostty, Yazi, btop и RMPC, вычисляет ограниченные calculator expressions, запускает web search через `xdg-open`, вызывает screenshot modes и делегирует theme, wallpaper, network, Bluetooth, Mouseless и power actions.

## Примеры CLI

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

Hyprland открывает главное меню через `SUPER + Space`.
