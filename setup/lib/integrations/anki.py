#!/usr/bin/env python3

import json
import sys
import tempfile
from pathlib import Path

RECOLOR_ID = "688199788"
THEME_NAME = "(dark) Catppuccin Mocha.json"


def find_recolor() -> Path | None:
    home = Path.home()

    candidates = [
        home / ".local/share/Anki2/addons21" / RECOLOR_ID,
        home / ".var/app/net.ankiweb.Anki/data/Anki2/addons21" / RECOLOR_ID,
    ]

    for candidate in candidates:
        if candidate.is_dir():
            return candidate

    return None


def load_json(path: Path) -> dict:
    try:
        with path.open("r", encoding="utf-8") as file:
            data = json.load(file)

        if not isinstance(data, dict):
            raise ValueError(f"{path} does not contain a JSON object")

        return data

    except json.JSONDecodeError as error:
        raise RuntimeError(f"Invalid JSON in {path}: {error}") from error


def write_json_atomic(path: Path, data: dict) -> None:
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


def effective_config(
    defaults: dict,
    meta: dict,
) -> dict:
    config = defaults.copy()

    user_config = meta.get("config", {})

    if isinstance(user_config, dict):
        config.update(user_config)

    return config


def apply_dark_theme(
    config: dict,
    theme: dict,
) -> int:
    config_colors = config.get("colors")
    theme_colors = theme.get("colors")

    if not isinstance(config_colors, dict):
        raise RuntimeError("ReColor config does not contain a valid 'colors' object")

    if not isinstance(theme_colors, dict):
        raise RuntimeError("Theme does not contain a valid 'colors' object")

    changed = 0

    for name, theme_entry in theme_colors.items():
        if name not in config_colors:
            continue

        config_entry = config_colors[name]

        if not isinstance(config_entry, list):
            continue

        if not isinstance(theme_entry, list):
            continue

        # ReColor color entries use:
        #
        # [0] display name
        # [1] light color
        # [2] dark color
        # [3] CSS variable
        #
        # Catppuccin Mocha is a dark-only theme, so we only
        # replace index 2.
        if len(config_entry) < 3 or len(theme_entry) < 3:
            continue

        new_color = theme_entry[2]

        if config_entry[2] != new_color:
            config_entry[2] = new_color
            changed += 1

    return changed


def main() -> int:
    recolor_dir = find_recolor()

    if recolor_dir is None:
        print("ReColor is not installed; " f"expected Anki add-on {RECOLOR_ID}.")
        return 0

    config_path = recolor_dir / "config.json"
    meta_path = recolor_dir / "meta.json"
    theme_path = recolor_dir / "themes" / THEME_NAME

    if not config_path.is_file():
        print(
            f"ReColor default configuration was not found: " f"{config_path}",
            file=sys.stderr,
        )
        return 1

    if not theme_path.is_file():
        print(
            f"Catppuccin Mocha theme was not found: " f"{theme_path}",
            file=sys.stderr,
        )
        return 1

    try:
        defaults = load_json(config_path)

        if meta_path.exists():
            meta = load_json(meta_path)
        else:
            meta = {}

        theme = load_json(theme_path)

        config = effective_config(
            defaults,
            meta,
        )

        changed = apply_dark_theme(
            config,
            theme,
        )

        meta["config"] = config

        write_json_atomic(
            meta_path,
            meta,
        )

    except (OSError, RuntimeError, ValueError) as error:
        print(
            f"Failed to configure ReColor: {error}",
            file=sys.stderr,
        )
        return 1

    if changed == 0:
        print("Anki ReColor is already using " "Catppuccin Mocha.")
    else:
        print(f"Applied Catppuccin Mocha to " f"{changed} ReColor color entries.")

    print(f"ReColor configuration: {meta_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
