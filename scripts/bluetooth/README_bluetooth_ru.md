# Bluetooth backend и frontend

[English version](README_bluetooth.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

`bluetooth.sh` предоставляет структурированный CLI поверх `bluetoothctl`/BlueZ; `rofi.sh` является интерактивным frontend.

## CLI

```bash
./scripts/bluetooth/bluetooth.sh status
./scripts/bluetooth/bluetooth.sh toggle
./scripts/bluetooth/bluetooth.sh list
./scripts/bluetooth/bluetooth.sh scan 5
./scripts/bluetooth/bluetooth.sh info AA:BB:CC:DD:EE:FF
./scripts/bluetooth/bluetooth.sh pair AA:BB:CC:DD:EE:FF
./scripts/bluetooth/bluetooth.sh connect AA:BB:CC:DD:EE:FF
./scripts/bluetooth/bluetooth.sh trust AA:BB:CC:DD:EE:FF
./scripts/bluetooth/bluetooth.sh rename AA:BB:CC:DD:EE:FF 'Device name'
```

Backend также поддерживает disconnect, untrust, block/unblock и remove.
