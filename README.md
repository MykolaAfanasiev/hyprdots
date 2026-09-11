# Hyprdots Norexil

Hyprdots Norexil is a keyboard-first Arch Linux and Hyprland environment built as a reproducible system rather than a loose collection of dotfiles. The repository combines modular Hyprland Lua configuration, a unified launcher, a CLI-backed control center, wallpaper-aware theming, terminal tooling, desktop services, and an installer with automated tests.

[Русская версия](README_ru.md)

## Highlights

- Hyprland configuration written as small Lua modules.
- `SUPER + Space` opens the unified Hyprdots Launcher.
- `SUPER + CTRL + SHIFT + M` opens the Control Center.
- Backend/frontend separation: core actions are available through CLI scripts and Rofi is only a frontend.
- Fixed, Dynamic, and Hybrid theme modes with live application reloads.
- Matugen wallpaper palettes with automatic light/dark selection.
- Mouseless keyboard-driven pointer control.
- NetworkManager and Bluetooth CLI backends with Rofi frontends.
- Ghostty, Zsh, Starship, Zellij, tmux, Neovim, Yazi, MPD/RMPC, Waybar, SwayNC, Hyprlock, Hypridle, and related desktop integrations.
- GNU Stow deployment and an Arch-focused installer/test suite.

## Architecture

```text
configuration files
        │
        ▼
component backends / CLI
        │
        ├───────────────┐
        ▼               ▼
    Launcher       Control Center
        │               │
        └───────┬───────┘
                ▼
           Rofi frontend

Future frontends can call the same CLI backends without moving desktop logic into the UI.
```

The browser is intentionally not configured by Hyprdots. Web search uses the system default browser through `xdg-open`.

## Installation

The supported target is Arch Linux. Clone the repository, enter it, and run:

```bash
./install.sh
```

The installer checks the system, lets you choose package groups, installs official/AUR requirements, deploys `configs` to `~/.config` and `home` to `~` with GNU Stow, prepares runtime directories and integrations, enables services, and performs post-install verification.

Mouseless may require one new login or reboot after the installer adds the user to the `input` and `uinput` groups.

## Main keybindings

| Key | Action |
|---|---|
| `SUPER + Space` | Unified Launcher |
| `SUPER + CTRL + SHIFT + M` | Control Center |
| `SUPER + A` | Appearance section |
| `SUPER + SHIFT + S` | Screenshot section |
| `Print` | Quick screenshot |
| `SUPER + CTRL + N` | Network frontend |
| `SUPER + CTRL + B` | Bluetooth frontend |
| `SUPER + SHIFT + V` | Clipboard history |
| `SUPER + Alt + L` | Lock session |
| `SUPER + Alt + P` | Power menu |
| `SUPER + H/J/K/L` | Focus windows |
| `SUPER + 1…0` | Switch workspaces 1…10 |

See the [Hyprland documentation](configs/hypr/README_hyprland.md) for the complete binding and module overview.

## Theme system

The theme engine exposes three modes:

- **Fixed** — a selected static palette controls the environment.
- **Dynamic** — Matugen derives the palette from the active wallpaper.
- **Hybrid** — the dynamic wallpaper palette remains dominant while a selected static theme adds a controlled tint.

Static themes currently include `catppuccin-frappe`, `catppuccin-latte`, `catppuccin-macchiato`, `catppuccin-mocha`, `dracula`, `everforest-dark`, `gruvbox-dark`, `kanagawa-dragon`, `kanagawa-wave`, `nord`, `one-dark`, `rose-pine-dawn`, `rose-pine-moon`, `rose-pine`, `solarized-dark`, `solarized-light`, `tokyo-night`.

Theme settings such as automatic light/dark mode, brightness threshold, Matugen scheme, and Hybrid tint strength live in `configs/theme/settings.conf` and can be changed through the CLI or Rofi Theme Settings frontend.

See [Theme engine](scripts/theme-switcher/README_theme_switcher.md) and [Matugen](configs/matugen/README_matugen.md).

## Repository map

| Area | Documentation |
|---|---|
| Configurations | [English](configs/README_configs.md) · [Русский](configs/README_configs_ru.md) |
| Scripts and CLI backends | [English](scripts/README_scripts.md) · [Русский](scripts/README_scripts_ru.md) |
| Installer | [English](setup/README_setup.md) · [Русский](setup/README_setup_ru.md) |
| Tests | [English](tests/README_tests.md) · [Русский](tests/README_tests_ru.md) |
| Home-directory files | [English](home/README_home.md) · [Русский](home/README_home_ru.md) |

### Core components

| Component | English | Русский |
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

## Development

Repository formatting is controlled by `.editorconfig` and uses two-space indentation for shell files. Run:

```bash
./scripts/dev/format.sh
./tests/static/check.sh
./tests/installer/run.sh
```

Large source-code comment banners use one fixed style with 72 `=` characters:

```bash
# ========================================================================
# Section name
# ========================================================================
```

Lua uses the same convention with `--`.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines, project
structure, development conventions, and Pull Request workflow.

## Project documentation

- [Contributing](CONTRIBUTING.md) — contribution guidelines and Pull Request workflow.
- [Changelog](CHANGELOG.md) — notable changes and release history.
- [License](LICENSE) — MIT License.
