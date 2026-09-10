# Configurations

[Русская версия](README_configs_ru.md) · [Back to project](../README.md)

`configs/` is deployed to `~/.config` with GNU Stow. Each top-level directory owns one application or desktop subsystem. Runtime/generated theme files normally live under `~/.cache/hyprdots` and are referenced by these configurations rather than overwriting source palettes.

| Directory | Purpose | Documentation |
|---|---|---|
| `bluetooth` | Palette and Rofi styling used by the Bluetooth frontend. | [README](bluetooth/README_bluetooth.md) |
| `btop` | System monitor configuration, launcher, live theme reload helper, and generated palette links. | [README](btop/README_btop.md) |
| `ghostty` | Terminal configuration, keybindings, launcher, and generated theme integration. | [README](ghostty/README_ghostty.md) |
| `hypr` | Lua-based Hyprland configuration and the central desktop keybinding/path integration. | [README](hypr/README_hyprland.md) |
| `hypridle` | Idle timers and helper scripts for brightness, locking, and power actions. | [README](hypridle/README_hypridle.md) |
| `hyprlock` | Lock-screen layout, session helpers, keyboard-layout display, and generated theme integration. | [README](hyprlock/README_hyprlock.md) |
| `hyprpaper` | Wallpaper daemon configuration and restart/control helpers. | [README](hyprpaper/README_hyprpaper.md) |
| `hyprsunset` | Color-temperature schedule and optional local location configuration. | [README](hyprsunset/README_hyprsunset.md) |
| `matugen` | Wallpaper-derived palette generation with automatic light/dark selection. | [README](matugen/README_matugen.md) |
| `mouseless` | Keyboard-pointer mappings plus uinput/udev support files. | [README](mouseless/README_mouseless.md) |
| `mpd` | Music Player Daemon configuration used by RMPC/MPC and session integrations. | [README](mpd/README_mpd.md) |
| `networkmanager` | Palette and Rofi styling used by the Wi-Fi frontend. | [README](networkmanager/README_networkmanager.md) |
| `nvim` | Modular Neovim configuration, plugins, LSP/formatting setup, terminal integration, and live theme reload. | [README](nvim/README_nvim.md) |
| `obsidian` | Theme snippet deployment helper for discovered Obsidian vaults. | [README](obsidian/README_obsidian.md) |
| `rmpc` | Terminal MPD client configuration, launcher, and generated theme integration. | [README](rmpc/README_rmpc.md) |
| `rofi` | Shared Rofi behavior/layout, themed palette preparation, app/window launcher, and clipboard picker. | [README](rofi/README_rofi.md) |
| `starship` | Prompt modules, build pipeline, and runtime theme preparation. | [README](starship/README_starship.md) |
| `swaync` | Notification center configuration, CSS layout, controls, and generated theme integration. | [README](swaync/README_swaync.md) |
| `systemd` | Repository-managed user units and drop-ins for desktop services. | [README](systemd/README_systemd.md) |
| `theme` | Static theme definitions and shared Dynamic/Hybrid settings. | [README](theme/README_theme.md) |
| `tmux` | Server-oriented tmux configuration split into modules with runtime theme overrides. | [README](tmux/README_tmux.md) |
| `waybar` | Bar configuration, scripts, CSS layout, and generated theme integration. | [README](waybar/README_waybar.md) |
| `wlogout` | Graphical power menu layout, action dispatcher, and generated theme integration. | [README](wlogout/README_wlogout.md) |
| `xdg-desktop-portal-termfilechooser` | Configuration for the terminal file chooser portal used with Yazi. | [README](xdg-desktop-portal-termfilechooser/README_xdg_desktop_portal_termfilechooser.md) |
| `xdg-desktop-portal` | Portal preference configuration for the Hyprland desktop session. | [README](xdg-desktop-portal/README_xdg_desktop_portal.md) |
| `yazi` | Terminal file manager configuration, packages, keymaps, launcher, and live theme reload helper. | [README](yazi/README_yazi.md) |
| `zellij` | Primary local terminal multiplexer configuration, launcher, and prepared runtime theme. | [README](zellij/README_zellij.md) |
| `zsh` | Modular shell environment using Sheldon, Starship, aliases, tools, and terminal integrations. | [README](zsh/README_zsh.md) |

Application-specific logic should remain in its component directory, while reusable orchestration belongs under `scripts/`.
