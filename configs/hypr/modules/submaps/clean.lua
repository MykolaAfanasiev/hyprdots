-- Variables
local vars = require("modules.vars.global")

-- ============
-- Clean Submap
-- ============
hl.define_submap("clean", function ()
  hl.bind(vars.mainMod .. " + CTRL + SHIFT + escape", function ()
    hl.dispatch(hl.dsp.exec_cmd([[notify-send "Submap has been reset"]]))
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)
