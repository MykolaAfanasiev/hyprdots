-- Variables
local vars = require("modules.vars.global")
local paths = require("modules.vars.paths")

-- Submaps
require("modules.submaps.clean")
require("modules.submaps.screenshot")
require("modules.submaps.config-submap")

-- =========================================================
-- Return to standard/global mode from any submap
-- =========================================================

hl.bind(vars.mainMod .. " + CTRL + SHIFT + ALT + escape", function()
  hl.dispatch(hl.dsp.submap("reset"))
end, {
  submap_universal = true,
  description = "Return to standard/global mode",
})

-- =============
-- Basic actions
-- =============

hl.bind(vars.mainMod .. " + RETURN", hl.dsp.exec_cmd(vars.terminal))
hl.bind(vars.mainMod .. " + SPACE", hl.dsp.exec_cmd(paths.rofi.launch))

hl.bind("CTRL + SHIFT + X", hl.dsp.window.close())

-- Optional: if you use clipboard history very often, keep it here
hl.bind(vars.mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(paths.rofi.clipboard))

-- Notifications
hl.bind("ALT + N", hl.dsp.exec_cmd(paths.swaync.control .. " toggle"))

-- ==============
-- Window actions
-- ==============
hl.bind(vars.mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({
  mode = "fullscreen",
  action = "toggle",
}))

hl.bind(vars.mainMod .. " + F", hl.dsp.window.float({
  action = "toggle",
}))

hl.bind(vars.mainMod .. " + V", hl.dsp.layout("togglesplit"))


-- =============
-- Focus windows
-- =============
hl.bind(vars.mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(vars.mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(vars.mainMod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(vars.mainMod .. " + K", hl.dsp.focus({ direction = "u" }))

-- Focus next monitor / screen
hl.bind(vars.mainMod .. " + TAB", hl.dsp.focus({ monitor = "+1" }))

-- Move active window to next monitor / screen
hl.bind(vars.mainMod .. " + SHIFT + TAB", hl.dsp.window.move({
  monitor = "+1",
  follow = true,
}))


-- ==========
-- Workspaces
-- ==========
for i = 1, 10 do
  local key = tostring(i % 10) -- 10 becomes key 0

  -- Switch workspace
  hl.bind(vars.mainMod .. " + " .. key, hl.dsp.focus({
    workspace = i,
  }))

  -- Move active window to workspace
  hl.bind(vars.mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({
    workspace = i,
  }))
end
-- Scroll through existing workspaces
hl.bind(vars.mainMod .. " + mouse_down", hl.dsp.focus({
  workspace = "e+1",
}))

hl.bind(vars.mainMod .. " + mouse_up", hl.dsp.focus({
  workspace = "e-1",
}))

-- ===================
-- Mouse move / resize
-- ===================

hl.bind(vars.mainMod .. " + mouse:272", hl.dsp.window.drag(), {
  mouse = true,
})

hl.bind(vars.mainMod .. " + mouse:273", hl.dsp.window.resize(), {
  mouse = true,
})
-- ================================
-- Volume / brightness / media keys
-- ================================

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), {
  locked = true,
  repeating = true,
})

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), {
  locked = true,
  repeating = true,
})

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +1%"), {
  locked = true,
  repeating = true,
})

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -1%"), {
  locked = true,
  repeating = true,
})

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), {
  locked = true,
})

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
  locked = true,
})

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
  locked = true,
})

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
  locked = true,
})

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
  locked = true,
})
