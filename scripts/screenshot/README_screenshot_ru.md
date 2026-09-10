# Screenshot tool

[English version](README_screenshot.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

Screenshot component — небольшой Python CLI, устанавливаемый как `screenshot-tool`. Он объединяет `grim`, `slurp`, `satty`, `wl-copy` и desktop notifications.

## Поведение по умолчанию

```bash
screenshot-tool
```

делает fullscreen screenshot, копирует его в clipboard, сохраняет в настроенный каталог и отправляет notification.

## Примеры

```bash
screenshot-tool --area
screenshot-tool --area --edit
screenshot-tool --no-save
screenshot-tool --no-copy
screenshot-tool --output ~/Pictures/example.png
```

Installer использует Pipx для console entry point. Unified Launcher предоставляет именованные screenshot actions, а `Print` в Hyprland запускает быстрый default action.

## Структура исходников

- `main.py` — entry point.
- `cli/` — Click options.
- `utils/` — dependency checks, запуск команд, notifications, paths и capture helpers.
- `pyproject.toml` — package metadata и console script.
