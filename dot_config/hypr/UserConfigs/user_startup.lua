-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User startup overrides (auto-generated).
-- Add commands with exec_once("your command")
-- Example:
-- exec_once("${XDG_CONFIG_HOME:-$HOME/.config}/hypr/UserScripts/MyStartup.sh")

local user_startup_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_startup_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_startup_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_startup_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.exec_once then
          user_startup_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_startup_helper then
    error("Failed to load user_startup_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local exec_once = user_startup_helper.exec_once

-- Converted from Startup_Apps.conf
local startup_commands = {
  "systemd-run --user --quiet --collect --unit=swww-daemon --property=Restart=on-failure swww-daemon --format xrgb",
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "$HOME/.config/hypr/scripts/Polkit.sh",
  "nm-applet --indicator",
  "systemctl --user start waybar.service",
  "wl-paste --type text --watch cliphist store",
  "wl-paste --type image --watch cliphist store",
  "hypridle",
  "bitwarden",
  "obsidian",
  "ags",
  "blueman-applet",
  "$HOME/.config/hypr/UserScripts/RainbowBorders.sh",
  "fcitx5-remote -r",
  "fcitx5 -d --replace",
  "eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)",
  "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
  "sleep 50 && /usr/local/bin/wlsunset -S 5:00 -s 18:00 > $HOME/.config/wlsunset.log 2>&1; notify-send 'Brightness value changed'",
  "/usr/bin/kdeconnect-indicator",
  "aw-qt",
  "aw-watcher-window-hyprland --host 127.0.0.1 --port 5600 --poll-time 2",
}

local function run_startup_commands()
  for _, cmd in ipairs(startup_commands) do
    exec_once(cmd)
  end
end

if hl and hl.on then
  hl.on("hyprland.start", run_startup_commands)
else
  run_startup_commands()
end
