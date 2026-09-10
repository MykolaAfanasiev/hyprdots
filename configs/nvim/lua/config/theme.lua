local M = {}

function M.reload()
  -- Reload the generated Hyprdots-aware theme specification.
  package.loaded["themes.current"] = nil

  local ok_spec, spec = pcall(require, "themes.current")

  if not ok_spec or type(spec) ~= "table" then
    vim.notify("Failed to reload Hyprdots theme", vim.log.levels.ERROR)
    return false
  end

  local ok_catppuccin, catppuccin = pcall(require, "catppuccin")

  if not ok_catppuccin then
    vim.notify("Catppuccin is not loaded", vim.log.levels.ERROR)
    return false
  end

  local ok_setup, err = pcall(catppuccin.setup, spec.opts or {})

  if not ok_setup then
    vim.notify(
      "Failed to apply Hyprdots palette: " .. tostring(err),
      vim.log.levels.ERROR
    )
    return false
  end

  local ok_colorscheme, colorscheme_err = pcall(
    vim.cmd.colorscheme,
    "catppuccin"
  )

  if not ok_colorscheme then
    vim.notify(
      "Failed to reload colorscheme: " .. tostring(colorscheme_err),
      vim.log.levels.ERROR
    )
    return false
  end

  vim.cmd.redraw()

  return true
end

return M
