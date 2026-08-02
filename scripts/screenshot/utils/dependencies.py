from shutil import which

import click

from cli.option_class import ScreenshotOptions


def check_dependencies(options: ScreenshotOptions) -> None:
    """Check whether all required external commands are installed."""

    required_commands = {
        "grim",
        "notify-send",
    }

    if options.area:
        required_commands.add("slurp")

    if options.edit:
        required_commands.add("satty")

    if options.copy_to_clipboard:
        required_commands.add("wl-copy")

    missing_commands = sorted(
        command
        for command in required_commands
        if which(command) is None
    )

    if missing_commands:
        missing = ", ".join(missing_commands)

        raise click.ClickException(
            f"Missing required commands: {missing}"
        )
