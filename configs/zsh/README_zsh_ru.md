# Zsh

[English version](README_zsh.md) · [Конфигурации](../README_configs_ru.md) · [Проект](../../README_ru.md)

## Назначение

Модульное shell-окружение с Sheldon, Starship, aliases, tools и terminal integrations.

## Файлы

- `.zshrc`
- `modules/00-environment.zsh`
- `modules/05-ghostty-integration.zsh`
- `modules/10-options.zsh`
- `modules/20-completion.zsh`
- `modules/30-history.zsh`
- `modules/40-keybindings.zsh`
- `modules/50-aliases.zsh`
- `modules/60-functions.zsh`
- `modules/70-tools.zsh`
- `modules/80-plugins.zsh`
- `modules/90-prompt.zsh`
- `modules/95-tmux.zsh`
- `modules/99-integrations.zsh`
- `plugins.toml`



## Разработка

Исходная конфигурация хранится в репозитории и разворачивается installer/Stow workflow. Генерируемое и изменяемое runtime-состояние по возможности должно оставаться вне отслеживаемых source-файлов.
