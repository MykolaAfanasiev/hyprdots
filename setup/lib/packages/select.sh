#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_PACKAGE_SELECT_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_PACKAGE_SELECT_LOADED=1


declare -ag SELECTED_ARCH_REQUIRED=()
declare -ag SELECTED_ARCH_RECOMMENDED=()
declare -ag SELECTED_ARCH_DEFAULT_APPS=()
declare -ag SELECTED_AUR_REQUIRED=()


print_package_list() {
    local array_name="$1"
    local -n packages="$array_name"

    local package

    for package in "${packages[@]}"; do
        printf '  - %s\n' "$package"
    done
}


select_packages_individually() {
    local source_name="$1"
    local destination_name="$2"
    local default_answer="$3"

    local -n source="$source_name"
    local -n destination="$destination_name"

    destination=()

    local package
    local answer

    for package in "${source[@]}"; do
        while true; do
            if [[ "$default_answer" == "yes" ]]; then
                read -r -p "Install $package? [Y/n] " answer
                answer="${answer:-y}"
            else
                read -r -p "Install $package? [y/N] " answer
                answer="${answer:-n}"
            fi

            case "${answer,,}" in
                y|yes)
                    destination+=("$package")
                    break
                    ;;

                n|no)
                    break
                    ;;

                *)
                    warn "Please answer y or n."
                    ;;
            esac
        done
    done
}


select_package_group() {
    local title="$1"
    local description="$2"
    local source_name="$3"
    local destination_name="$4"
    local default_mode="$5"

    local -n source="$source_name"
    local -n destination="$destination_name"

    section "$title"

    printf '%s\n\n' "$description"

    print_package_list "$source_name"

    printf '\n'
    printf 'Choose:\n'
    printf '  [A] Install all\n'
    printf '  [C] Choose individually\n'
    printf '  [N] Install none\n'
    printf '\n'

    local answer

    while true; do
        if [[ "$default_mode" == "all" ]]; then
            read -r -p "Selection [A/c/n]: " answer
            answer="${answer:-a}"
        else
            read -r -p "Selection [a/c/N]: " answer
            answer="${answer:-n}"
        fi

        case "${answer,,}" in
            a|all)
                destination=("${source[@]}")
                return 0
                ;;
            c|custom)
                local individual_default="no"

                if [[ "$default_mode" == "all" ]]; then
                    individual_default="yes"
                fi

                select_packages_individually \
                    "$source_name" \
                    "$destination_name" \
                    "$individual_default"

                return 0
                ;;
              n|none)
                  destination=()
                  return 0
                  ;;

              *)
                  warn "Choose A, C, or N."
                  ;;
        esac
    done
}


print_selected_group() {
    local title="$1"
    local array_name="$2"

    local -n packages="$array_name"

    printf '%s\n' "$title"

    if (( ${#packages[@]} == 0 )); then
        printf '  (none)\n'
        return 0
    fi

    print_package_list "$array_name"
}


print_package_selection_summary() {
    section "Package selection summary"

    print_selected_group \
        "Required Arch packages:" \
        SELECTED_ARCH_REQUIRED

    printf '\n'

    print_selected_group \
        "Recommended Arch packages:" \
        SELECTED_ARCH_RECOMMENDED

    printf '\n'

    print_selected_group \
        "Default applications:" \
        SELECTED_ARCH_DEFAULT_APPS

    printf '\n'

    print_selected_group \
        "AUR packages:" \
        SELECTED_AUR_REQUIRED
}


run_package_selection() {
    section "[2/10] Package selection"

    if [[ ! -t 0 ]]; then
        die "Interactive package selection requires a terminal."
    fi

    local -a arch_required=()
    local -a arch_recommended=()
    local -a arch_default_apps=()
    local -a aur_required=()

    load_package_manifest \
        "$SETUP_DIR/packages/arch-required.txt" \
        arch_required

    load_package_manifest \
        "$SETUP_DIR/packages/arch-recommended.txt" \
        arch_recommended

    load_package_manifest \
        "$SETUP_DIR/packages/arch-default-apps.txt" \
        arch_default_apps

    load_package_manifest \
        "$SETUP_DIR/packages/aur-required.txt" \
        aur_required

    select_package_group \
        "Core packages" \
        "Packages directly required by Hyprdots Norexil." \
        arch_required \
        SELECTED_ARCH_REQUIRED \
        all

    if (( ${#SELECTED_ARCH_REQUIRED[@]} < ${#arch_required[@]} )); then
        warn "Some core packages were skipped."
        warn "Parts of Hyprdots Norexil may not work without them."
    fi

    select_package_group \
        "Recommended packages" \
        "Recommended desktop integration and Wayland packages." \
        arch_recommended \
        SELECTED_ARCH_RECOMMENDED \
        all

    select_package_group \
        "Default applications" \
        "Applications used by the default Hyprdots Norexil configuration." \
        arch_default_apps \
        SELECTED_ARCH_DEFAULT_APPS \
        all

    select_package_group \
        "AUR packages" \
        "Packages required by the configuration but not provided by the official Arch repositories." \
        aur_required \
        SELECTED_AUR_REQUIRED \
        all

    print_package_selection_summary

    printf '\n'
    success "Package selection complete"
}
