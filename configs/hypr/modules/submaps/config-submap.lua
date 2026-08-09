-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")

local current_dir = submap.current_dir()

local clock_cmd =
    current_dir .. "../../../waybar/scripts/clock.sh"
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
                hl.dsp.exec_cmd(clock_cmd .. " toggle")
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
