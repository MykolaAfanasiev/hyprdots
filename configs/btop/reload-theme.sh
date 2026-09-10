#!/usr/bin/env bash

set -euo pipefail

if ! pgrep -x btop >/dev/null 2>&1; then
  exit 0
fi

pkill -SIGUSR2 -x btop
