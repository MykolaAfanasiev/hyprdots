# Installer

[English version](README_setup.md) · [Проект](../README_ru.md)

`setup/` содержит installer для Arch Linux, который запускается через корневой `install.sh`. Installer разделён на модули, чтобы стадии можно было тестировать отдельно.

## Стадии

1. проверка системы;
2. выбор пакетов;
3. установка пакетов;
4. локальная конфигурация;
5. развёртывание GNU Stow;
6. установка screenshot-tool;
7. runtime-каталоги;
8. permissions;
9. shell/desktop integrations;
10. services;
11. post-install verification.

## Структура

- `install.sh` — orchestration installer.
- `lib/checks.sh`, `lib/common.sh`, `lib/filesystem.sh` — общая инфраструктура.
- `lib/packages/` — manifests, selection, plan и official/AUR install.
- `lib/configs/`, `lib/links/`, `lib/directories/` — deployment и local state.
- `lib/integrations/` — системные/application integrations, включая Mouseless и Obsidian.
- `lib/services/` — system/user services.
- `lib/verify/` — финальная проверка.
- `packages/` — package manifests.

Тесты installer: `./tests/installer/run.sh`.
