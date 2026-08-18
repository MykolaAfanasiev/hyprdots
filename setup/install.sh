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
source "$LIB_DIR/checks.sh"

source "$LIB_DIR/packages/manifest.sh"
source "$LIB_DIR/packages/select.sh"

source "$LIB_DIR/packages/plan.sh"
source "$LIB_DIR/packages/arch.sh"
source "$LIB_DIR/packages/aur.sh"
source "$LIB_DIR/packages/install.sh"

source "$LIB_DIR/configs/local.sh"

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
}


main "$@"
