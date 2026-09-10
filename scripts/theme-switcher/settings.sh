#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

SETTINGS_FILE="$PROJECT_ROOT/configs/theme/settings.conf"
THEME_CLI="$SCRIPT_DIR/theme.sh"

usage() {
  cat <<'EOF_USAGE'
Usage:
  settings.sh show
  settings.sh get <key>
  settings.sh set <key> <value> [--no-apply]
  settings.sh path
  settings.sh apply
EOF_USAGE
}

load_settings() {
  MATUGEN_MODE="auto"
  MATUGEN_LIGHT_THRESHOLD="0.56"
  MATUGEN_SCHEME="scheme-content"
  MATUGEN_PREFER="saturation"

  HYBRID_ACCENT_TINT="0.25"
  HYBRID_NEUTRAL_TINT="0.12"

  if [[ -r "$SETTINGS_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$SETTINGS_FILE"
  fi
}

validate_number() {
  local value="$1"

  awk -v value="$value" '
    BEGIN {
      if (value !~ /^[0-9]+([.][0-9]+)?$/)
        exit 1

      if (value < 0 || value > 1)
        exit 1
    }
  '
}

validate_setting() {
  local key="$1"
  local value="$2"

  case "$key" in
  MATUGEN_MODE)
    case "$value" in
    auto | dark | light) ;;
    *) return 1 ;;
    esac
    ;;

  MATUGEN_LIGHT_THRESHOLD | HYBRID_ACCENT_TINT | HYBRID_NEUTRAL_TINT)
    validate_number "$value"
    ;;

  MATUGEN_SCHEME)
    case "$value" in
    scheme-content | \
      scheme-tonal-spot | \
      scheme-fidelity | \
      scheme-expressive | \
      scheme-neutral | \
      scheme-monochrome | \
      scheme-rainbow | \
      scheme-fruit-salad)
      ;;
    *)
      return 1
      ;;
    esac
    ;;

  MATUGEN_PREFER)
    case "$value" in
    saturation | \
      less-saturation | \
      darkness | \
      lightness | \
      value | \
      closest-to-fallback)
      ;;
    *)
      return 1
      ;;
    esac
    ;;

  *)
    return 1
    ;;
  esac
}

get_setting() {
  local key="$1"

  load_settings

  case "$key" in
  MATUGEN_MODE)
    printf '%s\n' "$MATUGEN_MODE"
    ;;
  MATUGEN_LIGHT_THRESHOLD)
    printf '%s\n' "$MATUGEN_LIGHT_THRESHOLD"
    ;;
  MATUGEN_SCHEME)
    printf '%s\n' "$MATUGEN_SCHEME"
    ;;
  MATUGEN_PREFER)
    printf '%s\n' "$MATUGEN_PREFER"
    ;;
  HYBRID_ACCENT_TINT)
    printf '%s\n' "$HYBRID_ACCENT_TINT"
    ;;
  HYBRID_NEUTRAL_TINT)
    printf '%s\n' "$HYBRID_NEUTRAL_TINT"
    ;;
  *)
    printf 'Unknown setting: %s\n' "$key" >&2
    return 1
    ;;
  esac
}

set_setting() {
  local key="$1"
  local value="$2"

  if ! validate_setting "$key" "$value"; then
    printf 'Invalid value for %s: %s\n' "$key" "$value" >&2
    return 1
  fi

  python3 - "$SETTINGS_FILE" "$key" "$value" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
key = sys.argv[2]
value = sys.argv[3]

text = path.read_text()

pattern = re.compile(
    rf'^{re.escape(key)}=".*"$',
    re.MULTILINE,
)

replacement = f'{key}="{value}"'

if pattern.search(text):
    text = pattern.sub(replacement, text, count=1)
else:
    text = text.rstrip() + "\n" + replacement + "\n"

path.write_text(text)
PY
}

apply_if_relevant() {
  local key="$1"
  local mode

  mode="$("$THEME_CLI" mode)"

  case "$key" in
  MATUGEN_*)
    case "$mode" in
    dynamic | hybrid)
      "$THEME_CLI" apply
      ;;
    esac
    ;;

  HYBRID_*)
    if [[ "$mode" == "hybrid" ]]; then
      "$THEME_CLI" apply
    fi
    ;;
  esac
}

show_settings() {
  load_settings

  printf 'MATUGEN_MODE=%s\n' "$MATUGEN_MODE"
  printf 'MATUGEN_LIGHT_THRESHOLD=%s\n' "$MATUGEN_LIGHT_THRESHOLD"
  printf 'MATUGEN_SCHEME=%s\n' "$MATUGEN_SCHEME"
  printf 'MATUGEN_PREFER=%s\n' "$MATUGEN_PREFER"
  printf 'HYBRID_ACCENT_TINT=%s\n' "$HYBRID_ACCENT_TINT"
  printf 'HYBRID_NEUTRAL_TINT=%s\n' "$HYBRID_NEUTRAL_TINT"
}

main() {
  local command="${1:-}"

  case "$command" in
  show)
    [[ $# -eq 1 ]] || {
      usage >&2
      exit 2
    }

    show_settings
    ;;

  get)
    [[ $# -eq 2 ]] || {
      usage >&2
      exit 2
    }

    get_setting "$2"
    ;;

  set)
    [[ $# -ge 3 && $# -le 4 ]] || {
      usage >&2
      exit 2
    }

    set_setting "$2" "$3"

    if [[ ${4:-} != "--no-apply" ]]; then
      apply_if_relevant "$2"
    fi
    ;;

  path)
    [[ $# -eq 1 ]] || {
      usage >&2
      exit 2
    }

    printf '%s\n' "$SETTINGS_FILE"
    ;;

  apply)
    [[ $# -eq 1 ]] || {
      usage >&2
      exit 2
    }

    "$THEME_CLI" apply
    ;;

  *)
    usage >&2
    exit 2
    ;;
  esac
}

main "$@"
