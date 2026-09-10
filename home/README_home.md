# Home-directory files

[Русская версия](README_home_ru.md) · [Project](../README.md)

The `home/` Stow package contains files whose destination is relative to the user's home directory rather than `~/.config`.

Current managed files include:

- `.zshenv` — early Zsh environment entry point.
- `.local/share/applications/yazi.desktop` — desktop entry used for Yazi integration.

The installer deploys this package with GNU Stow using the home directory as the target.
