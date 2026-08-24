#!/usr/bin/env bash

# This file provides helpers and dynamic overrides used indirectly by
# package-selection scenario tests that source this file.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_PACKAGE_SELECTION_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_TEST_PACKAGE_SELECTION_LOADED=1


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

# shellcheck source=setup/lib/packages/manifest.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/manifest.sh"

# shellcheck source=setup/lib/packages/select.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/select.sh"


setup_package_selection_test() {
    create_test_sandbox

    PROJECT_ROOT="$TEST_ROOT/project"
    SETUP_DIR="$PROJECT_ROOT/setup"

    mkdir -p -- "$SETUP_DIR/packages"

    SELECTED_ARCH_REQUIRED=()
    SELECTED_ARCH_RECOMMENDED=()
    SELECTED_ARCH_DEFAULT_APPS=()
    SELECTED_AUR_REQUIRED=()

    PACKAGE_INSTALLATION_NEEDED=1

    TEST_STDIN_IS_TERMINAL=1

    export PROJECT_ROOT
    export SETUP_DIR
}


stdin_is_terminal() {
    (( TEST_STDIN_IS_TERMINAL != 0 ))
}


mock_terminal() {
    TEST_STDIN_IS_TERMINAL="$1"
}


create_manifest() {
    local filename="$1"
    shift

    local path="$SETUP_DIR/packages/$filename"

    : > "$path"

    if (( $# > 0 )); then
        printf '%s\n' "$@" > "$path"
    fi
}


create_default_manifests() {
    create_manifest \
        arch-required.txt \
        hyprland \
        waybar

    create_manifest \
        arch-recommended.txt \
        xdg-desktop-portal-hyprland \
        wireplumber

    create_manifest \
        arch-default-apps.txt \
        kitty \
        btop

    create_manifest \
        aur-required.txt \
        wlogout
}


create_fake_pacman_all_installed() {
    create_fake_command pacman 0
}


create_fake_pacman_all_missing() {
    create_fake_command pacman 1
}


create_fake_pacman_with_missing() {
    local missing_package="$1"

    cat > "$TEST_BIN/pacman" <<EOF_PACMAN
#!/usr/bin/env bash

printf '%s\n' "\$*" >> "$TEST_STATE/pacman.log"

if [[ "\${1:-}" == "-Qq" &&
      "\${2:-}" == "$missing_package" ]]
then
    exit 1
fi

exit 0
EOF_PACMAN

    chmod +x -- "$TEST_BIN/pacman"
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


run_package_test_captured() {
    local output_file="$1"
    shift

    set +e

    (
        set -e
        "$@"
    ) > "$output_file" 2>&1

    PACKAGE_TEST_STATUS=$?

    set -e
}


assert_package_output_contains() {
    local output_file="$1"
    local expected="$2"
    local message="${3:-Expected output was not found}"

    if grep -Fq -- "$expected" "$output_file"; then
        return 0
    fi

    printf 'FAIL: %s\n' "$message" >&2
    printf '  expected output: %s\n' "$expected" >&2

    return 1
}
