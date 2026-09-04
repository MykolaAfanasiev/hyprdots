#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_LOCAL_CONFIGS_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_LOCAL_CONFIGS_LOADED=1

create_local_config() {
    local template="$1"
    local destination="$2"
    local label="$3"

    if [[ -e "$destination" || -L "$destination" ]]; then
        success "$label already exists"
        return 0
    fi

    if [[ ! -r "$template" ]]; then
        die "Local config template is not readable: $template"
    fi

    mkdir -p -- "$(dirname -- "$destination")"

    cp -- \
        "$template" \
        "$destination"

    success "Created $label"
}

coordinate_format_valid() {
    local value="$1"

    [[ "$value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]
}

configure_hyprsunset_location() {
    local destination="$PROJECT_ROOT/configs/hyprsunset/location.conf"

    if [[ -e "$destination" || -L "$destination" ]]; then
        success "Hyprsunset location already exists"
        return 0
    fi

    warn "Hyprsunset location is not configured."

    if ! confirm \
        "Configure Hyprsunset location now?" \
        no; then
        info "Skipping Hyprsunset location configuration"
        return 0
    fi

    local latitude
    local longitude

    while true; do
        read -r -p "Latitude: " latitude

        if coordinate_format_valid "$latitude"; then
            break
        fi

        warn "Latitude must be a number, for example: 48.765"
    done

    while true; do
        read -r -p "Longitude: " longitude

        if coordinate_format_valid "$longitude"; then
            break
        fi

        warn "Longitude must be a number, for example: 11.424"
    done

    printf \
        'LATITUDE=%s\nLONGITUDE=%s\n' \
        "$latitude" \
        "$longitude" \
        > "$destination"

    chmod 600 "$destination"

    success "Hyprsunset location configured"
}

run_local_config_setup() {
    section "[4/11] Local configuration"

    create_local_config \
        "$PROJECT_ROOT/configs/hypr/modules/vars/local.lua.example" \
        "$PROJECT_ROOT/configs/hypr/modules/vars/local.lua" \
        "Hyprland local config"

    configure_hyprsunset_location

    printf '\n'
    success "Local configuration complete"
}
