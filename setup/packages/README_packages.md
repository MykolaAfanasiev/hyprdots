# Package manifests

[Русская версия](README_packages_ru.md) · [Installer](../README_setup.md) · [Project](../../README.md)

Package manifests are intentionally separated by role and contain one package name per line with no comments so the installer can consume them directly.

- `arch-required.txt` — packages required by the configuration or installer-integrated components.
- `arch-recommended.txt` — strongly recommended desktop/Wayland integrations and optional preview tools.
- `arch-default-apps.txt` — default user-facing applications that may be skipped as a group.
- `aur-required.txt` — required packages outside the official Arch repositories.

The current stack includes Matugen/ImageMagick for Dynamic/Hybrid theming, Rofimoji and emoji fonts for the Launcher, the PipeWire/WirePlumber audio stack, terminal workflow tools, NetworkManager/BlueZ integration, and the local MPD/RMPC stack. Mouseless itself is installed from its pinned Go module by the installer, so `go` is a required Arch package rather than Mouseless being listed as an AUR package.

The installer deploys `configs -> ~/.config` and `home -> ~` with GNU Stow and intentionally does not use `--adopt`.
