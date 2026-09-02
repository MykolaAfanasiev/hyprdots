local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false
opt.laststatus = 3
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.winborder = "rounded"

-- Editing
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.wrap = false
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.inccommand = "split"

-- Files / undo
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 300

-- Completion
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- Whitespace
opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- Keep Mason binaries available to all tools started from Neovim.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end
