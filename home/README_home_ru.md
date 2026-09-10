# Файлы домашнего каталога

[English version](README_home.md) · [Проект](../README_ru.md)

Stow package `home/` содержит файлы, которые должны находиться относительно домашнего каталога пользователя, а не в `~/.config`.

Сейчас управляются:

- `.zshenv` — ранний entry point окружения Zsh.
- `.local/share/applications/yazi.desktop` — desktop entry для интеграции Yazi.

Installer разворачивает этот package через GNU Stow с домашним каталогом в качестве target.
