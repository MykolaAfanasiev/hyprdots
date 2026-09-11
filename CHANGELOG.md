# Changelog

All notable changes to Hyprdots Norexil will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- Modular Hyprland configuration written in Lua.
- Unified Hyprdots Launcher with keyboard-first navigation.
- CLI-backed Control Center with Rofi frontend.
- Theme engine with Fixed, Dynamic, and Hybrid modes.
- Wallpaper-aware color generation using Matugen.
- Automatic light and dark theme selection based on wallpaper brightness.
- Static theme collection.
- Wallpaper switcher and theme integration.
- Mouseless keyboard-driven pointer control.
- NetworkManager CLI backend and Rofi frontend.
- Bluetooth CLI backend and Rofi frontend.
- Screenshot tool and screenshot menu.
- Clipboard history integration.
- Power and session management menus.
- Waybar and SwayNC integration.
- Hyprlock and Hypridle integration.
- Ghostty, Zsh, Starship, Zellij, tmux, Neovim, and Yazi configurations.
- MPD, MPC, and RMPC music setup.
- GNU Stow based configuration deployment.
- Arch Linux installation system.
- Package manifests for official Arch repositories and the AUR.
- Installer tests and static checks.
- GitHub Actions CI.
- English and Russian project documentation.
- Contribution guidelines.

### Changed

- Reorganized desktop actions into reusable CLI backends and frontends.
- Standardized repository formatting and shell indentation.
- Standardized source-code section comments.
- Reorganized project documentation into component-specific README files.

### Fixed

- Installer behavior across clean Arch Linux environments.
- MPD service setup and runtime directory handling.
- Zellij configuration and theme integration.
- NetworkManager and Bluetooth integration.
- ShellCheck and formatting issues.
- Installer test behavior in CI environments.

### Removed