#!/usr/bin/env bash

# E2E state and helper functions are consumed indirectly by scenario tests.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_E2E_LOADED:-}" ]]; then
  return 0
fi

readonly HYPRDOTS_TEST_E2E_LOADED=1

HYPRDOTS_E2E_REPO_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$HYPRDOTS_E2E_REPO_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$HYPRDOTS_E2E_REPO_ROOT/tests/lib/assertions.sh"

# ============================================================
# Dependencies
# ============================================================

require_e2e_command() {
  local command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    return 0
  fi

  printf 'FAIL: E2E dependency is missing: %s\n' \
    "$command_name" >&2

  return 1
}

e2e_can_switch_to_unprivileged_user() {
  if ((EUID != 0)); then
    return 0
  fi

  local probe="$TEST_ROOT/chown-probe"

  : >"$probe"

  if chown 65534:65534 "$probe" 2>/dev/null; then
    rm -f -- "$probe"
    return 0
  fi

  rm -f -- "$probe"
  return 1
}

# ============================================================
# Sandbox
# ============================================================

setup_e2e_test() {
  create_test_sandbox

  require_e2e_command script

  if ((EUID == 0)); then
    require_e2e_command setpriv
  fi

  E2E_PROJECT="$TEST_ROOT/project"

  mkdir -p -- \
    "$E2E_PROJECT"

  cp -a -- \
    "$HYPRDOTS_E2E_REPO_ROOT/install.sh" \
    "$E2E_PROJECT/"

  cp -a -- \
    "$HYPRDOTS_E2E_REPO_ROOT/setup" \
    "$E2E_PROJECT/"

  cp -a -- \
    "$HYPRDOTS_E2E_REPO_ROOT/configs" \
    "$E2E_PROJECT/"

  cp -a -- \
    "$HYPRDOTS_E2E_REPO_ROOT/home" \
    "$E2E_PROJECT/"

  cp -a -- \
    "$HYPRDOTS_E2E_REPO_ROOT/scripts" \
    "$E2E_PROJECT/"

  # Local machine-specific configuration must never leak
  # into the isolated E2E environment.
  rm -f -- \
    "$E2E_PROJECT/configs/hypr/modules/vars/local.lua" \
    "$E2E_PROJECT/configs/hyprsunset/location.conf"

  unset HYPRDOTS_WALLPAPER_DIR
  unset HYPRDOTS_SCREENSHOT_DIR
  unset PIPX_BIN_DIR

  E2E_STATUS=0

  export E2E_PROJECT
}

# ============================================================
# Fake external commands
# ============================================================

create_e2e_pacman_all_installed() {
  cat >"$TEST_BIN/pacman" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/pacman.log"

if [[ "\${1:-}" == "--version" ]]; then
    printf 'Pacman vE2E\n'
    exit 0
fi

if [[ "\${1:-}" == "-Qq" ]]; then
    exit 0
fi

exit 0
EOF

  chmod +x -- \
    "$TEST_BIN/pacman"
}

create_e2e_sudo() {
  local status="$1"

  cat >"$TEST_BIN/sudo" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/sudo.log"

exit $status
EOF

  chmod +x -- \
    "$TEST_BIN/sudo"
}

