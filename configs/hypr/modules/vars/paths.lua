local utils = require("..modules.submaps.utils")

local module_dir = utils.real_dir()

local project_root = module_dir .. "../../../"

local M = {}

M.project_root = project_root

M.waybar = {
    root = project_root .. "configs/waybar/",
    launch = project_root .. "configs/waybar/launch.sh",
    clock = project_root .. "configs/waybar/scripts/clock.sh",
}

return M
