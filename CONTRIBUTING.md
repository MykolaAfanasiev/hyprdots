# Contributing to Hyprdots Norexil

Thanks for your interest in Hyprdots Norexil.

Issues, bug reports, ideas, documentation improvements, new themes, tests,
fixes, and other contributions are welcome.

You do not need to be an expert to contribute.

## Ways to contribute

You can help the project by:

- reporting bugs;
- suggesting improvements or new features;
- improving English or Russian documentation;
- fixing documentation mistakes;
- adding or improving tests;
- fixing bugs;
- improving scripts or configuration;
- adding support for new themes;
- improving existing themes;
- improving installer behavior;
- improving portability across Linux distributions;
- reviewing existing issues or pull requests.

## Issues

Feel free to open an issue if you:

- found a bug;
- have an idea for an improvement;
- want to request a new feature;
- found unclear or incorrect documentation;
- have a question about how a project component works.

For bug reports, please include as much useful information as possible, such as:

- what you expected to happen;
- what actually happened;
- relevant error messages or logs;
- the affected component;
- steps that reproduce the problem.

## Pull requests

Pull requests are welcome.

A typical contribution workflow is:

1. Fork the repository.
2. Create a branch for your change.
3. Make and test your changes.
4. Commit the changes with a clear commit message.
5. Push the branch to your fork.
6. Open a Pull Request against Hyprdots Norexil.

For small fixes, documentation changes, tests, and themes, you can usually open
a Pull Request directly.

For large architectural changes or major new features, opening an issue first
is recommended so the idea can be discussed before significant work is done.

Please avoid committing personal paths, credentials, tokens, machine-specific
identifiers, or other private data.

## Development checks

Before opening a Pull Request, run the checks that are relevant to your change.

Format the repository with:

```bash
./scripts/dev/format.sh
```

Run static checks with:

```bash
./tests/static/check.sh
```

Run installer tests with:

```bash
./tests/installer/run.sh
```

A contribution does not necessarily need to modify every part of the project,
but existing checks should continue to pass.

## Code and configuration style

Please try to follow the existing project structure and style.

Shell files use two-space indentation.

Large section comments use this format:

```bash
# ========================================================================
# Section name
# ========================================================================
```

Lua uses the equivalent form:

```lua
-- ========================================================================
-- Section name
-- ========================================================================
```

Prefer keeping reusable desktop logic in CLI/backend scripts instead of placing
it directly inside a Rofi frontend.

When adding a new component, consider whether it also needs:

- documentation;
- installer integration;
- package declarations;
- tests;
- theme integration.

## Themes

New themes are welcome.

When adding a theme, please try to make it work consistently across all
supported components rather than changing only one application.

If a theme cannot support a particular component, document that limitation.

## Tests

New tests are very welcome.

Tests are especially useful for:

- installer behavior;
- package detection;
- configuration deployment;
- CLI backends;
- regressions caused by previous bugs.

A small regression test accompanying a bug fix is appreciated whenever
practical.

## Documentation

Documentation contributions are welcome even without code changes.

The project contains both English and Russian documentation. When practical,
changes affecting user-facing behavior should be reflected in both versions.

Do not worry if you cannot write both languages perfectly — improvements can
still be reviewed and corrected during the Pull Request.

## Forks and derivative projects

Forking and modifying Hyprdots Norexil for your own setup is welcome.

The project is distributed under the MIT License. Copies and substantial
portions of the software must retain the copyright notice and license text as
described in the `LICENSE` file.

If you publicly distribute a project derived substantially from Hyprdots
Norexil, a visible acknowledgment of the original Hyprdots Norexil project and
Norexildev is appreciated.

You are free to adapt the project to your own needs and build something
different from it.

## Project structure

Hyprdots Norexil is organized by responsibility.

```text
configs/   Application and desktop configuration
scripts/   Reusable CLI backends and interactive frontends
setup/     Installer implementation
tests/     Static and installer tests
home/      Files deployed directly into the user's home directory
```

Most directories contain their own documentation.

For example:

```text
scripts/networkmanager/
├── README_networkmanager.md
├── README_networkmanager_ru.md
├── network.sh
└── rofi.sh
```

When adding a new component, follow the structure of an existing similar
component whenever possible.

### Documentation naming

Component documentation follows this convention:

```text
README_<component>.md
README_<component>_ru.md
```

For example:

```text
README_mouseless.md
README_mouseless_ru.md
```

Higher-level directories also contain index documentation, such as:

```text
configs/README_configs.md
scripts/README_scripts.md
setup/README_setup.md
tests/README_tests.md
```

New component documentation should be linked from the appropriate index README.

### Where should a change go?

As a general rule:

- application configuration belongs in `configs/<component>/`;
- reusable desktop logic belongs in `scripts/<component>/`;
- installation logic belongs in `setup/`;
- tests belong in `tests/`;
- files deployed directly into `$HOME` belong in `home/`.

A component may use both `configs/` and `scripts/`.

For example, a Rofi-based tool may have:

```text
configs/example/
└── theme.rasi

scripts/example/
├── example.sh
└── rofi.sh
```

The CLI/backend should contain the reusable logic, while the frontend should
mainly provide user interaction.

If you are unsure where a larger new component should live, feel free to open
an issue before implementing it.

## Project direction

Contributions are welcome, but not every proposed feature will necessarily be
merged.

Hyprdots Norexil aims to remain:

- keyboard-first;
- Hyprland focused;
- distribution-aware;
- reproducible and modular;
- usable through CLI backends independently of their graphical frontends.

Changes that fit these principles are especially welcome.

## Distribution support

Hyprdots Norexil currently targets Arch Linux as its primary supported
distribution.

Support for NixOS is planned as a second installation and configuration path.

The goal is to keep the desktop experience and project architecture shared
between distributions while allowing distribution-specific installation logic
where necessary.

Arch Linux is intended to remain the fast-moving, traditional package-based
option, while NixOS will provide a declarative and highly reproducible
alternative with straightforward rollback capabilities.

Contributions that improve portability between supported distributions are
welcome, provided they do not compromise the shared project structure.

## License

By contributing to Hyprdots Norexil, you agree that your contributions will be
licensed under the project's MIT License.
