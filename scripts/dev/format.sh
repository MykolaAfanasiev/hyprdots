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

printf 'Formatting %d shell files with shfmt...\n' "${#SHELL_FORMAT_FILES[@]}"

# Do not pass printer/parser flags here. shfmt reads the repository
# .editorconfig, which is also what conform.nvim uses on save.
shfmt -w -- "${SHELL_FORMAT_FILES[@]}"

printf 'Shell formatting complete.\n'
