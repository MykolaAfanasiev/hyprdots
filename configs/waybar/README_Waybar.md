# Waybar Configuration

A minimal and modular Waybar configuration designed for Hyprland.

The setup focuses on a clean visual layout, keyboard-driven controls, and easy customization.

[Русская версия](README_Waybar.ru.md) · [Back to hyprdots](../../)

## Features

- Hyprland workspace integration
- Active Hyprland submap indicator
- Keyboard layout indicator
- WirePlumber volume module
- System tray
- Custom clock with compact and expanded modes
- Keyboard-controlled Waybar restart
- Catppuccin Mocha color theme
- Modular CSS theme structure
- Dedicated launch script
- Integration with the Hyprland `config` submap

## Structure

```text
waybar/
├── config.jsonc
├── style.css
├── launch.sh
├── scripts/
│   └── clock.sh
└── themes/
    ├── current.css
    └── catppuccin-mocha.css
```

### Files

| File | Description |
|---|---|
| `config.jsonc` | Main Waybar configuration |
| `style.css` | Main stylesheet and module layout |
| `launch.sh` | Waybar launcher |
| `scripts/clock.sh` | Custom clock state and rendering logic |
| `themes/current.css` | Imports the currently active color theme |
| `themes/catppuccin-mocha.css` | Catppuccin Mocha color palette |

## Layout

The current module layout is:

```text
Left                 Center                 Right
────────────────────────────────────────────────────────
Workspaces            Submap     Tray  Language  Volume  Clock
```

Configured approximately as:

```jsonc
"modules-left": [
    "hyprland/workspaces"
],

"modules-center": [
    "hyprland/submap"
],

"modules-right": [
    "tray",
    "hyprland/language",
    "wireplumber",
    "custom/clock"
]
```

## Launching Waybar

Waybar is started through `launch.sh` instead of invoking `waybar`
directly from the Hyprland configuration.

```bash
./launch.sh
```

The launcher determines its own directory and exports it as
`WAYBAR_CONFIG_DIR`:

```bash
#!/usr/bin/env bash

WAYBAR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export WAYBAR_CONFIG_DIR="$WAYBAR_DIR"

exec waybar \
    -c "$WAYBAR_DIR/config.jsonc" \
    -s "$WAYBAR_DIR/style.css"
```

This allows scripts referenced by Waybar to work independently of the
location of the dotfiles repository.

## Custom Clock

The standard Waybar clock module is replaced with a custom script:

```text
scripts/clock.sh
```

The clock has two display modes.

Compact mode:

```text
14:32
```

Expanded mode:

```text
Monday, August 10, 2026 14:32:45
```

The script stores its current state inside the runtime directory and can
be toggled with:

```bash
./scripts/clock.sh toggle
```

Waybar continuously reads the clock output with:

```jsonc
"custom/clock": {
    "exec": "$WAYBAR_CONFIG_DIR/scripts/clock.sh watch",
    "format": "{}",
    "tooltip": false
}
```

## Hyprland Config Submap

Waybar controls are integrated into the Hyprland configuration submap.

Navigation:

```text
SUPER + Ctrl + Shift + N
        ↓
      config
        ↓ W
  config_waybar
```

Inside `config_waybar`:

| Key | Action |
|---|---|
| `1` | Toggle compact / expanded clock |
| `R` | Restart Waybar |
| `Esc` | Return to the main config submap |
| `Shift + Esc` | Return to the global keymap |

Restarting Waybar kills the current Waybar process and starts it again
through `launch.sh`.

## Workspaces

The workspace module uses Hyprland workspace information:

```text
hyprland/workspaces
```

Named special workspaces are also supported.

Current special workspace icons include:

```text
terminal   → 
monitor    → 󰍛
notes      → 󰎚
```

## Audio

Audio information is provided by the WirePlumber module:

```text
wireplumber
```

The module displays the current volume and an audio icon.

Example:

```text
󰕿 100%
```

## Styling

The bar itself is transparent while individual modules use their own
background containers.

Typical module styling:

```css
#workspaces,
#submap,
#tray,
#language,
#wireplumber,
#custom-clock {
    background: @module_bg;
    color: @module_fg;

    margin: 0.3em 0.2em;
    padding: 0 0.75em;

    border-radius: 0.6em;
}
```

Most spacing values use `em`, allowing the layout to scale together with
the configured font size.

## Themes

Colors are separated from the main Waybar stylesheet.

`style.css` imports:

```css
@import "themes/current.css";
```

`themes/current.css` selects the active theme.

For example:

```css
@import "catppuccin-mocha.css";
```

The current theme is based on Catppuccin Mocha.

Semantic colors are used by the main stylesheet:

```css
@define-color bar_bg transparent;

@define-color module_bg @surface0;
@define-color module_fg @text;
@define-color module_hover @surface1;

@define-color accent @mauve;
@define-color accent_fg @crust;

@define-color muted @overlay0;
@define-color warning @yellow;
@define-color critical @red;
```

This keeps component styling independent from the actual color palette
and makes switching themes easier.

## Font

A Nerd Font is required for workspace, audio, and status icons.

Recommended:

```text
JetBrainsMono Nerd Font
```

Example:

```css
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    font-weight: 500;
}
```

## Dependencies

The configuration expects the following components:

```text
waybar
wireplumber
Hyprland
Nerd Font
```

The custom clock script also requires a standard POSIX-like shell
environment with `bash` and `date`.

## Design Goals

The configuration follows a few simple principles:

- minimal visual noise
- independent module containers
- keyboard-first controls
- reusable scripts
- centralized paths
- easily replaceable color themes
- no hardcoded repository location
