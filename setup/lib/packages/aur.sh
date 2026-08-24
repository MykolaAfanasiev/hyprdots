#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_AUR_PACKAGES_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_AUR_PACKAGES_LOADED=1


check_aur_requirements() {
    if ! command_exists git; then
        die "git is required to install AUR packages."
    fi

    if ! command_exists makepkg; then
        die "makepkg is required to install AUR packages."
    fi

    if ! pacman -Qq base-devel >/dev/null 2>&1; then
        die "base-devel is required to build AUR packages."
    fi
}


aur_package_installed() {
    pacman -Qq "$1" >/dev/null 2>&1
}


install_aur_package() {
    local package="$1"

    if aur_package_installed "$package"; then
        success "$package is already installed"
        return 0
    fi

    local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/aur"
    local build_dir
    local repo_dir

    mkdir -p "$cache_root"

    build_dir="$(
        mktemp -d \
            "$cache_root/${package}.XXXXXX"
    )"

    repo_dir="$build_dir/repository"

    info "Downloading AUR package: $package"

    if ! git clone \
        --depth=1 \
        "https://aur.archlinux.org/${package}.git" \
        "$repo_dir"
    then
        rm -rf "$build_dir"
        die "Failed to clone AUR package: $package"
    fi

    printf '\n'
    warn "AUR packages are user-maintained."
    printf 'Review the package files before continuing:\n'
    printf '  %s\n\n' "$repo_dir"

    if ! confirm \
        "Build and install $package?" \
        no
    then
        rm -rf "$build_dir"
        die "AUR package installation cancelled: $package"
    fi

    if ! (
    cd -- "$repo_dir" || exit 1

    makepkg \
        -si \
        --needed
    ); then
        rm -rf -- "$build_dir"
        die "Failed to build or install AUR package: $package"
    fi

    rm -rf -- "$build_dir"

    success "$package installed"
}


install_aur_packages() {
    local -a packages=("$@")

    if (( ${#packages[@]} == 0 )); then
        success "No AUR packages selected"
        return 0
    fi

    section "AUR packages"

    check_aur_requirements

    local package

    for package in "${packages[@]}"; do
        install_aur_package "$package"
    done

    success "AUR packages installed"
}
