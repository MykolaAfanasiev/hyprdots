#!/usr/bin/env python
from .run_command import run_command

# Notification
def notify(title: str, message: str, icon: str | None = None) -> None:
    # CMD
    cmd = ["notify-send"]
    if icon:
        cmd.extend(["-i", icon])

    cmd.extend([title, message])
    # Subprocess
    run_command(cmd)
