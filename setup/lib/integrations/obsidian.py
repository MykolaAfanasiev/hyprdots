#!/usr/bin/env python3

import json
import os
import sys
import tempfile
import urllib.request
from pathlib import Path


HOME = Path.home()

THEME_NAME = "Catppuccin"
THEME_BASE_URL = (
    "https://raw.githubusercontent.com/"
    "catppuccin/obsidian/main"
)

PROJECT_ROOT = Path(__file__).resolve().parents[3]

APPEARANCE_TEMPLATE = (
    PROJECT_ROOT
    / "setup"
    / "templates"
    / "obsidian"
    / "appearance.json"
)


def find_obsidian_config() -> Path | None:
    candidates = [
        HOME / ".config" / "obsidian" / "obsidian.json",
        HOME
        / ".var"
        / "app"
        / "md.obsidian.Obsidian"
        / "config"
        / "obsidian"
        / "obsidian.json",
    ]

    xdg_config_home = os.environ.get("XDG_CONFIG_HOME")

    if xdg_config_home:
        candidates.insert(
            0,
            Path(xdg_config_home)
            / "obsidian"
            / "obsidian.json",
        )

    seen = set()

    for candidate in candidates:
        candidate = candidate.expanduser()

        if candidate in seen:
            continue

        seen.add(candidate)

        if candidate.is_file():
            return candidate

    return None


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}

    with path.open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.NamedTemporaryFile(
        mode="w",
        encoding="utf-8",
        dir=path.parent,
        delete=False,
    ) as temporary:
        json.dump(
            data,
            temporary,
            indent=2,
            ensure_ascii=False,
        )

        temporary.write("\n")

        temporary_path = Path(temporary.name)

    temporary_path.replace(path)


def find_vaults(config_path: Path) -> list[Path]:
    config = load_json(config_path)
    vaults = config.get("vaults", {})

    result = []

    for vault in vaults.values():
        path = vault.get("path")

        if not path:
            continue

        vault_path = Path(path).expanduser()

        if vault_path.is_dir():
            result.append(vault_path)

    return result


def download(url: str, destination: Path) -> None:
    destination.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    with urllib.request.urlopen(
        url,
        timeout=30,
    ) as response:
        data = response.read()

    destination.write_bytes(data)


def install_theme(vault: Path) -> None:
    theme_dir = (
        vault
        / ".obsidian"
        / "themes"
        / THEME_NAME
    )

    print(f"Installing Catppuccin: {vault}")

    download(
        f"{THEME_BASE_URL}/theme.css",
        theme_dir / "theme.css",
    )

    download(
        f"{THEME_BASE_URL}/manifest.json",
        theme_dir / "manifest.json",
    )


def configure_appearance(vault: Path) -> None:
    appearance_path = (
        vault
        / ".obsidian"
        / "appearance.json"
    )

    current = load_json(appearance_path)
    desired = load_json(APPEARANCE_TEMPLATE)

    current.update(desired)

    write_json(
        appearance_path,
        current,
    )


def main() -> int:
    config_path = find_obsidian_config()

    if config_path is None:
        print(
            "Obsidian configuration was not found. "
            "Launch Obsidian and open a vault first."
        )
        return 0

    vaults = find_vaults(config_path)

    if not vaults:
        print(
            "No registered Obsidian vaults were found."
        )
        return 0

    print(
        f"Found {len(vaults)} Obsidian vault(s)."
    )

    for vault in vaults:
        try:
            install_theme(vault)
            configure_appearance(vault)
            print(f"Configured: {vault}")

        except (
            OSError,
            urllib.error.URLError,
            json.JSONDecodeError,
        ) as error:
            print(
                f"Failed to configure {vault}: {error}",
                file=sys.stderr,
            )
            return 1

    print(
        "Obsidian Catppuccin configuration complete."
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
