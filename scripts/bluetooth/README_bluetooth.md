# Bluetooth backend and frontend

[Русская версия](README_bluetooth_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

`bluetooth.sh` provides a structured CLI over `bluetoothctl`/BlueZ; `rofi.sh` is the interactive frontend.

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

The backend also supports disconnect, untrust, block/unblock, and remove operations.
