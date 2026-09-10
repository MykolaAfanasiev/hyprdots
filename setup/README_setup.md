# Installer

[Русская версия](README_setup_ru.md) · [Project](../README.md)

`setup/` implements the Arch Linux installer used by the root `install.sh` entry point. The installer is intentionally modular so individual stages can be tested in isolation.

## Stages

1. system checks;
2. package selection;
3. package installation;
4. local configuration;
5. GNU Stow deployment;
6. screenshot-tool installation;
7. runtime directories;
8. permissions;
9. shell/desktop integrations;
10. services;
11. post-install verification.

## Layout

- `install.sh` — installer orchestration.
- `lib/checks.sh`, `lib/common.sh`, `lib/filesystem.sh` — shared infrastructure.
- `lib/packages/` — manifests, selection, planning, official/AUR installation.
- `lib/configs/`, `lib/links/`, `lib/directories/` — deployment and local state.
- `lib/integrations/` — application/system integration, including Mouseless and Obsidian.
- `lib/services/` — system/user service activation.
- `lib/verify/` — post-install verification.
- `packages/` — package manifests.

Run installer tests with `./tests/installer/run.sh`.
