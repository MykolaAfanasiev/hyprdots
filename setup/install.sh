#!/usr/bin/env bash

set -euo pipefail


# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

SETUP_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
    pwd
)"

PROJECT_ROOT="$(
    cd -- "$SETUP_DIR/.." &&
    pwd
)"

LIB_DIR="$SETUP_DIR/lib"


# ------------------------------------------------------------
# Modules
# ------------------------------------------------------------

source "$LIB_DIR/common.sh"
source "$LIB_DIR/filesystem.sh"
source "$LIB_DIR/checks.sh"

source "$LIB_DIR/packages/manifest.sh"
source "$LIB_DIR/packages/select.sh"

source "$LIB_DIR/packages/plan.sh"
source "$LIB_DIR/packages/arch.sh"
source "$LIB_DIR/packages/aur.sh"
source "$LIB_DIR/packages/install.sh"

source "$LIB_DIR/configs/local.sh"

source "$LIB_DIR/links/config.sh"

source "$LIB_DIR/tools/screenshot.sh"

source "$LIB_DIR/directories/runtime.sh"

source "$LIB_DIR/permissions/runtime.sh"

source "$LIB_DIR/verify/report.sh"
source "$LIB_DIR/verify/packages.sh"
source "$LIB_DIR/verify/configs.sh"
source "$LIB_DIR/verify/runtime.sh"
source "$LIB_DIR/verify/install.sh"

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

main() {
    section "Hyprdots Norexil Installer"

    printf 'Project: %s\n' "$PROJECT_ROOT"

    run_system_checks

    printf '\n'
    info "Stage 1 complete."

    run_package_selection

    printf '\n'
    info "Stage 2 complete."

    run_package_installation

    printf '\n'
    info "Stage 3 complete."

    run_local_config_setup

    printf '\n'
    info "Stage 4 complete."

    run_config_link_setup

    printf '\n'
    info "Stage 5 complete."

    run_screenshot_tool_setup

    printf '\n'
    info "Stage 6 complete."

    run_runtime_directory_setup

    printf '\n'
    info "Stage 7 complete."

    run_permission_setup

    printf '\n'
    info "Stage 8 complete."

    run_post_install_verification

    printf '\n'
    info "Stage 9 complete."
}


main "$@"