create_e2e_stow() {
  cat >"$TEST_BIN/stow" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/stow.log"

package="\${*: -1}"

case "\$package" in
    configs)
        mkdir -p -- \
            "$TEST_HOME/.config/ghostty" \
            "$TEST_HOME/.config/hypr" \
            "$TEST_HOME/.config/mpd" \
            "$TEST_HOME/.config/rmpc/themes" \
            "$TEST_HOME/.config/systemd/user/mpd.service.d" \
            "$TEST_HOME/.config/starship" \
            "$TEST_HOME/.config/tmux" \
            "$TEST_HOME/.config/xdg-desktop-portal" \
            "$TEST_HOME/.config/xdg-desktop-portal-termfilechooser" \
            "$TEST_HOME/.config/yazi" \
            "$TEST_HOME/.config/zellij" \
            "$TEST_HOME/.config/zsh"

        ln -sf -- "$E2E_PROJECT/configs/ghostty/config.ghostty" \
            "$TEST_HOME/.config/ghostty/config.ghostty"
        ln -sf -- "$E2E_PROJECT/configs/hypr/hyprland.lua" \
            "$TEST_HOME/.config/hypr/hyprland.lua"
        ln -sf -- "$E2E_PROJECT/configs/mpd/mpd.conf" \
            "$TEST_HOME/.config/mpd/mpd.conf"
        ln -sf -- "$E2E_PROJECT/configs/rmpc/config.ron" \
            "$TEST_HOME/.config/rmpc/config.ron"
        ln -sf -- "$E2E_PROJECT/configs/rmpc/themes/catppuccin-mocha.ron" \
            "$TEST_HOME/.config/rmpc/themes/catppuccin-mocha.ron"
        ln -sf -- "$E2E_PROJECT/configs/systemd/user/mpd.service.d/10-hyprdots.conf" \
            "$TEST_HOME/.config/systemd/user/mpd.service.d/10-hyprdots.conf"
        ln -sf -- "$E2E_PROJECT/configs/starship/starship.toml" \
            "$TEST_HOME/.config/starship/starship.toml"
        ln -sf -- "$E2E_PROJECT/configs/tmux/tmux.conf" \
            "$TEST_HOME/.config/tmux/tmux.conf"
        ln -sf -- "$E2E_PROJECT/configs/xdg-desktop-portal/hyprland-portals.conf" \
            "$TEST_HOME/.config/xdg-desktop-portal/hyprland-portals.conf"
        ln -sf -- "$E2E_PROJECT/configs/xdg-desktop-portal-termfilechooser/config" \
            "$TEST_HOME/.config/xdg-desktop-portal-termfilechooser/config"
        ln -sf -- "$E2E_PROJECT/configs/yazi/yazi.toml" \
            "$TEST_HOME/.config/yazi/yazi.toml"
        ln -sf -- "$E2E_PROJECT/configs/zellij/config.kdl" \
            "$TEST_HOME/.config/zellij/config.kdl"
        ln -sf -- "$E2E_PROJECT/configs/zsh/.zshrc" \
            "$TEST_HOME/.config/zsh/.zshrc"
        ;;

    home)
        mkdir -p -- \
            "$TEST_HOME/.local/share/applications"

        ln -sf -- "$E2E_PROJECT/home/.zshenv" \
            "$TEST_HOME/.zshenv"
        ln -sf -- "$E2E_PROJECT/home/.local/share/applications/yazi.desktop" \
            "$TEST_HOME/.local/share/applications/yazi.desktop"
        ;;
esac

exit 0
EOF

  chmod +x -- \
    "$TEST_BIN/stow"
}

create_e2e_systemctl() {
  cat >"$TEST_BIN/systemctl" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/systemctl.log"

if [[ "\${1:-}" == "--user" && "\${2:-}" == "status" ]]; then
    printf '%s\n' 'mpd.service - Music Player Daemon' 'Active: active (running)'
fi

exit 0
EOF

  chmod +x -- \
    "$TEST_BIN/systemctl"
}

create_e2e_screenshot_tool() {
  cat >"$TEST_BIN/screenshot-tool" <<EOF
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/screenshot-tool.log"

exit 0
EOF

  chmod +x -- \
    "$TEST_BIN/screenshot-tool"
}

# ============================================================
# Complete fake environment
# ============================================================

prepare_e2e_environment() {
  local sudo_status="$1"

  mkdir -p -- \
    "$E2E_PROJECT/configs/hyprsunset"

  cat > \
    "$E2E_PROJECT/configs/hyprsunset/location.conf" <<'EOF'
LATITUDE=48.7
LONGITUDE=11.4
EOF

  chmod 600 -- \
    "$E2E_PROJECT/configs/hyprsunset/location.conf"

  create_e2e_pacman_all_installed
  create_e2e_sudo "$sudo_status"
  create_e2e_stow
  create_e2e_systemctl
  create_e2e_chsh
  create_e2e_screenshot_tool
}

