# Hyprland

[English version](README_hyprland.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Lua-конфигурация Hyprland и центральная интеграция keybindings/paths рабочего стола.

## Файлы

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

## Интеграция

`hyprland.lua` загружает desktop-модули. `modules/vars/paths.lua` определяет пути к Launcher, Control Center, Rofi, networking, wallpaper, lock/power и другим helpers. Главные keybindings находятся в `modules/submaps/submaps.lua`.

Текущие визуальные frontend открываются напрямую, без невидимых configuration/screenshot submap.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
