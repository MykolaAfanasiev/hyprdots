# Палитры тем

[English version](README_theme.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Статические темы и общие настройки Dynamic/Hybrid.

## Файлы

- `default`
- `settings.conf`
- `themes/catppuccin-frappe.theme`
- `themes/catppuccin-latte.theme`
- `themes/catppuccin-macchiato.theme`
- `themes/catppuccin-mocha.theme`
- `themes/dracula.theme`
- `themes/dynamic.theme`
- `themes/everforest-dark.theme`
- `themes/gruvbox-dark.theme`
- `themes/hybrid.theme`
- `themes/kanagawa-dragon.theme`
- `themes/kanagawa-wave.theme`
- `themes/nord.theme`
- `themes/one-dark.theme`
- `themes/rose-pine-dawn.theme`
- `themes/rose-pine-moon.theme`
- `themes/rose-pine.theme`
- `themes/solarized-dark.theme`
- `themes/solarized-light.theme`
- `themes/tokyo-night.theme`

## Палитры

Статические палитры — shell-style `.theme` файлы с семантическими `COLOR_*` и ANSI ролями. Текущие статические темы: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`. `dynamic.theme` и `hybrid.theme` являются provider-файлами theme engine, а не обычными статическими вариантами.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
