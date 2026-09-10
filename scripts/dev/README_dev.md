# Development utilities

[Русская версия](README_dev_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

These helpers keep local formatting, Git hooks, and CI behavior aligned with `.editorconfig`.

```bash
./scripts/dev/format.sh
./scripts/dev/check-format.sh
./scripts/dev/setup-git-hooks.sh
```

Shell formatting uses the repository style, including two-space indentation. Static validation is orchestrated by `tests/static/check.sh`.
