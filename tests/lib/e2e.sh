#!/usr/bin/env bash

# E2E state and helper functions are consumed indirectly by scenario tests.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_E2E_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_TEST_E2E_LOADED=1

HYPRDOTS_E2E_REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$HYPRDOTS_E2E_REPO_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$HYPRDOTS_E2E_REPO_ROOT/tests/lib/assertions.sh"


require_e2e_command() {
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        return 0
    fi

    printf 'FAIL: E2E dependency is missing: %s\n' \
        "$command_name" >&2

    return 1
}


setup_e2e_test() {
    create_test_sandbox

    require_e2e_command script

    if (( EUID == 0 )); then
        require_e2e_command setpriv
    fi

    E2E_PROJECT="$TEST_ROOT/project"

    mkdir -p "$E2E_PROJECT"

    cp -a -- \
        "$HYPRDOTS_E2E_REPO_ROOT/install.sh" \
        "$E2E_PROJECT/"

    cp -a -- \
        "$HYPRDOTS_E2E_REPO_ROOT/setup" \
        "$E2E_PROJECT/"

    cp -a -- \
        "$HYPRDOTS_E2E_REPO_ROOT/configs" \
        "$E2E_PROJECT/"

    cp -a -- \
        "$HYPRDOTS_E2E_REPO_ROOT/scripts" \
        "$E2E_PROJECT/"

    # Local machine state must never leak into the E2E environment.
    rm -f -- \
        "$E2E_PROJECT/configs/hypr/modules/vars/local.lua" \
        "$E2E_PROJECT/configs/hyprsunset/location.conf"

    unset HYPRDOTS_WALLPAPER_DIR
    unset HYPRDOTS_SCREENSHOT_DIR
    unset PIPX_BIN_DIR

    E2E_STATUS=0

    export E2E_PROJECT
}


create_e2e_pacman_all_installed() {
    cat > "$TEST_BIN/pacman" <<EOF_PACMAN
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/pacman.log"

if [[ "\${1:-}" == "--version" ]]; then
    printf 'Pacman vE2E\n'
    exit 0
fi

if [[ "\${1:-}" == "-Qq" ]]; then
    exit 0
fi

exit 0
EOF_PACMAN

    chmod +x -- "$TEST_BIN/pacman"
}


create_e2e_sudo() {
    local status="$1"

    cat > "$TEST_BIN/sudo" <<EOF_SUDO
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/sudo.log"

exit $status
EOF_SUDO

    chmod +x -- "$TEST_BIN/sudo"
}


create_e2e_stow() {
    cat > "$TEST_BIN/stow" <<EOF_STOW
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/stow.log"

mkdir -p -- \
    "$TEST_HOME/.config/hypr"

rm -f -- \
    "$TEST_HOME/.config/hypr/hyprland.lua"

ln -s -- \
    "$E2E_PROJECT/configs/hypr/hyprland.lua" \
    "$TEST_HOME/.config/hypr/hyprland.lua"

exit 0
EOF_STOW

    chmod +x -- "$TEST_BIN/stow"
}


create_e2e_screenshot_tool() {
    cat > "$TEST_BIN/screenshot-tool" <<EOF_SCREENSHOT
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/screenshot-tool.log"

exit 0
EOF_SCREENSHOT

    chmod +x -- "$TEST_BIN/screenshot-tool"
}


prepare_e2e_environment() {
    local sudo_status="$1"

    mkdir -p -- \
        "$E2E_PROJECT/configs/hyprsunset"

    cat > \
        "$E2E_PROJECT/configs/hyprsunset/location.conf" <<'EOF_LOCATION'
LATITUDE=48.7
LONGITUDE=11.4
EOF_LOCATION

    chmod 600 -- \
        "$E2E_PROJECT/configs/hyprsunset/location.conf"

    create_e2e_pacman_all_installed
    create_e2e_sudo "$sudo_status"
    create_e2e_stow
    create_e2e_screenshot_tool
}


run_e2e_installer() {
    local input="$1"
    local output_file="$2"

    local command

    printf -v command \
        'bash %q' \
        "$E2E_PROJECT/install.sh"

    set +e

    if (( EUID == 0 )); then
        # The real installer correctly rejects root. CI containers normally
        # run as root, so execute only the installer subprocess as a normal
        # unprivileged UID inside its isolated sandbox.
        chown -R \
            65534:65534 \
            "$TEST_ROOT"

        printf '%b' "$input" |
            setpriv \
                --reuid=65534 \
                --regid=65534 \
                --clear-groups \
                env \
                    "HOME=$HOME" \
                    "USER=e2e" \
                    "PATH=$PATH" \
                    "TMPDIR=$TMPDIR" \
                    "XDG_CONFIG_HOME=$XDG_CONFIG_HOME" \
                    "XDG_CACHE_HOME=$XDG_CACHE_HOME" \
                    "XDG_DATA_HOME=$XDG_DATA_HOME" \
                    "XDG_STATE_HOME=$XDG_STATE_HOME" \
                script \
                    -qec "$command" \
                    /dev/null \
                > "$output_file" 2>&1

        E2E_STATUS="${PIPESTATUS[1]}"
    else
        printf '%b' "$input" |
            script \
                -qec "$command" \
                /dev/null \
                > "$output_file" 2>&1

        E2E_STATUS="${PIPESTATUS[1]}"
    fi

    set -e
}

assert_e2e_output_contains() {
    local output_file="$1"
    local expected="$2"

    if grep -Fq -- "$expected" "$output_file"; then
        return 0
    fi

    printf 'FAIL: expected E2E output was not found\n' >&2
    printf '  expected: %s\n' "$expected" >&2

    return 1
}

assert_e2e_output_not_contains() {
    local output_file="$1"
    local unexpected="$2"

    if ! grep -Fq -- "$unexpected" "$output_file"; then
        return 0
    fi

    printf 'FAIL: unexpected E2E output was found\n' >&2
    printf '  unexpected: %s\n' "$unexpected" >&2

    return 1
}
