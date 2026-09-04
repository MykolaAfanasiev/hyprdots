#!/usr/bin/env bash

# This module exports installer state through global variables to other
# modules loaded with source. ShellCheck analyzes this file in isolation.
# shellcheck disable=SC2034

if [[ -n "${HYPRDOTS_PACKAGE_SELECT_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_PACKAGE_SELECT_LOADED=1

declare -ag SELECTED_ARCH_REQUIRED=()
declare -ag SELECTED_ARCH_RECOMMENDED=()
declare -ag SELECTED_ARCH_DEFAULT_APPS=()
declare -ag SELECTED_AUR_REQUIRED=()
declare -gi PACKAGE_INSTALLATION_NEEDED=1

stdin_is_terminal() {
  [[ -t 0 ]]
}

print_package_list() {
  local array_name="$1"
  local -n packages_ref="$array_name"

  local package

  for package in "${packages_ref[@]}"; do
    printf '  - %s\n' "$package"
  done
}

select_packages_individually() {
  local source_name="$1"
  local destination_name="$2"
  local default_answer="$3"

  local -n source_ref="$source_name"
  # destination_ref is a nameref to an array supplied by the caller.
  # shellcheck disable=SC2178
  local -n destination_ref="$destination_name"

  destination_ref=()

  local package
  local answer

  for package in "${source_ref[@]}"; do
    while true; do
      if [[ "$default_answer" == "yes" ]]; then
        read -r -p "Install $package? [Y/n] " answer
        answer="${answer:-y}"
      else
        read -r -p "Install $package? [y/N] " answer
        answer="${answer:-n}"
      fi

      case "${answer,,}" in
      y | yes)
        destination_ref+=("$package")
        break
        ;;

      n | no)
        break
        ;;

      *)
        warn "Please answer y or n."
        ;;
      esac
    done
  done
}

select_package_group() {
  local title="$1"
  local description="$2"
  local source_name="$3"
  local destination_name="$4"
  local default_mode="$5"

  local -n source_ref="$source_name"
  # destination_ref is a nameref to an array supplied by the caller.
  # shellcheck disable=SC2178
  local -n destination_ref="$destination_name"

  section "$title"

  printf '%s\n\n' "$description"

  print_package_list "$source_name"

  printf '\n'
  printf 'Choose:\n'
  printf '  [A] Install all\n'
  printf '  [C] Choose individually\n'
  printf '  [N] Install none\n'
  printf '\n'

  local answer

  while true; do
    if [[ "$default_mode" == "all" ]]; then
      read -r -p "Selection [A/c/n]: " answer
      answer="${answer:-a}"
    else
      read -r -p "Selection [a/c/N]: " answer
      answer="${answer:-n}"
    fi

    case "${answer,,}" in
    a | all)
      destination_ref=("${source_ref[@]}")
      return 0
      ;;

    c | custom)
      local individual_default="no"

      if [[ "$default_mode" == "all" ]]; then
        individual_default="yes"
      fi

      select_packages_individually \
        "$source_name" \
        "$destination_name" \
        "$individual_default"

      return 0
      ;;

    n | none)
      destination_ref=()
      return 0
      ;;

    *)
      warn "Choose A, C, or N."
      ;;
    esac
  done
}

print_selected_group() {
  local title="$1"
  local array_name="$2"

  local -n packages_ref="$array_name"

  printf '%s\n' "$title"

  if ((${#packages_ref[@]} == 0)); then
    printf '  (none)\n'
    return 0
  fi

  print_package_list "$array_name"
}

print_package_selection_summary() {
  section "Package selection summary"

  print_selected_group \
    "Required Arch packages:" \
    SELECTED_ARCH_REQUIRED

  printf '\n'

  print_selected_group \
    "Recommended Arch packages:" \
    SELECTED_ARCH_RECOMMENDED

  printf '\n'

  print_selected_group \
    "Default applications:" \
    SELECTED_ARCH_DEFAULT_APPS

  printf '\n'

  print_selected_group \
    "AUR packages:" \
    SELECTED_AUR_REQUIRED
}

package_is_selected() {
  local package="$1"
  local array_name
  local candidate

  for array_name in \
    SELECTED_ARCH_REQUIRED \
    SELECTED_ARCH_RECOMMENDED \
    SELECTED_ARCH_DEFAULT_APPS \
    SELECTED_AUR_REQUIRED; do
    local -n packages_ref="$array_name"

    for candidate in "${packages_ref[@]}"; do
      if [[ "$candidate" == "$package" ]]; then
        return 0
      fi
    done
  done

  return 1
}

package_group_installed() {
  local array_name="$1"
  local -n packages_ref="$array_name"

  local package

  for package in "${packages_ref[@]}"; do
    if ! pacman -Qq "$package" >/dev/null 2>&1; then
      return 1
    fi
  done

  return 0
}

run_package_selection() {
  section "[2/11] Package selection"

  PACKAGE_INSTALLATION_NEEDED=1

  if ! stdin_is_terminal; then
    die "Interactive package selection requires a terminal."
  fi

  local -a arch_required=()
  local -a arch_recommended=()
  local -a arch_default_apps=()
  local -a aur_required=()

  load_package_manifest \
    "$SETUP_DIR/packages/arch-required.txt" \
    arch_required

  load_package_manifest \
    "$SETUP_DIR/packages/arch-recommended.txt" \
    arch_recommended

  load_package_manifest \
    "$SETUP_DIR/packages/arch-default-apps.txt" \
    arch_default_apps

  load_package_manifest \
    "$SETUP_DIR/packages/aur-required.txt" \
    aur_required

  if package_group_installed arch_required &&
    package_group_installed arch_recommended &&
    package_group_installed arch_default_apps &&
    package_group_installed aur_required; then
    SELECTED_ARCH_REQUIRED=("${arch_required[@]}")
    SELECTED_ARCH_RECOMMENDED=("${arch_recommended[@]}")
    SELECTED_ARCH_DEFAULT_APPS=("${arch_default_apps[@]}")
    SELECTED_AUR_REQUIRED=("${aur_required[@]}")

    PACKAGE_INSTALLATION_NEEDED=0

    success "All Hyprdots Norexil packages are already installed"
    info "Skipping package selection"

    return 0
  fi

  select_package_group \
    "Core packages" \
    "Packages directly required by Hyprdots Norexil." \
    arch_required \
    SELECTED_ARCH_REQUIRED \
    all

  if ((${#SELECTED_ARCH_REQUIRED[@]} < ${#arch_required[@]})); then
    warn "Some core packages were skipped."
    warn "Parts of Hyprdots Norexil may not work without them."
  fi

  select_package_group \
    "Recommended packages" \
    "Recommended desktop integration and Wayland packages." \
    arch_recommended \
    SELECTED_ARCH_RECOMMENDED \
    all

  select_package_group \
    "Default applications" \
    "Applications used by the default Hyprdots Norexil configuration." \
    arch_default_apps \
    SELECTED_ARCH_DEFAULT_APPS \
    all

  select_package_group \
    "AUR packages" \
    "Packages required by the configuration but not provided by the official Arch repositories." \
    aur_required \
    SELECTED_AUR_REQUIRED \
    all

  print_package_selection_summary

  printf '\n'
  success "Package selection complete"
}
