# Конфигурации

[English version](README_configs.md) · [К проекту](../README_ru.md)

`configs/` разворачивается в `~/.config` через GNU Stow. Каждый каталог верхнего уровня отвечает за одно приложение или desktop subsystem. Runtime/generated темы обычно находятся в `~/.cache/hyprdots`, поэтому исходные палитры в репозитории не перезаписываются.

| Каталог | Назначение | Документация |
|---|---|---|
| `bluetooth` | Палитра и оформление Rofi, используемые Bluetooth frontend. | [README](bluetooth/README_bluetooth_ru.md) |
| `btop` | Конфигурация системного монитора, launcher, live reload темы и ссылки на палитры. | [README](btop/README_btop_ru.md) |
| `ghostty` | Конфигурация терминала, keybindings, launcher и интеграция с генерируемой темой. | [README](ghostty/README_ghostty_ru.md) |
| `hypr` | Lua-конфигурация Hyprland и центральная интеграция keybindings/paths рабочего стола. | [README](hypr/README_hyprland_ru.md) |
| `hypridle` | Idle-таймеры и helper scripts для яркости, блокировки и питания. | [README](hypridle/README_hypridle_ru.md) |
| `hyprlock` | Экран блокировки, session helpers, отображение раскладки и интеграция с темой. | [README](hyprlock/README_hyprlock_ru.md) |
| `hyprpaper` | Конфигурация wallpaper daemon и helper scripts для управления/перезапуска. | [README](hyprpaper/README_hyprpaper_ru.md) |
| `hyprsunset` | Расписание цветовой температуры и необязательная локальная настройка координат. | [README](hyprsunset/README_hyprsunset_ru.md) |
| `matugen` | Генерация палитры из wallpaper с автоматическим выбором light/dark. | [README](matugen/README_matugen_ru.md) |
| `mouseless` | Keyboard-pointer mappings и системные uinput/udev файлы. | [README](mouseless/README_mouseless_ru.md) |
| `mpd` | Конфигурация Music Player Daemon для RMPC/MPC и session integrations. | [README](mpd/README_mpd_ru.md) |
| `networkmanager` | Палитра и оформление Rofi, используемые Wi-Fi frontend. | [README](networkmanager/README_networkmanager_ru.md) |
| `nvim` | Модульный Neovim, plugins, LSP/formatting, terminal integration и live reload темы. | [README](nvim/README_nvim_ru.md) |
| `obsidian` | Helper для установки theme snippet в найденные Obsidian vaults. | [README](obsidian/README_obsidian_ru.md) |
| `rmpc` | Конфигурация terminal MPD client, launcher и интеграция с темой. | [README](rmpc/README_rmpc_ru.md) |
| `rofi` | Общие behavior/layout Rofi, подготовка темы, app/window launcher и clipboard picker. | [README](rofi/README_rofi_ru.md) |
| `starship` | Модули prompt, build pipeline и подготовка runtime-темы. | [README](starship/README_starship_ru.md) |
| `swaync` | Notification center, CSS layout, управление и интеграция с генерируемой темой. | [README](swaync/README_swaync_ru.md) |
| `systemd` | Управляемые репозиторием user units и drop-ins для desktop services. | [README](systemd/README_systemd_ru.md) |
| `theme` | Статические темы и общие настройки Dynamic/Hybrid. | [README](theme/README_theme_ru.md) |
| `tmux` | Конфигурация tmux для серверов, разделённая на модули, с runtime theme override. | [README](tmux/README_tmux_ru.md) |
| `waybar` | Конфигурация панели, scripts, CSS layout и интеграция с темой. | [README](waybar/README_waybar_ru.md) |
| `wlogout` | Графическое power menu, dispatcher действий и интеграция с темой. | [README](wlogout/README_wlogout_ru.md) |
| `xdg-desktop-portal-termfilechooser` | Конфигурация terminal file chooser portal, используемого с Yazi. | [README](xdg-desktop-portal-termfilechooser/README_xdg_desktop_portal_termfilechooser_ru.md) |
| `xdg-desktop-portal` | Настройки предпочтений portal для Hyprland session. | [README](xdg-desktop-portal/README_xdg_desktop_portal_ru.md) |
| `yazi` | Конфигурация terminal file manager, packages, keymaps, launcher и live reload темы. | [README](yazi/README_yazi_ru.md) |
| `zellij` | Основной локальный terminal multiplexer, launcher и подготовленная runtime-тема. | [README](zellij/README_zellij_ru.md) |
| `zsh` | Модульное shell-окружение с Sheldon, Starship, aliases, tools и terminal integrations. | [README](zsh/README_zsh_ru.md) |

Логика конкретного приложения должна оставаться рядом с его конфигурацией, а переиспользуемая orchestration-логика находится в `scripts/`.
