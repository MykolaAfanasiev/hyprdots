#!/usr/bin/env python3

import configparser
import sys
import urllib.request
from pathlib import Path

FLAVOR = "Mocha"
ACCENT = "Mauve"

BASE_URL = (
    "https://raw.githubusercontent.com/"
    "catppuccin/zen-browser/main/themes/"
    f"{FLAVOR}/{ACCENT}"
)

FILES = {
    "userChrome.css": f"{BASE_URL}/userChrome.css",
    "userContent.css": f"{BASE_URL}/userContent.css",
    "zen-logo-mocha.svg": f"{BASE_URL}/zen-logo-mocha.svg",
}

PREF = 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

CHROME_IMPORT = '@import url("norexil/userChrome.css");'
CONTENT_IMPORT = '@import url("norexil/userContent.css");'


def zen_roots() -> list[Path]:
    home = Path.home()

    return [
        home / ".config" / "zen",
        home / ".zen",
        # Flatpak
        home / ".var" / "app" / "app.zen_browser.zen" / ".zen",
        home / ".var" / "app" / "app.zen_browser.zen" / "config" / "zen",
    ]


def find_zen_root() -> Path | None:
    for root in zen_roots():
        if (root / "profiles.ini").is_file():
            return root

    return None


def find_profile(root: Path) -> Path | None:
    ini_path = root / "profiles.ini"

    config = configparser.ConfigParser()
    config.read(ini_path, encoding="utf-8")

    # Modern Firefox/Zen:
    # prefer the profile assigned to this installation.
    for section in config.sections():
        if not section.startswith("Install"):
            continue

        path_value = config.get(
            section,
            "Default",
            fallback="",
        )

        if not path_value:
            continue

        path = root / path_value

        if path.is_dir():
            return path

    # Fallback to legacy Profile Default=1.
    profiles = []

    for section in config.sections():
        if not section.startswith("Profile"):
            continue

        path_value = config.get(
            section,
            "Path",
            fallback="",
        )

        if not path_value:
            continue

        is_relative = config.getboolean(
            section,
            "IsRelative",
            fallback=True,
        )

        path = root / path_value if is_relative else Path(path_value).expanduser()

        profiles.append(
            (
                config.getboolean(
                    section,
                    "Default",
                    fallback=False,
                ),
                path,
            )
        )

    for is_default, path in profiles:
        if is_default and path.is_dir():
            return path

    for _, path in profiles:
        if path.is_dir():
            return path

    return None


def download(url: str, destination: Path) -> None:
    destination.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    print(f"Downloading: {destination.name}")

    with urllib.request.urlopen(
        url,
        timeout=30,
    ) as response:
        destination.write_bytes(response.read())


def ensure_import(path: Path, import_line: str) -> None:
    if path.exists():
        content = path.read_text(encoding="utf-8")
    else:
        content = ""

    if import_line in content:
        return

    new_content = "/* Hyprdots Norexil */\n" f"{import_line}\n\n" f"{content}"

    path.write_text(
        new_content,
        encoding="utf-8",
    )


def ensure_pref(profile: Path) -> None:
    user_js = profile / "user.js"

    if user_js.exists():
        lines = user_js.read_text(encoding="utf-8").splitlines()
    else:
        lines = []

    prefix = 'user_pref("toolkit.' 'legacyUserProfileCustomizations.stylesheets"'

    filtered = [line for line in lines if not line.strip().startswith(prefix)]

    filtered.append(PREF)

    user_js.write_text(
        "\n".join(filtered) + "\n",
        encoding="utf-8",
    )


def configure_theme(profile: Path) -> None:
    chrome = profile / "chrome"
    managed = chrome / "norexil"

    chrome.mkdir(
        parents=True,
        exist_ok=True,
    )

    managed.mkdir(
        parents=True,
        exist_ok=True,
    )

    for filename, url in FILES.items():
        download(
            url,
            managed / filename,
        )

    ensure_import(
        chrome / "userChrome.css",
        CHROME_IMPORT,
    )

    ensure_import(
        chrome / "userContent.css",
        CONTENT_IMPORT,
    )

    ensure_pref(profile)


def main() -> int:
    root = find_zen_root()

    if root is None:
        print(
            "Zen configuration was not found. "
            "Launch Zen once and rerun the installer."
        )
        return 0

    profile = find_profile(root)

    if profile is None:
        print(f"No usable Zen profile found in {root}")
        return 0

    print(f"Zen profile: {profile}")
    print(f"Theme: Catppuccin {FLAVOR} / {ACCENT}")

    try:
        configure_theme(profile)
    except (
        OSError,
        urllib.error.URLError,
    ) as error:
        print(
            f"Failed to configure Zen: {error}",
            file=sys.stderr,
        )
        return 1

    print("Zen theme configuration complete.")
    print("Restart Zen Browser to apply it.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
