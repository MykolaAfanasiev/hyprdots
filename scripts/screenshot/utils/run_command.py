#!/usr/bin/env python3
import subprocess

# Subprocess commands


def run_command(cmd: list[str], capture_output: bool = False) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        text=True,
        capture_output=capture_output,
    )
