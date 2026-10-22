-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- System defaults migrated from configs/LayerRules.conf (auto-generated).
-- Add additional rules with apply_layer_rule({...}).
-- Example:
-- apply_layer_rule({
--   name = "My Layer Rule",
--   match = { namespace = "rofi" },
--   blur = true,
-- })

local function apply_layer_rule(rule)
  if hl.layer_rule then
    hl.layer_rule(rule)
  end
end

-- No active layer rules were found in configs/LayerRules.conf.
