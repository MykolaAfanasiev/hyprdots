-- =========
-- Variables
-- =========
local vars = require("modules.vars.global")

-- ==================
-- Special workspaces
-- ==================

local special_workspaces = {
  {
    name = "terminal",
    key = "T",
    command = vars.apps.terminal,
  },
  {
    name = "notes",
    key = "N",
    command = vars.apps.notes,
  },
  {
    name = "monitor",
    key = "B",
    command = vars.apps.system_monitor,
  }
}

for _, special in ipairs(special_workspaces) do
  -- auto launching the app
  hl.workspace_rule({
    workspace = "special:" .. special.name,
    on_created_empty = special.command,
  })


  -- show or hide
  hl.bind(
    vars.mainMod .. "+" .. special.key,
    hl.dsp.workspace.toggle_special(special.name),
    {
      description = "Toggle special workspace:" .. special.name,
    }
  )

  -- move window
  hl.bind(
    vars.mainMod .. "+ SHIFT +" .. special.key,
    hl.dsp.window.move(
      { workspace = "special:" .. special.name }
    ),
    {
      description = "Move window to special workspace:" .. special.name,
    }
  )
end
