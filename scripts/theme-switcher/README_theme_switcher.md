# Theme switcher

[Русская версия](README_theme_switcher_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

The theme switcher is the central palette backend for Hyprdots. It renders application-specific outputs from semantic theme roles and reloads supported applications.

## Modes

- **Fixed** — use one static `.theme` file.
- **Dynamic** — generate the palette from the current wallpaper with Matugen.
- **Hybrid** — generate from the wallpaper, then blend chroma toward a selected static theme while preserving dynamic lightness.

## CLI

```bash
./scripts/theme-switcher/theme.sh list
./scripts/theme-switcher/theme.sh current
./scripts/theme-switcher/theme.sh mode
./scripts/theme-switcher/theme.sh mode dynamic
./scripts/theme-switcher/theme.sh set catppuccin-mocha
./scripts/theme-switcher/theme.sh hybrid gruvbox-dark
./scripts/theme-switcher/theme.sh apply
./scripts/theme-switcher/theme.sh wallpaper
./scripts/theme-switcher/theme.sh reload
./scripts/theme-switcher/theme.sh path ghostty
```

Theme settings are managed independently:

```bash
./scripts/theme-switcher/settings.sh show
./scripts/theme-switcher/settings.sh get MATUGEN_LIGHT_THRESHOLD
./scripts/theme-switcher/settings.sh set MATUGEN_LIGHT_THRESHOLD 0.60
```

## Rendering

`lib/render.sh` creates per-application theme files; `lib/reload.sh` reloads supported applications; `lib/blend-palette.py` performs Hybrid blending in OKLab. Runtime state is stored under `~/.local/state/hyprdots/theme` and generated output under `~/.cache/hyprdots/theme`.

Static themes: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`.
