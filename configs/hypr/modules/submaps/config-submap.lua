local home = assert(
    os.getenv("HOME"),
    "HOME environment variable is not set"
)

local clock_cmd =
    home .. "/.hyprdots/configs/waybar/scripts/clock.sh"


-- ==========================================
-- Open config submap
-- ==========================================

hl.bind(
    "SUPER + CTRL + SHIFT + ALT + C",
    hl.dsp.submap("config"),
    {
        description = "Open configuration menu",
    }
)


-- ==========================================
-- Main config submap
-- ==========================================

hl.define_submap("config_waybar", function()

    -- Waybar settings
    hl.bind(
        "W",
        hl.dsp.submap("config_waybar")
    )

    -- Exit configuration mode
    hl.bind(
        "escape",
        hl.dsp.submap("reset")
    )
end)


-- ==========================================
-- Waybar configuration submap
-- ==========================================

hl.define_submap("config_waybar", function()

    -- Toggle compact / detailed clock
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

    -- Return to main configuration menu
    hl.bind(
        "escape",
        hl.dsp.submap("config")
    )

    -- Completely exit configuration mode
    hl.bind(
        "SHIFT + escape",
        hl.dsp.submap("reset")
    )
end)
