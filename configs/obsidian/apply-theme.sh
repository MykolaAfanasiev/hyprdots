#!/usr/bin/env bash

set -euo pipefail

OBSIDIAN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$OBSIDIAN_DIR/../.." && pwd)"

THEME_CLI="$PROJECT_ROOT/scripts/theme-switcher/theme.sh"
OBSIDIAN_CONFIG="${OBSIDIAN_CONFIG_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/obsidian/obsidian.json}"

generated_theme=""

if [[ -x "$THEME_CLI" ]]; then
  generated_theme="$(
    "$THEME_CLI" path obsidian 2>/dev/null ||
      true
  )"
fi

if [[ -z "$generated_theme" || ! -r "$generated_theme" ]]; then
  printf 'Obsidian theme file is unavailable.\n' >&2
  exit 1
fi

if [[ ! -r "$OBSIDIAN_CONFIG" ]]; then
  printf 'Obsidian config not found: %s\n' "$OBSIDIAN_CONFIG" >&2
  exit 0
fi

python3 - "$OBSIDIAN_CONFIG" "$generated_theme" <<'PY'
import json
import sys
from pathlib import Path

config_file = Path(sys.argv[1])
theme_file = Path(sys.argv[2])

try:
    data = json.loads(config_file.read_text())
except (OSError, json.JSONDecodeError) as exc:
    raise SystemExit(f"Cannot read Obsidian config: {exc}")

vaults = data.get("vaults", {})

if not isinstance(vaults, dict):
    raise SystemExit("Invalid vault list in Obsidian config")

theme = theme_file.read_text()
updated = 0

for vault in vaults.values():
    if not isinstance(vault, dict):
        continue

    raw_path = vault.get("path")

    if not isinstance(raw_path, str) or not raw_path:
        continue

    vault_path = Path(raw_path).expanduser()
    obsidian_dir = vault_path / ".obsidian"

    if not obsidian_dir.is_dir():
        continue

    snippets_dir = obsidian_dir / "snippets"
    snippets_dir.mkdir(parents=True, exist_ok=True)

    output = snippets_dir / "hyprdots-theme.css"
    output.write_text(theme)

    appearance_file = obsidian_dir / "appearance.json"

    appearance = {}

    if appearance_file.exists():
        try:
            appearance = json.loads(appearance_file.read_text())
        except (OSError, json.JSONDecodeError):
            appearance = {}

    enabled = appearance.get("enabledCssSnippets", [])

    if not isinstance(enabled, list):
        enabled = []

    if "hyprdots-theme" not in enabled:
        enabled.append("hyprdots-theme")

    appearance["enabledCssSnippets"] = enabled

    appearance_file.write_text(
        json.dumps(
            appearance,
            indent=2,
            ensure_ascii=False,
        )
        + "\n"
    )

    print(f"Updated: {output}")
    updated += 1

if updated == 0:
    print("No Obsidian vaults found.")
PY
