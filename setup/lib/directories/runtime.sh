#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_RUNTIME_DIRECTORIES_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_RUNTIME_DIRECTORIES_LOADED=1


expand_home_path() {
    local path="$1"

    # Match a literal '~' entered by the user.
    # shellcheck disable=SC2088
    case "$path" in
        "~")
            printf '%s\n' "$HOME"
            ;;

        "~/"*)
            printf '%s/%s\n' \
                "$HOME" \
                "${path#~/}"
            ;;

        *)
            printf '%s\n' "$path"
            ;;
    esac
}


absolute_path() {
    local path="$1"

    if [[ "$path" == /* ]]; then
        printf '%s\n' "$path"
        return 0
    fi

    printf '%s/%s\n' \
        "$PWD" \
        "$path"
}


create_directory_link() {
    local target="$1"
    local destination="$2"
    local label="$3"

    if [[ -e "$destination" || -L "$destination" ]]; then
        warn "$label default path already exists:"
        printf '  %s\n' "$destination"

        if ! confirm \
            "Back it up and replace it with a symlink?" \
            no
        then
            warn "Skipping $label link"
            return 0
        fi

        local backup
        backup="$(backup_path "$destination")"

        info "Backup created: $backup"
    fi

    ln -s -- \
        "$target" \
        "$destination"

    success "$label linked to: $target"
}


configure_runtime_directory() {
    local label="$1"
    local default_path="$2"

    section "$label"

    printf 'Default location:\n'
    printf '  %s\n\n' "$default_path"

    printf 'Choose location:\n'
    printf '  [D] Default  - use %s\n' "$default_path"
    printf '  [C] Custom   - use another directory\n'
    printf '\n'

    local answer

    while true; do
        read -r -p "Selection [D/c]: " answer
        answer="${answer:-d}"

        case "${answer,,}" in
            d|default)
                mkdir -p -- "$default_path"

                success "$label directory: $default_path"
                return 0
                ;;

            c|custom)
                break
                ;;

            *)
                warn "Choose D or C."
                ;;
        esac
    done

    local custom_path

    while true; do
        read -r -p "Directory path: " custom_path

        if [[ -z "$custom_path" ]]; then
            warn "Directory path cannot be empty."
            continue
        fi

        custom_path="$(expand_home_path "$custom_path")"
        custom_path="$(absolute_path "$custom_path")"

        if [[ -d "$custom_path" ]]; then
            break
        fi

        warn "Directory does not exist:"
        printf '  %s\n' "$custom_path"

        if confirm \
            "Create this directory?" \
            no
        then
            mkdir -p -- "$custom_path"
            break
        fi
    done

    local resolved_custom_path
    resolved_custom_path="$(readlink -f -- "$custom_path")"

    if [[ "$resolved_custom_path" == "$default_path" ]]; then
        success "$label directory: $default_path"
        return 0
    fi

    create_directory_link \
        "$resolved_custom_path" \
        "$default_path" \
        "$label"
}


run_runtime_directory_setup() {
    section "[7/10] Runtime directories"

    configure_runtime_directory \
        "Wallpapers" \
        "$HOME/.wallpapers"

    configure_runtime_directory \
        "Screenshots" \
        "$HOME/Screenshots"

    printf '\n'
    success "Runtime directory setup complete"
}
