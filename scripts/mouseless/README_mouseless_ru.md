# Mouseless backend

[English version](README_mouseless.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

`mouseless.sh` — независимый от UI controller сервиса Mouseless. Сами keyboard-pointer mappings находятся в `configs/mouseless/config.yaml`.

## CLI

```bash
./scripts/mouseless/mouseless.sh start
./scripts/mouseless/mouseless.sh stop
./scripts/mouseless/mouseless.sh restart
./scripts/mouseless/mouseless.sh toggle
./scripts/mouseless/mouseless.sh status
./scripts/mouseless/mouseless.sh enabled
./scripts/mouseless/mouseless.sh enable
./scripts/mouseless/mouseless.sh disable
./scripts/mouseless/mouseless.sh path
./scripts/mouseless/mouseless.sh logs
```

Installer устанавливает pinned binary, разворачивает user service, настраивает `uinput` и необходимые группы.
