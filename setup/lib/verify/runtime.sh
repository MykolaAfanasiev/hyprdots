#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_VERIFY_RUNTIME_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_VERIFY_RUNTIME_LOADED=1

verify_screenshot_command() {
    local command_name="screenshot-tool"

    if ! command_exists "$command_name"; then
        verify_warn "$command_name is not available in PATH"
        return 0
    fi

    local executable
    executable="$(command -v "$command_name")"

    if verify_screenshot_tool "$executable"; then
        verify_pass "$command_name is working: $executable"
    else
        verify_fail "$command_name exists but cannot be executed correctly"
    fi
}

verify_runtime_directory() {
    local label="$1"
    local path="$2"

    if [[ -L "$path" ]]; then
        local target

        if ! target="$(readlink -f -- "$path")"; then
            verify_fail "$label directory symlink is broken"
            return 0
        fi

        if [[ ! -d "$target" ]]; then
            verify_fail "$label symlink target is not a directory"
            return 0
        fi

        verify_pass "$label directory: $path -> $target"
        return 0
    fi

    if [[ -d "$path" ]]; then
        verify_pass "$label directory: $path"
        return 0
    fi

    if [[ -e "$path" ]]; then
        verify_fail "$label path exists but is not a directory"
        return 0
    fi

    verify_fail "$label directory does not exist: $path"
}

verify_runtime_directories() {
    local wallpaper_dir="${HYPRDOTS_WALLPAPER_DIR:-$HOME/.wallpapers}"
    local screenshot_dir="${HYPRDOTS_SCREENSHOT_DIR:-$HOME/Screenshots}"

    verify_runtime_directory \
        "Wallpapers" \
        "$wallpaper_dir"

    verify_runtime_directory \
        "Screenshots" \
        "$screenshot_dir"
}

verify_installer_entrypoints() {
    local -a files=(
        "$PROJECT_ROOT/install.sh"
        "$SETUP_DIR/install.sh"
    )

    local file

    for file in "${files[@]}"; do
        if [[ -x "$file" ]]; then
            verify_pass \
                "Executable: ${file#"$PROJECT_ROOT/"}"
        else
            verify_fail \
                "Not executable: ${file#"$PROJECT_ROOT/"}"
        fi
    done
}

verify_runtime_script_permissions() {
    local -a non_executable=()

    local directory
    local file
    local total=0

    for directory in \
        "$PROJECT_ROOT/configs" \
        "$PROJECT_ROOT/scripts"; do
        [[ -d "$directory" ]] || continue

        while IFS= read -r -d '' file; do
            ((total += 1))

            if [[ ! -x "$file" ]]; then
                non_executable+=("$file")
            fi
        done < <(
            find "$directory" \
                -type f \
                -name '*.sh' \
                -print0
        )
    done

    if ((${#non_executable[@]} == 0)); then
        verify_pass "All $total runtime shell script(s) are executable"
        return 0
    fi

    verify_fail \
        "${#non_executable[@]} runtime shell script(s) are not executable"

    for file in "${non_executable[@]}"; do
        printf '  - %s\n' "${file#"$PROJECT_ROOT/"}"
    done
}

verify_mpd_user_service() {
    if ! package_is_selected mpd; then
        return 0
    fi

    if [[ "${CONFIG_DEPLOYMENT_MODE:-unknown}" != "automatic" ]]; then
        return 0
    fi

    if ! command_exists systemctl; then
        verify_fail "systemctl is unavailable; MPD user service cannot be verified"
        return 0
    fi

    if command systemctl --user is-enabled --quiet mpd.service; then
        verify_pass "MPD user service is enabled"
    else
        verify_fail "MPD user service is not enabled"
    fi

    if command systemctl --user is-active --quiet mpd.service; then
        verify_pass "MPD user service is active"
    else
        verify_fail "MPD user service is not active"
    fi

    if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
        local socket="$XDG_RUNTIME_DIR/mpd/socket"

        if [[ -S "$socket" ]]; then
            verify_pass "MPD Unix socket is available: $socket"
        else
            verify_fail "MPD Unix socket is missing: $socket"
        fi
    fi
}

verify_runtime() {
    section "Runtime"

    verify_screenshot_command
    verify_runtime_directories
    verify_installer_entrypoints
    verify_runtime_script_permissions
    verify_mpd_user_service
}
