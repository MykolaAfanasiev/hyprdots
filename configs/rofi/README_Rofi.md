# Rofi Configuration

A minimal and modular Rofi configuration for Hyprland.

The setup provides a combined application/window launcher and clipboard history while keeping the same visual style as the rest of the desktop configuration.

[Русская версия](README_Rofi.ru.md) · [Back to hyprdots](../../)

## Features

- Combined `drun` and `window` launcher
- Short `D` / `W` mode prefixes
- Fuzzy matching
- Application icons
- Two-column result layout
- Catppuccin Mocha color theme
- Dedicated launcher script
- Clipboard history through `cliphist`
- Clipboard persistence through `wl-clip-persist`
- Shared Rofi styling for launcher and clipboard picker
- Hyprland keybind integration
- Repository-independent paths through the Hyprland path module

## Structure

```text
rofi/
├── config.rasi
├── theme.rasi
├── launch.sh
├── clipboard.sh
└── themes/
    ├── current.rasi
    └── catppuccin-mocha.rasi
```

### Files

| File | Description |
|---|---|
| `config.rasi` | Main Rofi behavior and mode configuration |
| `theme.rasi` | Main layout and widget styling |
| `launch.sh` | Starts the main Rofi launcher |
| `clipboard.sh` | Opens clipboard history and restores the selected entry |
| `themes/current.rasi` | Imports the currently active color palette |
| `themes/catppuccin-mocha.rasi` | Catppuccin Mocha color palette |

## Launcher

The main launcher uses Rofi `combi` mode and combines:

```text
W → open windows
D → installed applications
```

Current configuration:

```rasi
configuration {
    modes: [ combi ];
    combi-modes: [ window, drun ];

    combi-hide-mode-prefix: false;
    combi-display-format: "{mode} {text}";

    window {
        display-name: "W";
    }

    drun {
        display-name: "D";
    }

    show-icons: true;
    matching: "fuzzy";
    sorting-method: "fzf";

    drun-display-format: "{name}";
    window-format: "{c} · {t:20}";

    font: "JetBrainsMono Nerd Font 13";
}

@theme "theme.rasi"
```

This keeps application names compact while window titles are shortened to 20 characters.

## Launch Script

Rofi is started through `launch.sh` instead of relying on the default `~/.config/rofi` location.

```bash
#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec rofi \
    -config "$ROFI_DIR/config.rasi" \
    -show combi
```

The script resolves its own directory, so the configuration can be launched regardless of the current working directory.

## Clipboard History

Clipboard history is provided by:

```text
wl-clipboard
    ↓
cliphist
    ↓
Rofi
    ↓
wl-copy
```

Hyprland starts clipboard watchers when the session starts:

```lua
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type image --watch cliphist store")
hl.exec_cmd("wl-clip-persist --clipboard regular")
```

`clipboard.sh` opens the stored clipboard entries in Rofi:

```bash
#!/usr/bin/env bash

ROFI_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

selection="$(
    cliphist list |
        rofi \
            -dmenu \
            -display-columns 2 \
            -config "$ROFI_DIR/config.rasi" \
            -theme "$ROFI_DIR/theme.rasi"
)"

[[ -z "$selection" ]] && exit 0

printf '%s\n' "$selection" |
    cliphist decode |
    wl-copy
```

Selecting an entry restores it to the regular Wayland clipboard. It can then be pasted normally with `Ctrl + V`.

## Hyprland Integration

Rofi paths are centralized in the Hyprland path module:

```lua
M.rofi = {
    root = project_root .. "configs/rofi/",
    launch = project_root .. "configs/rofi/launch.sh",
    clipboard = project_root .. "configs/rofi/clipboard.sh",
}
```

Current keybindings:

| Key | Action |
|---|---|
| `SUPER + Space` | Open Rofi launcher |
| `SUPER + Shift + V` | Open clipboard history |

The bindings use the centralized paths instead of hardcoded repository locations.

## Layout

The launcher uses a centered search field and a two-column result list:

```text
╭────────────────────────────────────────────────────╮
│                       Search                       │
│                                                    │
│  D Firefox                    D Obsidian            │
│  W firefox · ChatGPT          D Kitty               │
│  D Visual Studio Code         W kitty · nvim        │
╰────────────────────────────────────────────────────╯
```

The search placeholder disappears automatically when typing.

## Styling

The main theme separates Rofi behavior from visual styling.

```text
config.rasi
    ↓
theme.rasi
    ↓
themes/current.rasi
    ↓
themes/catppuccin-mocha.rasi
```

The main window uses the Catppuccin base color while the search field and selected entries use surface colors.

Example:

```rasi
window {
    background-color: @base;
    border-color: @surface1;
    border-radius: 14px;
}

inputbar {
    background-color: @surface0;
    border-radius: 14px;
}

element selected.normal {
    background-color: @surface0;
    text-color: @text;
}
```

## Themes

The active palette is selected through:

```text
themes/current.rasi
```

Current configuration:

```rasi
@import "catppuccin-mocha.rasi"
```

This keeps palette selection separate from the main layout and makes adding more themes straightforward.

## Font

The configuration uses:

```text
JetBrainsMono Nerd Font
```

A Nerd Font is recommended so application and desktop icons render correctly.

## Dependencies

The current setup expects:

```text
rofi
cliphist
wl-clipboard
wl-clip-persist
JetBrainsMono Nerd Font
```

## Design Goals

- keyboard-first workflow
- one launcher for applications and windows
- fast fuzzy search
- minimal visual noise
- shared visual language with Waybar
- reusable launch scripts
- centralized repository paths
- separate layout and color palette
- simple clipboard history without a separate GUI application
