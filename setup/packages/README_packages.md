# Package manifests

These files describe the Arch Linux packages used by the current hyprdots setup.
They are intentionally split by role so the future installer can decide what to
install automatically and what to offer as an option.

## Files

- `arch-required.txt` — packages directly required by the configuration or by
  installation of repository components.
- `arch-recommended.txt` — desktop-integration packages strongly recommended
  for a complete Hyprland session, but not directly invoked by most configs.
- `arch-default-apps.txt` — user-facing applications and optional workflow
  components configured by the repository. These can be skipped when that
  workflow is not wanted.
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

The desktop audio stack is built around PipeWire/WirePlumber. Waybar uses its
WirePlumber module and `wpctl`, while Hyprland media key bindings use `pactl`.
The required list therefore selects PipeWire, WirePlumber, PipeWire's PulseAudio
compatibility layer, and the PipeWire JACK provider.

The default application group also contains the local music stack:

- `mpd` as the playback daemon;
- `mpc` for command-line control and scripting;
- `rmpc` as the interactive TUI client.

MPD is configured to accept local clients through
`$XDG_RUNTIME_DIR/mpd/socket`. The repository deploys a systemd user-unit
drop-in that creates the `mpd` runtime directory, and the installer enables and
restarts `mpd.service` after automatic Stow deployment.

## AUR

The required AUR group currently contains:

- `wlogout` for the graphical power menu;
- `tmux-plugin-manager` for reproducible tmux plugin installation;
- `xdg-desktop-portal-termfilechooser-hunkyburrito-git` for using Yazi as the
  portal file chooser.

`base-devel` and `git` are kept in `arch-required.txt` so a clean installation
has the tools needed to build an AUR package even when no AUR helper is already
installed.

## Terminal workflow

The required package list also covers the complete keyboard-oriented terminal
stack stored in this repository:

- Ghostty as the local terminal;
- Zsh, Sheldon, Starship, fzf, zoxide, eza and bat for the interactive shell;
- Zellij for local terminal multiplexing;
- tmux and TPM for remote/server sessions;
- Neovim for editing and terminal scrollback;
- Yazi for terminal file management and portal file selection.

## Yazi previews

Yazi itself is required. Its optional preview/search tools are kept in the
recommended list: `7zip`, `chafa`, `fd`, `ffmpeg`, `imagemagick`, `jq`,
`poppler`, `resvg` and `ripgrep`. Selecting the recommended group enables the
full preview experience without making those tools mandatory for a minimal
installation.

## GNU Stow layout

The installer deploys two Stow packages with different targets:

```text
configs -> ~/.config
home    -> ~
```

The `configs` package contains application configuration. The `home` package
contains files whose destination is relative to the home directory, currently
`.zshenv` and `.local/share/applications/yazi.desktop`.

The installer never uses `stow --adopt`; an existing unmanaged destination is
therefore reported as a conflict instead of being silently moved into the
repository.

## Repository formatting

`shfmt` is included in the recommended Arch packages because the repository
uses it both in Neovim format-on-save and in the development/CI formatting
gate. The formatting rules live in the repository-level `.editorconfig`, so
Neovim, `scripts/dev/format.sh`, the Git pre-commit hook and CI all use the
same two-space shell indentation.
