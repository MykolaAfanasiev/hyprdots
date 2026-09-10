# NetworkManager backend и frontend

[English version](README_networkmanager.md) · [Скрипты](../README_scripts_ru.md) · [Проект](../../README_ru.md)

`network.sh` — Wi-Fi CLI-backend на `nmcli`; `rofi.sh` даёт интерактивный выбор сети, не перенося network-логику в Rofi.

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

Saved profiles, активный SSID, signal/security и connection actions определяются через NetworkManager.
