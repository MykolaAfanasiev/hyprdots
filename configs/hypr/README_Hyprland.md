<div align="center">

# Hyprland Configuration

**A modular, keyboard-driven Hyprland setup written in Lua.**

[Русская версия](README_Hyprland.ru.md)

![Hyprland](https://img.shields.io/badge/Hyprland-Lua-58E1FF?style=flat-square)
![Wayland](https://img.shields.io/badge/Wayland-ready-6B6B6B?style=flat-square)
![Status](https://img.shields.io/badge/status-personal%20configuration-orange?style=flat-square)

</div>

> [!IMPORTANT]
> This is a personal configuration rather than a universal installer. Review the monitor, application, and path settings before using it on another system.

## Overview

This directory contains the Hyprland part of my dotfiles. The configuration is split into small Lua modules for monitors, input, appearance, animations, autostart, window rules, keybindings, submaps, and special workspaces.

The setup is designed around:

- keyboard-first navigation;
- reusable Lua modules;
- Vim-style window focus;
- named special workspaces;
- a multi-step screenshot submap;
- clipboard history and notification controls;
- smooth but relatively lightweight animations.

## Highlights

- Modular Lua entry point in `hyprland.lua`
- US and Russian keyboard layouts
- `Alt + Shift` layout switching
- Dwindle layout with preserved splits
- Vim-style focus using `H`, `J`, `K`, and `L`
- Workspaces `1`–`10`
- Special workspaces for terminal, notes, and system monitoring
- Screenshot menu integrated with `screenshot-tool`
- Clipboard history through `cliphist`
- Media, volume, and brightness controls
- Touchpad workspace gesture
- Keyboard-driven configuration submap

## Directory structure

```text
hypr/
├── .luarc.json
├── hyprland.lua
└── modules/
    ├── animations.lua
    ├── autostart.lua
    ├── decoration.lua
    ├── input.lua
    ├── misc.lua
    ├── monitor.lua
    ├── special_workspaces.lua
    ├── windowsrules.lua
    ├── submaps/
    │   ├── clean.lua
    │   ├── config-submap.lua
    │   ├── screenshot.lua
    │   ├── submaps.lua
    │   └── utils.lua
    └── vars/
        ├── global.lua
        └── variables.lua
```

## Module overview

| Module | Purpose |
|---|---|
| `hyprland.lua` | Loads all configuration modules |
| `monitor.lua` | Monitor output, resolution, position, and scale |
| `input.lua` | Keyboard layouts, pointer settings, and gestures |
| `decoration.lua` | Gaps, borders, rounding, shadows, and blur |
| `animations.lua` | Curves, springs, animations, and layout options |
| `autostart.lua` | Starts wallpaper, bar, notifications, clipboard, and idle services |
| `windowsrules.lua` | Window and XWayland rules |
| `special_workspaces.lua` | Named scratchpad-style workspaces |
| `submaps/submaps.lua` | Main keybindings and submap registration |
| `submaps/screenshot.lua` | Screenshot selection workflow |
| `submaps/clean.lua` | Minimal submap with a reset binding |
| `vars/global.lua` | Main modifier and application commands |
| `vars/variables.lua` | Wayland, cursor, toolkit, and XDG environment variables |
| `submaps/config-submap.lua` | Configuration submap for controlling Waybar and other configurable components |
| `submaps/utils.lua` | Shared helper functions for switching between submaps |

## Requirements

### Core

- Hyprland with Lua configuration support
- GNU Stow, or another method for creating symlinks

### Commands used by the configuration

The configuration calls the following programs. Install only the components you intend to use:

| Purpose | Commands |
|---|---|
| Terminal | `kitty` |
| Application launcher | `wofi` |
| Status bar | `waybar` |
| Notifications | `swaync`, `swaync-client`, `notify-send` |
| Wallpaper | `hyprpaper` |
| Idle management | `hypridle` |
| Clipboard | `cliphist`, `wl-copy`, `wl-paste`, `wl-clip-persist` |
| Screenshots | `screenshot-tool` |
| Brightness | `brightnessctl` |
| Audio | `pactl` |
| Media | `playerctl` |
| Notes workspace | `obsidian` |
| System monitor | `btop` |

Check a command with:

```bash
command -v kitty
```

## Installation

The current configuration contains paths that expect the repository at:

```text
~/.config/.dotfiles
```

Clone the repository there:

```bash
git clone <repository-url> "$HOME/.config/.dotfiles"
```

Back up an existing Hyprland configuration before continuing:

```bash
mv "$HOME/.config/hypr" "$HOME/.config/hypr.backup"
mkdir -p "$HOME/.config/hypr"
```

Link the Hyprland package with GNU Stow:

```bash
stow \
  --dir="$HOME/.config/.dotfiles/configs" \
  --target="$HOME/.config/hypr" \
  hypr
```

Reload Hyprland:

```bash
hyprctl reload
```

To update the links later:

```bash
stow --restow \
  --dir="$HOME/.config/.dotfiles/configs" \
  --target="$HOME/.config/hypr" \
  hypr
```

## Configuration before first use

### Monitor

The included monitor configuration is currently tailored to:

```lua
hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = "1.33",
})
```

Find your monitor names with:

```bash
hyprctl monitors
```

Then edit:

```text
modules/monitor.lua
```

### Applications and modifier

Application commands and the primary modifier are defined in:

```text
modules/vars/global.lua
```

Current defaults:

```lua
M.mainMod = "SUPER"
M.terminal = "kitty"
M.fileManager = "dolphin"
```

### Repository paths

Some commands currently reference this path directly:

```text
$HOME/.config/.dotfiles/configs/hypr
```

Keep the repository at `~/.config/.dotfiles`, or replace these paths in:

- `modules/autostart.lua`
- `modules/vars/global.lua`

### Auxiliary configuration files

`autostart.lua` and `global.lua` reference configuration files for:

- Hyprpaper
- Hypridle
- Waybar
- SwayNC
- Wofi

These files must exist at the referenced paths, or the commands should be changed to match your own configuration layout.

## Keybindings

`SUPER` is the default main modifier.

### Applications and system actions

| Binding | Action |
|---|---|
| `SUPER + Enter` | Open Kitty |
| `SUPER + Space` | Open Wofi |
| `Ctrl + X` | Close the active window |
| `Alt + N` | Toggle SwayNC |
| `SUPER + Shift + V` | Open clipboard history |
| `Print` | Take a quick screenshot |
| `SUPER + Shift + S` | Open the screenshot submap |

### Window management

| Binding | Action |
|---|---|
| `SUPER + F` | Toggle floating mode |
| `SUPER + Shift + F` | Toggle fullscreen |
| `SUPER + V` | Toggle the Dwindle split direction |
| `SUPER + H/J/K/L` | Focus left/down/up/right window |
| `SUPER + Tab` | Focus the next monitor |
| `SUPER + Shift + Tab` | Move the active window to the next monitor |
| `SUPER + Left Mouse` | Move a window |
| `SUPER + Right Mouse` | Resize a window |

### Workspaces

| Binding | Action |
|---|---|
| `SUPER + 1…9` | Switch to workspace `1…9` |
| `SUPER + 0` | Switch to workspace `10` |
| `SUPER + Shift + 1…9` | Move the active window to workspace `1…9` |
| `SUPER + Shift + 0` | Move the active window to workspace `10` |
| `SUPER + Mouse Wheel` | Cycle through existing workspaces |

### Special workspaces

Each special workspace launches its application when created empty.

| Workspace | Toggle | Move active window | Application |
|---|---|---|---|
| Terminal | `SUPER + T` | `SUPER + Shift + T` | `kitty` |
| Notes | `SUPER + N` | `SUPER + Shift + N` | `obsidian` |
| Monitor | `SUPER + B` | `SUPER + Shift + B` | `kitty -e btop` |

### Media controls

The standard brightness, volume, mute, play/pause, next, and previous hardware keys are configured through `brightnessctl`, `pactl`, and `playerctl`.

## Screenshot submap

The screenshot integration expects this executable:

```text
~/.local/bin/screenshot-tool
```

See the dedicated documentation in:

```text
../../scripts/screenshot/README.md
```

Open the screenshot menu:

```text
SUPER + Shift + S
```

Choose the capture type:

| Key | Mode |
|---|---|
| `F` | Fullscreen |
| `A` | Select an area |
| `Esc` | Close the screenshot menu |

Then choose an action:

| Key | Copy | Save | Edit |
|---|:---:|:---:|:---:|
| `1` | Yes | Yes | No |
| `2` | Yes | Yes | Yes |
| `3` | Yes | No | No |
| `4` | Yes | No | Yes |
| `5` | No | Yes | No |
| `6` | No | Yes | Yes |

Inside a mode submenu:

- `Esc` returns to capture-type selection.
- `Shift + Esc` closes all screenshot submaps.

## Config submap

The `config` submap provides a keyboard-driven interface for controlling
configurable components without adding more global keybindings.

Open the config submap:

```text
SUPER + Ctrl + Shift + N
```

Available sections:

| Key | Action |
|---|---|
| `W` | Open the Waybar configuration submap |
| `Esc` | Return to the global keymap |

### Waybar configuration

Inside the Waybar configuration submap:

| Key | Action |
|---|---|
| `1` | Toggle the Waybar clock between compact and expanded modes |
| `Esc` | Return to the main `config` submap |
| `Shift + Esc` | Return directly to the global keymap |

Current navigation flow:

```text
SUPER + Ctrl + Shift + N
        ↓
      config
        ↓ W
  config_waybar
        ↓ 1
   toggle clock
        ↓
      reset
```

The submap structure is designed to be extended later with additional
Waybar and system configuration actions.

## Submap safety bindings

| Binding | Action |
|---|---|
| `SUPER + Ctrl + Shift + C` | Enter the `clean` submap |
| `SUPER + Ctrl + Shift + Esc` | Reset from the `clean` submap |
| `SUPER + Ctrl + Shift + Alt + Esc` | Universal return to the global keymap |

## Input configuration

The current keyboard configuration uses:

```text
Layouts:  us, ru
Variant:  intl,
Switch:   Alt + Shift
```

A three-finger horizontal touchpad gesture switches workspaces.

## Troubleshooting

### Reload the configuration

```bash
hyprctl reload
```

### View Hyprland errors

```bash
hyprctl configerrors
```

### Verify the symlinks

```bash
ls -la "$HOME/.config/hypr"
```

### A keybinding command does not run

Check whether the command is available in Hyprland's environment:

```bash
command -v screenshot-tool
```

For executables installed in `~/.local/bin`, make sure that directory is included in `PATH` before Hyprland starts.

### An autostart component is missing

Run the command manually in a terminal, then check the paths in `modules/autostart.lua` and `modules/vars/global.lua`.

## Current limitations

- The monitor name and scale are machine-specific.
- Several paths assume the repository is located at `~/.config/.dotfiles`.
- Auxiliary Waybar, SwayNC, Wofi, Hyprpaper, and Hypridle files are referenced but are not part of this Hyprland directory.
- Some applications are personal defaults and may not be installed on another machine.

## License

This configuration is distributed under the license found in the repository root.
