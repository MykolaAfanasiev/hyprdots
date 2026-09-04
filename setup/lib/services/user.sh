#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_USER_SERVICES_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_USER_SERVICES_LOADED=1

show_mpd_service_status() {
  command systemctl --user status mpd.service --no-pager -l >&2 || true
}

activate_mpd_service() {
  if ! package_is_selected mpd; then
    info "MPD was not selected; user service activation skipped"
    return 0
  fi

  if [[ "${CONFIG_DEPLOYMENT_MODE:-unknown}" != "automatic" ]]; then
    info "Automatic configuration deployment was not selected; MPD activation skipped"
    info "After deploying configs, run: systemctl --user daemon-reload"
    info "Then run: systemctl --user enable mpd.service && systemctl --user restart mpd.service"
    return 0
  fi

  if ! command_exists systemctl; then
    die "systemctl is unavailable; MPD user service cannot be activated."
  fi

  if [[ ! -r "$HOME/.config/mpd/mpd.conf" ]]; then
    die "MPD configuration is not deployed: $HOME/.config/mpd/mpd.conf"
  fi

  if [[ ! -r "$HOME/.config/systemd/user/mpd.service.d/10-hyprdots.conf" ]]; then
    die "MPD systemd override is not deployed."
  fi

  info "Reloading the user systemd manager..."

  if ! command systemctl --user daemon-reload; then
    die "Failed to reload the user systemd manager."
  fi

  info "Enabling MPD user service..."

  if ! command systemctl --user enable mpd.service; then
    die "Failed to enable mpd.service."
  fi

  info "Starting MPD with the deployed configuration..."

  # restart also starts an inactive service and applies updated config/drop-ins
  # on subsequent installer runs.
  if ! command systemctl --user restart mpd.service; then
    show_mpd_service_status
    die "Failed to start mpd.service."
  fi

  if ! command systemctl --user is-active --quiet mpd.service; then
    show_mpd_service_status
    die "mpd.service did not become active."
  fi

  success "MPD user service is enabled and running"
}

run_user_service_setup() {
  section "[10/11] Services"

  activate_system_service \
    networkmanager \
    NetworkManager.service \
    "NetworkManager"

  activate_system_service \
    bluez \
    bluetooth.service \
    "Bluetooth"

  activate_mpd_service

  printf '\n'
  success "Service setup complete"
}

show_system_service_status() {
  local service="$1"

  command sudo systemctl status "$service" --no-pager -l >&2 || true
}

activate_system_service() {
  local package="$1"
  local service="$2"
  local name="$3"

  if ! package_is_selected "$package"; then
    info "$name was not selected; service activation skipped"
    return 0
  fi

  if ! command_exists systemctl; then
    die "systemctl is unavailable; $name cannot be activated."
  fi

  info "Enabling $name service..."

  if ! command sudo systemctl enable --now "$service"; then
    show_system_service_status "$service"
    die "Failed to enable and start $service."
  fi

  if ! command systemctl is-active --quiet "$service"; then
    show_system_service_status "$service"
    die "$service did not become active."
  fi

  success "$name service is enabled and running"
}
