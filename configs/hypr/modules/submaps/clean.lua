-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")
-- ==========================================
-- Open clean submap
-- ==========================================

hl.bind(vars.mainMod .. " + CTRL + SHIFT + C", submap.switch("clean"))

-- ============
-- Clean Submap
-- ============
hl.define_submap("clean", function ()
  hl.bind(vars.mainMod .. " + CTRL + SHIFT + escape", function ()
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)
