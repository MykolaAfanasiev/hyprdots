# Hyprdots Norexil

Hyprdots Norexil — keyboard-first окружение для Arch Linux и Hyprland, построенное как воспроизводимая система, а не просто набор dotfiles. Репозиторий объединяет модульный Lua-конфиг Hyprland, единый launcher, Control Center с CLI-backend, темы от wallpaper, терминальный workflow, desktop-сервисы и installer с автоматическими тестами.

[English version](README.md)

## Основные возможности

- Hyprland разделён на небольшие Lua-модули.
- `SUPER + Space` открывает единый Hyprdots Launcher.
- `SUPER + CTRL + SHIFT + M` открывает Control Center.
- Backend/frontend разделены: основная логика доступна через CLI, а Rofi является только интерфейсом.
- Режимы тем Fixed, Dynamic и Hybrid с live reload приложений.
- Matugen строит палитру из wallpaper и автоматически выбирает light/dark.
- Mouseless позволяет управлять указателем с клавиатуры.
- NetworkManager и Bluetooth имеют отдельные CLI-backend и Rofi-frontend.
- Интеграции Ghostty, Zsh, Starship, Zellij, tmux, Neovim, Yazi, MPD/RMPC, Waybar, SwayNC, Hyprlock, Hypridle и других компонентов.
- Развёртывание через GNU Stow и installer/test suite для Arch Linux.

## Архитектура

```text
конфигурационные файлы
          │
          ▼
CLI / backend компонентов
          │
          ├───────────────┐
          ▼               ▼
      Launcher       Control Center
          │               │
          └───────┬───────┘
                  ▼
             Rofi frontend

Будущий frontend сможет использовать те же CLI-backend без переноса логики в UI.
```

Браузер намеренно не настраивается Hyprdots. Web Search открывает системный браузер по умолчанию через `xdg-open`.

## Установка

Целевая система — Arch Linux. Клонируй репозиторий, перейди в него и запусти:

```bash
./install.sh
```

Installer проверяет систему, предлагает группы пакетов, устанавливает официальные/AUR зависимости, разворачивает `configs` в `~/.config` и `home` в `~` через GNU Stow, создаёт runtime-каталоги, настраивает интеграции и сервисы и выполняет финальную проверку.

После добавления пользователя в группы `input` и `uinput` для Mouseless может понадобиться один новый login или reboot.

## Главные горячие клавиши

| Клавиша | Действие |
|---|---|
| `SUPER + Space` | Единый Launcher |
| `SUPER + CTRL + SHIFT + M` | Control Center |
| `SUPER + A` | Раздел Appearance |
| `SUPER + SHIFT + S` | Раздел Screenshot |
| `Print` | Быстрый screenshot |
| `SUPER + CTRL + N` | Network frontend |
| `SUPER + CTRL + B` | Bluetooth frontend |
| `SUPER + SHIFT + V` | История clipboard |
| `SUPER + Alt + L` | Блокировка сессии |
| `SUPER + Alt + P` | Power menu |
| `SUPER + H/J/K/L` | Фокус окон |
| `SUPER + 1…0` | Workspace 1…10 |

Полный обзор находится в [README Hyprland](configs/hypr/README_hyprland_ru.md).

## Система тем

Есть три режима:

- **Fixed** — выбранная статическая палитра полностью управляет окружением.
- **Dynamic** — Matugen получает палитру из активного wallpaper.
- **Hybrid** — wallpaper остаётся главным источником, а выбранная статическая тема слегка меняет характер цветов.

Статические темы: `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`.

Параметры light/dark, brightness threshold, Matugen scheme и Hybrid tint находятся в `configs/theme/settings.conf` и доступны через CLI и Rofi Theme Settings.

Подробнее: [Theme engine](scripts/theme-switcher/README_theme_switcher_ru.md) и [Matugen](configs/matugen/README_matugen_ru.md).

## Карта репозитория

| Раздел | Документация |
|---|---|
| Конфигурации | [English](configs/README_configs.md) · [Русский](configs/README_configs_ru.md) |
| Скрипты и CLI-backend | [English](scripts/README_scripts.md) · [Русский](scripts/README_scripts_ru.md) |
| Installer | [English](setup/README_setup.md) · [Русский](setup/README_setup_ru.md) |
| Тесты | [English](tests/README_tests.md) · [Русский](tests/README_tests_ru.md) |
| Файлы домашнего каталога | [English](home/README_home.md) · [Русский](home/README_home_ru.md) |

### Основные компоненты

| Компонент | English | Русский |
|---|---|---|
| Launcher | [README](scripts/launcher/README_launcher.md) | [README](scripts/launcher/README_launcher_ru.md) |
| Control Center | [README](scripts/control-center/README_control_center.md) | [README](scripts/control-center/README_control_center_ru.md) |
| Theme switcher | [README](scripts/theme-switcher/README_theme_switcher.md) | [README](scripts/theme-switcher/README_theme_switcher_ru.md) |
| Mouseless | [README](scripts/mouseless/README_mouseless.md) | [README](scripts/mouseless/README_mouseless_ru.md) |
| NetworkManager | [README](scripts/networkmanager/README_networkmanager.md) | [README](scripts/networkmanager/README_networkmanager_ru.md) |
| Bluetooth | [README](scripts/bluetooth/README_bluetooth.md) | [README](scripts/bluetooth/README_bluetooth_ru.md) |
| Wallpaper switcher | [README](scripts/wallpaper-switcher/README_wallpaper_switcher.md) | [README](scripts/wallpaper-switcher/README_wallpaper_switcher_ru.md) |
| Screenshot tool | [README](scripts/screenshot/README_screenshot.md) | [README](scripts/screenshot/README_screenshot_ru.md) |
| Hyprland | [README](configs/hypr/README_hyprland.md) | [README](configs/hypr/README_hyprland_ru.md) |

## Разработка

Форматирование задаётся `.editorconfig`; shell-файлы используют отступ в два пробела. Основные проверки:

```bash
./scripts/dev/format.sh
./tests/static/check.sh
./tests/installer/run.sh
```

Большие секции комментариев используют фиксированную линию из 72 символов `=`:

```bash
# ========================================================================
# Section name
# ========================================================================
```

Для Lua используется тот же стиль с `--`.

## Документация проекта

- [Участие в разработке](CONTRIBUTING.md) — правила участия, структура проекта и Pull Request workflow.
- [История изменений](CHANGELOG.md) — основные изменения и история релизов.
- [Лицензия](LICENSE) — MIT License.

## Лицензия

См. [LICENSE](LICENSE).
