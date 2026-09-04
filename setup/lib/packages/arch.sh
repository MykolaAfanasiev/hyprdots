#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_ARCH_PACKAGES_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_ARCH_PACKAGES_LOADED=1

arch_package_installed() {
  local package="$1"

  pacman -Qq "$package" >/dev/null 2>&1
}

split_arch_packages() {
  local source_name="$1"
  local installed_name="$2"
  local missing_name="$3"

  local -n source_ref="$source_name"
  local -n installed_ref="$installed_name"
  local -n missing_ref="$missing_name"

  installed_ref=()
  missing_ref=()

  local package

  for package in "${source_ref[@]}"; do
    if arch_package_installed "$package"; then
      installed_ref+=("$package")
    else
      missing_ref+=("$package")
    fi
  done
}

install_arch_packages() {
  local -a requested_packages=("$@")
  local -a installed_packages=()
  local -a missing_packages=()

  if ((${#requested_packages[@]} == 0)); then
    success "No official Arch packages selected"
    return 0
  fi

  section "Official Arch packages"

  split_arch_packages \
    requested_packages \
    installed_packages \
    missing_packages

  if ((${#installed_packages[@]} > 0)); then
    printf 'Already installed:\n'
    print_package_list installed_packages
    printf '\n'
  fi

  if ((${#missing_packages[@]} == 0)); then
    success "All selected official Arch packages are already installed"
    return 0
  fi

  printf 'To install:\n'
  print_package_list missing_packages

  printf '\n'
  info "Installing ${#missing_packages[@]} official Arch package(s)..."

  sudo pacman \
    -S \
    --needed \
    "${missing_packages[@]}"

  success "Official Arch packages installed"
}
