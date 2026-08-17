from pathlib import Path
from datetime import datetime

# Screenshots path


def make_screenshot_path() -> Path:
    # Directory
    save_dir = Path.home() / "Screenshots"
    save_dir.mkdir(parents=True, exist_ok=True)

    # Filename
    filename = f"screenshot_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.png"
    return save_dir / filename
