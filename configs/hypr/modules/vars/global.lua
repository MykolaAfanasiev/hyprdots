local M = {}

M.mainMod = "SUPER"
M.terminal = "kitty"
M.fileManager = "dolphin"
M.menu = "wofi --show drun"
M.clipboard =
    "cliphist list | " ..
    "wofi -dmenu " ..
    "--conf $HOME/.config/.dotfiles/configs/hypr/wofi/config " ..
    "--style $HOME/.config/.dotfiles/configs/hypr/wofi/style.css | " ..
    "cliphist decode | wl-copy"

return M
