-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- System defaults migrated from configs/Startup_Apps.conf (auto-generated).
-- Add commands with exec_once("your command")
-- Example:
-- exec_once("swaync")

local session = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or "default"

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function exec_once(cmd)
  local key = cmd:gsub("[^%w_.-]", "_"):sub(1, 80)
  local marker = "/tmp/hypr-lua-system-exec-once-" .. session .. "-" .. key
  local log = "/tmp/hypr-lua-system-startup-" .. key .. ".log"
  local readiness = "runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}; export XDG_RUNTIME_DIR=\"$runtime\"; for _ in $(seq 1 60); do if [ -n \"$WAYLAND_DISPLAY\" ] && [ -S \"$runtime/$WAYLAND_DISPLAY\" ]; then break; fi; for sock in \"$runtime\"/wayland-[0-9]*; do [ -S \"$sock\" ] || continue; case \"$(basename \"$sock\")\" in *awww*) continue ;; esac; export WAYLAND_DISPLAY=\"$(basename \"$sock\")\"; break; done; sleep 0.1; done; if [ -n \"$HYPRLAND_INSTANCE_SIGNATURE\" ]; then for hypr_sock in \"$runtime/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock\" \"$runtime/hypr/.socket.sock\"; do [ -S \"$hypr_sock\" ] && break; done; sleep 0.1; fi"
  local inner = readiness .. "; " .. cmd
  local script = "[ -e " .. shell_quote(marker) .. " ] || { touch " .. shell_quote(marker) .. " && sh -lc " .. shell_quote(inner) .. " >>" .. shell_quote(log) .. " 2>&1 & }"
  os.execute("sh -lc " .. shell_quote(script))
end

-- No active startup entries were found in configs/Startup_Apps.conf.