# ============================================================
# Installer execution
# ============================================================

run_e2e_installer() {
  local input="$1"
  local output_file="$2"

  local command

  printf -v command \
    'bash %q' \
    "$E2E_PROJECT/install.sh"

  set +e

  if ((EUID == 0)); then
    # GitHub Actions runs the Arch container as root.
    #
    # The real installer intentionally rejects root, so only the
    # installer subprocess is executed under an unprivileged UID.
    #
    # UID/GID 65534 normally belongs to nobody. Its login shell can
    # be nologin, therefore SHELL is explicitly set to /bin/bash
    # before util-linux "script" creates the pseudo-terminal.

    chown -R \
      65534:65534 \
      "$TEST_ROOT"

    printf '%b' "$input" |
      setpriv \
        --reuid=65534 \
        --regid=65534 \
        --clear-groups \
        env \
        "HOME=$HOME" \
        "USER=e2e" \
        "LOGNAME=e2e" \
        "SHELL=/bin/bash" \
        "PATH=$PATH" \
        "TMPDIR=$TMPDIR" \
        "XDG_CONFIG_HOME=$XDG_CONFIG_HOME" \
        "XDG_CACHE_HOME=$XDG_CACHE_HOME" \
        "XDG_DATA_HOME=$XDG_DATA_HOME" \
        "XDG_STATE_HOME=$XDG_STATE_HOME" \
        "XDG_RUNTIME_DIR=" \
        script \
        -qec "$command" \
        /dev/null \
        >"$output_file" 2>&1

    E2E_STATUS="${PIPESTATUS[1]}"
  else
    # Explicit SHELL keeps local execution identical to CI instead
    # of depending on the user's interactive shell (zsh, bash, etc.).

    printf '%b' "$input" |
      env \
        "HOME=$HOME" \
        "USER=e2e" \
        "LOGNAME=e2e" \
        "SHELL=/bin/bash" \
        "PATH=$PATH" \
        "TMPDIR=$TMPDIR" \
        "XDG_CONFIG_HOME=$XDG_CONFIG_HOME" \
        "XDG_CACHE_HOME=$XDG_CACHE_HOME" \
        "XDG_DATA_HOME=$XDG_DATA_HOME" \
        "XDG_STATE_HOME=$XDG_STATE_HOME" \
        "XDG_RUNTIME_DIR=" \
        script \
        -qec "$command" \
        /dev/null \
        >"$output_file" 2>&1

    E2E_STATUS="${PIPESTATUS[1]}"
  fi

  set -e
}

# ============================================================
# E2E assertions
# ============================================================

assert_e2e_output_contains() {
  local output_file="$1"
  local expected="$2"

  if grep -Fq -- "$expected" "$output_file"; then
    return 0
  fi

  printf 'FAIL: expected E2E output was not found\n' >&2
  printf '  expected: %s\n' "$expected" >&2

  return 1
}

assert_e2e_output_not_contains() {
  local output_file="$1"
  local unexpected="$2"

  if ! grep -Fq -- "$unexpected" "$output_file"; then
    return 0
  fi

  printf 'FAIL: unexpected E2E output was found\n' >&2
  printf '  unexpected: %s\n' "$unexpected" >&2

  return 1
}

print_e2e_output() {
  local output_file="$1"

  printf '\n--- E2E installer output ---\n' >&2

  if [[ -f "$output_file" ]]; then
    cat -- "$output_file" >&2
  else
    printf 'Output file does not exist: %s\n' \
      "$output_file" >&2
  fi

  printf '%s\n' \
    '----------------------------' >&2
}

create_e2e_chsh() {
  cat >"$TEST_BIN/chsh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF

  chmod +x "$TEST_BIN/chsh"
}
