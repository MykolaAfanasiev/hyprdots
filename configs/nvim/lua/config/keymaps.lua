local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Window resizing
map("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "Resize left" })
map("n", "<M-j>", "<cmd>resize +2<cr>", { desc = "Resize down" })
map("n", "<M-k>", "<cmd>resize -2<cr>", { desc = "Resize up" })
map("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "Resize right" })

-- Editing
map("n", "<leader>q", "<cmd>close<cr>", { desc = "Close window" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Keep selection while indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Diagnostics
map("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
