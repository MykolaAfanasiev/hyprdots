-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")

local paths = require("modules.vars.paths")
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
    "S",
    submap.switch("config_swaync")
  )
  hl.bind(
    "H",
    submap.switch("config_hyprpaper")
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

-- ==========================================
-- SwayNC configuration submap
-- ==========================================

hl.define_submap("config_swaync", function()
  -- Toggle Do Not Disturb
  hl.bind(
    "d",
    function()
      hl.dispatch(
        hl.dsp.exec_cmd(paths.swaync.control .. " dnd")
      )

      hl.dispatch(
        hl.dsp.submap("reset")
      )
    end
  )

  -- Reload config and CSS
  hl.bind(
    "r",
    function()
      hl.dispatch(
        hl.dsp.exec_cmd(paths.swaync.control .. " reload")
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

-- ==========================================
-- Hyprpaper configuration submap
-- ==========================================

hl.define_submap("config_hyprpaper", function()
    hl.bind(
        "r",
        function()
            hl.dispatch(
                hl.dsp.exec_cmd(paths.hyprpaper.control .. " restart")
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

