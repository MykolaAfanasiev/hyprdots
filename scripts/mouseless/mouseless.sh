#!/usr/bin/env bash

set -euo pipefail

SERVICE="mouseless.service"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

CONFIG="$PROJECT_ROOT/configs/mouseless/config.yaml"

usage() {
  cat <<'EOF_USAGE'
Usage:
  mouseless.sh start
  mouseless.sh stop
  mouseless.sh restart
  mouseless.sh toggle
  mouseless.sh status
  mouseless.sh enabled
  mouseless.sh enable
  mouseless.sh disable
  mouseless.sh path
  mouseless.sh logs
EOF_USAGE
}

start() {
  systemctl --user start "$SERVICE"
}

stop() {
  systemctl --user stop "$SERVICE"
}

restart() {
  systemctl --user restart "$SERVICE"
}

toggle() {
  if systemctl --user is-active --quiet "$SERVICE"; then
    stop
  else
    start
  fi
}

status() {
  if systemctl --user is-active --quiet "$SERVICE"; then
    printf 'running\n'
  else
    printf 'stopped\n'
  fi
}

enabled() {
  if systemctl --user is-enabled --quiet "$SERVICE"; then
    printf 'enabled\n'
  else
    printf 'disabled\n'
  fi
}

enable() {
  systemctl --user enable --now "$SERVICE"
}

disable() {
  systemctl --user disable --now "$SERVICE"
}

logs() {
  journalctl \
    --user \
    --unit "$SERVICE" \
    --follow
}

main() {
  case "${1:-}" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart | reload)
    restart
    ;;
  toggle)
    toggle
    ;;
  status)
    status
    ;;
  enabled)
    enabled
    ;;
  enable)
    enable
    ;;
  disable)
    disable
    ;;
  path)
    printf '%s\n' "$CONFIG"
    ;;
  logs)
    logs
    ;;
  *)
    usage >&2
    return 2
    ;;
  esac
}

main "$@"
