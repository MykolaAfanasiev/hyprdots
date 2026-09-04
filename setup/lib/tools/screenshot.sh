#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_SCREENSHOT_TOOL_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_SCREENSHOT_TOOL_LOADED=1

read_python_project_name() {
    local pyproject="$1"

    python - "$pyproject" << 'PY'
import sys
import tomllib

pyproject = sys.argv[1]

with open(pyproject, "rb") as file:
    data = tomllib.load(file)

name = data.get("project", {}).get("name")

if not name:
    raise SystemExit(1)

print(name)
PY
}

verify_screenshot_tool() {
    local executable="$1"

    "$executable" --help > /dev/null 2>&1
}

run_screenshot_tool_setup() {
    section "[6/11] Screenshot tool"

    local tool_dir="$PROJECT_ROOT/scripts/screenshot"
    local pyproject="$tool_dir/pyproject.toml"
    local command_name="screenshot-tool"

    if [[ ! -d "$tool_dir" ]]; then
        die "Screenshot tool directory does not exist: $tool_dir"
    fi

    if [[ ! -r "$pyproject" ]]; then
        die "Screenshot tool pyproject.toml is not readable: $pyproject"
    fi

    if ! command_exists python; then
        warn "Python is not installed."
        warn "Skipping screenshot tool installation."
        return 0
    fi

    if ! command_exists pipx; then
        warn "pipx is not installed."
        warn "Skipping screenshot tool installation."
        return 0
    fi

    #
    # The command is already available.
    #
    if command_exists "$command_name"; then
        local executable
        executable="$(command -v "$command_name")"

        if verify_screenshot_tool "$executable"; then
            success "$command_name is already available: $executable"
            return 0
        fi

        die "$command_name exists but could not be executed correctly."
    fi

    #
    # The command is not in PATH.
    #
    local pipx_bin_dir
    pipx_bin_dir="$(pipx environment --value PIPX_BIN_DIR)"

    local expected_executable="$pipx_bin_dir/$command_name"

    if [[ -x "$expected_executable" ]]; then
        warn "$command_name is installed but is not available in PATH."
        warn "pipx binary directory: $pipx_bin_dir"
        return 0
    fi

    #
    # Not installed: install it.
    #
    info "Installing $command_name with pipx..."

    pipx install \
        --editable \
        "$tool_dir"

    #
    # Verify installation.
    #
    if command_exists "$command_name"; then
        local executable
        executable="$(command -v "$command_name")"

        if verify_screenshot_tool "$executable"; then
            success "$command_name installed: $executable"
            return 0
        fi
    fi

    if [[ -x "$expected_executable" ]]; then
        warn "$command_name was installed but $pipx_bin_dir is not in PATH."
        return 0
    fi

    die "$command_name was not found after pipx installation."
}
