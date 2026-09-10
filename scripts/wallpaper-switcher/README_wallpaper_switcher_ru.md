# Wallpaper switcher

[English version](README_wallpaper_switcher.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

`wallpaper.sh` отвечает за state и переключение wallpaper; `rofi.sh`/`launch.sh` являются текущим picker frontend.

## CLI

```bash
./scripts/wallpaper-switcher/wallpaper.sh current
./scripts/wallpaper-switcher/wallpaper.sh list
./scripts/wallpaper-switcher/wallpaper.sh dir
./scripts/wallpaper-switcher/wallpaper.sh set ~/.wallpapers/example.png
```

После успешной смены backend обновляет cache/symlink Hyprdots и вызывает `theme.sh wallpaper`. Fixed сохраняет свою палитру, а Dynamic/Hybrid пересчитываются по новому wallpaper.
