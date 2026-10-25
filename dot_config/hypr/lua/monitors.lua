-- Derived from LinuxBeginnings/Hyprland-Dots.
-- SPDX-License-Identifier: GPL-3.0-or-later

local config_home = os.getenv("XDG_CONFIG_HOME") or ((os.getenv("HOME") or "") .. "/.config")
local user_monitors = config_home .. "/hypr/UserConfigs/monitors.lua"
local ok, err = pcall(dofile, user_monitors)

if not ok then
  error("Unable to load monitor configuration " .. user_monitors .. ": " .. tostring(err))
end
