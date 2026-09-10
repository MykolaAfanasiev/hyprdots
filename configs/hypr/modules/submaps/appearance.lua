-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")
local paths = require("modules.vars.paths")

local function launch_and_reset(command)
  return function()
    hl.dispatch(hl.dsp.submap("reset"))
    hl.dispatch(hl.dsp.exec_cmd(command))
  end
end

-- ==========================================
-- Open appearance submap
-- ==========================================

hl.bind(vars.mainMod .. " + A", submap.switch("appearance"))

-- ==========================================
-- Main appearance submap
-- ==========================================

hl.define_submap("appearance", function()
  hl.bind("W", launch_and_reset(paths.wallpaper_switcher.launch))
  hl.bind("T", launch_and_reset(paths.theme_switcher.rofi))

  hl.bind("escape", submap.switch("reset"))
end)
