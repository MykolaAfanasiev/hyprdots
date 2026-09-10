# Инструменты разработки

[English version](README_dev.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

Эти helpers синхронизируют локальное форматирование, Git hooks и CI с `.editorconfig`.

```bash
./scripts/dev/format.sh
./scripts/dev/check-format.sh
./scripts/dev/setup-git-hooks.sh
```

Shell formatting использует стиль репозитория, включая отступ в два пробела. Static validation запускается через `tests/static/check.sh`.
