# Scripts

[Русская версия](README_scripts_ru.md) · [Back to project](../README.md)

`scripts/` contains executable Hyprdots logic. The preferred architecture is a CLI backend plus an optional frontend. Backends should not call Rofi; frontends may call the backend.

| Component | Purpose | Documentation |
|---|---|---|
| `launcher` | Unified actions and search entry point | [README](launcher/README_launcher.md) |
| `control-center` | System settings/control aggregation | [README](control-center/README_control_center.md) |
| `theme-switcher` | Fixed/Dynamic/Hybrid theme engine | [README](theme-switcher/README_theme_switcher.md) |
| `wallpaper-switcher` | Wallpaper state and picker | [README](wallpaper-switcher/README_wallpaper_switcher.md) |
| `networkmanager` | Wi-Fi backend and Rofi UI | [README](networkmanager/README_networkmanager.md) |
| `bluetooth` | Bluetooth backend and Rofi UI | [README](bluetooth/README_bluetooth.md) |
| `mouseless` | Mouseless service CLI | [README](mouseless/README_mouseless.md) |
| `screenshot` | Python screenshot CLI | [README](screenshot/README_screenshot.md) |
| `dev` | Formatting and Git hook utilities | [README](dev/README_dev.md) |

## Design rule

```text
configuration -> backend CLI -> frontend
```

This keeps future frontends, such as Quickshell, replaceable without rewriting system logic.
