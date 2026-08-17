import os
from datetime import datetime
from pathlib import Path


DEFAULT_SCREENSHOT_DIR = Path.home() / "Screenshots"


def get_screenshot_dir() -> Path:
    configured_dir = os.environ.get("HYPRDOTS_SCREENSHOT_DIR")

    if configured_dir:
        return Path(configured_dir).expanduser()

    return DEFAULT_SCREENSHOT_DIR


def make_screenshot_path() -> Path:
    save_dir = get_screenshot_dir()
    save_dir.mkdir(parents=True, exist_ok=True)

    filename = f"screenshot_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.png"
    return save_dir / filename
