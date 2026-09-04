#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"

# shellcheck source=scripts/dev/shell-format-common.sh
source "$SCRIPT_DIR/shell-format-common.sh"

require_shfmt
load_shell_format_files

printf 'Checking %d shell files with shfmt...\n' "${#SHELL_FORMAT_FILES[@]}"

# -d only checks and prints a diff. Formatting rules come from .editorconfig.
shfmt -d -- "${SHELL_FORMAT_FILES[@]}"

printf 'Shell formatting is clean.\n'
