#!/usr/bin/env python

from .notify import notify
from .run_command import run_command
from .screenshot_path import make_screenshot_path


class ScreenshotTools:
    def __init__(self) -> None:
        self.title = "Screenshot"
        self.save_path = make_screenshot_path()
    
    # Slurp
    def select_area(self) -> str:
        result = run_command(["slurp"], capture_output=True)
        return result.stdout.strip()
    
    # Grim
    def capture_area(self, selected_area: str) -> int:
        result = run_command(["grim", "-g", selected_area, str(self.save_path)])
        return result.returncode
    
    # Edit
    def edit_screenshot(self) -> int:
        result = run_command([
            "satty",
            "--filename", str(self.save_path),
            "--output-filename", str(self.save_path),
            "--copy-command", "wl-copy",
        ])

        return result.returncode

    # Run
    def run(self) -> int:
        selected_area = self.select_area()

        if not selected_area:
            notify(self.title, "Canceled: no area selected.")
            return 1

        capture_code = self.capture_area(selected_area)

        if capture_code != 0:
            notify(self.title, "Error capturing screenshot.")
            return 2

        edit_code = self.edit_screenshot()

        if edit_code == 0:
            notify(self.title, f"Edited and saved: {self.save_path}", str(self.save_path))
            return 0

        notify(self.title, f"Editing canceled. Saved: {self.save_path}", str(self.save_path))
        return 3
