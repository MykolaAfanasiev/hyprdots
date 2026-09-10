# Wallpaper switcher

[Русская версия](README_wallpaper_switcher_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

`wallpaper.sh` owns wallpaper state and switching; `rofi.sh`/`launch.sh` provide the current picker frontend.

## CLI

```bash
./scripts/wallpaper-switcher/wallpaper.sh current
./scripts/wallpaper-switcher/wallpaper.sh list
./scripts/wallpaper-switcher/wallpaper.sh dir
./scripts/wallpaper-switcher/wallpaper.sh set ~/.wallpapers/example.png
```

After a successful switch the backend updates the Hyprdots wallpaper cache/symlink and calls `theme.sh wallpaper`. Fixed mode keeps its palette; Dynamic and Hybrid modes regenerate from the new wallpaper.
