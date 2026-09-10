-- Hyprdots theme override.
--
-- This module is intentionally loaded last.
-- The regular Hyprland configuration remains the fallback if the generated
-- theme is missing or invalid.

local function apply_theme()
  local home = os.getenv("HOME")

  if not home or home == "" then
    return
  end

  local theme_file = home .. "/.cache/hyprdots/theme/current/hyprland.lua"

  local file = io.open(theme_file, "r")

  if not file then
    return
  end

  file:close()

  local loaded, palette = pcall(dofile, theme_file)

  if not loaded or type(palette) ~= "table" then
    return
  end

  local function hex(value)
    if type(value) ~= "string" then
      return nil
    end

    local color = value:match("^#(%x%x%x%x%x%x)$")
    return color
  end

  local blue = hex(palette.blue)
  local mauve = hex(palette.mauve)
  local surface2 = hex(palette.surface2)
  local crust = hex(palette.crust)

  if not blue or not mauve or not surface2 or not crust then
    return
  end

  hl.config({
    general = {
      col = {
        active_border = {
          colors = {
            "rgba(" .. blue .. "ee)",
            "rgba(" .. mauve .. "ee)",
          },
          angle = 45,
        },

        inactive_border = "rgba(" .. surface2 .. "aa)",
      },
    },

    decoration = {
      shadow = {
        color = tonumber("ee" .. crust, 16),
      },
    },
  })
end

-- Never allow a theme failure to break the Hyprland configuration.
local ok, err = pcall(apply_theme)

if not ok then
  print("Hyprdots theme error: " .. tostring(err))
end
