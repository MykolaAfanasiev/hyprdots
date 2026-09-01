#!/usr/bin/env bash


# ------------------------------------------------------------
# System information helpers
# ------------------------------------------------------------

get_effective_uid() {
    printf '%s\n' "$EUID"
}


get_bash_major_version() {
    printf '%s\n' "${BASH_VERSINFO[0]}"
}


get_os_release_path() {
    printf '%s\n' "/etc/os-release"
}


is_directory_writable() {
    [[ -w "$1" ]]
}


# ------------------------------------------------------------
# Checks
# ------------------------------------------------------------

check_not_root() {
    local effective_uid
    effective_uid="$(get_effective_uid)"

    if (( effective_uid == 0 )); then
        die "Do not run the installer as root. Run ./install.sh as your normal user."
    fi

    success "Running as user: ${USER:-$(id -un)}"
}


check_bash() {
    local bash_major
    bash_major="$(get_bash_major_version)"

    if (( bash_major < 4 )); then
        die "Bash 4 or newer is required."
    fi

    success "Bash ${BASH_VERSION}"
}


check_home() {
    if [[ -z "${HOME:-}" ]]; then
        die "\$HOME is not set."
    fi

    if [[ ! -d "$HOME" ]]; then
        die "Home directory does not exist: $HOME"
    fi

    if ! is_directory_writable "$HOME"; then
        die "Home directory is not writable: $HOME"
    fi

    success "Home directory: $HOME"
}


check_arch_linux() {
    local os_release
    os_release="$(get_os_release_path)"

    if [[ ! -r "$os_release" ]]; then
        die "Cannot read $os_release."
    fi

    local ID=""
    local ID_LIKE=""
    local PRETTY_NAME=""

    # shellcheck source=/etc/os-release
    source "$os_release"

    if [[ "${ID:-}" == "arch" ]]; then
        success "Operating system: ${PRETTY_NAME:-Arch Linux}"
        return 0
    fi

    if [[ " ${ID_LIKE:-} " == *" arch "* ]]; then
        warn "Arch-based distribution detected: ${PRETTY_NAME:-${ID:-unknown}}"
        warn "The installer is primarily tested on Arch Linux."
        return 0
    fi

    die "Unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}. Arch Linux is required."
}


check_pacman() {
    if ! command_exists pacman; then
        die "pacman was not found."
    fi

    success "pacman found: $(command -v pacman)"
}


check_sudo() {
    if ! command_exists sudo; then
        die "sudo was not found."
    fi

    success "sudo found: $(command -v sudo)"

    info "Checking sudo access..."

    if sudo -n true 2>/dev/null; then
        success "sudo access available"
        return 0
    fi

    if sudo -v; then
        success "sudo authentication successful"
        return 0
    fi

    die "Unable to authenticate with sudo."
}


check_repository() {
    local required_paths=(
        "$PROJECT_ROOT/configs"
        "$PROJECT_ROOT/home"
        "$PROJECT_ROOT/scripts"
        "$SETUP_DIR/packages"
    )

    local path

    for path in "${required_paths[@]}"; do
        if [[ ! -d "$path" ]]; then
            die "Required repository path is missing: $path"
        fi
    done

    success "Repository structure looks valid"
}


run_system_checks() {
    section "[1/10] System check"

    check_not_root
    check_bash
    check_home
    check_arch_linux
    check_pacman
    check_sudo
    check_repository

    printf '\n'
    success "System check passed"
}
