-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")

local paths = require("vars.paths")
-- ==========================================
-- Open config submap
-- ==========================================

hl.bind(
  vars.mainMod .. " + CTRL + SHIFT + N",
  submap.switch("config")
)


-- ==========================================
-- Main config submap
-- ==========================================

hl.define_submap("config", function()
  hl.bind(
    "W",
    submap.switch("config_waybar")
  )

  hl.bind(
    "escape",
    submap.switch("reset")
  )
end)


-- ==========================================
-- Waybar configuration submap
-- ==========================================

hl.define_submap("config_waybar", function()
  hl.bind(
    "1",
    function()
      hl.dispatch(
        hl.dsp.exec_cmd(paths.waybar.clock .. " toggle")
      )

      hl.dispatch(
        hl.dsp.submap("reset")
      )
    end
  )
  hl.bind(
    "r",
    function()
      hl.dispatch(
        hl.dsp.exec_cmd(
          'pkill -x waybar; sleep 0.2; "' .. paths.waybar.launch .. '"'
        )
      )

      hl.dispatch(
        hl.dsp.submap("reset")
      )
    end
  )


  hl.bind(
    "escape",
    submap.switch("config")
  )

  hl.bind(
    "SHIFT + escape",
    submap.switch("reset")
  )
end)
