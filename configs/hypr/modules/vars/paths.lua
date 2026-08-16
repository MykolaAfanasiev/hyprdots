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

M.hyprlock = {
    root = project_root .. "configs/hyprlock/",
    launch = project_root .. "configs/hyprlock/launch.sh",
}

M.hypridle = {
    root = project_root .. "configs/hypridle/",
    launch = project_root .. "configs/hypridle/launch.sh",
}

M.wlogout = {
    root = project_root .. "configs/wlogout/",
    launch = project_root .. "configs/wlogout/launch.sh",
}
return M
