# NetworkManager backend and frontend

[Русская версия](README_networkmanager_ru.md) · [Scripts](../README_scripts.md) · [Project](../../README.md)

`network.sh` is the Wi-Fi CLI backend built on `nmcli`; `rofi.sh` provides interactive network selection without moving network logic into Rofi.

## CLI

```bash
./scripts/networkmanager/network.sh status
./scripts/networkmanager/network.sh on
./scripts/networkmanager/network.sh off
./scripts/networkmanager/network.sh toggle
./scripts/networkmanager/network.sh list
./scripts/networkmanager/network.sh connect '<ssid>'
./scripts/networkmanager/network.sh disconnect
./scripts/networkmanager/network.sh forget '<ssid>'
./scripts/networkmanager/network.sh rescan
./scripts/networkmanager/network.sh info '<ssid>'
```

Saved profiles, active SSIDs, signal/security information, and connection actions are resolved through NetworkManager.
