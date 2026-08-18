# Package manifests

These files describe the Arch Linux packages used by the current hyprdots setup.
They are intentionally split by role so the future installer can decide what to
install automatically and what to offer as an option.

## Files

- `arch-required.txt` — packages directly required by the configuration or by
  installation of repository components.
- `arch-recommended.txt` — desktop-integration packages strongly recommended
  for a complete Hyprland session, but not directly invoked by most configs.
- `arch-default-apps.txt` — applications referenced by the default values in
  `configs/hypr/modules/vars/global.lua`. These can be skipped when the commands
  are overridden in `local.lua`.
- `aur-required.txt` — required packages that are not in the official Arch
  repositories.

All manifest files contain exactly one package name per line and no comments so
they can be consumed directly by the installation script later.

## Base system assumption

The project targets Arch Linux and assumes the `base` package is installed.
Commands supplied by the base system, such as `bash`, `date`, `shuf`, `find`,
`realpath`, `pgrep`, `pkill`, `flock`, and `systemctl`, are therefore not
repeated in the package manifests.

## Screenshot tool

The screenshot CLI is installed as a local Python application with `pipx`.
Its Python dependency (`click`) remains declared in
`scripts/screenshot/pyproject.toml`; it is intentionally not duplicated in the
Arch package manifests.

Its external runtime commands are covered by the required package list:
`grim`, `slurp`, `satty`, `wl-copy` (from `wl-clipboard`) and `notify-send`
(from `libnotify`).

## Audio

The configuration is built around PipeWire/WirePlumber. Waybar uses its
WirePlumber module and `wpctl`, while Hyprland media key bindings use `pactl`.
The required list therefore selects PipeWire, WirePlumber, PipeWire's PulseAudio
compatibility layer, and the PipeWire JACK provider.

## AUR

`wlogout` is currently installed from the AUR. `base-devel` and `git` are kept
in `arch-required.txt` so a clean installation has the tools needed to build an
AUR package even when no AUR helper is already installed.
