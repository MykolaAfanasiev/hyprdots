#!/usr/bin/env python
import sys
from utils.screenshot_tools import ScreenshotTools

def main() -> int:
    screenshot = ScreenshotTools()
    return screenshot.run()
    

if __name__ == "__main__":
    sys.exit(main())
