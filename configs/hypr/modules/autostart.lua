local paths = require("vars.paths")

hl.on("hyprland.start", function ()
  -- Wallpaper
  hl.exec_cmd("hyprpaper -c ~/.config/.dotfiles/configs/hypr/hyprland_settinigs/hyprpaper.conf")

  -- Bar
  hl.exec_cmd(paths.waybar.launch)

  -- Notifications
  hl.exec_cmd("swaync -c $HOME/.config/.dotfiles/configs/hypr/swaync/config.json -s $HOME/.config/.dotfiles/configs/hypr/swaync/style.css")

  -- Clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("wl-clip-persist --clipboard regular")

  -- Idle daemon
  hl.exec_cmd("hypridle -c $HOME/.config/.dotfiles/configs/hypr/hyprland_settinigs/hypridle.conf")
end)
