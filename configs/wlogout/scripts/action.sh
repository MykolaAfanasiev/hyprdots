#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

HYPRLOCK_LAUNCH="$PROJECT_ROOT/configs/hyprlock/launch.sh"

close_menu() {
    pkill -x wlogout >/dev/null 2>&1 || true
}

case "${1:-}" in
    lock)
        close_menu
        exec "$HYPRLOCK_LAUNCH"
        ;;

    suspend)
        close_menu
        exec systemctl suspend
        ;;

    logout)
        close_menu
        exec hyprshutdown \
            --top-label "Logging out..."
        ;;

    reboot)
        close_menu
        exec hyprshutdown \
            --top-label "Restarting..." \
            --post-cmd "reboot"
        ;;

    shutdown)
        close_menu
        exec hyprshutdown \
            --top-label "Shutting down..." \
            --post-cmd "shutdown -P 0"
        ;;

    *)
        echo "Usage: $0 {lock|suspend|logout|reboot|shutdown}" >&2
        exit 1
        ;;
esac
