from pathlib import Path
from .notify import notify
from .run_command import run_command
from .screenshot_path import make_screenshot_path
from cli.option_class import ScreenshotOptions


class ScreenshotTools:
    def __init__(self) -> None:
        self.title = "Screenshot"

    def resolve_output_path(
        self,
        options: ScreenshotOptions,
    ) -> Path:
        """Use the custom output path or generate a default path."""

        if options.output is not None:
            output_path = options.output.expanduser()
            output_path.parent.mkdir(parents=True, exist_ok=True)
            return output_path

        return make_screenshot_path()

    # Slurp
    def select_area(self) -> str:
        result = run_command(["slurp"], capture_output=True)
        return result.stdout.strip()

    # Grim
    def capture_area(
        self,
        selected_area: str,
        screenshot_path: Path,
    ) -> int:

        result = run_command(
            [
                "grim",
                "-g",
                selected_area,
                str(screenshot_path),
            ]
        )

        return result.returncode

    def capture_fullscreen(
        self,
        screenshot_path: Path,
    ) -> int:
        result = run_command(
            [
                "grim",
                str(screenshot_path),
            ]
        )

        return result.returncode

    # Edit

    def edit_with_satty(
        self,
        screenshot_path: Path,
    ) -> int:
        result = run_command(
            [
                "satty",
                "--filename",
                str(screenshot_path),
                "--output-filename",
                str(screenshot_path),
                "--copy-command",
                "wl-copy",
            ]
        )

        return result.returncode
    # Run

    def run(self, options: ScreenshotOptions) -> int:
        screenshot_path = self.resolve_output_path(options)

        if options.area:
            geometry = self.select_area()

            if not geometry:
                notify(
                    self.title,
                    "Area selection cancelled.",
                )
                return 1

            capture_result = self.capture_area(
                geometry,
                screenshot_path,
            )
        else:
            capture_result = self.capture_fullscreen(
                screenshot_path,
            )

        if capture_result != 0:
            notify(
                self.title,
                "Failed to capture the screenshot.",
            )
            return 2

        if options.edit:
            edit_result = self.edit_with_satty(
                screenshot_path,
            )

            if edit_result:
                notify(
                    self.title,
                    "Screenshot editing was cancelled.",
                )
                return 3

        if options.copy_to_clipboard:
            copy_result = self.copy_to_clipboard(
                screenshot_path,
            )

            if copy_result != 0:
                notify(
                    self.title,
                    "Failed to copy the screenshot.",
                )
                return 4

        if options.save:
            notify(
                self.title,
                f"Screenshot saved to:\n{screenshot_path}",
                icon=str(screenshot_path),
            )
        else:
            notify(
                self.title,
                "Screenshot copied to the clipboard.",
            )
            screenshot_path.unlink(missing_ok=True)

        return 0

    def copy_to_clipboard(
        self,
        screenshot_path: Path,
    ) -> int:
        with screenshot_path.open("rb") as image_file:
            result = run_command(
                [
                    "wl-copy",
                    "--type",
                    "image/png",
                ],
                stdin=image_file,
                text=False,
            )

        return result.returncode
