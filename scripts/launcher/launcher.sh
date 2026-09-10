#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

CONTROL_CLI="$PROJECT_ROOT/scripts/control-center/control-center.sh"
GHOSTTY_LAUNCH="$PROJECT_ROOT/configs/ghostty/launch.sh"
YAZI_LAUNCH="$PROJECT_ROOT/configs/yazi/launch.sh"
BTOP_LAUNCH="$PROJECT_ROOT/configs/btop/launch.sh"
RMPC_LAUNCH="$PROJECT_ROOT/configs/rmpc/launch.sh"
POWER_ACTION="$PROJECT_ROOT/configs/wlogout/scripts/action.sh"

usage() {
  cat <<'EOF_USAGE'
Usage:
  launcher.sh terminal
  launcher.sh files [path]
  launcher.sh monitor
  launcher.sh music

  launcher.sh calc <expression>
  launcher.sh search <query>

  launcher.sh screenshot <full|area|full-edit|area-edit|full-copy|area-copy|full-save|area-save>
  launcher.sh power <lock|suspend|hibernate|logout|reboot|shutdown>

  launcher.sh theme <theme arguments...>
  launcher.sh wallpaper <wallpaper arguments...>
  launcher.sh network <network arguments...>
  launcher.sh bluetooth <bluetooth arguments...>
  launcher.sh mouseless <mouseless arguments...>

  launcher.sh status
  launcher.sh help
EOF_USAGE
}

require_executable() {
  local path="$1"

  if [[ ! -x "$path" ]]; then
    printf 'Required executable is unavailable: %s\n' "$path" >&2
    return 127
  fi
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command is not installed: %s\n' "$command_name" >&2
    return 127
  fi
}

launch_detached() {
  "$@" >/dev/null 2>&1 &
}

open_terminal() {
  require_executable "$GHOSTTY_LAUNCH"
  launch_detached "$GHOSTTY_LAUNCH"
}

open_files() {
  local path="${1:-$HOME}"

  require_executable "$GHOSTTY_LAUNCH"
  require_executable "$YAZI_LAUNCH"

  launch_detached \
    "$GHOSTTY_LAUNCH" \
    -e "$YAZI_LAUNCH" "$path"
}

open_monitor() {
  require_executable "$GHOSTTY_LAUNCH"
  require_executable "$BTOP_LAUNCH"

  launch_detached \
    "$GHOSTTY_LAUNCH" \
    -e "$BTOP_LAUNCH"
}

open_music() {
  require_executable "$GHOSTTY_LAUNCH"
  require_executable "$RMPC_LAUNCH"

  launch_detached \
    "$GHOSTTY_LAUNCH" \
    -e "$RMPC_LAUNCH"
}

calculate() {
  local expression="$1"

  python3 - "$expression" <<'PY'
import ast
import math
import operator
import sys

expression = sys.argv[1].strip().replace("^", "**")

if not expression:
    raise SystemExit("Empty expression")

binary_ops = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.FloorDiv: operator.floordiv,
    ast.Mod: operator.mod,
    ast.Pow: operator.pow,
}

unary_ops = {
    ast.UAdd: operator.pos,
    ast.USub: operator.neg,
}

constants = {
    "pi": math.pi,
    "e": math.e,
    "tau": math.tau,
}

functions = {
    "abs": abs,
    "round": round,
    "sqrt": math.sqrt,
    "sin": math.sin,
    "cos": math.cos,
    "tan": math.tan,
    "asin": math.asin,
    "acos": math.acos,
    "atan": math.atan,
    "log": math.log,
    "log10": math.log10,
    "ln": math.log,
    "floor": math.floor,
    "ceil": math.ceil,
}


def evaluate(node):
    if isinstance(node, ast.Expression):
        return evaluate(node.body)

    if isinstance(node, ast.Constant):
        if isinstance(node.value, (int, float)) and not isinstance(node.value, bool):
            return node.value
        raise ValueError("Only numeric constants are allowed")

    if isinstance(node, ast.BinOp) and type(node.op) in binary_ops:
        return binary_ops[type(node.op)](
            evaluate(node.left),
            evaluate(node.right),
        )

    if isinstance(node, ast.UnaryOp) and type(node.op) in unary_ops:
        return unary_ops[type(node.op)](evaluate(node.operand))

    if isinstance(node, ast.Name) and node.id in constants:
        return constants[node.id]

    if isinstance(node, ast.Call):
        if not isinstance(node.func, ast.Name) or node.func.id not in functions:
            raise ValueError("Function is not allowed")

        if node.keywords:
            raise ValueError("Keyword arguments are not allowed")

        return functions[node.func.id](*(evaluate(arg) for arg in node.args))

    raise ValueError("Unsupported expression")


