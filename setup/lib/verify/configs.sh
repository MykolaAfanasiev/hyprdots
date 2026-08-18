#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_CONFIGS_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_VERIFY_CONFIGS_LOADED=1


verify_hyprland_local_config() {
    local config="$PROJECT_ROOT/configs/hypr/modules/vars/local.lua"

    if [[ -r "$config" ]]; then
        verify_pass "Hyprland local config exists"
    else
        verify_fail "Hyprland local config is missing or unreadable"
    fi
}


verify_hyprsunset_location() {
    local config="$PROJECT_ROOT/configs/hyprsunset/location.conf"

    if [[ ! -e "$config" && ! -L "$config" ]]; then
        verify_warn "Hyprsunset location is not configured"
        return 0
    fi

    if [[ -L "$config" ]]; then
        verify_warn "Hyprsunset location.conf is a symlink"
        return 0
    fi

    if [[ ! -r "$config" ]]; then
        verify_fail "Hyprsunset location.conf is not readable"
        return 0
    fi

    verify_pass "Hyprsunset location is configured"

    local permissions
    permissions="$(stat -c '%a' -- "$config")"

    if [[ "$permissions" == "600" ]]; then
        verify_pass "Hyprsunset location permissions are 600"
    else
        verify_fail \
            "Hyprsunset location permissions are $permissions; expected 600"
    fi
}


verify_hyprland_link() {
    local source="$PROJECT_ROOT/configs/hypr/hyprland.lua"
    local destination="$HOME/.config/hypr/hyprland.lua"

    local resolved_source
    resolved_source="$(readlink -f -- "$source")"

    if symlink_points_to \
        "$destination" \
        "$resolved_source"
    then
        verify_pass "Hyprland configuration symlink is correct"
        return 0
    fi

    if [[ -L "$destination" ]]; then
        verify_warn "Hyprland configuration symlink points somewhere else"
        return 0
    fi

    if [[ -e "$destination" ]]; then
        verify_warn "Hyprland configuration is not a symlink"
        return 0
    fi

    verify_warn "Hyprland configuration link is not configured"
}


verify_configuration() {
    section "Configuration"

    verify_hyprland_local_config
    verify_hyprsunset_location
    verify_hyprland_link
}
