#!/usr/bin/env bash

# Test state and dynamically overridden functions are consumed indirectly
# by Stage 3 scenario tests.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_PACKAGE_INSTALLATION_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_TEST_PACKAGE_INSTALLATION_LOADED=1

HYPRDOTS_TEST_REPO_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &&
    pwd
)"

# shellcheck source=tests/lib/sandbox.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/sandbox.sh"

# shellcheck source=tests/lib/assertions.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/assertions.sh"

# shellcheck source=tests/lib/fake-command.sh
source "$HYPRDOTS_TEST_REPO_ROOT/tests/lib/fake-command.sh"

# shellcheck source=setup/lib/common.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/common.sh"

# shellcheck source=setup/lib/packages/select.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/select.sh"

# shellcheck source=setup/lib/packages/plan.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/plan.sh"

# shellcheck source=setup/lib/packages/arch.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/arch.sh"

# shellcheck source=setup/lib/packages/aur.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/aur.sh"

# shellcheck source=setup/lib/packages/install.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/install.sh"


setup_package_installation_test() {
    create_test_sandbox

    PROJECT_ROOT="$TEST_ROOT/project"
    SETUP_DIR="$PROJECT_ROOT/setup"

    SELECTED_ARCH_REQUIRED=()
    SELECTED_ARCH_RECOMMENDED=()
    SELECTED_ARCH_DEFAULT_APPS=()
    SELECTED_AUR_REQUIRED=()

    PACKAGE_INSTALLATION_NEEDED=1

    TEST_AVAILABLE_COMMANDS=""
    TEST_CONFIRM_STATUS=0

    export PROJECT_ROOT
    export SETUP_DIR
}


mock_available_commands() {
    TEST_AVAILABLE_COMMANDS=" $* "
}


command_exists() {
    local command_name="$1"

    [[ "$TEST_AVAILABLE_COMMANDS" == *" $command_name "* ]]
}


mock_confirm_yes() {
    TEST_CONFIRM_STATUS=0
}


mock_confirm_no() {
    TEST_CONFIRM_STATUS=1
}


confirm() {
    return "$TEST_CONFIRM_STATUS"
}


create_fake_pacman() {
    local install_status="$1"
    shift

    local installed_file="$TEST_STATE/installed-packages"

    : > "$installed_file"

    if (( $# > 0 )); then
        printf '%s\n' "$@" > "$installed_file"
    fi

    cat > "$TEST_BIN/pacman" <<EOF_PACMAN
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/pacman.log"

if [[ "\${1:-}" == "-Qq" ]]; then
    grep -Fxq -- "\${2:-}" "$installed_file"
    exit \$?
fi

if [[ "\${1:-}" == "-S" ]]; then
    exit $install_status
fi

exit 0
EOF_PACMAN

    chmod +x -- "$TEST_BIN/pacman"
}


create_fake_sudo_passthrough() {
    cat > "$TEST_BIN/sudo" <<EOF_SUDO
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/sudo.log"

"\$@"
EOF_SUDO

    chmod +x -- "$TEST_BIN/sudo"
}


create_fake_git_clone() {
    local clone_status="$1"

    cat > "$TEST_BIN/git" <<EOF_GIT
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/git.log"

if [[ "\${1:-}" == "clone" ]]; then
    if (( $clone_status != 0 )); then
        exit $clone_status
    fi

    destination="\${@: -1}"

    mkdir -p -- "\$destination"
fi

exit 0
EOF_GIT

    chmod +x -- "$TEST_BIN/git"
}


create_fake_makepkg() {
    local status="$1"

    cat > "$TEST_BIN/makepkg" <<EOF_MAKEPKG
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/makepkg.log"

exit $status
EOF_MAKEPKG

    chmod +x -- "$TEST_BIN/makepkg"
}


assert_array_equals() {
    local array_name="$1"
    shift

    local -n actual_ref="$array_name"

    if (( ${#actual_ref[@]} != $# )); then
        printf 'FAIL: array %s has unexpected length\n' "$array_name" >&2
        printf '  expected: %s\n' "$#" >&2
        printf '  actual:   %s\n' "${#actual_ref[@]}" >&2
        return 1
    fi

    local index=0
    local expected

    for expected in "$@"; do
        if [[ "${actual_ref[$index]}" != "$expected" ]]; then
            printf 'FAIL: array %s differs at index %s\n' \
                "$array_name" \
                "$index" >&2

            printf '  expected: %s\n' "$expected" >&2
            printf '  actual:   %s\n' "${actual_ref[$index]}" >&2
            return 1
        fi

        (( index += 1 ))
    done
}


assert_array_empty() {
    local array_name="$1"
    local -n actual_ref="$array_name"

    if (( ${#actual_ref[@]} == 0 )); then
        return 0
    fi

    printf 'FAIL: array %s should be empty\n' "$array_name" >&2
    return 1
}


run_install_test_captured() {
    local output_file="$1"
    shift

    set +e

    (
        set -e
        "$@"
    ) > "$output_file" 2>&1

    INSTALL_TEST_STATUS=$?

    set -e
}


assert_install_output_contains() {
    local output_file="$1"
    local expected="$2"

    if grep -Fq -- "$expected" "$output_file"; then
        return 0
    fi

    printf 'FAIL: expected output was not found\n' >&2
    printf '  expected: %s\n' "$expected" >&2
    return 1
}


assert_log_contains() {
    local logfile="$1"
    local expected="$2"

    if [[ -f "$logfile" ]] &&
       grep -Fq -- "$expected" "$logfile"
    then
        return 0
    fi

    printf 'FAIL: expected command was not logged\n' >&2
    printf '  file:     %s\n' "$logfile" >&2
    printf '  expected: %s\n' "$expected" >&2
    return 1
}


assert_no_aur_build_dirs() {
    local cache_root="${XDG_CACHE_HOME:-$HOME/.cache}/hyprdots/aur"

    if [[ ! -d "$cache_root" ]]; then
        return 0
    fi

    local remaining
    remaining="$(
        find "$cache_root" \
            -mindepth 1 \
            -maxdepth 1 \
            -print \
            -quit
    )"

    if [[ -z "$remaining" ]]; then
        return 0
    fi

    printf 'FAIL: AUR temporary build directory was not removed\n' >&2
    printf '  remaining: %s\n' "$remaining" >&2
    return 1
}
