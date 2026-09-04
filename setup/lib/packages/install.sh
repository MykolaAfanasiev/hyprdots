#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_PACKAGE_INSTALL_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_PACKAGE_INSTALL_LOADED=1

print_install_plan() {
  local arch_name="$1"
  local aur_name="$2"

  local -n arch_ref="$arch_name"
  local -n aur_ref="$aur_name"

  section "Installation plan"

  printf 'Official Arch packages:\n'

  if ((${#arch_ref[@]} == 0)); then
    printf '  (none)\n'
  else
    print_package_list "$arch_name"
  fi

  printf '\n'
  printf 'AUR packages:\n'

  if ((${#aur_ref[@]} == 0)); then
    printf '  (none)\n'
  else
    print_package_list "$aur_name"
  fi
}

run_package_installation() {
  section "[3/11] Package installation"

  if ((PACKAGE_INSTALLATION_NEEDED == 0)); then
    success "All packages are already installed"
    info "Skipping package installation"
    return 0
  fi

  local -a arch_packages=()
  local -a aur_packages=()

  build_package_plan \
    arch_packages \
    aur_packages

  print_install_plan \
    arch_packages \
    aur_packages

  printf '\n'

  if ! confirm \
    "Install these packages now?" \
    yes; then
    die "Package installation cancelled."
  fi

  install_arch_packages \
    "${arch_packages[@]}"

  install_aur_packages \
    "${aur_packages[@]}"

  printf '\n'
  success "Package installation complete"
}
