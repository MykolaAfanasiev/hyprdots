# Matugen

[English version](README_matugen.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Генерация палитры из wallpaper с автоматическим выбором light/dark.

## Файлы

- `config.toml`
- `generate.sh`
- `templates/hyprdots.theme`

## Поведение

`generate.sh` читает `configs/theme/settings.conf`, измеряет яркость wallpaper через ImageMagick, в auto-режиме выбирает `light` или `dark` и запускает Matugen с выбранными scheme/preference. Полученную палитру использует render pipeline theme-switcher.

## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
