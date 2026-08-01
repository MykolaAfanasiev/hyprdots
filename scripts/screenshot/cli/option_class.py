from dataclasses import dataclass
from pathlib import Path


@dataclass(slots=True, frozen=True)
class ScreenshotOptions:
    """
    @dataclass automatically generates __init__(),
    so fields do not need to be assigned manually with self.area = area, etc.
    """
    area: bool = False
    edit: bool = False
    copy_to_clipboard: bool = True
    save: bool = True
    output: Path | None = None

    @property
    def mode(self) -> str:
        """
        @property allows this method to be accessed like an attribute:
        options.mode instead of options.mode()
        Returns "area" if area is True; otherwise returns "fullscreen".
        """
        return "area" if self.area else "fullscreen"
