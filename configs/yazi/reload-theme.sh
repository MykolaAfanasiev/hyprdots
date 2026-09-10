#!/usr/bin/env bash

set -euo pipefail

if ! command -v ya >/dev/null 2>&1; then
  exit 0
fi

ya emit-to 0 app:theme >/dev/null 2>&1 || true
