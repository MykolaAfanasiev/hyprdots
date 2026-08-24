#!/usr/bin/env bash

# Test state and dynamically overridden functions are consumed indirectly
# by Stage 9 scenario tests.
# shellcheck disable=SC2034,SC2317,SC2329

if [[ -n "${HYPRDOTS_TEST_VERIFICATION_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_TEST_VERIFICATION_LOADED=1

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

# shellcheck source=setup/lib/filesystem.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/filesystem.sh"

# print_package_list and package-selection state.
# shellcheck source=setup/lib/packages/select.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/select.sh"

# shellcheck source=setup/lib/packages/plan.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/packages/plan.sh"

# shellcheck source=setup/lib/tools/screenshot.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/tools/screenshot.sh"

# shellcheck source=setup/lib/verify/report.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/verify/report.sh"

# shellcheck source=setup/lib/verify/packages.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/verify/packages.sh"

# shellcheck source=setup/lib/verify/configs.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/verify/configs.sh"

# shellcheck source=setup/lib/verify/runtime.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/verify/runtime.sh"

# shellcheck source=setup/lib/verify/install.sh
source "$HYPRDOTS_TEST_REPO_ROOT/setup/lib/verify/install.sh"


TEST_SCREENSHOT_TOOL_STATUS=0


setup_verification_test() {
    create_test_sandbox

    PROJECT_ROOT="$TEST_ROOT/project"
    SETUP_DIR="$PROJECT_ROOT/setup"

    mkdir -p \
        "$PROJECT_ROOT/configs" \
        "$PROJECT_ROOT/scripts" \
        "$SETUP_DIR"

    SELECTED_ARCH_REQUIRED=()
    SELECTED_ARCH_RECOMMENDED=()
    SELECTED_ARCH_DEFAULT_APPS=()
    SELECTED_AUR_REQUIRED=()

    TEST_SCREENSHOT_TOOL_STATUS=0

    reset_verification_report

    export PROJECT_ROOT
    export SETUP_DIR
}


verify_screenshot_tool() {
    return "$TEST_SCREENSHOT_TOOL_STATUS"
}


mock_screenshot_tool_status() {
    TEST_SCREENSHOT_TOOL_STATUS="$1"
}


create_fake_pacman_installed() {
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

exit 0
EOF_PACMAN

    chmod +x -- "$TEST_BIN/pacman"
}


create_valid_verification_environment() {
    mkdir -p \
        "$PROJECT_ROOT/configs/hypr/modules/vars" \
        "$PROJECT_ROOT/configs/hyprsunset" \
        "$PROJECT_ROOT/configs/example" \
        "$PROJECT_ROOT/scripts/example" \
        "$HOME/.config/hypr" \
        "$HOME/.wallpapers" \
        "$HOME/Screenshots" \
        "$SETUP_DIR"

    printf '%s\n' '-- local config' \
        > "$PROJECT_ROOT/configs/hypr/modules/vars/local.lua"

    printf '%s\n' '-- hyprland config' \
        > "$PROJECT_ROOT/configs/hypr/hyprland.lua"

    cat > "$PROJECT_ROOT/configs/hyprsunset/location.conf" <<'EOF_LOCATION'
LATITUDE=48.7
LONGITUDE=11.4
EOF_LOCATION

    chmod 600 \
        "$PROJECT_ROOT/configs/hyprsunset/location.conf"

    ln -s \
        "$PROJECT_ROOT/configs/hypr/hyprland.lua" \
        "$HOME/.config/hypr/hyprland.lua"

    printf '#!/usr/bin/env bash\n' \
        > "$PROJECT_ROOT/install.sh"

    printf '#!/usr/bin/env bash\n' \
        > "$SETUP_DIR/install.sh"

    printf '#!/usr/bin/env bash\n' \
        > "$PROJECT_ROOT/configs/example/run.sh"

    printf '#!/usr/bin/env bash\n' \
        > "$PROJECT_ROOT/scripts/example/tool.sh"

    chmod +x \
        "$PROJECT_ROOT/install.sh" \
        "$SETUP_DIR/install.sh" \
        "$PROJECT_ROOT/configs/example/run.sh" \
        "$PROJECT_ROOT/scripts/example/tool.sh"

    create_fake_command \
        screenshot-tool \
        0

    mock_screenshot_tool_status 0
}


run_verification_test_captured() {
    local output_file="$1"
    shift

    set +e

    (
        set -e
        "$@"
    ) > "$output_file" 2>&1

    VERIFICATION_TEST_STATUS=$?

    set -e
}


assert_verify_output_contains() {
    local output_file="$1"
    local expected="$2"

    if grep -Fq -- "$expected" "$output_file"; then
        return 0
    fi

    printf 'FAIL: expected verification output was not found\n' >&2
    printf '  expected: %s\n' "$expected" >&2

    return 1
}
