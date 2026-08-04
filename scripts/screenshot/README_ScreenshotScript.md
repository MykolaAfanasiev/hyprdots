<div align="center">

# Screenshot Tool

A small command-line screenshot utility for **Wayland**, built for a keyboard-driven **Hyprland** workflow.

[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Wayland](https://img.shields.io/badge/Wayland-supported-black?logo=linux&logoColor=white)](https://wayland.freedesktop.org/)
[![Status](https://img.shields.io/badge/status-work%20in%20progress-orange)](#roadmap)

[Русская версия](README_ScreenshotScript.ru.md) · [Back to hyprdots](../../)

</div>

## About

`Screenshot Tool` combines `grim`, `slurp`, `satty`, `wl-copy`, and desktop notifications behind one simple command.

It can capture the full screen or a selected area, open the result in Satty, copy it to the clipboard, save it to a file, or combine these actions. The tool is also integrated into the Hyprland configuration through a screenshot submap.

## Features

- Fullscreen screenshots with `grim`
- Interactive area selection with `slurp`
- Optional editing and annotation with `satty`
- Clipboard support through `wl-copy`
- Optional file saving
- Custom output paths
- Desktop notifications
- Dependency checks based on the selected options
- Installable `screenshot-tool` command
- Hyprland screenshot submap

## Default behaviour

Running the command without options:

```bash
screenshot-tool
```

will:

1. capture the full screen;
2. copy the image to the clipboard;
3. save it to `~/Screenshots`;
4. show a desktop notification.

The generated filename uses this format:

```text
screenshot_YYYY-MM-DD_HH-MM-SS.png
```

## Requirements

### Python

- Python 3.10 or newer
- Click 8.1 or newer

### External commands

| Command | Package or tool | Used for | Required when |
|---|---|---|---|
| `grim` | grim | Capturing screenshots | Always |
| `notify-send` | libnotify | Desktop notifications | Always |
| `slurp` | slurp | Selecting an area | `--area` |
| `satty` | satty | Editing screenshots | `--edit` |
| `wl-copy` | wl-clipboard | Copying images | Clipboard copying is enabled |

### Arch Linux

```bash
sudo pacman -S grim slurp satty wl-clipboard libnotify python-pipx
```

## Installation

The project defines a console entry point named `screenshot-tool` in `pyproject.toml`.

### Editable installation

Use this during development so changes to the source code are applied immediately:

```bash
cd ~/.config/.dotfiles/scripts/screenshot
pipx install --editable .
```

Make sure the Pipx binary directory is in your `PATH`:

```bash
pipx ensurepath
```

Restart the terminal, then verify the installation:

```bash
command -v screenshot-tool
screenshot-tool --help
```

### Reinstall after packaging changes

```bash
pipx reinstall screenshot-tool
```

### Uninstall

```bash
pipx uninstall screenshot-tool
```

## Usage

```text
Usage: screenshot-tool [OPTIONS]

Options:
  --area / --fullscreen  Select an area or capture the full screen.
  --edit / --no-edit     Open the screenshot in Satty.
  --copy / --no-copy     Copy the screenshot to the clipboard.
  --save / --no-save     Save the screenshot as a file.
  -o, --output FILE      Set a custom output path.
  --help                 Show the help message.
```

## Examples

### Fullscreen, copy and save

```bash
screenshot-tool
```

### Select an area, copy and save

```bash
screenshot-tool --area
```

### Select an area and edit it

```bash
screenshot-tool --area --edit
```

### Copy without saving

```bash
screenshot-tool --no-save
```

A temporary screenshot is created for clipboard copying and removed after the operation.

### Save without copying

```bash
screenshot-tool --no-copy
```

### Save to a custom path

```bash
screenshot-tool --output ~/Pictures/example.png
```

The parent directory is created automatically when it does not exist.

### Area screenshot, edit and copy without saving

```bash
screenshot-tool --area --edit --no-save
```

## Hyprland integration

The tool is integrated into the Lua-based Hyprland configuration.

### Quick screenshot

| Key | Action |
|---|---|
| `Print` | Fullscreen screenshot, copy and save |

### Open the screenshot menu

| Key | Action |
|---|---|
| `Super + Shift + S` | Open the screenshot submap |

### Select capture mode

| Key | Action |
|---|---|
| `F` | Fullscreen options |
| `A` | Area-selection options |
| `Esc` | Close the screenshot menu |

### Screenshot actions

The following keys work inside both the fullscreen and area submaps:

| Key | Action |
|---|---|
| `1` | Copy and save |
| `2` | Edit, copy and save |
| `3` | Copy without saving |
| `4` | Edit and copy without saving |
| `5` | Save without copying |
| `6` | Edit and save without copying |
| `Esc` | Return to capture-mode selection |
| `Shift + Esc` | Close all screenshot submaps |

The integration is located at:

```text
configs/hypr/modules/submaps/screenshot.lua
```

## Project structure

```text
scripts/screenshot/
├── cli/
│   ├── __init__.py
│   ├── cli_options.py       # Click option definitions
│   └── option_class.py      # Immutable screenshot options
├── utils/
│   ├── dependencies.py      # External dependency checks
│   ├── notify.py            # Desktop notifications
│   ├── run_command.py       # subprocess wrapper
│   ├── screenshot_path.py   # Default path and filename generation
│   └── screenshot_tools.py  # Capture, edit, copy and save logic
├── main.py                  # CLI entry point
└── pyproject.toml           # Package metadata and console command
```

## Exit codes

| Code | Meaning |
|---:|---|
| `0` | Screenshot operation completed successfully |
| `1` | Area selection was cancelled |
| `2` | Screenshot capture failed |
| `3` | Screenshot editing was cancelled or failed |
| `4` | Copying to the clipboard failed |

Missing dependencies and invalid option combinations are reported by Click before the screenshot workflow starts.

## Roadmap

- [x] Install the project as a real `screenshot-tool` command
- [x] Add fullscreen and area capture modes
- [x] Add clipboard and file-saving options
- [x] Add Satty editing
- [x] Add dependency checks
- [x] Add Hyprland screenshot submaps
- [ ] Add `--notify/--no-notify`
- [ ] Add a screenshot delay option
- [ ] Add cursor inclusion and exclusion options
- [ ] Add monitor selection
- [ ] Add active-window capture
- [ ] Add a configuration file
- [ ] Add configurable filename templates
- [ ] Replace the current intermediate file workflow with a proper temporary file
- [ ] Add more detailed error messages
- [ ] Add tests
- [ ] Add a demo image or GIF

## Current status

This utility is part of a personal dotfiles project and is still under active development. Command-line options and internal structure may change.
