#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_CONFIGS_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_VERIFY_CONFIGS_LOADED=1

verify_hyprland_local_config() {
  local config="$PROJECT_ROOT/configs/hypr/modules/vars/local.lua"

  if [[ -r "$config" ]]; then
    verify_pass "Hyprland local config exists"
  else
    verify_fail "Hyprland local config is missing or unreadable"
  fi
}

verify_hyprsunset_location() {
  local config="$PROJECT_ROOT/configs/hyprsunset/location.conf"

  if [[ ! -e "$config" && ! -L "$config" ]]; then
    verify_warn "Hyprsunset location is not configured"
    return 0
  fi

  if [[ -L "$config" ]]; then
    verify_warn "Hyprsunset location.conf is a symlink"
    return 0
  fi

  if [[ ! -r "$config" ]]; then
    verify_fail "Hyprsunset location.conf is not readable"
    return 0
  fi

  verify_pass "Hyprsunset location is configured"

  local permissions
  permissions="$(stat -c '%a' -- "$config")"

  if [[ "$permissions" == "600" ]]; then
    verify_pass "Hyprsunset location permissions are 600"
  else
    verify_fail \
      "Hyprsunset location permissions are $permissions; expected 600"
  fi
}

verify_hyprland_link() {
  local source="$PROJECT_ROOT/configs/hypr/hyprland.lua"
  local destination="$HOME/.config/hypr/hyprland.lua"

  local resolved_source
  resolved_source="$(readlink -f -- "$source")"

  if managed_path_resolves_to \
    "$destination" \
    "$resolved_source"; then
    verify_pass "Hyprland configuration resolves to the repository"
    return 0
  fi

  if [[ -L "$destination" ]]; then
    verify_warn "Hyprland configuration symlink points somewhere else"
    return 0
  fi

  if [[ -e "$destination" ]]; then
    verify_warn "Hyprland configuration is not a symlink"
    return 0
  fi

  verify_warn "Hyprland configuration link is not configured"
}

managed_path_resolves_to() {
  local destination="$1"
  local source="$2"

  [[ -e "$destination" || -L "$destination" ]] || return 1
  [[ -e "$source" || -L "$source" ]] || return 1

  local resolved_destination
  local resolved_source

  resolved_destination="$(readlink -f -- "$destination")" || return 1
  resolved_source="$(readlink -f -- "$source")" || return 1

  [[ "$resolved_destination" == "$resolved_source" ]]
}

verify_managed_configuration_links() {
  local -a mappings=(
    "Ghostty|$PROJECT_ROOT/configs/ghostty/config.ghostty|$HOME/.config/ghostty/config.ghostty"
    "MPD|$PROJECT_ROOT/configs/mpd/mpd.conf|$HOME/.config/mpd/mpd.conf"
    "rmpc|$PROJECT_ROOT/configs/rmpc/config.ron|$HOME/.config/rmpc/config.ron"
    "rmpc theme|$PROJECT_ROOT/configs/rmpc/themes/catppuccin-mocha.ron|$HOME/.config/rmpc/themes/catppuccin-mocha.ron"
    "MPD systemd override|$PROJECT_ROOT/configs/systemd/user/mpd.service.d/10-hyprdots.conf|$HOME/.config/systemd/user/mpd.service.d/10-hyprdots.conf"
    "Starship|$PROJECT_ROOT/configs/starship/starship.toml|$HOME/.config/starship/starship.toml"
    "tmux|$PROJECT_ROOT/configs/tmux/tmux.conf|$HOME/.config/tmux/tmux.conf"
    "Zellij|$PROJECT_ROOT/configs/zellij/config.kdl|$HOME/.config/zellij/config.kdl"
    "Yazi|$PROJECT_ROOT/configs/yazi/yazi.toml|$HOME/.config/yazi/yazi.toml"
    "Zsh|$PROJECT_ROOT/configs/zsh/.zshrc|$HOME/.config/zsh/.zshrc"
    "XDG portal|$PROJECT_ROOT/configs/xdg-desktop-portal/hyprland-portals.conf|$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"
    "Terminal file chooser|$PROJECT_ROOT/configs/xdg-desktop-portal-termfilechooser/config|$HOME/.config/xdg-desktop-portal-termfilechooser/config"
    "Zsh environment|$PROJECT_ROOT/home/.zshenv|$HOME/.zshenv"
    "Yazi desktop entry|$PROJECT_ROOT/home/.local/share/applications/yazi.desktop|$HOME/.local/share/applications/yazi.desktop"
  )

  local -a unresolved=()
  local mapping
  local label
  local source
  local destination

  for mapping in "${mappings[@]}"; do
    IFS='|' read -r label source destination <<<"$mapping"

    if ! managed_path_resolves_to "$destination" "$source"; then
      unresolved+=("$label: $destination")
    fi
  done

  if ((${#unresolved[@]} == 0)); then
    verify_pass \
      "All ${#mappings[@]} managed configuration paths resolve to the repository"
    return 0
  fi

  verify_warn \
    "${#unresolved[@]} managed configuration path(s) are not deployed"

  local item

  for item in "${unresolved[@]}"; do
    printf '  - %s\n' "$item"
  done
}

verify_configuration() {
  section "Configuration"

  verify_hyprland_local_config
  verify_hyprsunset_location
  verify_hyprland_link
  verify_managed_configuration_links
}
