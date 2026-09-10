# Mouseless backend

[Русская версия](README_mouseless_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

`mouseless.sh` is the UI-independent service controller for the Mouseless keyboard-pointer daemon. The actual mappings are stored in `configs/mouseless/config.yaml`.

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

The installer installs the pinned Mouseless binary, deploys the user service, configures `uinput`, and handles the required group membership.
