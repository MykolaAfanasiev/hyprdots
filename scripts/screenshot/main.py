#!/usr/bin/env python
import sys
from utils.notify import notify
from utils.run_command import run_command
from utils.screenshot_path import make_screenshot_path

def main() -> int:
    # Path
    save_path = make_screenshot_path()
    
    # Selected area
    selected_area = run_command(["slurp"], capture_output=True).stdout.strip()

    if not selected_area:
        notify("Screenshot", "Canceled: no area selected.")
        return 1
    
    # Taking Screenshot
    grim_result = run_command (["grim", "-g", selected_area, str(save_path)])

    if grim_result.returncode != 0:
        notify("Screenshot", "Error capturing screenshot.")
        return 1

    # Editing Screenshot
    satty_result = run_command([
        "satty",
        "--filename", str(save_path),
        "--output-filename", str(save_path),
        "--copy-command", "wl-copy",
    ])

    if satty_result.returncode == 0:
        notify("Screenshot", f"Edited and saved: {save_path}", str(save_path))
    else:
        notify("Screenshot", f"Editing canceled. Saved: {save_path}", str(save_path))
    return 0

if __name__ == "__main__":
    sys.exit(main())
