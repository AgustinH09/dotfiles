-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- System defaults migrated from configs/Keybinds.conf (auto-generated).
-- Add keybinds with bind("MODS", "KEY", fn, opts).
-- Example:
-- bind("SUPER", "Z", exec_cmd("thunar"), { description = "Open file manager" })

local dsp = hl.dsp or hl
local group_api = (dsp and dsp.group) or {}
local workspace_api = (dsp and dsp.workspace) or {}
local function resolve_cmd(cmd)
  local defaults = rawget(_G, "KOOLDOTS_DEFAULTS") or {}
  local resolved_term = defaults.term or os.getenv("TERMINAL") or "kitty"
  local resolved_files = defaults.files or "thunar"
  local resolved_edit = defaults.edit or os.getenv("EDITOR") or "nano"
  local resolved_visual = defaults.visual or os.getenv("VISUAL") or ""
  cmd = tostring(cmd)
  cmd = cmd:gsub("%$term", resolved_term)
  cmd = cmd:gsub("%$files", resolved_files)
  cmd = cmd:gsub("%$edit", resolved_edit)
  cmd = cmd:gsub("%$visual", resolved_visual)
  return cmd
end

local function exec_cmd(cmd)
  local resolved = resolve_cmd(cmd)
  if dsp and dsp.exec_cmd then
    return dsp.exec_cmd(resolved)
  end
  return function() hl.exec_cmd(resolved) end
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function raw_dispatch_cmd(command)
  if dsp and dsp.exec_raw then
    return dsp.exec_raw(tostring(command))
  end
  local expression = "hl.dsp.exec_raw(" .. string.format("%q", tostring(command)) .. ")"
  return exec_cmd("hyprctl dispatch " .. shell_quote(expression))
