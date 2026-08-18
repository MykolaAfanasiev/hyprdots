#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_RUNTIME_PERMISSIONS_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_RUNTIME_PERMISSIONS_LOADED=1


ensure_executable() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        warn "Cannot set executable permission; file does not exist:"
        printf '  %s\n' "$file"
        return 0
    fi

    if [[ -x "$file" ]]; then
        return 0
    fi

    chmod u+x -- "$file"

    info "Made executable: ${file#"$PROJECT_ROOT/"}"
}


ensure_installer_entrypoints_executable() {
    ensure_executable \
        "$PROJECT_ROOT/install.sh"

    ensure_executable \
        "$SETUP_DIR/install.sh"
}


ensure_runtime_scripts_executable() {
    local directory
    local file

    for directory in \
        "$PROJECT_ROOT/configs" \
        "$PROJECT_ROOT/scripts"
    do
        if [[ ! -d "$directory" ]]; then
            warn "Runtime directory does not exist:"
            printf '  %s\n' "$directory"
            continue
        fi

        while IFS= read -r -d '' file; do
            ensure_executable "$file"
        done < <(
            find "$directory" \
                -type f \
                -name '*.sh' \
                -print0
        )
    done
}


secure_hyprsunset_location() {
    local location_file="$PROJECT_ROOT/configs/hyprsunset/location.conf"

    if [[ ! -e "$location_file" ]]; then
        info "Hyprsunset location is not configured; skipping permissions"
        return 0
    fi

    if [[ -L "$location_file" ]]; then
        warn "Hyprsunset location.conf is a symlink; permissions were not changed"
        return 0
    fi

    chmod 600 -- "$location_file"

    success "Hyprsunset location permissions: 600"
}


run_permission_setup() {
    section "[8/10] Permissions"

    ensure_installer_entrypoints_executable
    ensure_runtime_scripts_executable
    secure_hyprsunset_location

    printf '\n'
    success "Permissions setup complete"
}
