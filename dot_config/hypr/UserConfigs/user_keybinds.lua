-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User keybind overrides (auto-generated).
-- Add, override, or rebind keybinds with bind("MODS", "KEY", fn, opts) and unbind("MODS", "KEY").
--
-- 1. ADDING A NEW KEYBIND (combo not used by default):
--    bind("SUPER", "Z", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--    bind("SUPER SHIFT", "V", exec_cmd("pavucontrol"), { description = "Audio Control" })
--
-- 2. OVERRIDING AN EXISTING COMBO WITH A DIFFERENT APP/COMMAND:
--    unbind("SUPER", "Return")
--    bind("SUPER", "Return", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--
-- 3. REBINDING AN ACTION TO A NEW KEY COMBINATION:
--    unbind("SUPER", "E")
--    unbind("SUPER", "F")
--    bind("SUPER", "F", exec_cmd("$HOME/.config/hypr/scripts/LaunchFileManager.sh '$files' '$term'"), { description = "File manager" })
--    bind("SUPER", "E", exec_cmd("emacsclient -c -a 'emacs'"), { description = "Launch Emacs" })
--
-- 4. REBINDING DISPATCHERS (e.g. killactive, workspace):
--    unbind("SUPER", "Q")
--    bind("SUPER", "Q", dispatch("killactive"), { description = "Close active window" })
--
-- 5. BIND OPTIONS (locked, repeating):
--    bind("CTRL ALT", "bracketright", exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"), { description = "Brightness up", repeating = true })
--    bind("", "XF86AudioMute", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle"), { description = "Mute audio", locked = true })
--
-- Helper functions live in ${XDG_CONFIG_HOME:-$HOME/.config}/hypr/lua/user_keybinds_helper.lua so they can be updated separately.
local user_keybinds_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_keybinds_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_keybinds_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_keybinds_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.bind then
          user_keybinds_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_keybinds_helper then
    error("Failed to load user_keybinds_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local exec_cmd = user_keybinds_helper.exec_cmd
local dispatch = user_keybinds_helper.dispatch
local bind = user_keybinds_helper.bind
local unbind = user_keybinds_helper.unbind

-- Converted from UserKeybinds.conf
bind("SUPER", "D", exec_cmd("pkill rofi || true && rofi -show drun -modi drun, filebrowser, run, window"))
bind("SUPER", "B", exec_cmd("xdg-open \"https://\""))
bind("SUPER", "A", exec_cmd("pkill rofi || true && ags -t 'overview'"))
bind("SUPER", "Return", exec_cmd("$term"))
bind("SUPER", "E", exec_cmd("$files"))
bind("SUPER", "H", exec_cmd("$HOME/.config/hypr/scripts/KeyHints.sh"))
bind("SUPER ALT", "R", exec_cmd("$HOME/.config/hypr/scripts/Refresh.sh"))
bind("SUPER ALT", "E", exec_cmd("$HOME/.config/hypr/scripts/RofiEmoji.sh"))
bind("SUPER", "S", exec_cmd("$HOME/.config/hypr/scripts/RofiSearch.sh"))
bind("SUPER ALT", "O", exec_cmd("$HOME/.config/hypr/scripts/ChangeBlur.sh"))
bind("SUPER SHIFT", "G", exec_cmd("$HOME/.config/hypr/scripts/GameMode.sh"))
bind("SUPER ALT", "L", exec_cmd("$HOME/.config/hypr/scripts/ChangeLayout.sh"))
bind("SUPER ALT", "V", exec_cmd("$HOME/.config/hypr/scripts/ClipManager.sh"))
bind("SUPER CTRL", "R", exec_cmd("$HOME/.config/hypr/scripts/RofiThemeSelector.sh"))
bind("SUPER CTRL SHIFT", "R", exec_cmd("pkill rofi || true && $HOME/.config/hypr/scripts/RofiThemeSelector-modified.sh"))
bind("SUPER SHIFT", "F", dispatch("fullscreen", ""))
bind("SUPER CTRL", "F", dispatch("fullscreen", "1"))
bind("SUPER", "SPACE", dispatch("togglefloating", ""))
bind("SUPER ALT", "SPACE", exec_cmd("$HOME/.config/hypr/scripts/Float-all-Windows.sh"))
bind("SUPER SHIFT", "Return", exec_cmd("[float; move 15% 5%; size 70% 60%] $term -e tmux new-session -A -s dropdown"))
bind("SUPER ALT", "mouse_down", exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')\""))
bind("SUPER ALT", "mouse_up", exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')\""))
bind("SUPER CTRL ALT", "B", exec_cmd("pkill -SIGUSR1 waybar"))
bind("SUPER CTRL", "B", exec_cmd("$HOME/.config/hypr/scripts/WaybarStyles.sh"))
bind("SUPER ALT", "B", exec_cmd("$HOME/.config/hypr/scripts/WaybarLayout.sh"))
bind("SUPER SHIFT", "M", exec_cmd("$HOME/.config/hypr/UserScripts/RofiBeats.sh"))
bind("SUPER", "W", exec_cmd("$HOME/.config/hypr/UserScripts/WallpaperSelect.sh"))
bind("SUPER SHIFT", "W", exec_cmd("$HOME/.config/hypr/UserScripts/WallpaperEffects.sh"))
bind("CTRL ALT", "W", exec_cmd("$HOME/.config/hypr/UserScripts/WallpaperRandom.sh"))
bind("SUPER CTRL", "O", exec_cmd("hyprctl setprop active opaque toggle"))
bind("SUPER SHIFT", "K", exec_cmd("$HOME/.config/hypr/scripts/KeyBinds.sh"))
bind("SUPER SHIFT", "A", exec_cmd("$HOME/.config/hypr/scripts/Animations.sh"))
bind("SUPER SHIFT", "O", exec_cmd("$HOME/.config/hypr/UserScripts/ZshChangeTheme.sh"))
bind("ALT", "SHIFT_L", exec_cmd("$HOME/.config/hypr/scripts/SwitchKeyboardLayout.sh"), { locked = true })
bind("SUPER ALT", "C", exec_cmd("$HOME/.config/hypr/UserScripts/RofiCalc.sh"))
bind("", "xf86KbdBrightnessDown", exec_cmd("$HOME/.config/hypr/scripts/BrightnessKbd.sh --dec"), { ["repeat"] = true })
bind("", "xf86KbdBrightnessUp", exec_cmd("$HOME/.config/hypr/scripts/BrightnessKbd.sh --inc"), { ["repeat"] = true })
bind("", "xf86Launch1", exec_cmd("rog-control-center"))
bind("", "xf86Launch3", exec_cmd("asusctl led-mode -n"))
bind("", "xf86Launch4", exec_cmd("asusctl profile -n"))
bind("", "xf86MonBrightnessDown", exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --dec"), { ["repeat"] = true })
bind("", "xf86MonBrightnessUp", exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"), { ["repeat"] = true })
bind("", "xf86TouchpadToggle", exec_cmd("$HOME/.config/hypr/scripts/TouchPad.sh"))
bind("SUPER", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --now"))
bind("SUPER SHIFT", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --area"))
bind("SUPER CTRL", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in5"))
bind("SUPER ALT", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in10"))
bind("ALT", "F6", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --active"))

-- Personal overrides loaded after system and user keybinds.
for _, combo in ipairs({
  { "SUPER", "E" },
  { "SUPER", "H" },
  { "SUPER", "I" },
  { "SUPER", "Y" },
  { "SUPER", "h" },
  { "SUPER", "j" },
  { "SUPER", "k" },
  { "SUPER", "l" },
  { "SUPER", "T" },
  { "SUPER CTRL", "h" },
  { "SUPER CTRL", "j" },
  { "SUPER CTRL", "k" },
  { "SUPER CTRL", "l" },
  { "SUPER CTRL", "space" },
  { "SUPER SHIFT", "h" },
  { "SUPER SHIFT", "j" },
  { "SUPER SHIFT", "k" },
  { "SUPER SHIFT", "l" },
  { "SUPER SHIFT", "H" },
  { "SUPER SHIFT", "Return" },
  { "SUPER SHIFT", "O" },
  { "ALT", "E" },
}) do
  unbind(combo[1], combo[2])
end

bind("SUPER SHIFT", "h", dispatch("resizeactive", "-50 0"), { ["repeat"] = true })
bind("SUPER SHIFT", "l", dispatch("resizeactive", "50 0"), { ["repeat"] = true })
bind("SUPER SHIFT", "k", dispatch("resizeactive", "0 -50"), { ["repeat"] = true })
bind("SUPER SHIFT", "j", dispatch("resizeactive", "0 50"), { ["repeat"] = true })

bind("SUPER CTRL", "h", dispatch("movewindow", "l"))
bind("SUPER CTRL", "l", dispatch("movewindow", "r"))
bind("SUPER CTRL", "k", dispatch("movewindow", "u"))
bind("SUPER CTRL", "j", dispatch("movewindow", "d"))

bind("SUPER", "h", dispatch("movefocus", "l"))
bind("SUPER", "l", dispatch("movefocus", "r"))
bind("SUPER", "k", dispatch("movefocus", "u"))
bind("SUPER", "j", dispatch("movefocus", "d"))

bind("SUPER", "T", exec_cmd("$files"))
bind("SUPER SHIFT", "H", exec_cmd("$HOME/.config/hypr/scripts/KeyHints.sh"))
bind("SUPER SHIFT", "Return", exec_cmd("$HOME/.config/hypr/scripts/Dropterminal.sh kitty"))
bind("SUPER CTRL", "space", exec_cmd("fcitx5-remote -t"))
bind("ALT", "E", exec_cmd("pkill fcitx5 -9; sleep 1; fcitx5 -d --replace; sleep 1; fcitx5-remote -r"))
bind("SUPER", "I", exec_cmd("hints"))
bind("SUPER", "Y", exec_cmd("hints --mode scroll"))
bind("SUPER SHIFT", "O", exec_cmd("hyprctl setprop active opaque toggle"))
