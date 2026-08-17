import subprocess
from typing import Any, IO

# Subprocess commands


def run_command(
    cmd: list[str],
    capture_output: bool = False,
    *,
    stdin: int | IO[Any] | None = None,
    text: bool = True,
) -> subprocess.CompletedProcess:
    return subprocess.run(
        cmd,
        stdin=stdin,
        text=text,
        capture_output=capture_output,
    )