end

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalize_mods(mods)
  mods = trim(mods)
  if mods == "" then
    return ""
  end
  local known = {
    super = "SUPER",
    super_l = "SUPER_L",
    super_r = "SUPER_R",
    shift = "SHIFT",
    shift_l = "SHIFT_L",
    shift_r = "SHIFT_R",
    ctrl = "CTRL",
    control = "CTRL",
    ctrl_l = "CTRL_L",
    ctrl_r = "CTRL_R",
    control_l = "CTRL_L",
    control_r = "CTRL_R",
    alt = "ALT",
    alt_l = "ALT_L",
    alt_r = "ALT_R",
    meta = "META",
    meta_l = "META_L",
    meta_r = "META_R",
    mod2 = "MOD2",
    mod3 = "MOD3",
    mod5 = "MOD5",
  }
  local parts = {}
  for token in mods:gmatch("%S+") do
    parts[#parts + 1] = known[token:lower()] or token
  end
  return table.concat(parts, " ")
end

local function chord(mods, key)
  mods = normalize_mods(mods):gsub("%s+", " + ")
  key = trim(key)
  if mods == "" then
    return key
  end
  return mods .. " + " .. key
end

local function key_variants(key, mods)
  key = trim(key):gsub("^xf86", "XF86")
  local key_aliases = {
    XF86AudioPlayPause = "XF86AudioPlay",
    XF86audiolowervolume = "XF86AudioLowerVolume",
    XF86audiomute = "XF86AudioMute",
    XF86audioraisevolume = "XF86AudioRaiseVolume",
    XF86audiostop = "XF86AudioStop",
  }
  key = key_aliases[key] or key
  local shifted_number_keys = {
    ["code:10"] = "exclam",
    ["code:11"] = "at",
    ["code:12"] = "numbersign",
    ["code:13"] = "dollar",
    ["code:14"] = "percent",
    ["code:15"] = "asciicircum",
    ["code:16"] = "ampersand",
    ["code:17"] = "asterisk",
    ["code:18"] = "parenleft",
    ["code:19"] = "parenright",
  }
  local number_keys = {
    ["code:10"] = "1",
    ["code:11"] = "2",
    ["code:12"] = "3",
    ["code:13"] = "4",
    ["code:14"] = "5",
    ["code:15"] = "6",
    ["code:16"] = "7",
    ["code:17"] = "8",
    ["code:18"] = "9",
    ["code:19"] = "0",
  }
  if mods:upper():match("SHIFT") and shifted_number_keys[key] then
    local number_key = number_keys[key]
    if number_key then
      return { shifted_number_keys[key], number_key }
    end
    return { shifted_number_keys[key] }
  end
  if number_keys[key] then
    return { number_keys[key] }
  end
  return { key }
end

local function workspace_value(value)
  value = trim(value)
  return tonumber(value) or value
end

local function direction(value)
  local directions = {
    l = "left",
    r = "right",
    u = "up",
    d = "down",
    left = "left",
    right = "right",
    up = "up",
    down = "down",
  }
  return directions[trim(value)] or trim(value)
end

local function dispatch(name, args)
  local window_api = (dsp and dsp.window) or hl.window or {}
  name = trim(name)
  args = trim(args)
  if name == "exec" then
    return exec_cmd(args)
  end
  if name == "killactive" and window_api.close then
    return window_api.close()
  end
  if name == "fullscreen" and window_api.fullscreen then
    if args == "1" then
      return window_api.fullscreen({ mode = "maximized" })
    end
    return window_api.fullscreen({ mode = "fullscreen" })
  end
  if name == "movefocus" and dsp and dsp.focus then
    return function()
      local ok, dispatcher = pcall(dsp.focus, { direction = direction(args) })
      if ok and dispatcher then
        hl.dispatch(dispatcher)
      end
    end
  end
  if name == "cyclenext" then
    if args == "prev" or args == "b" then
      return exec_cmd("${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/LuaCycleWindow.sh previous")
    end
    return exec_cmd("${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/LuaCycleWindow.sh next")
  end
  if name == "swapwindow" then
    local swap_direction = trim(args)
    if swap_direction == "" then
      return nil
    end
    return exec_cmd("${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/LuaSwapWindow.sh " .. swap_direction)
  end
  if name == "workspace" and dsp and dsp.focus then
    return function() hl.dispatch(dsp.focus({ workspace = workspace_value(args) })) end
  end
  if name == "movetoworkspace" and window_api.move then
    return function() hl.dispatch(window_api.move({ workspace = workspace_value(args) })) end
  end
  if name == "movetoworkspacesilent" and window_api.move then
    return function() hl.dispatch(window_api.move({ workspace = workspace_value(args), follow = false })) end
  end
  if name == "togglefloating" and window_api.float then
    return function() hl.dispatch(window_api.float({ action = "toggle" })) end
  end
  if name == "pseudo" and window_api.pseudo then
    return function() hl.dispatch(window_api.pseudo()) end
  end
  if (name == "layoutmsg" or name == "layout") and dsp and dsp.layout then
    return function() hl.dispatch(dsp.layout(args)) end
  end
  if name == "togglegroup" and group_api.toggle then
    return function() hl.dispatch(group_api.toggle()) end
  end
  if name == "changegroupactive" and group_api.next and group_api.prev then
    if args == "b" or args == "prev" or args == "-1" then
      return function() hl.dispatch(group_api.prev()) end
    end
    return function() hl.dispatch(group_api.next()) end
  end
  if name == "togglespecialworkspace" and workspace_api.toggle_special then
    return function()
      if args ~= "" then
        hl.dispatch(workspace_api.toggle_special({ name = args }))
      else
        hl.dispatch(workspace_api.toggle_special())
      end
    end
  end
  if name == "bringactivetotop" and window_api.bring_to_top then
    return function() hl.dispatch(window_api.bring_to_top()) end
  end
  if name == "resizewindow" and window_api.resize then
    return window_api.resize()
  end
  if name == "resizeactive" and window_api.resize then
    local x, y = args:match("^(%-?%d+)%s+(%-?%d+)$")
    if x and y then
      return window_api.resize({ x = tonumber(x) or 0, y = tonumber(y) or 0, relative = true })
    end
  end
  if name == "movewindow" and args == "" and window_api.drag then
    return window_api.drag()
  end
  if args ~= "" then
    return raw_dispatch_cmd(name .. " " .. args)
  end
  return raw_dispatch_cmd(name)
end

local function bind(mods, key, fn, opts)
  local seen = {}
  for _, key_variant in ipairs(key_variants(key, mods)) do
    local key_chord = chord(mods, key_variant)
    if not seen[key_chord] then
      seen[key_chord] = true
      if opts then
        hl.bind(key_chord, fn, opts)
      else
        hl.bind(key_chord, fn)
      end
    end
  end
end

local function unbind(mods, key)
  if hl.unbind then
    local seen = {}
    for _, key_variant in ipairs(key_variants(key, mods)) do
      local key_chord = chord(mods, key_variant)
      if not seen[key_chord] then
        seen[key_chord] = true
        local ok = pcall(hl.unbind, mods, key_variant)
        if not ok then
          pcall(hl.unbind, key_chord)
        end
      end
    end
  end
end

-- Converted from configs/Keybinds.conf
bind("CTRL ALT", "Delete", function() hl.dispatch(hl.dsp.exit()) end)
bind("SUPER", "Q", dispatch("killactive", ""))
bind("SUPER SHIFT", "Q", exec_cmd("$HOME/.config/hypr/scripts/KillActiveProcess.sh"))
bind("CTRL ALT", "L", exec_cmd("$HOME/.config/hypr/scripts/LockScreen.sh"))
bind("CTRL ALT", "P", exec_cmd("$HOME/.config/hypr/scripts/Wlogout.sh"))
bind("SUPER SHIFT", "N", exec_cmd("swaync-client -t -sw"))
bind("SUPER SHIFT", "E", exec_cmd("$HOME/.config/hypr/scripts/Kool_Quick_Settings.sh"))
bind("SUPER CTRL", "D", dispatch("layoutmsg", "removemaster"))
bind("SUPER", "I", dispatch("layoutmsg", "addmaster"))
bind("SUPER", "J", dispatch("layoutmsg", "cyclenext"))
bind("SUPER", "K", dispatch("layoutmsg", "cycleprev"))
bind("SUPER CTRL", "Return", dispatch("layoutmsg", "swapwithmaster"))
bind("SUPER SHIFT", "I", dispatch("layoutmsg", "togglesplit"))
bind("SUPER", "P", dispatch("pseudo", ""))
bind("SUPER", "M", dispatch("layoutmsg", "splitratio 0.3"))
bind("SUPER", "G", dispatch("togglegroup", ""))
bind("SUPER CTRL", "tab", dispatch("changegroupactive", ""))
bind("ALT", "tab", dispatch("cyclenext", ""))
bind("ALT", "tab", dispatch("bringactivetotop", ""))
bind("", "xf86audioraisevolume", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --inc"), { locked = true, ["repeat"] = true })
bind("", "xf86audiolowervolume", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --dec"), { locked = true, ["repeat"] = true })
bind("", "xf86AudioMicMute", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle-mic"), { locked = true })
bind("", "xf86audiomute", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle"), { locked = true })
bind("", "xf86Sleep", exec_cmd("systemctl suspend"), { locked = true })
bind("", "xf86Rfkill", exec_cmd("$HOME/.config/hypr/scripts/AirplaneMode.sh"), { locked = true })
bind("", "xf86AudioPlayPause", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
bind("", "xf86AudioPause", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
bind("", "xf86AudioPlay", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"), { locked = true })
bind("", "xf86AudioNext", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --nxt"), { locked = true })
bind("", "xf86AudioPrev", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --prv"), { locked = true })
bind("", "xf86audiostop", exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --stop"), { locked = true })
bind("SUPER", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --now"))
bind("SUPER SHIFT", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --area"))
bind("SUPER CTRL", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in5"))
bind("SUPER CTRL SHIFT", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in10"))
bind("ALT", "Print", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --active"))
bind("SUPER SHIFT", "S", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --swappy"))
bind("SUPER SHIFT", "left", dispatch("resizeactive", "-50 0"), { ["repeat"] = true })
bind("SUPER SHIFT", "right", dispatch("resizeactive", "50 0"), { ["repeat"] = true })
bind("SUPER SHIFT", "up", dispatch("resizeactive", "0 -50"), { ["repeat"] = true })
bind("SUPER SHIFT", "down", dispatch("resizeactive", "0 50"), { ["repeat"] = true })
bind("SUPER CTRL", "left", dispatch("movewindow", "l"))
bind("SUPER CTRL", "right", dispatch("movewindow", "r"))
bind("SUPER CTRL", "up", dispatch("movewindow", "u"))
bind("SUPER CTRL", "down", dispatch("movewindow", "d"))
bind("SUPER ALT", "left", dispatch("swapwindow", "l"))
bind("SUPER ALT", "right", dispatch("swapwindow", "r"))
bind("SUPER ALT", "up", dispatch("swapwindow", "u"))
bind("SUPER ALT", "down", dispatch("swapwindow", "d"))
bind("SUPER", "left", dispatch("movefocus", "l"))
bind("SUPER", "right", dispatch("movefocus", "r"))
bind("SUPER", "up", dispatch("movefocus", "u"))
bind("SUPER", "down", dispatch("movefocus", "d"))
bind("SUPER", "tab", dispatch("workspace", "m+1"))
bind("SUPER SHIFT", "tab", dispatch("workspace", "m-1"))
bind("SUPER SHIFT", "U", dispatch("movetoworkspace", "special"))
bind("SUPER", "U", dispatch("togglespecialworkspace", ""))
bind("SUPER", "code:10", dispatch("workspace", "1"))
bind("SUPER", "code:11", dispatch("workspace", "2"))
bind("SUPER", "code:12", dispatch("workspace", "3"))
bind("SUPER", "code:13", dispatch("workspace", "4"))
bind("SUPER", "code:14", dispatch("workspace", "5"))
bind("SUPER", "code:15", dispatch("workspace", "6"))
bind("SUPER", "code:16", dispatch("workspace", "7"))
bind("SUPER", "code:17", dispatch("workspace", "8"))
bind("SUPER", "code:18", dispatch("workspace", "9"))
bind("SUPER", "code:19", dispatch("workspace", "10"))
bind("SUPER SHIFT", "code:10", dispatch("movetoworkspace", "1"))
bind("SUPER SHIFT", "code:11", dispatch("movetoworkspace", "2"))
bind("SUPER SHIFT", "code:12", dispatch("movetoworkspace", "3"))
bind("SUPER SHIFT", "code:13", dispatch("movetoworkspace", "4"))
bind("SUPER SHIFT", "code:14", dispatch("movetoworkspace", "5"))
bind("SUPER SHIFT", "code:15", dispatch("movetoworkspace", "6"))
bind("SUPER SHIFT", "code:16", dispatch("movetoworkspace", "7"))
bind("SUPER SHIFT", "code:17", dispatch("movetoworkspace", "8"))
bind("SUPER SHIFT", "code:18", dispatch("movetoworkspace", "9"))
bind("SUPER SHIFT", "code:19", dispatch("movetoworkspace", "10"))
bind("SUPER SHIFT", "bracketleft", dispatch("movetoworkspace", "-1"))
bind("SUPER SHIFT", "bracketright", dispatch("movetoworkspace", "+1"))
bind("SUPER CTRL", "code:10", dispatch("movetoworkspacesilent", "1"))
bind("SUPER CTRL", "code:11", dispatch("movetoworkspacesilent", "2"))
bind("SUPER CTRL", "code:12", dispatch("movetoworkspacesilent", "3"))
bind("SUPER CTRL", "code:13", dispatch("movetoworkspacesilent", "4"))
bind("SUPER CTRL", "code:14", dispatch("movetoworkspacesilent", "5"))
bind("SUPER CTRL", "code:15", dispatch("movetoworkspacesilent", "6"))
bind("SUPER CTRL", "code:16", dispatch("movetoworkspacesilent", "7"))
bind("SUPER CTRL", "code:17", dispatch("movetoworkspacesilent", "8"))
bind("SUPER CTRL", "code:18", dispatch("movetoworkspacesilent", "9"))
bind("SUPER CTRL", "code:19", dispatch("movetoworkspacesilent", "10"))
bind("SUPER CTRL", "bracketleft", dispatch("movetoworkspacesilent", "-1"))
bind("SUPER CTRL", "bracketright", dispatch("movetoworkspacesilent", "+1"))
bind("SUPER", "mouse_down", dispatch("workspace", "e+1"))
bind("SUPER", "mouse_up", dispatch("workspace", "e-1"))
bind("SUPER", "period", dispatch("workspace", "e+1"))
bind("SUPER", "comma", dispatch("workspace", "e-1"))
bind("SUPER", "mouse:272", dispatch("movewindow", ""))
bind("SUPER", "mouse:273", dispatch("resizewindow", ""))
