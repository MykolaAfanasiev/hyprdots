# Hyprlock

[English version](README_hyprlock.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Экран блокировки, session helpers, отображение раскладки и интеграция с темой.

## Файлы

- `hyprlock.conf`
- `launch.sh`
- `layout.conf`
- `prepare-theme.sh`
- `scripts/keyboard-layout.sh`
- `scripts/session.sh`
- `themes/catppuccin-mocha.conf`
- `themes/current.conf`



## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
