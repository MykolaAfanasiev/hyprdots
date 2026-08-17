#!/usr/bin/env python3

from pathlib import Path
import click
from utils.screenshot_tools import ScreenshotTools
from cli.cli_options import apply_options, common_options
from cli.option_class import ScreenshotOptions
from utils.dependencies import check_dependencies


@click.command()
@apply_options(common_options)
def main(
    area: bool,
    edit: bool,
    copy_to_clipboard: bool,
    save: bool,
    output: Path | None,
) -> None:
    # Check conflicts
    if not save and output is not None:
        raise click.UsageError(
            "--output cannot be used together with --no-save."
        )
    options = ScreenshotOptions(
        area=area,
        edit=edit,
        copy_to_clipboard=copy_to_clipboard,
        save=save,
        output=output,
    )

    check_dependencies(options)

    screenshot = ScreenshotTools()
    exit_code = screenshot.run(options)
    raise click.exceptions.Exit(exit_code)


if __name__ == "__main__":
    main()
