#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_CONFIG_LINKS_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_CONFIG_LINKS_LOADED=1


symlink_points_to() {
    local link="$1"
    local expected_target="$2"

    [[ -L "$link" ]] || return 1

    local actual_target

    actual_target="$(readlink -f -- "$link")" || return 1

    [[ "$actual_target" == "$expected_target" ]]
}


ensure_symlink() {
    local source="$1"
    local destination="$2"
    local label="$3"

    local resolved_source
    resolved_source="$(readlink -f -- "$source")"

    mkdir -p -- "$(dirname -- "$destination")"

    if [[ -e "$destination" || -L "$destination" ]]; then
        local backup
        backup="$(backup_path "$destination")"

        info "Backup created: $backup"
    fi

    ln -s -- \
        "$resolved_source" \
        "$destination"

    success "Linked $label"
}


show_manual_link_instructions() {
    local source="$1"
    local destination="$2"

    printf '\n'
    info "Manual configuration selected."
    printf '\n'
    printf 'Source:\n'
    printf '  %s\n' "$source"
    printf '\n'
    printf 'Destination:\n'
    printf '  %s\n' "$destination"
    printf '\n'

    if [[ -e "$destination" || -L "$destination" ]]; then
        warn "A file or symlink already exists at the destination."
        printf 'Back it up before creating the new symlink.\n'
        printf '\n'
    fi

    printf 'Create the symlink manually when you are ready.\n'
}


setup_config_link() {
    local source="$1"
    local destination="$2"
    local label="$3"

    if [[ ! -e "$source" ]]; then
        die "Symlink source does not exist: $source"
    fi

    local resolved_source
    resolved_source="$(readlink -f -- "$source")"

    if symlink_points_to \
        "$destination" \
        "$resolved_source"
    then
        success "$label is already linked"
        return 0
    fi

    section "$label"

    printf 'Choose how to configure this link:\n'
    printf '  [A] Automatic - backup existing config and create symlink\n'
    printf '  [M] Manual    - make no changes and show paths\n'
    printf '\n'

    local answer

    while true; do
        read -r -p "Selection [A/m]: " answer
        answer="${answer:-a}"

        case "${answer,,}" in
            a|automatic)
                ensure_symlink \
                    "$resolved_source" \
                    "$destination" \
                    "$label"

                return 0
                ;;

            m|manual)
                show_manual_link_instructions \
                    "$resolved_source" \
                    "$destination"

                return 0
                ;;

            *)
                warn "Choose A or M."
                ;;
        esac
    done
}


run_config_link_setup() {
    section "[5/10] Configuration links"

    setup_config_link \
        "$PROJECT_ROOT/configs/hypr/hyprland.lua" \
        "$HOME/.config/hypr/hyprland.lua" \
        "Hyprland configuration"

    printf '\n'
    success "Configuration link setup complete"
}
