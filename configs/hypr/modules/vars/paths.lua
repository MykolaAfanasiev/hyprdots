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
	cli = project_root .. "scripts/wallpaper-switcher/wallpaper.sh",
	rofi = project_root .. "scripts/wallpaper-switcher/launch.sh",
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

M.hyprsunset = {
	root = project_root .. "configs/hyprsunset/",
	launch = project_root .. "configs/hyprsunset/launch.sh",
}

M.networkmanager = {
	root = project_root .. "scripts/networkmanager/",
	cli = project_root .. "scripts/networkmanager/network.sh",
	rofi = project_root .. "scripts/networkmanager/rofi.sh",
	launch = project_root .. "scripts/networkmanager/rofi.sh",
}

M.bluetooth = {
	root = project_root .. "scripts/bluetooth/",
	cli = project_root .. "scripts/bluetooth/bluetooth.sh",
	rofi = project_root .. "scripts/bluetooth/rofi.sh",
	launch = project_root .. "scripts/bluetooth/rofi.sh",
}

M.btop = {
	root = project_root .. "configs/btop/",
	launch = project_root .. "configs/btop/launch.sh",
}

M.ghostty = {
	root = project_root .. "configs/ghostty/",
	launch = project_root .. "configs/ghostty/launch.sh",
}

M.theme_switcher = {
  root = project_root .. "scripts/theme-switcher/",
  rofi = project_root .. "scripts/theme-switcher/rofi.sh",
  settings = project_root .. "scripts/theme-switcher/settings-rofi.sh",
}




M.launcher = {
  root = project_root .. "scripts/launcher/",
  cli = project_root .. "scripts/launcher/launcher.sh",
  rofi = project_root .. "scripts/launcher/rofi.sh",
}

M.control_center = {
  root = project_root .. "scripts/control-center/",
  cli = project_root .. "scripts/control-center/control-center.sh",
  rofi = project_root .. "scripts/control-center/rofi.sh",
}

return M