try:
    tree = ast.parse(expression, mode="eval")
    result = evaluate(tree)
except Exception as error:
    raise SystemExit(f"Calculator error: {error}") from error

if isinstance(result, float):
    print(f"{result:.12g}")
else:
    print(result)
PY
}

web_search() {
  local query="$1"
  local base_url="${HYPRDOTS_SEARCH_URL:-https://www.google.com/search?q=}"
  local encoded_query

  require_command xdg-open

  encoded_query="$(
    python3 - "$query" <<'PY'
import sys
import urllib.parse

print(urllib.parse.quote_plus(sys.argv[1]))
PY
  )"

  xdg-open "${base_url}${encoded_query}" >/dev/null 2>&1 &
}

screenshot() {
  local mode="$1"
  local -a arguments=()

  require_command screenshot-tool

  case "$mode" in
  full)
    ;;
  area)
    arguments+=(--area)
    ;;
  full-edit)
    arguments+=(--edit)
    ;;
  area-edit)
    arguments+=(--area --edit)
    ;;
  full-copy)
    arguments+=(--no-save)
    ;;
  area-copy)
    arguments+=(--area --no-save)
    ;;
  full-save)
    arguments+=(--no-copy)
    ;;
  area-save)
    arguments+=(--area --no-copy)
    ;;
  *)
    printf 'Unknown screenshot mode: %s\n' "$mode" >&2
    return 2
    ;;
  esac

  screenshot-tool "${arguments[@]}"
}

power_action() {
  local action="$1"

  require_executable "$POWER_ACTION"
  exec "$POWER_ACTION" "$action"
}

show_status() {
  local theme_mode="unavailable"
  local wifi="unavailable"
  local bluetooth="unavailable"
  local mouseless="unavailable"

  if [[ -x "$CONTROL_CLI" ]]; then
    theme_mode="$($CONTROL_CLI theme mode 2>/dev/null || printf 'unavailable')"
    wifi="$($CONTROL_CLI network status 2>/dev/null || printf 'unavailable')"
    bluetooth="$($CONTROL_CLI bluetooth status 2>/dev/null || printf 'unavailable')"
    mouseless="$($CONTROL_CLI mouseless status 2>/dev/null || printf 'unavailable')"
  fi

  printf 'theme_mode=%s\n' "$theme_mode"
  printf 'wifi=%s\n' "$wifi"
  printf 'bluetooth=%s\n' "$bluetooth"
  printf 'mouseless=%s\n' "$mouseless"
  printf 'terminal=%s\n' "$([[ -x "$GHOSTTY_LAUNCH" ]] && printf 'available' || printf 'unavailable')"
  printf 'files=%s\n' "$([[ -x "$YAZI_LAUNCH" ]] && printf 'available' || printf 'unavailable')"
}

delegate_control() {
  require_executable "$CONTROL_CLI"
  exec "$CONTROL_CLI" "$@"
}

main() {
  local command_name="${1:-}"

  case "$command_name" in
  terminal)
    [[ $# -eq 1 ]] || {
      usage >&2
      return 2
    }
    open_terminal
    ;;

  files)
    [[ $# -le 2 ]] || {
      usage >&2
      return 2
    }
    open_files "${2:-$HOME}"
    ;;

  monitor)
    [[ $# -eq 1 ]] || {
      usage >&2
      return 2
    }
    open_monitor
    ;;

  music)
    [[ $# -eq 1 ]] || {
      usage >&2
      return 2
    }
    open_music
    ;;

  calc)
    [[ $# -ge 2 ]] || {
      usage >&2
      return 2
    }
    shift
    calculate "$*"
    ;;

  search)
    [[ $# -ge 2 ]] || {
      usage >&2
      return 2
    }
    shift
    web_search "$*"
    ;;

  screenshot)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    screenshot "$2"
    ;;

  power)
    [[ $# -eq 2 ]] || {
      usage >&2
      return 2
    }
    power_action "$2"
    ;;

  theme | wallpaper | network | bluetooth | mouseless)
    shift
    delegate_control "$command_name" "$@"
    ;;

  status)
    [[ $# -eq 1 ]] || {
      usage >&2
      return 2
    }
    show_status
    ;;

  help | -h | --help)
    usage
    ;;

  "")
    usage >&2
    return 2
    ;;

  *)
    printf 'Unknown command: %s\n\n' "$command_name" >&2
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
