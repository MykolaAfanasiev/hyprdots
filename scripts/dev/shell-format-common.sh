#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_SHELL_FORMAT_COMMON_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_SHELL_FORMAT_COMMON_LOADED=1

FORMAT_PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

prepend_mason_bin() {
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local mason_bin="${NVIM_MASON_BIN:-$data_home/nvim/mason/bin}"

  if [[ -d "$mason_bin" ]]; then
    PATH="$mason_bin:$PATH"
    export PATH
  fi
}

require_shfmt() {
  prepend_mason_bin

  if command -v shfmt >/dev/null 2>&1; then
    return 0
  fi

  printf 'shfmt is required for shell formatting.\n' >&2
  printf 'Open Neovim once so Mason can install it, or install the shfmt package.\n' >&2
  return 1
}

load_shell_format_files() {
  mapfile -d '' SHELL_FORMAT_FILES < <(
    git -C "$FORMAT_PROJECT_ROOT" ls-files -z -- \
      '*.sh' \
      '*.zsh' \
      'configs/zsh/.zshrc' \
      'home/.zshenv'
  )

  if ((${#SHELL_FORMAT_FILES[@]} == 0)); then
    printf 'No tracked shell files found.\n' >&2
    return 1
  fi

  local index
  for index in "${!SHELL_FORMAT_FILES[@]}"; do
    SHELL_FORMAT_FILES[$index]="$FORMAT_PROJECT_ROOT/${SHELL_FORMAT_FILES[$index]}"
  done
}
