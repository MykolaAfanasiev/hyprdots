#!/usr/bin/env bash

if [[ -n "${HYPRDOTS_SCREENSHOT_TOOL_LOADED:-}" ]]; then
    return 0
fi

readonly HYPRDOTS_SCREENSHOT_TOOL_LOADED=1


read_python_project_name() {
    local pyproject="$1"

    python - "$pyproject" <<'PY'
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


pipx_package_installed() {
    local package="$1"

    pipx list --short 2>/dev/null |
        grep -Fxq -- "$package"
}


verify_screenshot_tool() {
    local executable="$1"

    "$executable" --help >/dev/null 2>&1
}


run_screenshot_tool_setup() {
    section "[6/10] Screenshot tool"

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

    local package_name

    if ! package_name="$(read_python_project_name "$pyproject")"; then
        die "Unable to read the Python package name from: $pyproject"
    fi

    info "Python package: $package_name"

    if pipx_package_installed "$package_name"; then
        success "$package_name is already installed with pipx"
    else
        info "Installing $package_name with pipx..."

        pipx install \
            --editable \
            "$tool_dir"

        success "$package_name installed"
    fi

    local pipx_bin_dir
    pipx_bin_dir="$(pipx environment --value PIPX_BIN_DIR)"

    local executable="$pipx_bin_dir/$command_name"

    if command_exists "$command_name"; then
        executable="$(command -v "$command_name")"
    elif [[ -x "$executable" ]]; then
        warn "$command_name is installed, but $pipx_bin_dir is not in PATH."
        warn "Restart the shell after adding the pipx binary directory to PATH."
    else
        die "$command_name executable was not found after installation."
    fi

    if ! verify_screenshot_tool "$executable"; then
        die "$command_name was found but could not be executed."
    fi

    success "$command_name is working: $executable"

    printf '\n'
    success "Screenshot tool setup complete"
}
