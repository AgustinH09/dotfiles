-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- System defaults migrated from configs/WindowRules.conf (auto-generated).
-- Add additional rules with apply_window_rule({...}).
-- Example:
-- apply_window_rule({
--   name = "My System Rule",
--   match = { class = "^pavucontrol$" },
--   float = true,
-- })

local function apply_window_rule(rule)
  if hl.window_rule then
    hl.window_rule(rule)
  end
end

-- No active window rules were found in configs/WindowRules.conf.
