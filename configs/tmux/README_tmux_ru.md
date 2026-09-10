# tmux

[English version](README_tmux.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Конфигурация tmux для серверов, разделённая на модули, с runtime theme override.

## Файлы

- `modules/00-options.conf`
- `modules/10-keybindings.conf`
- `modules/20-plugins.conf`
- `themes/catppuccin-mocha.conf`
- `themes/current.conf`
- `tmux.conf`



## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
