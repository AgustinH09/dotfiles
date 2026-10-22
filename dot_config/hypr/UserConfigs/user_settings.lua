-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User settings overrides (auto-generated).
-- This file is intentionally split from other user overrides.
-- Add only user-specific Lua overrides here.
-- Example:
-- hl.config({ general = { gaps_in = 4, gaps_out = 8 } })

-- Source reference from UserSettings.conf (hyprlang):
-- dwindle {
-- preserve_split = yes
-- special_scale_factor = 0.8
-- }
-- master {
-- new_status = master
-- new_on_top = 1
-- mfact = 0.5
-- }
-- general {
-- resize_on_border = true
-- layout = dwindle
-- }
-- input {
-- kb_layout = us
-- kb_variant =
-- kb_model =
-- kb_options =
-- kb_rules =
-- repeat_rate = 50
-- repeat_delay = 300
-- sensitivity = 0 #mouse sensitivity
-- numlock_by_default = true
-- left_handed = false
-- follow_mouse = true
-- float_switch_override_focus = false
-- touchpad {
-- disable_while_typing = true
-- natural_scroll = true
-- clickfinger_behavior = false
-- middle_button_emulation = true
-- tap-to-click = true
-- drag_lock = false
-- }
-- touchdevice {
-- enabled = true
-- }
-- tablet {
-- transform = 0
-- left_handed = 0
-- }
-- }
-- gestures {
-- workspace_swipe_distance = 500
-- workspace_swipe_invert = true
-- workspace_swipe_min_speed_to_force = 30
-- workspace_swipe_cancel_ratio = 0.5
-- workspace_swipe_create_new = true
-- workspace_swipe_forever = true
-- }
-- misc {
-- disable_hyprland_logo = true
-- disable_splash_rendering = true
-- mouse_move_enables_dpms = true
-- enable_swallow = off
-- swallow_regex = ^(kitty)$
-- focus_on_activate = false
-- initial_workspace_tracking = 0
-- middle_click_paste = false
-- }
-- binds {
-- workspace_back_and_forth = true
-- allow_workspace_cycles = true
-- pass_mouse_when_bound = false
-- }
-- xwayland {
-- force_zero_scaling = true
-- }
-- cursor {
-- no_hardware_cursors = 2 # change to 1 if want to disable
-- enable_hyprcursor = true
-- warp_on_change_workspace = true
-- no_warps = true
-- }

hl.config({
  dwindle = {
    preserve_split = true,
    special_scale_factor = 0.8,
  },
  master = {
    new_status = "master",
    new_on_top = true,
    mfact = 0.5,
  },
  general = {
    resize_on_border = true,
    layout = "dwindle",
    border_size = 2,
    gaps_in = 6,
    gaps_out = 8,
  },
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:escape_shifted_capslock",
    kb_rules = "",
    repeat_rate = 50,
    repeat_delay = 300,
    sensitivity = 0,
    numlock_by_default = true,
    left_handed = false,
    follow_mouse = 1,
    float_switch_override_focus = false,
    touchpad = {
      disable_while_typing = true,
      natural_scroll = false,
      clickfinger_behavior = true,
      middle_button_emulation = true,
      tap_to_click = true,
      drag_lock = false,
    },
    touchdevice = {
      enabled = true,
    },
    tablet = {
      transform = 0,
      left_handed = 0,
      output = "eDP-1",
    },
  },
  gestures = {
    workspace_swipe_distance = 500,
    workspace_swipe_invert = true,
    workspace_swipe_min_speed_to_force = 30,
    workspace_swipe_cancel_ratio = 0.5,
    workspace_swipe_create_new = true,
    workspace_swipe_forever = true,
  },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_enables_dpms = true,
    enable_swallow = false,
    swallow_regex = "^(kitty)$",
    focus_on_activate = false,
    initial_workspace_tracking = 0,
    middle_click_paste = false,
  },
  binds = {
    workspace_back_and_forth = true,
    allow_workspace_cycles = true,
    pass_mouse_when_bound = false,
  },
  xwayland = {
    force_zero_scaling = true,
  },
  cursor = {
    no_hardware_cursors = 2,
    enable_hyprcursor = true,
    warp_on_change_workspace = 1,
    no_warps = true,
    min_refresh_rate = 60,
  },
  opengl = {
    nvidia_anti_flicker = true,
  },
})
