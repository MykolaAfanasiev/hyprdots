-- ==========================================
-- Screenshot commands
-- ==========================================

local home = assert(
    os.getenv("HOME"),
    "HOME environment variable is not set"
)

local screenshot_cmd =
    home .. "/.local/bin/screenshot-tool"


-- Runs the screenshot command and returns to the global keymap.
local function run_screenshot(arguments)
    return function()
        hl.dispatch(
            hl.dsp.exec_cmd(screenshot_cmd .. arguments)
        )

        hl.dispatch(
            hl.dsp.submap("reset")
        )
    end
end


-- ==========================================
-- Quick screenshot
-- ==========================================

-- Fullscreen, copy to clipboard and save.
hl.bind(
    "PRINT",
    hl.dsp.exec_cmd(screenshot_cmd),
    {
        description = "Quick screenshot",
    }
)


-- ==========================================
-- Open screenshot submap
-- ==========================================

hl.bind(
    "SUPER + SHIFT + S",
    hl.dsp.submap("screenshot"),
    {
        description = "Open screenshot menu",
    }
)


-- ==========================================
-- Main screenshot submap
-- ==========================================

hl.define_submap("screenshot", function()
    -- Select screenshot type.
    hl.bind(
        "F",
        hl.dsp.submap("screenshot_fullscreen")
    )

    hl.bind(
        "A",
        hl.dsp.submap("screenshot_area")
    )

    -- Close the screenshot menu.
    hl.bind(
        "escape",
        hl.dsp.submap("reset")
    )
end)


-- ==========================================
-- Fullscreen screenshot options
-- ==========================================

hl.define_submap("screenshot_fullscreen", function()
    -- 1: Copy and save.
    hl.bind(
        "1",
        run_screenshot("")
    )

    -- 2: Edit, copy and save.
    hl.bind(
        "2",
        run_screenshot(" --edit")
    )

    -- 3: Copy without saving.
    hl.bind(
        "3",
        run_screenshot(" --no-save")
    )

    -- 4: Edit and copy without saving.
    hl.bind(
        "4",
        run_screenshot(" --edit --no-save")
    )

    -- 5: Save without copying.
    hl.bind(
        "5",
        run_screenshot(" --no-copy")
    )

    -- 6: Edit and save without copying.
    hl.bind(
        "6",
        run_screenshot(" --edit --no-copy")
    )

    -- Return to screenshot type selection.
    hl.bind(
        "escape",
        hl.dsp.submap("screenshot")
    )

    -- Completely close all screenshot submaps.
    hl.bind(
        "SHIFT + escape",
        hl.dsp.submap("reset")
    )
end)


-- ==========================================
-- Area screenshot options
-- ==========================================

hl.define_submap("screenshot_area", function()
    -- 1: Select area, copy and save.
    hl.bind(
        "1",
        run_screenshot(" --area")
    )

    -- 2: Select area, edit, copy and save.
    hl.bind(
        "2",
        run_screenshot(" --area --edit")
    )

    -- 3: Select area and copy without saving.
    hl.bind(
        "3",
        run_screenshot(" --area --no-save")
    )

    -- 4: Select area, edit and copy without saving.
    hl.bind(
        "4",
        run_screenshot(" --area --edit --no-save")
    )

    -- 5: Select area and save without copying.
    hl.bind(
        "5",
        run_screenshot(" --area --no-copy")
    )

    -- 6: Select area, edit and save without copying.
    hl.bind(
        "6",
        run_screenshot(" --area --edit --no-copy")
    )

    -- Return to screenshot type selection.
    hl.bind(
        "escape",
        hl.dsp.submap("screenshot")
    )

    -- Completely close all screenshot submaps.
    hl.bind(
        "SHIFT + escape",
        hl.dsp.submap("reset")
    )
end)
