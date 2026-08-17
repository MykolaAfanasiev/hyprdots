local M = {
  mainMod = "SUPER",

  apps = {
    terminal = "kitty",
    notes = "obsidian",
    system_monitor = "kitty -e btop",
  },

  monitor = {
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "auto",
  },
}

local function merge(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" and type(target[key]) == "table" then
      merge(target[key], value)
    else
      target[key] = value
    end
  end
end

local ok, local_vars = pcall(require, "modules.vars.local")

if ok then
  assert(type(local_vars) == "table", "modules.vars.local must return a table")
  merge(M, local_vars)
elseif not tostring(local_vars):find("module 'modules.vars.local' not found", 1, true) then
  error(local_vars, 0)
end

return M
