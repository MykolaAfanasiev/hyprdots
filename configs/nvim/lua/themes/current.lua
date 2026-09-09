local fallback = require("themes.catppuccin_mocha")
local spec = vim.deepcopy(fallback)

local theme_file = vim.fn.expand("~/.cache/hyprdots/theme/current/nvim.lua")

if vim.fn.filereadable(theme_file) ~= 1 then
  return spec
end

local ok, palette = pcall(dofile, theme_file)

if not ok or type(palette) ~= "table" then
  return spec
end

local palette_keys = {
  "rosewater",
  "flamingo",
  "pink",
  "mauve",
  "red",
  "maroon",
  "peach",
  "yellow",
  "green",
  "teal",
  "sky",
  "sapphire",
  "blue",
  "lavender",
  "text",
  "subtext1",
  "subtext0",
  "overlay2",
  "overlay1",
  "overlay0",
  "surface2",
  "surface1",
  "surface0",
  "base",
  "mantle",
  "crust",
}

local overrides = {}

for _, key in ipairs(palette_keys) do
  if palette[key] then
    overrides[key] = palette[key]
  end
end

spec.opts = vim.tbl_deep_extend("force", spec.opts or {}, {
  flavour = "mocha",
  color_overrides = {
    mocha = overrides,
  },
})

return spec
