from pathlib import Path
from collections.abc import Callable

import click


common_options = [
    click.option(
        "--area/--fullscreen",
        "area",
        default=False,
        show_default=True,
        help="Select an area with slurp instead of capturing the full screen.",
    ),
    click.option(
        "--edit/--no-edit",
        default=False,
        show_default=True,
        help="Open the screenshot in Satty.",
    ),
    click.option(
        "--copy/--no-copy",
        "copy_to_clipboard",
        default=True,
        show_default=True,
        help="Copy the screenshot to the clipboard.",
    ),
    click.option(
        "--save/--no-save",
        default=True,
        show_default=True,
        help="Save the screenshot as a file.",
    ),
    click.option(
        "-o",
        "--output",
        type=click.Path(
            path_type=Path,
            dir_okay=False,
            writable=True,
        ),
        default=None,
        help="Path where the screenshot should be saved.",
    ),
]


def apply_options(options: list[Callable]) -> Callable:
    """Apply multiple Click option decorators to a command."""

    def wrapper(func: Callable) -> Callable:
        for option in reversed(options):
            func = option(func)

        return func

    return wrapper
