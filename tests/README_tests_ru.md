# Тесты

[English version](README_tests.md) · [Проект](../README_ru.md)

Test suite защищает стиль репозитория и поведение installer.

## Static checks

```bash
./tests/static/check.sh
```

Static checks проверяют shell syntax/style, formatting и repository invariants, используемые CI.

## Installer tests

```bash
./tests/installer/run.sh
```

Installer tests разделены по стадиям: system checks, local configuration, runtime directories, Stow links, packages, permissions, screenshot setup, services, theme behavior, verification и end-to-end installation. Общие helpers находятся в `tests/lib/`.

E2E сценарий ожидает Arch Linux/Arch-based environment; CI использует Arch для проверки installer.
