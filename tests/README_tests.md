# Tests

[Русская версия](README_tests_ru.md) · [Project](../README.md)

The test suite protects both repository style and installer behavior.

## Static checks

```bash
./tests/static/check.sh
```

Static checks validate shell syntax/style, formatting, and repository invariants used by CI.

## Installer tests

```bash
./tests/installer/run.sh
```

Installer tests are grouped by stage: system checks, local configuration, runtime directories, Stow links, packages, permissions, screenshot setup, services, theme behavior, verification, and end-to-end installation. Shared test helpers live under `tests/lib/`.

The E2E path expects Arch Linux/Arch-based behavior; CI uses an Arch environment for installer validation.
