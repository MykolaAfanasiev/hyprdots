#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_DESKTOP_INTEGRATIONS_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_DESKTOP_INTEGRATIONS_LOADED=1

build_starship_config() {
  local builder="$PROJECT_ROOT/configs/starship/build.zsh"

  if [[ ! -r "$builder" ]]; then
    warn "Starship builder is missing: $builder"
    return 0
  fi

  if ! command_exists zsh || ! command_exists starship; then
    warn "Cannot build Starship config; zsh or starship is unavailable"
    return 0
  fi

  info "Building the generated Starship configuration..."

  if ! command zsh "$builder"; then
    die "Starship configuration build failed."
  fi

  success "Starship configuration built and validated"
}

prepare_sheldon_plugins() {
  local config_dir="$PROJECT_ROOT/configs/zsh"

  if [[ ! -r "$config_dir/plugins.toml" ]]; then
    warn "Sheldon configuration is missing"
    return 0
  fi

  if ! command_exists sheldon; then
    warn "Sheldon is unavailable; Zsh plugins were not installed"
    return 0
  fi

  info "Preparing Sheldon plugins..."

  if ! SHELDON_CONFIG_DIR="$config_dir" \
    command sheldon lock; then
    warn "Sheldon plugins could not be prepared"
    return 0
  fi

  success "Sheldon plugins are ready"
}

prepare_yazi_packages() {
  local config_dir="$PROJECT_ROOT/configs/yazi"

  if [[ ! -r "$config_dir/package.toml" ]]; then
    warn "Yazi package manifest is missing"
    return 0
  fi

  if ! command_exists ya; then
    warn "ya is unavailable; Yazi flavors were not installed"
    return 0
  fi

  info "Installing Yazi packages and flavors..."

  if ! YAZI_CONFIG_HOME="$config_dir" \
    command ya pkg install; then
    warn "Yazi packages could not be installed"
    return 0
  fi

  success "Yazi packages and flavors are ready"
}

prepare_tmux_plugins() {
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local plugin_root="$data_home/tmux/plugins"
  local installer=""
  local candidate

  for candidate in \
    /usr/share/tmux-plugin-manager/bin/install_plugins \
    /usr/share/tmux-plugin-manager/scripts/install_plugins.sh; do
    if [[ -x "$candidate" ]]; then
      installer="$candidate"
      break
    fi
  done

  if [[ -z "$installer" ]]; then
    warn "Tmux Plugin Manager installer was not found"
    return 0
  fi

  mkdir -p -- "$plugin_root"

  info "Installing tmux plugins..."

  if ! TMUX_PLUGIN_MANAGER_PATH="$plugin_root/" \
    "$installer"; then
    warn "tmux plugins could not be installed"
    return 0
  fi

  success "tmux plugins are ready"
}

configure_yazi_file_manager() {
  local desktop_file="${XDG_DATA_HOME:-$HOME/.local/share}/applications/yazi.desktop"

  if ! command_exists xdg-mime; then
    warn "xdg-mime is unavailable; the default file manager was not changed"
    return 0
  fi

  if [[ ! -r "$desktop_file" ]]; then
    warn "Yazi desktop entry is not deployed: $desktop_file"
    return 0
  fi

  command xdg-mime default yazi.desktop inode/directory

  if command_exists update-desktop-database; then
    command update-desktop-database "${desktop_file%/*}"
  fi

  success "Yazi is the default directory handler"
}

