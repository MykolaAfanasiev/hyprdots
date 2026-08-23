#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_CONFIG_LINKS_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_CONFIG_LINKS_LOADED=1


stow_configs() {
    if ! command_exists stow; then
        die "GNU Stow is not installed."
    fi

    mkdir -p -- "$HOME/.config"

    info "Deploying configurations with GNU Stow..."

    stow \
        --restow \
        --dir="$PROJECT_ROOT" \
        --target="$HOME/.config" \
        configs

    success "Configurations deployed with GNU Stow"
}


show_manual_stow_instructions() {
    printf '\n'
    info "Manual configuration selected."
    printf '\n'

    printf 'Stow directory:\n'
    printf '  %s\n' "$PROJECT_ROOT"

    printf '\n'
    printf 'Target directory:\n'
    printf '  %s\n' "$HOME/.config"

    printf '\n'
    printf 'Run:\n'
    printf '  stow --restow --dir="%s" --target="%s" configs\n' \
        "$PROJECT_ROOT" \
        "$HOME/.config"

    printf '\n'
    printf 'No configuration links were changed by the installer.\n'
}


setup_config_deployment() {
    section "Configuration deployment"

    printf 'Choose how to deploy the configurations:\n'
    printf '  [A] Automatic - deploy configs with GNU Stow\n'
    printf '  [M] Manual    - make no changes and show the Stow command\n'
    printf '\n'

    local answer

    while true; do
        read -r -p "Selection [A/m]: " answer
        answer="${answer:-a}"

        case "${answer,,}" in
            a|automatic)
                stow_configs
                return 0
                ;;

            m|manual)
                show_manual_stow_instructions
                return 0
                ;;

            *)
                warn "Choose A or M."
                ;;
        esac
    done
}


run_config_link_setup() {
    section "[5/10] Configuration deployment"

    setup_config_deployment

    printf '\n'
    success "Configuration deployment complete"
}
