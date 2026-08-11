-- Variables
local vars = require("modules.vars.global")
local submap = require("modules.submaps.utils")

local paths = require("modules.vars.paths")

-- ==========================================
-- Open appearance submap
-- ==========================================

hl.bind(
    vars.mainMod .. " + A",
    submap.switch("appearance")
)

-- ==========================================
-- Main appearance submap
-- ==========================================

hl.define_submap("appearance", function()
    hl.bind(
        "W",
        hl.dsp.exec_cmd(paths.wallpaper_switcher.launch)
    )

    -- позже
    -- hl.bind("T", ... theme switcher ...)

    hl.bind(
        "escape",
        submap.switch("reset")
    )
end)