configure_zen_file_picker() {
  local preference
  local profile_root
  local profiles_ini
  local relative_path
  local profile_dir
  local user_js
  local updated=0

  local -a profile_roots=(
    "$HOME/.zen"
    "$HOME/.var/app/app.zen_browser.zen/.zen"
  )

  preference='user_pref("widget.use-xdg-desktop-portal.file-picker", 1);'

  for profile_root in "${profile_roots[@]}"; do
    profiles_ini="$profile_root/profiles.ini"
    [[ -r "$profiles_ini" ]] || continue

    while IFS= read -r relative_path; do
      relative_path="${relative_path%$'\r'}"
      [[ -n "$relative_path" ]] || continue

      if [[ "$relative_path" == /* ]]; then
        profile_dir="$relative_path"
      else
        profile_dir="$profile_root/$relative_path"
      fi

      [[ -d "$profile_dir" ]] || continue

      user_js="$profile_dir/user.js"

      if [[ -f "$user_js" ]] &&
        grep -q \
          '^[[:space:]]*user_pref("widget\.use-xdg-desktop-portal\.file-picker",' \
          "$user_js"; then
        sed -i \
          '/^[[:space:]]*user_pref("widget\.use-xdg-desktop-portal\.file-picker",/c\
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);' \
          "$user_js"
      else
        printf '%s\n' "$preference" >>"$user_js"
      fi

      ((updated += 1))
    done < <(
      awk -F= '
                /^Path=/ {
                    sub(/^Path=/, "")
                    print
                }
            ' "$profiles_ini"
    )
  done

  if ((updated == 0)); then
    info "Zen profile was not found; launch Zen and rerun the installer later"
    return 0
  fi

  success "Zen uses the XDG portal file picker in $updated profile(s)"
}

offer_zsh_as_login_shell() {
  if ! command_exists zsh || ! command_exists chsh; then
    return 0
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    success "Zsh is already the login shell"
    return 0
  fi

  if ! confirm "Set Zsh as the login shell?" yes; then
    info "Login shell was not changed"
    return 0
  fi

  if ! command chsh -s "$zsh_path"; then
    warn "Could not change the login shell to $zsh_path"
    return 0
  fi

  success "Login shell changed to $zsh_path; it applies after the next login"
}

restart_desktop_portals() {
  local current_desktop="${XDG_CURRENT_DESKTOP:-}"

  if [[ "${current_desktop,,}" != *hyprland* ]]; then
    info "Hyprland session is not active; portal restart skipped"
    return 0
  fi

  if ! command_exists systemctl; then
    warn "systemctl is unavailable; portals were not restarted"
    return 0
  fi

  info "Restarting XDG desktop portals..."

  if ! command systemctl --user restart \
    xdg-desktop-portal-hyprland.service \
    xdg-desktop-portal-gtk.service \
    xdg-desktop-portal-termfilechooser.service \
    xdg-desktop-portal.service; then
    warn "Desktop portals could not be restarted"
    return 0
  fi

  success "Desktop portals restarted"
}

run_desktop_integration_setup() {
  section "[9/11] Shell and desktop integrations"

  build_starship_config
  prepare_sheldon_plugins
  prepare_yazi_packages
  prepare_tmux_plugins
  offer_zsh_as_login_shell

  if [[ "${CONFIG_DEPLOYMENT_MODE:-unknown}" == "automatic" ]]; then
    configure_yazi_file_manager
    configure_zen_file_picker
    configure_obsidian
    configure_anki
    configure_zen_theme
    restart_desktop_portals
  else
    info "Automatic deployment was not selected; desktop activation skipped"
  fi

  printf '\n'
  success "Shell and desktop integrations complete"
}

configure_obsidian() {
  local configurator="$PROJECT_ROOT/setup/lib/integrations/obsidian.py"

  if ! command_exists obsidian; then
    info "Obsidian is not installed; configuration skipped"
    return 0
  fi

  if ! command_exists python; then
    warn "Python is unavailable; Obsidian configuration skipped"
    return 0
  fi

  if [[ ! -r "$configurator" ]]; then
    warn "Obsidian configurator is missing: $configurator"
    return 0
  fi

  info "Configuring Obsidian..."

  if ! command python "$configurator"; then
    warn "Obsidian configuration failed"
    return 0
  fi

  success "Obsidian configuration is ready"
}

configure_anki() {
  local configurator="$PROJECT_ROOT/setup/lib/integrations/anki.py"

  if [[ ! -d "$HOME/.local/share/Anki2" ]] &&
    [[ ! -d "$HOME/.var/app/net.ankiweb.Anki" ]]; then
    info "Anki data directory was not found; configuration skipped"
    return 0
  fi

  if ! command_exists python; then
    warn "Python is unavailable; Anki configuration skipped"
    return 0
  fi

  if [[ ! -r "$configurator" ]]; then
    warn "Anki configurator is missing: $configurator"
    return 0
  fi

  info "Configuring Anki..."

  if ! command python "$configurator"; then
    warn "Anki configuration failed"
    return 0
  fi

  success "Anki Catppuccin Mocha configuration is ready"
}

configure_zen_theme() {
  local configurator="$PROJECT_ROOT/setup/lib/integrations/zen.py"

  if ! command_exists python; then
    warn "Python is unavailable; Zen theme configuration skipped"
    return 0
  fi

  if [[ ! -r "$configurator" ]]; then
    warn "Zen configurator is missing: $configurator"
    return 0
  fi

  info "Configuring Zen Browser theme..."

  if ! command python "$configurator"; then
    warn "Zen Browser theme configuration failed"
    return 0
  fi

  success "Zen Browser Catppuccin theme is ready"
}
