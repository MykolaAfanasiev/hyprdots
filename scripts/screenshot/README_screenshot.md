# Screenshot tool

[Русская версия](README_screenshot_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

The screenshot component is a small Python CLI packaged as `screenshot-tool`. It combines `grim`, `slurp`, `satty`, `wl-copy`, and desktop notifications.

## Default behavior

```bash
screenshot-tool
```

captures the full screen, copies it to the clipboard, saves it under the configured screenshots directory, and sends a notification.

## Common examples

```bash
screenshot-tool --area
screenshot-tool --area --edit
screenshot-tool --no-save
screenshot-tool --no-copy
screenshot-tool --output ~/Pictures/example.png
```

The installer uses Pipx to expose the console entry point. The unified Launcher provides named screenshot actions and Hyprland maps `Print` to the quick default action.

## Source layout

- `main.py` — entry point.
- `cli/` — Click option definitions.
- `utils/` — dependency checks, command execution, notifications, paths, and capture helpers.
- `pyproject.toml` — package metadata and console script.
