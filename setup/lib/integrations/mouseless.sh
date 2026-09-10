#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_MOUSELESS_INTEGRATION_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_MOUSELESS_INTEGRATION_LOADED=1

# The upstream project currently publishes tagged Go modules. Pinning the
# default version keeps clean installs reproducible while still allowing an
# override for development/testing.
readonly MOUSELESS_DEFAULT_VERSION="v0.3.0"

declare -gi MOUSELESS_RELOGIN_REQUIRED=0

mouseless_binary_path() {
  printf '%s\n' "${HYPRDOTS_MOUSELESS_BIN:-$HOME/.local/bin/mouseless}"
}

mouseless_version() {
  printf '%s\n' "${HYPRDOTS_MOUSELESS_VERSION:-$MOUSELESS_DEFAULT_VERSION}"
}

mouseless_config_present() {
  [[ -r "$PROJECT_ROOT/configs/mouseless/config.yaml" ]]
}

install_mouseless_binary() {
  if ! mouseless_config_present; then
    info "Mouseless configuration is not present; binary installation skipped"
    return 0
  fi

  local binary
  binary="$(mouseless_binary_path)"

  if [[ -x "$binary" ]]; then
    success "Mouseless is already installed: $binary"
    return 0
  fi

  if ! command_exists go; then
    warn "Go is unavailable; Mouseless was not installed"
    return 0
  fi

  local version
  local bin_dir

  version="$(mouseless_version)"
  bin_dir="$(dirname -- "$binary")"

  mkdir -p -- "$bin_dir"

  info "Installing Mouseless $version with Go..."

  if ! GOBIN="$bin_dir" \
    command go install "github.com/jbensmann/mouseless@$version"; then
    die "Failed to install Mouseless."
  fi

  if [[ ! -x "$binary" ]]; then
    die "Mouseless binary was not found after installation: $binary"
  fi

  success "Mouseless installed: $binary"
}

user_in_group() {
  local group="$1"
  local user="${USER:-$(id -un)}"

  id -nG "$user" 2>/dev/null | tr ' ' '\n' | grep -Fxq -- "$group"
}

ensure_system_group() {
  local group="$1"

  if getent group "$group" >/dev/null 2>&1; then
    return 0
  fi

  info "Creating system group: $group"
  command sudo groupadd --system "$group"
}

ensure_user_group_membership() {
  local user="${USER:-$(id -un)}"
  local -a missing=()
  local group

  for group in input uinput; do
    if ! user_in_group "$group"; then
      missing+=("$group")
    fi
  done

  if ((${#missing[@]} == 0)); then
    success "Mouseless input groups are already active"
    return 0
  fi

  info "Adding $user to groups: ${missing[*]}"

  command sudo usermod \
    -aG "$(
      IFS=,
      printf '%s' "${missing[*]}"
    )" \
    "$user"

  # Supplemental groups are fixed when a login session starts. The service is
  # enabled later, but startup is deferred until the next login when needed.
  # Consumed later by setup/lib/services/user.sh.
  # shellcheck disable=SC2034
  MOUSELESS_RELOGIN_REQUIRED=1

  warn "Mouseless group membership will apply after the next login or reboot"
}

install_mouseless_system_files() {
  local rule_source="$PROJECT_ROOT/configs/mouseless/99-mouseless.rules"
  local module_source="$PROJECT_ROOT/configs/mouseless/uinput.conf"
  local rule_destination="${HYPRDOTS_MOUSELESS_UDEV_RULE:-/etc/udev/rules.d/99-mouseless.rules}"
  local module_destination="${HYPRDOTS_MOUSELESS_MODULE_CONF:-/etc/modules-load.d/uinput.conf}"

  [[ -r "$rule_source" ]] || die "Mouseless udev rule is missing: $rule_source"
  [[ -r "$module_source" ]] || die "Mouseless module config is missing: $module_source"

  ensure_system_group input
  ensure_system_group uinput
  ensure_user_group_membership

  info "Installing Mouseless uinput configuration..."

  command sudo install \
    -Dm644 \
    "$rule_source" \
    "$rule_destination"

  command sudo install \
    -Dm644 \
    "$module_source" \
    "$module_destination"

  command sudo modprobe uinput
  command sudo udevadm control --reload-rules
  command sudo udevadm trigger

  success "Mouseless uinput configuration installed"
}

setup_mouseless_permissions() {
  if ! mouseless_config_present; then
    info "Mouseless configuration is not present; device permissions skipped"
    return 0
  fi

  warn "Mouseless needs access to keyboard input devices and /dev/uinput."
  warn "Processes running as your user can therefore read low-level keyboard input."

  install_mouseless_system_files
}
