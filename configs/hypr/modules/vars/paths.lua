local utils = require("modules.submaps.utils")

local module_dir = utils.real_dir()

local project_root = module_dir .. "../../../../"

local M = {}

M.project_root = project_root

M.waybar = {
    root = project_root .. "configs/waybar/",
    launch = project_root .. "configs/waybar/launch.sh",
    clock = project_root .. "configs/waybar/scripts/clock.sh",
}

M.rofi = {
  root = project_root .. "configs/rofi/",
  launch = project_root .. "configs/rofi/launch.sh",
  clipboard = project_root .. "configs/rofi/clipboard.sh",
}

M.swaync = {
    root = project_root .. "configs/swaync/",
    launch = project_root .. "configs/swaync/launch.sh",
    control = project_root .. "configs/swaync/scripts/control.sh",
}

M.hyprpaper = {
    root = project_root .. "configs/hyprpaper/",
    launch = project_root .. "configs/hyprpaper/launch.sh",
    control = project_root .. "configs/hyprpaper/scripts/control.sh",
}

M.wallpaper_switcher = {
    root = project_root .. "scripts/wallpaper-switcher/",
    launch = project_root .. "scripts/wallpaper-switcher/launch.sh",
}
return M
