# Theme switcher

[English version](README_theme_switcher.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

Theme switcher — центральный palette backend Hyprdots. Он преобразует семантические роли темы в форматы приложений и выполняет live reload поддерживаемых компонентов.

## Режимы

- **Fixed** — используется один статический `.theme` файл.
- **Dynamic** — палитра генерируется из текущего wallpaper через Matugen.
- **Hybrid** — сначала строится Dynamic палитра, затем её chroma слегка смешивается с выбранной статической темой при сохранении dynamic lightness.

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

Настройки темы управляются отдельным backend:

```bash
./scripts/theme-switcher/settings.sh show
./scripts/theme-switcher/settings.sh get MATUGEN_LIGHT_THRESHOLD
./scripts/theme-switcher/settings.sh set MATUGEN_LIGHT_THRESHOLD 0.60
```

## Rendering

`lib/render.sh` создаёт файлы темы для приложений, `lib/reload.sh` выполняет live reload, `lib/blend-palette.py` смешивает Hybrid в OKLab. State находится в `~/.local/state/hyprdots/theme`, generated output — в `~/.cache/hyprdots/theme`.

Статические темы: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`.
