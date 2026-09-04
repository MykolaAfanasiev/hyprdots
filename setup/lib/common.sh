#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_COMMON_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_COMMON_LOADED=1

# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    readonly COLOR_RESET=$'\033[0m'
    readonly COLOR_GREEN=$'\033[32m'
    readonly COLOR_YELLOW=$'\033[33m'
    readonly COLOR_RED=$'\033[31m'
    readonly COLOR_BLUE=$'\033[34m'
    readonly COLOR_BOLD=$'\033[1m'
else
    readonly COLOR_RESET=""
    readonly COLOR_GREEN=""
    readonly COLOR_YELLOW=""
    readonly COLOR_RED=""
    readonly COLOR_BLUE=""
    readonly COLOR_BOLD=""
fi

info() {
    printf '%s[INFO]%s %s\n' \
        "$COLOR_BLUE" \
        "$COLOR_RESET" \
        "$*"
}

success() {
    printf '%s[ OK ]%s %s\n' \
        "$COLOR_GREEN" \
        "$COLOR_RESET" \
        "$*"
}

warn() {
    printf '%s[WARN]%s %s\n' \
        "$COLOR_YELLOW" \
        "$COLOR_RESET" \
        "$*" >&2
}

error() {
    printf '%s[FAIL]%s %s\n' \
        "$COLOR_RED" \
        "$COLOR_RESET" \
        "$*" >&2
}

die() {
    error "$*"
    exit 1
}

section() {
    printf '\n%s%s%s\n\n' \
        "$COLOR_BOLD" \
        "$*" \
        "$COLOR_RESET"
}

confirm() {
    local prompt="$1"
    local default="${2:-no}"

    local answer

    while true; do
        if [[ "$default" == "yes" ]]; then
            read -r -p "$prompt [Y/n] " answer
            answer="${answer:-y}"
        else
            read -r -p "$prompt [y/N] " answer
            answer="${answer:-n}"
        fi

        case "${answer,,}" in
            y | yes)
                return 0
                ;;

            n | no)
                return 1
                ;;

            *)
                warn "Please answer y or n."
                ;;
        esac
    done
}

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

command_exists() {
    command -v "$1" > /dev/null 2>&1
}
