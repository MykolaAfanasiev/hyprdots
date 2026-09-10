# Starship

[English version](README_starship.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Модули prompt, build pipeline и подготовка runtime-темы.

## Файлы

- `build.zsh`
- `current.toml`
- `modules/10-os.toml`
- `modules/20-directory.toml`
- `modules/30-characters.toml`
- `modules/40-git-branch.toml`
- `modules/41-git-status.toml`
- `modules/50-cmd-duration.toml`
- `prepare-theme.zsh`
- `prompt.toml`
- `starship.toml`
- `themes/catppuccin-mocha.toml`



## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
