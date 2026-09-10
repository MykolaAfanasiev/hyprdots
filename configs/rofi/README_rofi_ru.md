# Rofi

[English version](README_rofi.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Общие behavior/layout Rofi, подготовка темы, app/window launcher и clipboard picker.

## Файлы

- `clipboard.sh`
- `config.rasi`
- `launch.sh`
- `layout.rasi`
- `prepare-theme.sh`
- `theme.rasi`
- `themes/catppuccin-mocha.rasi`
- `themes/current.rasi`
- `themes/wallpaper.rasi`

## Роль

Здесь находится общий layout/theme infrastructure Rofi, а также простой app/window launcher и clipboard UI. Единые Launcher и Control Center frontend находятся в `scripts/launcher` и `scripts/control-center`.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
