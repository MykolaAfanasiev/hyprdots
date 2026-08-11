# SwayNC Configuration

A minimal and modular SwayNC configuration for Hyprland.

The setup provides floating notifications, a notification control center, Do Not Disturb mode, Catppuccin Mocha styling, and keyboard-driven control through Hyprland.

[Русская версия](README_SwayNC.ru.md) · [Back to hyprdots](../../)

## Features

- Floating desktop notifications
- Notification Control Center
- Do Not Disturb mode
- Notification grouping
- Relative timestamps
- Notification images when available
- Separate timeouts for low, normal, and critical notifications
- Catppuccin Mocha color theme
- Transparent Control Center and notification cards
- Separate transparency for floating notifications
- Modular CSS theme structure
- Dedicated launch script
- Centralized control script for toggle, DND, and reload actions
- Hyprland keybind and `config` submap integration
- Repository-independent paths through the Hyprland path module
- JSON Schema support for configuration validation and editor completion

## Structure

```text
swaync/
├── config.json
├── style.css
├── launch.sh
├── scripts/
│   └── control.sh
└── themes/
    ├── current.css
    └── catppuccin-mocha.css
```

### Files

| File | Description |
|---|---|
| `config.json` | Main SwayNC behavior and widget configuration |
| `style.css` | Main notification and Control Center layout/styling |
| `launch.sh` | Starts SwayNC with the repository configuration |
| `scripts/control.sh` | Controls the panel, DND state, and configuration reload |
| `themes/current.css` | Imports the currently active color palette |
| `themes/catppuccin-mocha.css` | Catppuccin Mocha palette and SwayNC semantic variables |

## Configuration

The configuration uses the system SwayNC JSON Schema:

```json
{
  "$schema": "/etc/xdg/swaync/configSchema.json"
}
```

The schema is not part of the dotfiles configuration itself. It is provided by SwayNC and can be used by editors for validation and completion.

The current notification placement is:

```text
Horizontal: right
Vertical:   top
```

The Control Center and floating notification window are currently configured with a width of `500` pixels.

### Timeouts

```text
Low       5 seconds
Normal   10 seconds
Critical  disabled
```

A critical notification remains visible until it is dismissed or acted on.

## Control Center

The current Control Center contains three widgets:

```text
Notifications title + Clear All
Do Not Disturb
Notification list
```

Configured through:

```json
"widgets": [
  "title",
  "dnd",
  "notifications"
]
```

The notification list expands to fill the remaining space.

## Launch Script

SwayNC is started through `launch.sh` instead of depending on the default `~/.config/swaync` location.

```bash
#!/usr/bin/env bash

SWAYNC_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec swaync \
    -c "$SWAYNC_DIR/config.json" \
    -s "$SWAYNC_DIR/style.css"
```

The script resolves its own directory, so the configuration works independently of the repository location.

## Control Script

Runtime actions are centralized in:

```text
scripts/control.sh
```

Supported actions:

```bash
./scripts/control.sh toggle
./scripts/control.sh dnd
./scripts/control.sh reload
```

### Toggle Control Center

```bash
swaync-client -t
```

Opens or closes the SwayNC Control Center.

### Toggle Do Not Disturb

```bash
swaync-client -d
```

Toggles Do Not Disturb mode.

### Reload

```bash
swaync-client -R
swaync-client -rs
```

Reloads both `config.json` and `style.css` without restarting the SwayNC daemon.

The control script is also the preferred place for optional Hyprland feedback notifications such as:

```text
Do Not Disturb: ON
Do Not Disturb: OFF
SwayNC reloaded
```

This keeps runtime feedback logic out of the Hyprland keybinding files.

## Hyprland Integration

SwayNC paths are centralized in the Hyprland path module:

```lua
M.swaync = {
    root = project_root .. "configs/swaync/",
    launch = project_root .. "configs/swaync/launch.sh",
    control = project_root .. "configs/swaync/scripts/control.sh",
}
```

SwayNC is started automatically when the Hyprland session starts:

```lua
hl.exec_cmd(paths.swaync.launch)
```

### Global keybinding

```text
ALT + N → toggle Control Center
```

The binding calls the shared control script:

```lua
hl.bind(
    "ALT + N",
    hl.dsp.exec_cmd(paths.swaync.control .. " toggle")
)
```

## Hyprland Config Submap

SwayNC controls are integrated into the Hyprland `config` submap.

Navigation:

```text
SUPER + Ctrl + Shift + N
        ↓
      config
        ↓ S
  config_swaync
```

Inside `config_swaync`:

| Key | Action |
|---|---|
| `D` | Toggle Do Not Disturb |
| `R` | Reload SwayNC config and CSS |
| `Esc` | Return to the main config submap |
| `Shift + Esc` | Return to the global keymap |

## Styling

The visual configuration is separated from the color palette:

```text
style.css
    ↓
themes/current.css
    ↓
themes/catppuccin-mocha.css
```

`style.css` defines layout and widget appearance, while the theme file provides colors and shared semantic variables.

The configuration uses:

```text
JetBrainsMono Nerd Font
```

Current design principles include:

- Catppuccin Mocha colors
- rounded notification cards
- transparent floating notification window
- transparent Control Center background
- subtle notification borders
- no notification shadows
- muted secondary text
- mauve accent for active controls
- red accent for critical notifications and close-button hover

## Transparency

The Control Center and notification opacity are controlled independently in the theme.

Current values:

```css
--cc-bg: rgba(30, 30, 46, 0.88);

--noti-bg: 49, 50, 68;
--noti-bg-alpha: 0.92;
--floating-noti-bg-alpha: 0.82;
```

This allows the Control Center, stored notification cards, and floating notifications to use different levels of transparency.

The floating notification style can override the regular notification alpha with:

```css
.floating-notifications
.notification-row
.notification-background
.notification {
    background: rgba(
        var(--noti-bg),
        var(--floating-noti-bg-alpha)
    );
}
```

## Themes

The active theme is selected through:

```text
themes/current.css
```

Current configuration:

```css
@import url("catppuccin-mocha.css");
```

To add another theme, create a new palette file and change only the import in `current.css`.

For example:

```css
@import url("gruvbox.css");
```

The main `style.css` does not need to be rewritten.

## Catppuccin Mocha

The palette includes the standard Catppuccin Mocha colors and a set of SwayNC-specific semantic variables.

Examples:

```css
--cc-bg: rgba(30, 30, 46, 0.88);
--noti-bg: 49, 50, 68;
--noti-bg-hover: var(--surface1);
--noti-border-color: var(--surface1);

--text-color: var(--text);
--accent: var(--mauve);
--critical: var(--red);
```

Keeping semantic variables in the palette makes it possible to change the entire color scheme without changing the SwayNC layout rules.

## Testing

Send a test notification:

```bash
notify-send "SwayNC" "Test notification"
```

Toggle the Control Center:

```bash
./scripts/control.sh toggle
```

Toggle DND:

```bash
./scripts/control.sh dnd
```

Reload the configuration and stylesheet:

```bash
./scripts/control.sh reload
```

## Dependencies

The current setup expects:

```text
swaync
hyprland
JetBrainsMono Nerd Font
```

`notify-send` is useful for manually testing notifications and is normally provided by `libnotify`.

## Design Principles

The configuration follows the same general approach as the Waybar and Rofi modules:

- keep behavior and appearance separate
- keep palettes separate from layout CSS
- avoid hardcoded repository paths
- centralize runtime actions in small scripts
- integrate component controls into Hyprland submaps
- keep the interface keyboard-friendly
- keep visual noise low
- make themes easy to replace
