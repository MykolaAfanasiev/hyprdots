# Package manifests

[English version](README_packages.md) · [Installer](../README_setup_ru.md) · [Проект](../../README_ru.md)

Package manifests разделены по ролям и содержат ровно одно имя пакета на строку без комментариев, чтобы installer мог читать их напрямую.

- `arch-required.txt` — обязательные пакеты для конфигурации и installer-integrated компонентов.
- `arch-recommended.txt` — рекомендуемые desktop/Wayland integrations и optional preview tools.
- `arch-default-apps.txt` — user-facing приложения по умолчанию, которые можно пропустить группой.
- `aur-required.txt` — обязательные пакеты вне официальных Arch repositories.

Текущий stack включает Matugen/ImageMagick для Dynamic/Hybrid themes, Rofimoji и emoji fonts для Launcher, PipeWire/WirePlumber, terminal workflow, NetworkManager/BlueZ и MPD/RMPC. Сам Mouseless устанавливается installer из pinned Go module, поэтому `go` находится в required Arch packages.

Installer разворачивает `configs -> ~/.config` и `home -> ~` через GNU Stow и намеренно не использует `--adopt`.
