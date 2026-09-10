# Neovim

[English version](README_nvim.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Модульный Neovim, plugins, LSP/formatting, terminal integration и live reload темы.

## Файлы

- `ftplugin/java.lua`
- `init.lua`
- `lazy-lock.json`
- `reload-theme.sh`



## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
