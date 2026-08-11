local paths = require("modules.vars.paths")

hl.on("hyprland.start", function()
  -- Wallpaper
  hl.exec_cmd(paths.hyprpaper.launch)
  -- Bar
  hl.exec_cmd(paths.waybar.launch)

  -- Notifications
  hl.exec_cmd(paths.swaync.launch)

  -- Clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("wl-clip-persist --clipboard regular")

  -- Idle daemon
  hl.exec_cmd("hypridle -c $HOME/.config/.dotfiles/configs/hypr/hyprland_settinigs/hypridle.conf")
end)
