# Скрипты

[English version](README_scripts.md) · [К проекту](../README_ru.md)

В `scripts/` находится исполняемая логика Hyprdots. Основная архитектура: CLI-backend плюс необязательный frontend. Backend не должен вызывать Rofi; frontend может вызывать backend.

| Компонент | Назначение | Документация |
|---|---|---|
| `launcher` | Единая точка запуска действий и поиска | [README](launcher/README_launcher_ru.md) |
| `control-center` | Агрегация настроек и управления | [README](control-center/README_control_center_ru.md) |
| `theme-switcher` | Fixed/Dynamic/Hybrid theme engine | [README](theme-switcher/README_theme_switcher_ru.md) |
| `wallpaper-switcher` | Состояние wallpaper и picker | [README](wallpaper-switcher/README_wallpaper_switcher_ru.md) |
| `networkmanager` | Wi-Fi backend и Rofi UI | [README](networkmanager/README_networkmanager_ru.md) |
| `bluetooth` | Bluetooth backend и Rofi UI | [README](bluetooth/README_bluetooth_ru.md) |
| `mouseless` | CLI управления сервисом Mouseless | [README](mouseless/README_mouseless_ru.md) |
| `screenshot` | Python screenshot CLI | [README](screenshot/README_screenshot_ru.md) |
| `dev` | Formatter и Git hook utilities | [README](dev/README_dev_ru.md) |

## Правило архитектуры

```text
configuration -> backend CLI -> frontend
```

Так будущий Quickshell или другой frontend можно заменить без переписывания системной логики.
